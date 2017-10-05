//
//  ImageViewController.swift
//  LSX_Director
//
//  Created by Sven Pohle on 10/5/17.
//  Copyright © 2017 ATVI_MOCAP. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var thumbNailPaths:[String]?
    var takeNames:[String]?
    var takeIndex:Int = 0
    var image:UIImage?
    var takeName:String = "No Name"
    
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
    
    let uiButtonPrev:UIButton = {
        let w = UIButton()
        
        let image = UIImage(named: "prev")
        w.setImage(image, for: .normal)
        
        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    let uiButtonNext:UIButton = {
        let w = UIButton()
        
        let image = UIImage(named: "next")
        w.setImage(image, for: .normal)
        
        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    let uiNameFxView:UIVisualEffectView = {
        let w = UIVisualEffectView()
        w.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        w.alpha = 0.7
        
        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    let uiNameLabel:UILabel = {
        let w = UILabel()
        
        w.text = "Hello Sven"
        w.textAlignment = NSTextAlignment.center
        w.textColor = UIColor.darkGray
        
        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        if let paths = thumbNailPaths {
            let path = paths[takeIndex]
            if let data = getThumbData(path) {
                self.image = UIImage(data: data)
            }
        } else {
            dismissView()
        }
        
        if let takeNames = takeNames {
            takeName = takeNames[takeIndex]
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
        
        view.addSubview(uiNameFxView)
        uiNameFxView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uiNameFxView.bottomAnchor.constraint(equalTo: uiImageView.bottomAnchor, constant: 0).isActive = true
        uiNameFxView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: scalefactor*0.89).isActive = true
        uiNameFxView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(uiNameLabel)
        uiNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uiNameLabel.bottomAnchor.constraint(equalTo: uiImageView.bottomAnchor).isActive = true
        uiNameLabel.widthAnchor.constraint(equalTo: uiNameFxView.widthAnchor, multiplier: 1.0).isActive = true
        uiNameLabel.heightAnchor.constraint(equalTo: uiNameFxView.heightAnchor, multiplier: 1.0).isActive = true
        uiNameLabel.text = takeName
        
        view.addSubview(uiButtonPrev)
        uiButtonPrev.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        uiButtonPrev.rightAnchor.constraint(equalTo: uiImageView.leftAnchor, constant: 25).isActive = true
        uiButtonPrev.heightAnchor.constraint(equalToConstant: 150).isActive = true
        uiButtonPrev.widthAnchor.constraint(equalToConstant: 37).isActive = true
        uiButtonPrev.addTarget(self, action: #selector(getImagePrev), for: .touchUpInside)
        
        view.addSubview(uiButtonNext)
        uiButtonNext.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        uiButtonNext.leftAnchor.constraint(equalTo: uiImageView.rightAnchor, constant: -25).isActive = true
        uiButtonNext.heightAnchor.constraint(equalToConstant: 150).isActive = true
        uiButtonNext.widthAnchor.constraint(equalToConstant: 37).isActive = true
        uiButtonNext.addTarget(self, action: #selector(getImageNext), for: .touchUpInside)
        
        view.addSubview(uiDismissButton)
        uiDismissButton.topAnchor.constraint(equalTo: uiImageView.topAnchor, constant: -35).isActive = true
        uiDismissButton.rightAnchor.constraint(equalTo: uiImageView.rightAnchor, constant: -10).isActive = true
        uiDismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        uiDismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        uiDismissButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        uiSetupButtons()
    }
    
    func uiSetupButtons() {
        if takeIndex >= (thumbNailPaths?.count)!-1 {
            uiButtonNext.alpha = 0.0
        } else {
            uiButtonNext.alpha = 1.0
        }
    
        if takeIndex == 0 {
            uiButtonPrev.alpha = 0.0
        } else {
            uiButtonPrev.alpha = 1.0
        }
    }
    
    func setImageForTakeIndex(_ takeIndex:Int) {
        if let paths = self.thumbNailPaths {
            let path = paths[takeIndex]
            if let data = getThumbData(path) {
                self.image = UIImage(data: data)
                uiImageView.image = self.image!
            }
        }
        
        if let takeNames = takeNames {
            uiNameLabel.text = takeNames[takeIndex]
        }
        
    }
    
    @objc func getImagePrev() {
        takeIndex -= 1
        setImageForTakeIndex(takeIndex)
        uiSetupButtons()
    }
    
    @objc func getImageNext() {
        takeIndex += 1
        setImageForTakeIndex(takeIndex)
        uiSetupButtons()
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






















