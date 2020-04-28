//
//  JSONUtils.swift
//  LivePortraitSimulator
//
//  Created by Adhikari, Bishrant on 6/28/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation

class JSONUtils {
    
//    struct imagesEntry: Decodable {
//        var id: Int
//        var title: String
//        var imageName: String
//        var url: String
//        var videoLink: String
//        var physicalHeight: Float
//        var physicalWidth: Float
//        var updatedDate: String
//        var sharingText: String
//        var description: String
//        var folderName: String
//        var userEmail: String
//    }
//    struct ForestARConfig: Codable {
//        var version:String
//        var lastUpdate:String
//        var images: [imagesEntry]
//    }
    
//    struct ForestARConfigJSON: Decodable {
//        var version:String
//        var lastUpdate:String
//        var images: [imagesEntry]
//    }
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
            if img.imageName  == (imageName + ".png") {
                imageItem = img
                break
            }
        }
        //print(imageItem.videoLink)
        return imageItem
    }
}
