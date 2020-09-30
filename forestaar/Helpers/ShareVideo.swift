//
//  ShareVideo.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 11/4/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import LinkPresentation

class ShareVideo {
    private var imageName: String
    private var folderName: String
    private var videoLink: String
    private var sharingText: String
    private var parentView: UIView

    init(imageName: String, folderName: String, videoLink: String, sharingText: String, parentView: UIView) {
        self.imageName = imageName
        self.parentView = parentView
        self.videoLink = videoLink
        self.sharingText = sharingText
        self.folderName = folderName
    }
    

    public func getObjectsToShare(imageName: String, textToShare: String) -> [Any] {
        let imageUtils = ImageUtils()
        let bannerImage = imageUtils.getImageFromFileNameOriginal(name: imageName, folderName: self.folderName)
//        let appIcon = UIImage(named: "play")
        let tfsWebsite = URL(string: "https://tfsweb.tamu.edu")!
        let txForestInfoWebsite = URL(string: "https://texasforestinfo.tamu.edu")!
        let objectsToShare = [bannerImage, textToShare, tfsWebsite, txForestInfoWebsite] as [Any]
        return objectsToShare
    }
    
    func createShareUI(pView: UIView) -> UIActivityViewController {
        UIGraphicsBeginImageContext(self.parentView.frame.size)
        self.parentView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let textToShare = self.sharingText
        let activitiesItems = getObjectsToShare(imageName: imageName, textToShare: textToShare)
        
        var activities:[ShareActivity] = [ShareActivity(platform:"facebook", message: textToShare, imageName: self.imageName),
                                          ShareActivity(platform:"twitter", message: textToShare, imageName: self.imageName)]
        if Service.sharedInstance.checkIfAppIsInstalled(name: "instagram") {
            activities.append(ShareActivity(platform:"instagram", message: textToShare, imageName: self.imageName))
        }
        let activityVC = UIActivityViewController(activityItems: activitiesItems, applicationActivities: activities)
        //Excluded Activities
        activityVC.excludedActivityTypes = getExcludedActivities()
        activityVC.popoverPresentationController?.sourceView = pView;
        return activityVC
    }
}
