//
//  MyWebView.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/10/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import WebKit

class MyWebView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var webViewTitle: UINavigationItem!
    @IBOutlet weak var closeWebViewBtn: UIBarButtonItem!
    @IBOutlet weak var webViewArea: WKWebView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MyWebView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        closeWebViewBtn.target = self
    }
    
    func loadUrl(url: String, title: String) {
        let urlObj = URL(string: url)
        self.webViewTitle.title = title
        webViewArea.load(URLRequest(url: urlObj!))
    }
    
    @IBAction func reloadWebPage(_ sender: Any) {
        self.webViewArea.reload()
    }
}
