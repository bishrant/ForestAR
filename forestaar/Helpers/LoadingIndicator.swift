//
//  LoadingIndicator.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 10/29/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import UIKit
import Foundation

class LoadingIndicator {
    var vSpinner : UIView?
     
//    extension UIViewController {
        func showSpinner(onView : UIView) {
            let spinnerView = UIView.init(frame: onView.bounds)
            spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            let ai = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
            ai.startAnimating()
            ai.center = spinnerView.center
            
            DispatchQueue.main.async {
                spinnerView.addSubview(ai)
                onView.addSubview(spinnerView)
            }
            
            self.vSpinner = spinnerView
        }
        
        func removeSpinner() {
            DispatchQueue.main.async {
                self.vSpinner?.removeFromSuperview()
                self.vSpinner = nil
            }
        }
//    }
}
