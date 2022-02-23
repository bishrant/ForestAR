//
//  WebViewDelegate.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 11/18/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import UIKit

protocol WebViewDelegate {
    func closeWebView()
    func shareURL(title: String, url: URL, sourceItem: UIBarButtonItem)
}
