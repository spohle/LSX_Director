//
//  ProjectViewController.swift
//  LSX_Director
//
//  Created by ATVI_MOCAP on 9/29/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

class ProjectViewController: UIViewController {

    @IBOutlet weak var uiCollectionView: UICollectionView!
    var project: Project?
    var takes: [Int:Take]?
    
    let thumbCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiCollectionView.dataSource = self
        uiCollectionView.delegate = self
        
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

extension ProjectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Make sure that the number of items is worth the computing effort.
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            let dataSourceCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
            dataSourceCount > 0 else {
                return .zero
        }
        
        
        let cellCount = CGFloat(dataSourceCount)
        let itemSpacing = flowLayout.minimumInteritemSpacing
        let cellWidth = flowLayout.itemSize.width + itemSpacing
        var insets = flowLayout.sectionInset
        
        
        // Make sure to remove the last item spacing or it will
        // miscalculate the actual total width.
        let totalCellWidth = (cellWidth * cellCount) - itemSpacing
        let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
        
        
        // If the number of cells that exist take up less room than the
        // collection view width, then center the content with the appropriate insets.
        // Otherwise return the default layout inset.
        guard totalCellWidth < contentWidth else {
            return insets
        }
        
        
        // Calculate the right amount of padding to center the cells.
        let padding = (contentWidth - totalCellWidth) / 2.0
        insets.left = padding
        insets.right = padding
        return insets
    }
}

extension ProjectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let takes = self.takes {
            return takes.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "takeCell", for: indexPath) as! TakeCell
        
        if let takes = takes {
            let key = takes.keys.sorted()[indexPath.row]
            if let take = takes[key] {
                // http://lightstage.activision.com/thumb_images/2017_09_29_J_BERTI/237571/Shot_0696/2017_09_29_J_BERTI_Shot_0696_DX08_256.jpg
                let basePath = "http://lightstage.activision.com/thumb_images"
                let projectPath = "\(basePath)/\(project!.name!)"
                let takePath = "\(projectPath)/\(take.id!)"
                let canonShot = String(format: "Shot_%04d", Int(take.canonShot!)!)
                let thumbNailPath = "\(takePath)/\(canonShot)/\(project!.name!)_\(canonShot)_DX08_full.jpg"
                
                cell.uiTakeName.text = take.name
                
                if let cachedVersion = thumbCache.object(forKey: NSString(string: thumbNailPath)) {
                    cell.uiImageView.image = cachedVersion
                } else {
                    if let data = getThumbData(thumbNailPath) {
                        let image = UIImage(data: data)
                        thumbCache.setObject(image!, forKey: NSString(string: thumbNailPath))
                        cell.uiImageView.image = image
                    }
                }
            }
        }
        
        
        return cell
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

extension ProjectViewController: DataBaseTakesProtocol {
    func takesInfoRetrieved(takes: [Int:Take]) {
        self.takes = takes
        print (takes.count)
        self.uiCollectionView.reloadData()
    }
}
