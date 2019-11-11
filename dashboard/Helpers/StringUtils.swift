//
//  StringFormatter.swift
//  LivePortraitSimulator
//
//  Created by Adhikari, Bishrant on 6/25/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation

class StringUtils {
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
    }
    
}
