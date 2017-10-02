//
//  ProjectViewController.swift
//  LSX_Director
//
//  Created by ATVI_MOCAP on 9/29/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

class ProjectViewController: UIViewController {

    var project: Project?
    var takes: [Int:Take]?
    var takeGroupsDict: [String:[Take]] = [String:[Take]]()
    var takeGroups: [String] = [String]()
    let thumbCache = NSCache<NSString, UIImage>()
    
    var storedOffsets = [Int: CGFloat]()

    @IBOutlet weak var uiTakesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTakesTable.dataSource = self
        
        let takesModel = DataBaseTakesModel()
        takesModel.delegate = self
        if let project = project{
            takesModel.getTakesForProjectID(project.id!)
        }
    }
    
    @IBAction func uiReturnButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProjectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.takeGroupsDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TakeGroupCell", for: indexPath) as! TakeGroupCell
    
        let groupName = self.takeGroups[indexPath.row]
        
        print (indexPath.row, groupName)
        if let takes = self.takeGroupsDict[groupName] {
            cell.takes = takes
            cell.setCollectionViewData(withDataSource: self, withDelegate: self, forRow: indexPath.row)
        }
        
        return cell
    }
}

extension ProjectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let groupName = self.takeGroups[collectionView.tag]
        if let takes = self.takeGroupsDict[groupName] {
            return takes.count
        } else {
            return 0
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TakeCell", for: indexPath) as! TakeCell
        
        let groupName = self.takeGroups[collectionView.tag]
        if let takes = self.takeGroupsDict[groupName] {
            let sortedTakes = sortTakes(takes)
            let take = sortedTakes[indexPath.item]
            cell.uiTakeName.text = take.name!
            
            // http://lightstage.activision.com/thumb_images/2017_09_29_J_BERTI/237571/Shot_0696/2017_09_29_J_BERTI_Shot_0696_DX08_256.jpg
            let basePath = "http://lightstage.activision.com/thumb_images"
            let projectPath = "\(basePath)/\(project!.name!)"
            let takePath = "\(projectPath)/\(take.id!)"
            let canonShot = String(format: "Shot_%04d", Int(take.canonShot!)!)
            let thumbNailPath = "\(takePath)/\(canonShot)/\(project!.name!)_\(canonShot)_DX08_full.jpg"

            if let cachedVersion = thumbCache.object(forKey: NSString(string: thumbNailPath)) {
                cell.uiTakeThumbNail.image = cachedVersion
            } else {
                if let data = getThumbData(thumbNailPath) {
                    let image = UIImage(data: data)
                    thumbCache.setObject(image!, forKey: NSString(string: thumbNailPath))
                    cell.uiTakeThumbNail.image = image
                }
            }
        }
        
        return cell
    }
    
    func sortTakes(_ takes: [Take]) -> [Take] {
        var output:[Take] = [Take]()
        var takeIds = [Int:Take]()
        for take in takes {
            takeIds[take.id!] = take
        }
        
        for key in takeIds.keys.sorted() {
            output.append(takeIds[key]!)
        }
        
        return output
    }
}

extension ProjectViewController: UICollectionViewDelegate {
    
}

extension ProjectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let takesGroupCell = cell as? TakeGroupCell else { return }
        
        takesGroupCell.collectionViewOffset = self.storedOffsets[indexPath.row] ?? 0
        
        let groupName = self.takeGroups[indexPath.row]
        if let takes = self.takeGroupsDict[groupName] {
            takesGroupCell.takes = takes
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let takesGroupCell = cell as? TakeGroupCell else { return }
        storedOffsets[indexPath.row] = takesGroupCell.collectionViewOffset
    }
}

extension ProjectViewController: DataBaseTakesProtocol {
    func takesInfoRetrieved(takes: [Int:Take]) {
        self.takes = takes
        groupTakes(takes)
        self.uiTakesTable.reloadData()
    }
    
    /**
         Takes a dict of takes and splits them into their groupings
         @param takes the dictionary with the takes in
    */
    func groupTakes(_ takes: [Int:Take]) {
        var groups = [String:[Take]]()
        
        for takeId in takes.keys.sorted() {
            if let take = takes[takeId] {
                if let name = take.name {
                    // EXAMPLE : Upper_Lid_Raise-1
                    let index = name.index(name.endIndex, offsetBy: -2)
                    
                    let character = name[index]
                    if character == "-" {
                        let groupName = String(name[name.startIndex...name.index(name.endIndex, offsetBy: -3)])
                        if groups[groupName] != nil {
                            groups[groupName]!.append(take)
                        } else {
                            groups[groupName] = [take]
                            self.takeGroups.append(groupName)
                        }
                    }
                }
            }
        }
        
        self.takeGroupsDict = groups
    }
}













