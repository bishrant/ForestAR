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
    static let sharedInstance = Service();
    static let dataService = DataService();
    private var appUpdateSuccess: Bool = true;
    private var arImageSet: Set<ARReferenceImage>!
    public var appConfiguration: AppConfigJSON!
    private var db: SqliteDatabase!
    

       
    func getAppUpdateSuccess() -> Bool {
        return appUpdateSuccess
    }
    
    func getARImageSet() -> Set<ARReferenceImage> {
        return self.arImageSet
    }
    
    func getAppConfiguration(finished: @escaping (_: AppConfigJSON?) -> Void){
        let session = URLSession.shared;
        let url = URL(string:"https://txfipdev.tfs.tamu.edu/forestar/api/getimages")!;
        let task = session.dataTask(with: url, completionHandler: {
            data, response, error in
            if error != nil {finished(nil); return; }
            do {
                let json = try JSONDecoder().decode(AppConfigJSON.self, from: data!);
                finished(json);
            } catch {
                print("Error during JSON serialization \(error).");
                finished(nil);
            }
        })
        task.resume();
    }
    mutating func initializeApp (appConfig: AppConfigJSON?) {
        self.appUpdateSuccess = appConfig == nil;
        
    }
//    mutating func runInitializer() {
//          self.getAppConfiguration(finished: {
//              data in
//              self.appUpdateSuccess = data == nil;
//          });
//    }
    
    private init() {
        print("initializing singleton");

        self.appUpdate = AppUpdate();
//        DataService();


        
        
//        runInitializer();
//        self.appUpdateSuccess = self.appUpdate.checkAppUpdate()
//        let arImageUtils: ARImageUtils = ARImageUtils()
//        self.db = SqliteDatabase()
//        db.initializeDb()
//        self.arImageSet = arImageUtils.loadedImagesFromDirectoryContents()
//        self.appVersion = self.appVersion + 1
//        self.appConfiguration = self.appUpdate.getAppJSON()
    }
}

class DataService {
    var appService: Service!;
    init() {
        DispatchQueue.global(qos: .utility).async {
            let result = AppUpdate().getConfigurationFromServer();
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    self.appService.appConfiguration = data;
                case let .failure(error):
                    print(error);
                }
            }
        }
    }

}
