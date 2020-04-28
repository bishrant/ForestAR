//
//  AppUpdate.swift
//  LivePortraitSimulator
//
//  Created by Adhikari, Bishrant on 6/27/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import UIKit

class AppUpdate {
    public var appJSON: AppConfigJSON!
    public var appConfigJSON: AppConfigJSON!
    
    func getAppJSON() -> AppConfigJSON! {
        let jsonUtils = JSONUtils()
        return jsonUtils.parseJSON2(filename: "ForestARConfig", ext: "json")
    }
    
    func checkIfAppIsInstalled(name: String) -> Bool {
        let namePrefix = name + "://"
        let namePrefixUrl: NSURL = NSURL(string: namePrefix)!
        return UIApplication.shared.canOpenURL(namePrefixUrl as URL)
    }
}
