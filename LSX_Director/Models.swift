//
//  Projects.swift
//  LSX_Director
//
//  Created by ATVI_MOCAP on 9/26/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

class Project: NSObject {
    
    var id: Int?
    var name: String?
    var studio: String?
    var path: String?
    var day: String?
    var neutralTake: Take?
    
    override var description: String {
        let notDefined = "Not defined"
        return "[Project] \(name ?? notDefined)[\(id ?? -1)] = Studio: \(studio ?? notDefined), Path: \(path ?? notDefined)"
    }
}

class Take: NSObject {
    var id: Int?
    var name: String?
    var customName: String?
    var lsShotName: String?
    var canonShot: String?
    var neutralFrame: Int?
    var flashFrame: Int?
    var chosen: Bool?
    var thumbFileName: String?
}

protocol DataBaseProjectsModelProtocol: class {
    func projectsInfoRetrieved(projects: [Int:Project])
}

protocol DataBaseTakesProtocol: class {
    func takesInfoRetrieved(takes: [Int:Take])
    func takeBestedStatusSet()
}

class DataBaseTakesModel: NSObject, URLSessionDataDelegate {
    weak var delegate: DataBaseTakesProtocol!
    
    var data = Data()
    var startTime:CFAbsoluteTime?
    
    func setBestedStatus(forTake takeId:Int, newStatus status:Bool) {
        startTime = CFAbsoluteTimeGetCurrent()
        let basePath = "http://lightstage.activision.com/test/ios_set_take_bested_status.php?take_id=\(takeId)"
        var value="false"
        if status == true {
            value="true"
        }
        let urlPath = "\(basePath)&value=\(value)"
        print ("calling \(urlPath)")
        let url:URL = URL(string: urlPath)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                print (error!.localizedDescription)
            } else {
                self.parseBestedReturn()
            }
        }
        
        task.resume()
    }
    
    func parseBestedReturn() {
        DispatchQueue.main.async {
            self.delegate.takeBestedStatusSet()
        }
    }
    
    func getTakesForProjectID(_ id: Int) {
        startTime = CFAbsoluteTimeGetCurrent()
        let urlPath = "http://lightstage.activision.com/test/ios_get_project_shots.php?proj_id=\(id)"
        print ("calling \(urlPath)")
        let url: URL = URL(string: urlPath)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                print (error!.localizedDescription)
            } else {
                self.parseTakes(data!)
            }
        }
        
        task.resume()
    }
    
    func parseTakes(_ data: Data) {
        var jsonResults = NSArray()
        
        if let startTime = self.startTime {
            let timeElapsed = Double(CFAbsoluteTimeGetCurrent() - startTime)
            print ("Got Takes Info in: \(timeElapsed) seconds!")
        }
        
        do {
            jsonResults = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError{
            print (error.localizedDescription)
        }
        
        var element = NSDictionary()
        var takes: [Int:Take] = [Int:Take]()
        
        for i in 0..<jsonResults.count {
            element = jsonResults[i] as! NSDictionary
            let take = Take()
            
            if let takeId = element["id"] as? String {
                take.id = Int(takeId)
            }
            if let name = element["name"] as? String {
                take.name = name
            }
            if let cName = element["custom name"] as? String {
                take.customName = cName
            }
            if let lsName = element["ls_shot_name"] as? String {
                take.lsShotName = lsName
            }
            if let canon = element["canon_shot"] as? String {
                take.canonShot = canon
            }
            if let nFrame = element["neutral_frame"] as? String {
                take.neutralFrame = Int(nFrame)
            }
            if let fFrame = element["neutral_frame"] as? String {
                take.flashFrame = Int(fFrame)
            }
            if let chosen = element["chosen"] as? String {
                if chosen == "0" {
                    take.chosen = false
                } else {
                    take.chosen = true
                }
            }
            if let path = element["filename"] as? String {
                take.thumbFileName = path
            }
            
            takes[take.id!] = take
        }
        
        DispatchQueue.main.async {
            self.delegate.takesInfoRetrieved(takes: takes)
        }
    }
    
}

class DataBaseProjectsModel: NSObject, URLSessionDataDelegate {
    weak var delegate: DataBaseProjectsModelProtocol!
    
    var data = Data()
    var startTime:CFAbsoluteTime?

    func getProjects() {
        startTime = CFAbsoluteTimeGetCurrent()
        let urlPath = "http://lightstage.activision.com/test/ios_get_projects.php"
        print ("calling \(urlPath)")
        let url: URL = URL(string: urlPath)!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                print (error!.localizedDescription)
            } else {
                self.parseProjects(data!)
            }
        }
        
        task.resume()
    }
    
    func parseProjects(_ data: Data) {
        if let startTime = self.startTime {
            let timeElapsed = Double(CFAbsoluteTimeGetCurrent() - startTime)
            print ("Got Projects Info in: \(timeElapsed) seconds!")
        }
        
        
        var jsonResults = NSArray()
        
        do {
            jsonResults = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError{
            print (error.localizedDescription)
        }
        
        
        var element = NSDictionary()
        var projects: [Int:Project] = [Int:Project]()
        
        
        for i in 0..<jsonResults.count {
            element = jsonResults[i] as! NSDictionary
            
            let project = Project()
            let neutralTake = Take()
            project.neutralTake = neutralTake
            
            if let projectId = element["project_id"] as? String {
                project.id = Int(projectId)
            }
            if let projectName = element["name"] as? String {
                project.name = projectName
            }
            if let exportPath = element["export_path"] as? String {
                project.path = exportPath
            }
            if let studio = element["studio"] as? String {
                project.studio = studio
            }
            if let takeId = element["neutral_take_id"] as? String {
                neutralTake.id = Int(takeId)
            }
            if let canonShot = element["neutral_take_canon_shot"] as? String {
                let canonString = String(format: "%04d", Int(canonShot)!)
                neutralTake.canonShot = canonString
            }
            
            projects[project.id!] = project
        }
        
        DispatchQueue.main.async {
            self.delegate.projectsInfoRetrieved(projects: projects)
        }
    }
}














