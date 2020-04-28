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
    func checkAppUpdate() -> URLSessionDataTask {
//        var appUpdateSuccess: Bool = false
//        let jsonUtils: JSONUtils = JSONUtils()
//        let download: Download = Download()
        
        let session = URLSession.shared;
        let url = URL(string: "https://txfipdev.tfs.tamu.edu/forestar/api/getimages")!;
        
        let task = session.dataTask(with: url, completionHandler: {
            data, response, error in
            if error != nil {
//                print(error);
                return;
            }
            
            do {
                let json = try JSONDecoder().decode(AppConfigJSON.self, from: data!);
                print(json);
            } catch {
                print("Error during JSON serialization");
            }
        })
        task.resume();
        
        return task;
//        download.fileLoadFileSyncOverride(url: URL(string: "https://txfipdev.tfs.tamu.edu/forestar/api/getimages")!, override: true) { (path, error) in
//            if let er = error {
//                print(er)
//                appUpdateSuccess = false
//            } else {
//                self.appJSON = jsonUtils.parseJSON(filename: "ForestARConfig", ext: "json")
//                if let images = self.appJSON?.images {
//                    for i in images {
//                        let url = serverURL + i.imageName
//                        download.loadFileSync(url: URL(string: url)!) { (path, error) in
//                            if let er = error {
//                                print(er)
//                                appUpdateSuccess = false
//                            } else {
//                                appUpdateSuccess = true
//                            }
//                        }
//                    }
//                } else {
//                    print("app upto date")
//                    appUpdateSuccess = true
//                }
//                appUpdateSuccess = true
//            }
//        }
//

//        return appUpdateSuccess
    }
    

    
    
    func getAppJSON() -> AppConfigJSON! {
        let jsonUtils = JSONUtils()
        return jsonUtils.parseJSON(filename: "ForestARConfig", ext: "json")
    }
    
    func checkIfAppIsInstalled(name: String) -> Bool {
        let namePrefix = name + "://"
        let namePrefixUrl: NSURL = NSURL(string: namePrefix)!
        return UIApplication.shared.canOpenURL(namePrefixUrl as URL)
    }


func getStuffFromServer(finished: @escaping (_ completion: AppConfigJSON?)->()) -> URLSessionDataTask {
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
    return task;
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

enum NetworkError: Error {
    case url
    case server
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
            result = .success(self.parseJSON(jsonStr: data))
        } else {
            result = .failure(.server)
        }
        semaphore.signal();
    }.resume();
    
    _ = semaphore.wait(timeout: .distantFuture)
    return result;
}




//class func downloadData(finished: ((data: AppConfigJSON) -> Void) {
//    let session = URLSession.shared;
//    let url = URL(string:"https://txfipdev.tfs.tamu.edu/forestar/api/getimages")!;
//    var appData: AppConfigJSON?;
//    let task = session.dataTask(with: url, completionHandler: {
//        data, response, error in
//        if error != nil {
//            appData = nil;
//            finished(nil);
//            return;
//        }
//        do {
//            let json = try JSONDecoder().decode(AppConfigJSON.self, from: data!);
//            appData = json;
//            return;
//        } catch {
//            print("Error during JSON serialization \(error).");
//            appData = nil;
//            return;
//        }
//    })
//    task.resume();
//})
}
