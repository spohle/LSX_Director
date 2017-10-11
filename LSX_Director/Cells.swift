//
//  TakeCell.swift
//  LSX_Director
//
//  Created by ATVI_MOCAP on 9/29/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

class ProjectTableCell: UITableViewCell {
    
    @IBOutlet weak var uiProjectName: UILabel!
    @IBOutlet weak var uiBackgroundView: UIView!
    @IBOutlet weak var uiThumbNail: UIImageView!
    @IBOutlet weak var uiStudioName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure() {
        self.contentView.backgroundColor = UIColor.darkGray
        uiBackgroundView.backgroundColor = UIColor.white
        uiBackgroundView.layer.cornerRadius = 10
        
        uiBackgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        uiBackgroundView.layer.shadowOffset = CGSize(width: 6, height: 6)
        uiBackgroundView.layer.shadowOpacity = 0.8
    }
    
}

class TakeGroupCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var takes:[Take] = [Take]()
    
    var collectionViewOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }
        set {
            collectionView.contentOffset.x = newValue
        }
    }
    
    func setCollectionViewData(withDataSource dataSource: UICollectionViewDataSource, withDelegate delegate: UICollectionViewDelegate, forRow row: Int) {
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
        collectionView.tag = row
        collectionView.reloadData()
    }
}

class TakeCell: UICollectionViewCell {
    
    @IBOutlet weak var uiTakeThumbNail: UIImageView!
    @IBOutlet weak var uiTakeName: UILabel!
    @IBOutlet weak var uiFXView: UIVisualEffectView!
    
}
