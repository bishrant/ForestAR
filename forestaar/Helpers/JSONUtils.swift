//
//  JSONUtils.swift
//  LivePortraitSimulator
//
//  Created by Adhikari, Bishrant on 6/28/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation

class JSONUtils {

    func parseJSON2(filename: String, ext: String) -> AppConfigJSON? {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullFileName = documentsUrl.appendingPathComponent(filename + "." + ext)

        let placeHolderJson: AppConfigJSON? = nil
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: fullFileName.path), options: .mappedIfSafe)
            let parsedJSON = try! JSONDecoder().decode(AppConfigJSON.self, from: jsonData)
            return parsedJSON
        } catch let error {
            print("Unable to parse json", error)
            return placeHolderJson!
        }
    }
    
    func getImageDetailsFromJSON(json: AppConfigJSON, imageName: String) -> ARImageEntry {
        var imageItem: ARImageEntry!
        for img: ARImageEntry in json.images {
           // print(img.imageName)
            if img.imageName  == imageName.components(separatedBy: "___")[1] {
                imageItem = img
                break
            }
        }
        //print(imageItem.videoLink)
        return imageItem
    }
}
