//
//  ProjectTableCell.swift
//  LSX_Director
//
//  Created by ATVI_MOCAP on 9/26/17.
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
//        let colorValue = CGFloat( 240.0/255.0 )
//        self.contentView.backgroundColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
        self.contentView.backgroundColor = UIColor.darkGray
        uiBackgroundView.backgroundColor = UIColor.white
        uiBackgroundView.layer.cornerRadius = 10
        
        uiBackgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        uiBackgroundView.layer.shadowOffset = CGSize(width: 6, height: 6)
        uiBackgroundView.layer.shadowOpacity = 0.8
    }

}
