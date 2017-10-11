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
    @IBOutlet var uiPopUpView: UIView!
    
    var indicator = NVActivityIndicatorView(frame: CGRect())
    let takesModel = DataBaseTakesModel()
    
    var firstTime:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.animateIn()
        
        uiTakesTable.dataSource = self
        
        takesModel.delegate = self
        if let project = project{
            takesModel.getTakesForProjectID(project.id!)
        }
    }
    
    @IBAction func uiReturnButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uiRefreshButtonPressed(_ sender: Any) {
        print ("refreshing")
        
        if let project = project{
            animateIn()
            takesModel.getTakesForProjectID(project.id!)
        }
    }
        
    func updateBestedStatus(_ takeId:Int, _ status:Bool) {
        for groupName in self.takeGroupsDict.keys {
            if takeGroupsDict[groupName] != nil {
                for take in takeGroupsDict[groupName]! {
                    if takeId == take.id {
                        take.chosen = status
                    }
                }
            }
        }        
    }
    
    func animateIn() {
        self.view.addSubview(uiPopUpView)
        uiPopUpView.center = self.view.center
        
        uiPopUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        uiPopUpView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.uiPopUpView.alpha = 1.0
            self.uiPopUpView.transform = CGAffineTransform.identity
        }
        
        var types = [NVActivityIndicatorType]()
        types.append(contentsOf: [.blank, .ballPulse, .ballGridPulse, .ballClipRotate,
                                  .squareSpin, .ballClipRotatePulse, .ballClipRotateMultiple,
                                  .ballPulseRise, .ballRotate, .cubeTransition, .ballZigZag,
                                  .ballZigZagDeflect, .ballTrianglePath, .ballScale, .lineScale,
                                  .lineScaleParty, .ballScaleMultiple, .ballPulseSync, .ballBeat,
                                  .lineScalePulseOut, .lineScalePulseOutRapid, .ballScaleRipple,
                                  .ballScaleRippleMultiple, .ballSpinFadeLoader, .lineSpinFadeLoader,
                                  .triangleSkewSpin, .pacman, .ballGridBeat, .semiCircleSpin,
                                  .ballRotateChase, .orbit, .audioEqualizer])
        
        
        let size = CGSize(width: uiPopUpView.frame.height/4, height: uiPopUpView.frame.height/4)
        let origin = CGPoint(x: uiPopUpView.frame.origin.x + (uiPopUpView.frame.size.width/2) - size.width/2.0, y: (uiPopUpView.frame.origin.y + 100))
        let frame = CGRect(origin: origin, size: size)
        indicator = NVActivityIndicatorView(frame: frame)
        
        let randomNumber = Int(arc4random_uniform(UInt32(types.count)))
        indicator.type = types[randomNumber]
        self.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.4, animations: {
            self.uiPopUpView.alpha = 0.0
            self.uiPopUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        }) { (success) in
            self.indicator.stopAnimating()
            self.uiPopUpView.removeFromSuperview()
        }
        
    }
}

extension ProjectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.takeGroupsDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TakeGroupCell", for: indexPath) as! TakeGroupCell
        
        let groupName = self.takeGroups[indexPath.row]
        
        if let takes = self.takeGroupsDict[groupName] {
            cell.takes = takes
            cell.setCollectionViewData(withDataSource: self, withDelegate: self, forRow: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(380.0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(380.0)
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TakeCell", for: indexPath) as! TakeCell
                
        let groupName = self.takeGroups[collectionView.tag]
        if let takes = self.takeGroupsDict[groupName] {
            let sortedTakes = sortTakes(takes)
            let take = sortedTakes[indexPath.item]
            cell.uiTakeName.text = take.name!
            
            
            if take.chosen! == true {
                cell.uiFXView.backgroundColor = UIColor.green.withAlphaComponent(0.5)
            } else {
                cell.uiFXView.backgroundColor = UIColor.clear
            }
            
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
    
    func getThumbData(_ path:String) -> Data? {
        let thumbUrl = URL(string: path)
        do {
            let data = try Data(contentsOf: thumbUrl!)
            return data
        } catch {
            return nil
        }
    }
    
    func sortTakes(_ takes: [Take]) -> [Take] {
        var output:[Take] = [Take]()
        var takeIds = [Int:Take]()
        for take in takes {
            takeIds[take.id!] = take
        }
        
        for key in takeIds.keys.sorted().reversed() {
            output.append(takeIds[key]!)
        }
        
        return output
    }
}


extension ProjectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupName = self.takeGroups[collectionView.tag]
        if let takes = self.takeGroupsDict[groupName] {
            let thumbNails = getTakesThumbNailPaths(takes: takes)
            var takeNames:[String] = [String]()
            var takeBested:[Bool] = [Bool]()
            var takeIds:[Int] = [Int]()
            
            for take in takes {
                takeNames.append(take.name!)
                takeBested.append(take.chosen!)
                takeIds.append(take.id!)
            }
            
            let cell = collectionView.cellForItem(at: indexPath) as! TakeCell
            
            let imageViewController = ImageViewController()
            imageViewController.projectViewController = self
            imageViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            imageViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            imageViewController.thumbNailPaths = thumbNails?.reversed()
            imageViewController.takeNames = takeNames.reversed()
            imageViewController.takeBested = takeBested.reversed()
            imageViewController.takeIds = takeIds.reversed()
            imageViewController.takeIndex = indexPath.item
            imageViewController.takeCell = cell
            present(imageViewController, animated: false, completion: nil)
        }
    }
    
    func getTakesThumbNailPaths(takes:[Take]) -> [String]? {
        var thumbNails:[String] = [String]()
        
        for take in takes {
            let basePath = "http://lightstage.activision.com/thumb_images"
            let projectPath = "\(basePath)/\(self.project!.name!)"
            let takePath = "\(projectPath)/\(take.id!)"
            let canonShot = String(format: "Shot_%04d", Int(take.canonShot!)!)
            let thumbNailPath = "\(takePath)/\(canonShot)/\(project!.name!)_\(canonShot)_DX08_full.jpg"
            thumbNails.append(thumbNailPath)
        }
        
        return thumbNails
    }
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
        
        let contentOffset = uiTakesTable.contentOffset
        
        if self.firstTime == false {
            let indexPath = IndexPath(row: 0, section: 0)
            uiTakesTable.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
        uiTakesTable.reloadData()
        uiTakesTable.layoutIfNeeded()
        
        if self.firstTime == false {
            uiTakesTable.setContentOffset(contentOffset, animated: false)
        }
        
        self.firstTime = false

        animateOut()
    }
    
    func takeBestedStatusSet() {
        // do nothing here
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













