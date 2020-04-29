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
    public var serverURL: String = "https://txfipdev.tfs.tamu.edu/ForestAR/api/"
    private var arImageSet: Set<ARReferenceImage>!;
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
            switch result {
            case let .success(data):
                instance.appConfiguration = data!;
                if let images = instance.appConfiguration?.images {
                    for i in images {
                        let url = Service.sharedInstance.serverURL + "public/" + i.folderName + "/" + i.imageName
                        download.loadFileSync(url: URL(string: url)!, folderName: i.folderName) { (path, error) in
                            if let er = error {
                                print(er)
                                instance.appUpdateSuccess = false
                            } else {
                                instance.appUpdateSuccess = true
                            }
                        }
                    }
                } else {
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
    
    func triggerInit() -> Void {}
    
    func checkIfAppIsInstalled(name: String) -> Bool {
        let namePrefix = name + "://"
        let namePrefixUrl: NSURL = NSURL(string: namePrefix)!
        return UIApplication.shared.canOpenURL(namePrefixUrl as URL)
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
        return appConfig;
    }
    func getConfigurationFromServer() -> Result<AppConfigJSON?, NetworkError> {
        let path = Service.sharedInstance.serverURL + "getimages";
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
