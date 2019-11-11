//
//  MyMenu.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/11/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit

class MyMenu: UIView {
    @IBOutlet var sideMenuView: UIView!
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
    }
    
}
