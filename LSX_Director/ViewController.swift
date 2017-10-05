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
    var effect:UIVisualEffect!
    
    @IBOutlet weak var uiProjectsTable: UITableView!
    @IBOutlet var uiPopUpView: UIView!
    @IBOutlet weak var uiVisualEffectsView: UIVisualEffectView!
    
    
    @IBAction func uiReloadPressed(_ sender: Any) {
        self.animateIn()
        dataBaseModel.getProjects()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        effect = uiVisualEffectsView.effect
        uiVisualEffectsView.effect = nil
        uiVisualEffectsView.isUserInteractionEnabled = false
        
        uiPopUpView.layer.cornerRadius = 15
        uiPopUpView.layer.masksToBounds = false
        
        uiProjectsTable.dataSource = self
        uiProjectsTable.delegate = self
        uiProjectsTable.backgroundColor = UIColor.darkGray
        
        self.animateIn()
        
        dataBaseModel.delegate = self
        dataBaseModel.getProjects()
    }
    
    func animateIn() {
        self.view.addSubview(uiPopUpView)
        uiPopUpView.center = self.view.center
        
        uiPopUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        uiPopUpView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.uiVisualEffectsView.effect = self.effect
            self.uiPopUpView.alpha = 1.0
            self.uiPopUpView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.4, animations: {
            self.uiVisualEffectsView.effect = nil
            self.uiPopUpView.alpha = 0.0
            self.uiPopUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        }) { (success) in
            self.uiPopUpView.removeFromSuperview()
        }
        
    }
}

extension ViewController: DataBaseProjectsModelProtocol {
    func projectsInfoRetrieved(projects: [Int : Project]) {
        self.projects = projects
        self.animateOut()
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
   
            if let image = getThumbImage(project) {
                cell.uiThumbNail.image = image
            } else {
//                let height = uiProjectsTable.rowHeight
//                let width = height / 1.505
//                cell.uiThumbNail.image = UIImage(color: UIColor.red, size: CGSize(width: width, height: height))
                cell.uiThumbNail.image = UIImage(named: "ctx")
            }
        }
        
        return cell
    }

    func getThumbImage(_ project: Project) -> UIImage? {
        let basePath = "http://lightstage.activision.com/thumb_images"
        
        var thumbNailPath:String?
        
        if let projectName = project.name, let take = project.neutralTake {
            if let path = take.thumbFileName {
                thumbNailPath = "\(basePath)/\(projectName)/\(path)"
                return getThumbCache(thumbNailPath!, projectName)
            } else {
                if let canonShot = take.canonShot {
                    // http://lightstage.activision.com/thumb_images/2017_09_29_J_BERTI/238851/Shot_1976/2017_09_29_J_BERTI_Shot_1976_DX08_256.jpg
                    let canon = "Shot_\(canonShot)"
                    thumbNailPath = "\(basePath)/\(projectName)/\(take)/(canon)/\(projectName)_\(canon)_DX08_256.jpg"
                    return getThumbCache(thumbNailPath!, projectName)
                } else {
                    return nil
                }
            }
        } else {
            print ("Either ProjectName or neutralTake wasn't there")
            return nil
        }
    }
    
    fileprivate func getThumbCache(_ thumbNailPath: String, _ projectName: String) -> UIImage? {
        if let cachedVersion = thumbCache.object(forKey: NSString(string: thumbNailPath)) {
            return cachedVersion
        } else {
            if let data = getThumbData(thumbNailPath) {
                let image = UIImage(data: data)
                thumbCache.setObject(image!, forKey: NSString(string: thumbNailPath))
                return image
            } else {
                print ("Project: \(projectName) getThumbData failed!")
                return nil
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

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

