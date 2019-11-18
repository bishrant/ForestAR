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
    private var database: SqliteDatabase!
    static let sharedInstance = Service()
    private var appUpdateSuccess: Bool
    private var arImageSet: Set<ARReferenceImage>!
    public var appConfiguration: JSONUtils.photoId
    
    private init() {
        print("initializing singleton")
        self.appUpdate = AppUpdate()
        self.database = SqliteDatabase()
        self.appUpdateSuccess = self.appUpdate.checkAppUpdate()
        let arImageUtils: ARImageUtils = ARImageUtils()
        self.arImageSet = arImageUtils.loadedImagesFromDirectoryContents()
        self.appVersion = self.appVersion + 1
        self.appConfiguration = self.appUpdate.getAppJSON()
    }
       
    func getAppUpdateSuccess() -> Bool {
        return appUpdateSuccess
    }
    
    func getDatabase() -> SqliteDatabase {
        return self.database
    }
    
    func getARImageSet() -> Set<ARReferenceImage> {
        return self.arImageSet
    }
    //self.appConfiguration = appUpdate.getAppJSON()
}
