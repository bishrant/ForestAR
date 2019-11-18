//
//  ShareActivity.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/29/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import Photos

class ShareActivity: UIActivity {
    override var activityType: UIActivity.ActivityType? {
        return .postToFacebook
    }
    public var parent: ARDashboardController
    private var platform: String
    private var message: String
    private var imageName: String
    private var appUpdate: AppUpdate = AppUpdate()
    
    init(platform: String, message: String, imageName: String) {
        self.imageName = imageName
        self.parent = ARDashboardController()
        self.platform = platform
        self.message = message
        super.init()
    }
    override var activityTitle: String? {
//        return nil
        return NSLocalizedString(self.platform.firstCapitalized, comment: "Forest AR")
    }
    override var activityImage: UIImage? {
        return UIImage(named: self.platform)
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let lastAsset = fetchResult.firstObject {
            let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
            UIApplication.shared.open(url)
        }
    }
    
    override func perform() {
        switch platform {
        case "facebook":
            let fbURLWeb: NSURL = NSURL(string: "https://www.facebook.com/sharer/sharer.php?u=http://texasforestinfo.tamu.edu/")!
            UIApplication.shared.open(fbURLWeb as URL)
            break
        case "instagram":
            let imageUtils = ImageUtils()
            let instaImage = imageUtils.getImageFromFileName(name: self.imageName)
            UIImageWriteToSavedPhotosAlbum(instaImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            break
        case "twitter":
            let appInstalled = appUpdate.checkIfAppIsInstalled(name: "twitter")
            self.message = self.message + " @TXForestService"
            let prefix = appInstalled ? "twitter://post?message=" : "https://twitter.com/intent/tweet?text="
            let fullUrl = prefix + self.message.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!
            let appURL = NSURL(string: fullUrl)!
            UIApplication.shared.open(appURL as URL)
            break
        default:
            break
        }
    }
    
    
}
public func getExcludedActivities() -> [UIActivity.ActivityType] {
    return [UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.markupAsPDF,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.assignToContact
    ]
}


