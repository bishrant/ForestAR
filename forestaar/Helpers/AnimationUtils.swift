//
//  AnimationUtils.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 10/29/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import UIKit

class AnimationUtils {
    func hideWithAnimation(myView: UIView, delay: Float) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: TimeInterval(delay), animations: {
                myView.alpha = 0;
            }, completion: { _ in
                myView.isHidden = true
            })
        }
    }
    
    func showWithAnimation(myView: UIView, delay: Float) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: TimeInterval(delay), animations: {
                myView.alpha = 100;
            }, completion: { _ in
                myView.isHidden = false
            })
        }
    }
}
