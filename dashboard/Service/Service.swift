//
//  Service.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/29/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation

struct Service {
    private var appVersion: Int = 10
    private var appUpdate: AppUpdate = AppUpdate()
    private var database: SqliteDatabase = SqliteDatabase()
    static let sharedInstance = Service()
    private var appUpdateSuccess: Bool
    
    private init() {
        print("initializing singleton")
        self.appUpdateSuccess = self.appUpdate.checkAppUpdate()
        self.appVersion = self.appVersion + 1
        self.database.initializeDB()
    }
       
    func getAppUpdateSuccess() -> Bool {
        return appUpdateSuccess
    }
    
    func getDatabase() -> SqliteDatabase {
        return self.database
    }
    
}
