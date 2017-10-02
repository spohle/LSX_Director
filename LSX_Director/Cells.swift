//
//  TakeCell.swift
//  LSX_Director
//
//  Created by ATVI_MOCAP on 9/29/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

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
}
