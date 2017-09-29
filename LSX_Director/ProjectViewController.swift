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

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

extension ProjectViewController: DataBaseTakesProtocol {
    func takesInfoRetrieved(takes: [Int:Take]) {
        print (takes)
    }
}
