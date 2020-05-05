//
//  MyMenu.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 11/11/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import MessageUI

class MyMenu: UIView {
    
    @IBOutlet weak var sideMenuView: UIView!
    var currentMenu: String = "HOME"
    var delegate: MenuDelegate?
    
    @IBAction func menuItemClicked(_ sender: UIButton) {
        self.currentMenu = sender.titleLabel!.text!
        delegate?.menuSelected(menuName: self.currentMenu)
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        delegate?.menuClosed()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MyMenu", owner: self, options: nil)
        guard let content = sideMenuView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        
        let gradientViewForMenu = GradientViewOpaque(frame: content.bounds)
        self.insertSubview(gradientViewForMenu, at: 0)

    }
    
    @IBAction func sendEmail(_ sender: Any) {
        let email = "bishrant.adhikari@tfs.tamu.edu"
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    @IBAction func goToTFSHome(_ sender: Any) {
        self.goToLink(link: "https://tfsweb.tamu.edu")
    }
    @IBAction func gotoTFSTwitter(_ sender: Any) {
        self.goToLink(link: "https://twitter.com/TXForestService")
    }
    @IBAction func goToTFSFacebook(_ sender: Any) {
        self.goToLink(link: "https://www.facebook.com/texasforestservice/")
    }
    @IBAction func goToTFSInstagram(_ sender: Any) {
        self.goToLink(link: "https://www.instagram.com/texasforestservice/")
    }
    
    private func goToLink(link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}
