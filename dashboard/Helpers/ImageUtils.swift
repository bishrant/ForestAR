//
//  ImageUtils.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/29/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import UIKit

class ImageUtils {
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }


    func downloadImage(url: URL, completion: @escaping(_ result: UIImage) -> Void) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
    //            self.imageView.image = UIImage(data: data)
                completion(UIImage(data: data)!)
            }
        }
    }
    
    func getImageFromFileName(name: String) -> UIImage {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photoPath = documentsUrl.appendingPathComponent(name.components(separatedBy: "___")[1])
        let uiImageObj = UIImage.init(contentsOfFile: photoPath.path)
        return uiImageObj!
    }
    
    func getImageFromFileNameOriginal(name: String, folderName: String) -> UIImage {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photoPath = documentsUrl.appendingPathComponent(folderName+"___"+name)
        let uiImageObj = UIImage.init(contentsOfFile: photoPath.path)
        return uiImageObj!
    }
    
    func getImageFromFullFileName(name: String, folderName: String) -> UIImage {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photoPath = documentsUrl.appendingPathComponent(folderName + "___" + name)
        let uiImageObj = UIImage.init(contentsOfFile: photoPath.path)
        return uiImageObj!
    }

}
