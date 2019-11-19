//
//  Service.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/29/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import ARKit

struct Service {
    private var appVersion: Int = 10
    private var appUpdate: AppUpdate!
    static let sharedInstance = Service()
    private var appUpdateSuccess: Bool
    private var arImageSet: Set<ARReferenceImage>!
    public var appConfiguration: JSONUtils.ForestARConfig
    private var db: SqliteDatabase!
    
    private init() {
        print("initializing singleton")
        self.appUpdate = AppUpdate()
        self.appUpdateSuccess = self.appUpdate.checkAppUpdate()
        let arImageUtils: ARImageUtils = ARImageUtils()
        self.db = SqliteDatabase()
        db.initializeDb()
        self.arImageSet = arImageUtils.loadedImagesFromDirectoryContents()
        self.appVersion = self.appVersion + 1
        self.appConfiguration = self.appUpdate.getAppJSON()
    }
       
    func getAppUpdateSuccess() -> Bool {
        return appUpdateSuccess
    }
    
    func getARImageSet() -> Set<ARReferenceImage> {
        return self.arImageSet
    }
}
