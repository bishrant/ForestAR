//
//  web.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/4/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import WebKit

class Web1: UIView {

    @IBOutlet weak var webViewToolbar: UIToolbar!
    @IBOutlet var container: UIView!
    @IBOutlet weak var webView: WKWebView!
    private var jsonUtils: JSONUtils = JSONUtils()
        override init(frame: CGRect) {
            super.init(frame: frame)
            
//            initHeaders()
        }
        required init?(coder:NSCoder) {
            super.init(coder: coder)
            initHeaders()
        }
        
        private func initHeaders() {
         //   self.container = Bundle.main.loadNibNamed("web", owner: self, options: nil)?[0] as? UIView
         //   self.container.frame = UIScreen.main.bounds
        
         //   addSubview(self.container)
         //   self.container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    func setWebViewSize(parentWebView: UIView) {
        self.webView.frame.size.height = parentWebView.frame.height - self.webViewToolbar.frame.height
        self.webView.frame.size.width = parentWebView.frame.width
    }
    
    func show(webPageView: UIView, view: UIView, imageName: String) {
        let im = imageName.components(separatedBy: ".png")[0]
        let currentJson: JSONUtils.imagesEntry = self.jsonUtils.getImageDetailsFromJSON(json: Service.sharedInstance.appConfiguration, imageName: im)
        
//        webView.frame.size = webPageView.frame.size
        setWebViewSize(parentWebView: webPageView)
        let currentURL = URL(string: currentJson.url)!
        webView.load(URLRequest(url: currentURL))
        
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       options: [],
                       animations: {
                        webPageView.backgroundColor = .white
                        webPageView.alpha = 1
                        webPageView.frame.origin.y = 100
                        webPageView.frame.size.height = view.frame.height - 100
        })
    }


}

