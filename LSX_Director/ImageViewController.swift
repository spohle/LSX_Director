//
//  ImageViewController.swift
//  LSX_Director
//
//  Created by Sven Pohle on 10/5/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var thumbNailPath:String?
    var image:UIImage?
    
    let uiFxView:UIVisualEffectView = {
        let w = UIVisualEffectView()
        w.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        w.alpha = 0.5

        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    let uiDismissButton:UIButton = {
        let w = UIButton()
        w.setTitle("X", for: .normal)
        let image = UIImage(named: "close")
        w.setImage(image, for: .normal)

        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    let uiImageView:UIImageView = {
        let w = UIImageView()
        w.contentMode = UIViewContentMode.scaleAspectFit
        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        if let path = thumbNailPath {
            if let data = getThumbData(path) {
                self.image = UIImage(data: data)
            }
        } else {
            dismissView()
        }
        
        setupUI()
    }

    func setupUI() {
        let scalefactor:CGFloat = 0.9
        
        view.addSubview(uiFxView)
        uiFxView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uiFxView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        uiFxView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        uiFxView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        view.addSubview(uiImageView)
        uiImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uiImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 35).isActive = true
        uiImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: scalefactor).isActive = true
        uiImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: scalefactor).isActive = true
        uiImageView.image = self.image!
        
        
        view.addSubview(uiDismissButton)
        uiDismissButton.topAnchor.constraint(equalTo: uiImageView.topAnchor, constant: -35).isActive = true
        uiDismissButton.rightAnchor.constraint(equalTo: uiImageView.rightAnchor, constant: -10).isActive = true
        uiDismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        uiDismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        uiDismissButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    @objc func dismissView() {
        dismiss(animated: false, completion: nil)
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






















