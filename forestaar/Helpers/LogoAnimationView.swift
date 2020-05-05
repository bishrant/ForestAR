//
//  LogoAnimationView.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 11/18/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//
import UIKit
import SwiftyGif

class LogoAnimationView: UIView {
    var logoGifImageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGif()
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func addGif() {
        do {
            let g = try UIImage(gifName: "loading.gif")
            self.logoGifImageView = UIImageView(gifImage: g, loopCount: 1)
        
        }
        catch {
            print("err")
        }
    }

    private func commonInit() {
        backgroundColor = UIColor(white: 246.0 / 255.0, alpha: 1)
        addSubview(logoGifImageView)
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: 108).isActive = true
    }
}
