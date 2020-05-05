//
//  CustomWebUIView.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/8/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import WebKit

class CustomWebUIView: UIView {


    var webView: WKWebView = WKWebView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initView(parentView: UIView) {
        frame = parentView.frame
        frame.size.width = parentView.frame.width * 0.95
        center.x = parentView.center.x
        frame.size.height = parentView.frame.height - 100
        backgroundColor = .orange
        layer.cornerRadius = 15
        layer.masksToBounds = true
        layer.zPosition = 1001
        isOpaque = true
        frame.origin.y = parentView.frame.height + 100
        backgroundColor = .gray
        
//        self.webView.frame = self.view.frame
//        self.webView.frame.size.width = self.view.frame.width
//        self.webView.center.x = self.view.center.x
//        self.webView.frame.size.height = self.view.frame.height - 50
//        self.webView.backgroundColor = .red
//        self.webView.frame.origin.y = self.view.frame.origin.y
//        self.view.addSubview(self.webView)
//        return self.view
    }
    
    func loadUrl(url: String) {
        let currentURL = URL(string: url)!
        self.webView.load(URLRequest(url: currentURL))
    }
}
