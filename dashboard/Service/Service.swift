//
//  Service.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/29/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import ARKit
struct AppService {
    static let sharedAppService: AppService = AppService();
    public var config: AppConfigJSON!;
    private init() {}
    
    public mutating func SetAppConfig(config: AppConfigJSON) {
        self.config = config;
    }
}
struct Service0 {
    private var appVersion: Int = 10
    private var appUpdate: AppUpdate!
    static let sharedInstance = Service0();
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
        let url = URL(string: serverURL + "getimages")!;
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
    func parseJSON(jsonStr: Data) -> AppConfigJSON! {
        var appConfig: AppConfigJSON!;
        do {
            appConfig = try JSONDecoder().decode(AppConfigJSON.self, from: jsonStr);
        } catch  {
            appConfig = nil;
        }
        return appConfig;
    }
    
    enum NetworkError: Error {
        case url
        case server
    }
    
    func getConfigurationFromServer() -> Result<AppConfigJSON?, NetworkError> {
        let path = serverURL+"getimages";
        guard let url = URL(string: path) else {
            return .failure(.url)
        }
        
        var result: Result<AppConfigJSON?, NetworkError>!;
        
        let semaphore = DispatchSemaphore(value: 0);
        
        URLSession.shared.dataTask(with: url) {
            (data, _, _) in
            if let data = data {
                print("got dataa", data);
                let jsonData = self.parseJSON(jsonStr: data);
                result = .success(jsonData)
            } else {
                result = .failure(.server)
            }
            semaphore.signal();
        }.resume();
        
        _ = semaphore.wait(timeout: .distantFuture)
        return result;
    }
    
    init() {
        DispatchQueue.global(qos: .utility).async {
            let result = self.getConfigurationFromServer();
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    self.appService?.appConfiguration = data!;
                case let .failure(error):
                    print(error);
                }
            }
        }
    }
    
    
}
