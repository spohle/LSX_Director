//
//  ViewController.swift
//  LSX_Director
//
//  Created by ATVI_MOCAP on 9/26/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var projects = [Int:Project]()
    let thumbCache = NSCache<NSString, UIImage>()
    let dataBaseModel = DataBaseProjectsModel()
    
    @IBOutlet weak var uiProjectsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiProjectsTable.dataSource = self
        uiProjectsTable.delegate = self
        uiProjectsTable.backgroundColor = UIColor.darkGray
        
        dataBaseModel.delegate = self
        dataBaseModel.getProjects()
    }
    
    @IBAction func uiReloadPressed(_ sender: Any) {
        projects = [Int:Project]()
        uiProjectsTable.reloadData()
        dataBaseModel.getProjects()
    }
}

extension ViewController: DataBaseProjectsModelProtocol {
    func projectsInfoRetrieved(projects: [Int : Project]) {
        self.projects = projects
        self.uiProjectsTable.reloadData()
    }
}

// MARK: TableView Delegate methods
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let transform = CATransform3DTranslate(CATransform3DIdentity, 50, 0, 0)
        cell.layer.transform = transform
        
        UIView.animate(withDuration: 1.0) {
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = uiProjectsTable.indexPathForSelectedRow {
            let navigationController = segue.destination
            let viewControllers = navigationController.childViewControllers
            if let controller = viewControllers.first as? ProjectViewController {
                let key = self.projects.keys.sorted().reversed()[selectedIndexPath.row]
                if let project = self.projects[key] {
                    controller.navigationController?.navigationBar.topItem?.title = project.name
                    controller.project = project
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectTableCell
        cell.configure()
        
        let key = self.projects.keys.sorted().reversed()[indexPath.row]
        if let project = self.projects[key] {
            cell.uiProjectName.text = "\([project.id ?? -1]) \(project.name ?? "")"
            if let name = project.name {
                cell.uiProjectName.text = name
            }
            if let studio = project.studio {
                cell.uiStudioName.text = studio.uppercased()
            }
   
            setThumbNail(project, cell)
        }
        
        return cell
    }
    
    fileprivate func setThumbNail(_ project: Project, _ cell: ProjectTableCell) {
        // http://lightstage.activision.com/thumb_images/2017_09_20_C_OLSON/236661/Shot_2260/2017_09_20_C_OLSON_Shot_2260_DX08_256.jpg
        
        if let projectName = project.name,
            let take = project.neutralTake,
            let canon = take.canonShot,
            let takeId = take.id {
            
            let basePath = "http://lightstage.activision.com/thumb_images"
            let projectPath = "\(basePath)/\(projectName)"
            let takePath = "\(projectPath)/\(takeId)"
            let canonShot = String(format: "Shot_%04d", Int(canon)!)
            let thumbNailPath = "\(takePath)/\(canonShot)/\(projectName)_\(canonShot)_DX08_256.jpg"
            
            
            if let cachedVersion = thumbCache.object(forKey: NSString(string: thumbNailPath)) {
                cell.uiThumbNail.image = cachedVersion
            } else {
                if let data = getThumbData(thumbNailPath) {
                    let image = UIImage(data: data)
                    thumbCache.setObject(image!, forKey: NSString(string: thumbNailPath))
                    cell.uiThumbNail.image = image
                }
            }
        }
    }
    
    func getThumbData(_ path:String) -> Data? {
        let thumbUrl = URL(string: path)
        do {
            let data = try Data(contentsOf: thumbUrl!)
            return data
        } catch {
            return nil
        }
    }
    
    
}

