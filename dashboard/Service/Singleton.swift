//
//  Singleton.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 4/28/20.
//  Copyright © 2020 Adhikari, Bishrant. All rights reserved.
//


import Foundation;
import ARKit;

class Service {
    public var appConfiguration: AppConfigJSON!;
    private var arImageSet: Set<ARReferenceImage>!;
    private var appUpdate: AppUpdate!
    private var appUpdateSuccess: Bool = true;
    let arImageUtils: ARImageUtils = ARImageUtils()
    private var db: SqliteDatabase!
    public var downloadComplete: Bool = false;
    public var downloadError: Bool = false;
    static let sharedInstance: Service = {
        let instance = Service();
        instance.db = SqliteDatabase();
        let request = Request();
        let arImageUtils: ARImageUtils = ARImageUtils()
        let download: Download = Download()
        DispatchQueue.global(qos: .utility).async {
            let result = request.getConfigurationFromServer();
//            DispatchQueue.main.async {
                switch result {
                case let .success(data):
//                    print(data);
                    instance.appConfiguration = data!;
                    if let images = instance.appConfiguration?.images {
                        for i in images {
                            let url = serverURL + "api/public/" + i.folderName + "/" + i.imageName
                            download.loadFileSync(url: URL(string: url)!) { (path, error) in
                                if let er = error {
                                    print(er)
                                    instance.appUpdateSuccess = false
                                } else {
                                    instance.appUpdateSuccess = true
                                }
                            }
                        }
                    } else {
                        print("app upto date")
                        instance.appUpdateSuccess = true
                    }
                    instance.appUpdateSuccess = true;
                    instance.db.initializeDb();
                    instance.arImageSet = arImageUtils.loadedImagesFromDirectoryContents()
                    instance.downloadComplete = true;
                    instance.downloadError = false;
                case let .failure(error):
                    print(error);
                    instance.appUpdateSuccess = false;
                    instance.downloadComplete = false;
                    instance.downloadError = true;
                }
//            }
        }
        return instance;
    }()
    
    func getAppUpdateSuccess() -> Bool {
        return Service.sharedInstance.appUpdateSuccess
    }
    
    public func getAppConfig() -> AppConfigJSON! {
        return Service.sharedInstance.appConfiguration;
    }
    func getARImageSet() -> Set<ARReferenceImage> {
        return Service.sharedInstance.arImageSet
    }
}


class Request {
    enum NetworkError: Error {
        case url
        case server
    }
    func parseJSON(jsonStr: Data) -> AppConfigJSON! {
        var appConfig: AppConfigJSON!;
        do {
            appConfig = try JSONDecoder().decode(AppConfigJSON.self, from: jsonStr);
        } catch  {
            appConfig = nil;
        }
        //        print(appConfig);
        return appConfig;
    }
    func getConfigurationFromServer() -> Result<AppConfigJSON?, NetworkError> {
        let path = "https://txfipdev.tfs.tamu.edu/forestar/api/getimages";
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
}
