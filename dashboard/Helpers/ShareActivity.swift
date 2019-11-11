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
        return NSLocalizedString(self.platform.firstCapitalized, comment: "Forest AR")
    }
    override var activityImage: UIImage? {
        return UIImage(named: self.platform)
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        switch platform {
        case "facebook":
            let fbURLWeb: NSURL = NSURL(string: "https://www.facebook.com/sharer/sharer.php?u=http://texasforestinfo.tamu.edu/")!
            UIApplication.shared.open(fbURLWeb as URL)
            break
        case "instagram":
            parent.postToInstagram(imageName: self.imageName)
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

public func getObjectsToShare(imageName: String, textToShare: String) -> [Any] {
    let imageUtils = ImageUtils()
    let bannerImage = imageUtils.getImageFromFileName(name: imageName)
    let appIcon = UIImage(named: "AppIcon")
    let tfsWebsite = URL(string: "https://tfsweb.tamu.edu")!
    let txForestInfoWebsite = URL(string: "https://texasforestinfo.tamu.edu")!
    let objectsToShare = [textToShare, tfsWebsite, txForestInfoWebsite, bannerImage, appIcon!] as [Any]
    return objectsToShare
}
