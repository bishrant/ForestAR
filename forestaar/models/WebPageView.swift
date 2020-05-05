//
//  WebPageView.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/4/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit

class WebPageView: UIView {

    @IBOutlet var ContainerView: UIView!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        initHeader()
    }
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
        initHeader()
    }
    
    func initHeader() {
        
        if let c = Bundle.main.loadNibNamed("WebPageView", owner: self, options: nil)?.first as? WebPageView {
            addSubview(c)
            c.frame = self.bounds
            c.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
//        Bundle.main.loadNibNamed("WebPageView", owner: self, options: nil)
//        addSubview(ContainerView)
//        ContainerView.frame = self.bounds
//        ContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
