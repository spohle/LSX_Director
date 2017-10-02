//
//  ViewController.swift
//  LSX_Director
//
//  Created by ATVI_MOCAP on 9/26/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

enum ScrollDirection {
    case none
    case up
    case down
}

class ViewController: UIViewController {
    
    var projects = [Int:Project]()
    let thumbCache = NSCache<NSString, UIImage>()
    let dataBaseModel = DataBaseProjectsModel()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var lastContentOffset = CGFloat(0)
    var scrollDirection = ScrollDirection.none
    
    @IBOutlet weak var uiProjectsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiProjectsTable.dataSource = self
        uiProjectsTable.delegate = self
        uiProjectsTable.backgroundColor = UIColor.darkGray
        
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        view.addSubview(indicator)
        
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
        indicator.stopAnimating()
        self.projects = projects
        self.uiProjectsTable.reloadData()
    }
}

// MARK: TableView Delegate methods
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var offset = CGFloat(0)
        if self.scrollDirection == ScrollDirection.down {
            offset = 50
        } else if self.scrollDirection == ScrollDirection.up {
            offset = -50
        }
        
        let transform = CATransform3DTranslate(CATransform3DIdentity, 0, offset, 0)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset
        if currentOffset.y > self.lastContentOffset {
            self.scrollDirection = ScrollDirection.down
        } else {
            self.scrollDirection = ScrollDirection.up
        }
        
        self.lastContentOffset = currentOffset.y
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
        
        if let projectName = project.name, let take = project.neutralTake {
            
            if let path = take.thumbFileName {
                let basePath = "http://lightstage.activision.com/thumb_images"
                let projectPath = "\(basePath)/\(projectName)"
                let thumbNailPath = "\(projectPath)/\(path)"
                
    
                if let cachedVersion = thumbCache.object(forKey: NSString(string: thumbNailPath)) {
                    cell.uiThumbNail.image = cachedVersion
                } else {
                    if let data = getThumbData(thumbNailPath) {
                        let image = UIImage(data: data)
                        thumbCache.setObject(image!, forKey: NSString(string: thumbNailPath))
                        cell.uiThumbNail.image = image
                    }
                }
            } else {
                // TODO: default thumbnail image
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

