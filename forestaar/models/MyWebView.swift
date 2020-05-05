//
//  MyWebView.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 11/10/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import WebKit

class MyWebView: UIView , WKNavigationDelegate, WKUIDelegate{
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var webViewTitle: UINavigationItem!
    @IBOutlet weak var closeWebViewBtn: UIBarButtonItem!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    var webViewDelegate: WebViewDelegate!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    @IBAction func closeWebView(_ sender: Any) {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.stopLoading()
        self.webViewDelegate.closeWebView()
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
        webView.load(URLRequest(url: urlObj!))
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
            if (keyPath == "estimatedProgress") { // listen to changes and updated view
                progressBar.isHidden = webView.estimatedProgress == 1
                progressBar.setProgress(Float(webView.estimatedProgress), animated: false)
            }
    }
    

    @IBAction func reloadWebPage(_ sender: Any) {
        self.webView.reload()
    }
}
