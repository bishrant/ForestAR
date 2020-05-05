//
//  CustomSlider.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 10/25/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import UIKit

class CustomSlider : UISlider {
    @IBInspectable open var trackWidth:CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }

    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
    
//    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        return true
//    }
}
