//
//  ARImageUtils.swift
//  LivePortraitSimulator
//
//  Created by Adhikari, Bishrant on 6/28/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import ARKit


class ARImageUtils {
    
    func getPhysicalSize(imageName: String) -> [Float] {
        let appJSON = Service.sharedInstance.getAppConfig()
        var size: [Float] = [0, 0]
        if let images = appJSON?.images {
            for img in images {
                if img.imageName == imageName.components(separatedBy: "___")[1] {
                    size = [img.physicalWidth, img.physicalHeight]
                }
            }
        } else {
            size = [8, 4]
        }
        return size
    }
    /// Returns The Documents Directory
    ///
    /// - Returns: URL
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
        
    }
    
    /// Creates A Set Of ARReferenceImages From All PNG Content In The Documents Directory
    ///
    /// - Returns: Set<ARReferenceImage>
    func loadedImagesFromDirectoryContents() -> Set<ARReferenceImage>?{
        var index = 0
        var customReferenceSet = Set<ARReferenceImage>()
        let documentsDirectory = getDocumentsDirectory()
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            let filteredContents = directoryContents.filter{ $0.pathExtension == "png" || $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" }
            
            filteredContents.forEach { (url) in
                
                do{
                    //1. Create A Data Object From Our URL
                    let imageData = try Data(contentsOf: url)
                    guard let image = UIImage(data: imageData) else { return }
                    
                    //2. Convert The UIImage To A CGImage
                    guard let cgImage = image.cgImage else { return }
                    
                    //3. Get The Width Of The Image
                    let imagePhysicalSize = getPhysicalSize(imageName: url.lastPathComponent)
                    let fileName = url.lastPathComponent
                    
                    //4. Create A Custom AR Reference Image With A Unique Name
                    let customARReferenceImage = ARReferenceImage(cgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(imagePhysicalSize[0]))
                    
                    customARReferenceImage.name = fileName
                    
                    //4. Insert The Reference Image Into Our Set
                    customReferenceSet.insert(customARReferenceImage)
                    index += 1
                    
                }catch{
                    
                    print("Error Generating Images == \(error)")
                    
                }
                
            }
            
        } catch {
            print("Error Reading Directory Contents == \(error)")
        }
        
        
        //5. Return The Set
        return customReferenceSet
    }
}
