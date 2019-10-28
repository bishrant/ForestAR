//
//  ARDashboardViewController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/23/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import Photos
import Social
import FBSDKShareKit

extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
    var firstCapitalized: String {
        return String(prefix(1)).capitalized + dropFirst()
    }
}
class ARDashboardController: UIViewController, ARSCNViewDelegate, SharingDelegate {
    //, UIDocumentInteractionControllerDelegate
    @IBOutlet weak var sceneView: ARSCNView!
    private var spriteKitScene: SKScene!
    
    private var imageNode: SCNNode!
    private var videoHolder: SCNNode!
    private var imageAnchor: ARImageAnchor!
    private var videoPlayerNode: SKVideoNode?
    
    private var configuration: ARImageTrackingConfiguration!
    private var arImageSet: Set<ARReferenceImage>!
    private var appConfiguration: JSONUtils.photoId!
    private var playerLayer: AVPlayerLayer = AVPlayerLayer()
    private var videoUtils: VideoUtils = VideoUtils()
    @IBOutlet weak var overlayView: UIView!
    private var showHideControlsTask: DispatchWorkItem?
    @IBOutlet weak var videoControls: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
//        self.documentInteractionController.delegate = self
        let appUpdate: AppUpdate = AppUpdate()
        _ = appUpdate.checkAppUpdate()
        self.appConfiguration = appUpdate.getAppJSON()
        let arImageUtils: ARImageUtils = ARImageUtils()
        self.arImageSet = arImageUtils.loadedImagesFromDirectoryContents()
        
        // spritekit and position
        self.spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        self.spriteKitScene.scaleMode = .aspectFit
        
        self.showHideControlsTask = DispatchWorkItem {
            print("do something");
            self.toogleControlsWithAnimations(videoControlsView: self.videoControls)
        }
    }
    
    func showShareDialog<C: SharingContent>(_ content: C, mode: ShareDialog.Mode = .automatic) {
      let dialog = ShareDialog(fromViewController: self, content: content, delegate: self)
      dialog.mode = mode
      dialog.show()
    }
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String: Any]) {
      let title = "Share Success"
      let message = "Succesfully shared: \(results)"
//        let alertController = UIAlertController(nibName: title, bundle: message)
//      self.present(alertController, animated: true, completion: nil)
        print(results)
    }

    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
      let title = "Share Failed"
      let message = "Sharing failed with error \(error)"
        print(error)
//      let alertController = UIAlertController(title: title, message: message)
//      self.present(alertController, animated: true, completion: nil)
    }

    func sharerDidCancel(_ sharer: Sharing) {
      let title = "Share Cancelled"
      let message = "Sharing was cancelled by user."
        print(message)
//      let alertController = UIAlertController(title: title, message: message)
//      self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func playPauseBtnclicked(_ sender: UIButton) {
        DispatchQueue.main.async {
            if (self.videoPlayerNode !== nil) {
                if (self.playerLayer.player != nil && self.playerLayer.player!.rate != 0){
                    self.videoPlayerNode?.pause()
                    sender.setBackgroundImage(UIImage(systemName: "play"), for: UIControl.State.normal)
                    
                } else {
                    self.videoPlayerNode?.play()
                    sender.setBackgroundImage(UIImage(systemName: "pause"), for: UIControl.State.normal)
                }
            }
        }
        
    }
//    var documentController: UIDocumentInteractionController!
    
    
    
    
    class shareActivity: UIActivity {
        override var activityType: UIActivity.ActivityType? {
            return .postToFacebook
        }
        public var parent: ARDashboardController
        private var platform: String
        private var message: String
        private var anchorImageParent: ARImageAnchor
        
        init(platform: String, message: String, achorImage: ARImageAnchor) {
            self.anchorImageParent = achorImage
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
                let appInstalled = parent.checkIfAppIsInstalled(name: "instagram")
                if appInstalled {
//                    let appURL = NSURL(string: "instagram://")
                } else {
                    
                }
                let x = self.anchorImageParent.referenceImage.name
                parent.test()
                break
            
            case "twitter":
                let appInstalled = parent.checkIfAppIsInstalled(name: "twitter")
                self.message = self.message + " @TXForestService"
                let prefix = appInstalled ? "twitter://post?message=" : "https://twitter.com/intent/tweet?text="
                let fullUrl = prefix + self.message.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics)!
                let appURL = NSURL(string: fullUrl)!
                UIApplication.shared.open(appURL as URL)
                break
            default:
                break
            }

            
//            let fbURLID: NSURL = NSURL(string: "twitter://post?message=" + message)!
//
//            if let appURL = NSURL(string: "fb://") {
//                let canOpen = UIApplication.shared.canOpenURL(appURL as URL)
//                print("Can open \"\(appURL)\": \(canOpen)")
//            }
//            if(UIApplication.shared.canOpenURL(fbURLID as URL)){
//                // FB installed
//                UIApplication.shared.open(fbURLID as URL)
//            } else {
//                // FB is not installed, open in safari
//                UIApplication.shared.open(fbURLWeb as URL)
//            }
          //  parent.test()
            
//            let content = SharePhotoContent()
//            content.photos = [SharePhoto(image: #imageLiteral(resourceName: "facebook"), userGenerated: true)]
//            parent.showShareDialog(content)
        }
    }
    
    func checkIfAppIsInstalled(name: String) -> Bool {
        let namePrefix = name + "://"
        let namePrefixUrl: NSURL = NSURL(string: namePrefix)!
        return UIApplication.shared.canOpenURL(namePrefixUrl as URL)
    }
    
    
    public  var documentInteractionController = UIDocumentInteractionController()
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            print(error as Any)
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let lastAsset = fetchResult.firstObject {
            let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                let alertController = UIAlertController(title: "Error", message: "Instagram is not installed", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    public func postToInstagram(image: String) {
        let s = self.imageAnchor.referenceImage.name
//        /"https://txfipdev.tfs.tamu.edu/treeselector/" + i.imageName
        let img = UIImage()
        
        UIImageWriteToSavedPhotosAlbum(img!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        // let instagramURL = NSURL(string: "instagram://app")
        //        let img = UIImage(named: "180")
        //        if (UIApplication.shared.canOpenURL(instagramURL! as URL)) {
        //
        //            let imageData = img!.jpegData(compressionQuality: 100)
        //
        //            let captionString = "caption"
        //
        //            let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
        //            do{
        //               print(111)
        //                try imageData?.write(to: URL(fileURLWithPath: writePath), options: .atomic)
        //                let fileURL = NSURL(fileURLWithPath: writePath)
        //
        //                self.documentInteractionController = UIDocumentInteractionController(url: fileURL as URL)
        //
        //
        //
        //                self.documentInteractionController.uti = "com.instagram.exlusivegram"
        //
        ////                self.documentInteractionController.annotation = NSDictionary(object: captionString, forKey: "InstagramCaption")
        //                self.documentInteractionController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        //
        //            } catch {
        //                print(error)
        //                return
        //            }
        //
        //
        //        } else {
        //            print(" Instagram isn't installed ")
        //        }
    }
    
    
//    func showShareDialog<Content: SharingContent>(
//        _ content: SharingContent,
//        mode: ShareDialog.Mode = .automatic
//        ) {
//        let dialog = ShareDialog(
//            fromViewController: self,
//            content: content,
//            delegate: self
//        )
//        dialog.mode = mode
//        dialog.show()
//    }
      
    
    @IBAction func shareVideo(_ sender: UIButton) {
        //        @objc func share(sender:UIView){
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let img = UIImage(named: "180")
        let textToShare = "Check out Forest AR. An augumented reality app developed by the Texas A&M Forest Service. #TFS #ForestAR"
        let myWebsite1 = URL(string: "https://texasforestinfo.tamu.edu")
        if let myWebsite = URL(string: "https://tfsweb.tamu.edu") {//Enter link to your app here
            let objectsToShare = [textToShare, myWebsite,myWebsite1, img] as [Any]
            //                let u = UIActivity(activityType: UIActivity.ActivityType.postToFacebook)
            //                u.activityType = UIActivity.ActivityType.postToFacebook
            //                let f = UIActivity.ActivityType.postToFacebook
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [
                shareActivity(platform:"facebook", message: textToShare, achorImage: self.imageAnchor),
                shareActivity(platform:"twitter", message: textToShare, achorImage: self.imageAnchor),
                shareActivity(platform:"instagram", message: textToShare, achorImage: self.imageAnchor)
            ])
            
            //                activityVC.Activi
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,
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
            //
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
        
        //    }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configuration = ARImageTrackingConfiguration()
        self.configuration.trackingImages = self.arImageSet
        self.configuration.maximumNumberOfTrackedImages = 1
        //        // Run the view's session
        sceneView.session.run(self.configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    
    func toogleControlsWithAnimations(videoControlsView: UIView) {
        if (videoControlsView.isHidden) {
            UIView.animate(withDuration: 0.2, animations: {
                videoControlsView.alpha = 100;
            }, completion: { _ in
                videoControlsView.isHidden = false
            })
            self.showHideControlsTask!.cancel()
            // execute task in 10 seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: self.showHideControlsTask!)
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                videoControlsView.alpha = 0;
            }, completion: { _ in
                videoControlsView.isHidden = true // Here you hide it when animation done
            })
            self.showHideControlsTask!.cancel()
        }
    }
    
    
    func addVideoToAnchor(imageAnchors: ARImageAnchor) {
        let imageName = imageAnchors.referenceImage.name
        let jsonUtils = JSONUtils()
        let serverURL = "https://txfipdev.tfs.tamu.edu/treeselector/"
        let currentImgJson = jsonUtils.getImageDetailsFromJSON(json: self.appConfiguration, imageName: imageName!)
        print(imageName!, "found");
        print(UIDevice().identifierForVendor?.uuidString ?? "", "Device name")
        self.setupVideo(videoURL: serverURL + currentImgJson.videoLink)
        // self.isVideoLoaded = true
        // self.forcefullyClosedVideo = false
        
    }
    
    
    func setupVideo(videoURL: String) {
        let videoPlayer  = AVPlayer(url: URL(string: videoURL)!)
        videoPlayer.volume = 10
        self.playerLayer.player = videoPlayer
        
        DispatchQueue.main.async {
            self.playerLayer.frame = self.overlayView.bounds
            self.playerLayer.videoGravity = .resizeAspect
            self.overlayView.layer.addSublayer(self.playerLayer)
            //initialize video node
            
            self.videoPlayerNode = self.videoUtils.createVideoPlayerNode(videoPlayer: self.playerLayer.player!, spriteKitScene: self.spriteKitScene)
            
            let gesture1 = UITapGestureRecognizer(target: self, action:  #selector(self.togglePlaybackControlsVisibility))
            self.videoControls.addGestureRecognizer(gesture1)
            
            self.spriteKitScene.addChild(self.videoPlayerNode!)
            self.spriteKitScene.name = "spriteKitScene"
            
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.togglePlaybackControlsVisibility))
            self.overlayView.addGestureRecognizer(gesture)
            //            self.overlayView.backgroundColor = .red
            self.videoHolder = self.videoUtils.createVideoHolderOverImage(referenceImage: self.imageAnchor.referenceImage, spriteKitScene: self.spriteKitScene)
            
            self.videoPlayerNode?.play()
            
            // self.showHideOverlayControls(show: true)
            // self.setVideoPlaybackTime()
            DispatchQueue.main.async {
                // self.videoControls?.isHidden = false
            }
            self.imageNode.addChildNode(self.videoHolder)
        }
    }
    
    func setVideoPlaybackTime() {
        //        if let currentItem = self.playerLayer.player?.currentItem {
        //            let duration = currentItem.asset.duration.seconds
        //            self.totalTime = duration
        //            DispatchQueue.main.async {
        //                self.videoSlider.setValue(0, animated: false)
        //                self.totalTimeLbl.text = self.stringUtils.stringFromTimeInterval(interval: duration)
        //            }
        //        }
        
        //        DispatchQueue.main.async {
        //            self.addPeriodicTimeObserver()
        //            self.videoSlider.removeTarget(self, action: #selector(self.sliderChanged), for: UIControl.Event.valueChanged)
        //            self.videoSlider.addTarget(self, action: #selector(self.sliderChanged), for: UIControl.Event.valueChanged)
        //        }
    }
    
    //    func addPeriodicTimeObserver() {
    //        // Invoke callback every half second
    //        let interval = CMTime(seconds: 1,  preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    //        // Queue on which to invoke the callback
    //        let mainQueue = DispatchQueue.main
    //
    //        // Add time observer
    //        self.timeObserver = self.playerLayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
    //            [weak self] time in
    //            let t = self?.totalTime
    //            let sliderVal = Float (time.seconds / t!)
    //
    //            self?.videoSlider.value = sliderVal
    //            self?.currentTimeLbl.text = self?.stringUtils.stringFromTimeInterval(interval: time.seconds)
    //            if (time.seconds >= t!) {
    //                self?.playerDidFinishPlaying()
    //            }
    //        }
    //    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
        }) { (context) in
            self.overlayView.frame.size = size
            self.playerLayer.frame.size = size
        }
    }
    
    func findImageAnchorsForVideo(anchor: ARAnchor) {
        if let imageAnchors = anchor as? ARImageAnchor {
            // nothing in the view, first scan recognize image and start loading video
            if (self.imageAnchor == nil) {
                self.imageAnchor = imageAnchors
                
                // @todo send to analytics server for countinng the number of times an image has been recognized by the app
                self.imageAnchor?.setValue(imageAnchors.referenceImage.name, forKey: "name")
                self.addVideoToAnchor(imageAnchors: self.imageAnchor)
                
                
                // self.forcefullyClosedVideo = false
                //  self.isVideoPausedByUser = false
            }
        }
    }
    
    @IBAction func closeARDashboard(_ sender: UIButton) {
        print(self.imageAnchor.referenceImage.name, "ref image name")
    }
    @objc func togglePlaybackControlsVisibility(sender : UITapGestureRecognizer) {
        print("toggle playback controls visibility");
        self.toogleControlsWithAnimations(videoControlsView: self.videoControls);
        // self.videoControls.isHidden = !self.videoControls.isHidden
    }
    
    //     Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        self.imageNode = SCNNode()
        self.imageNode.name = "imageNode"
        
        //            if let imageAnchors = anchor as? ARImageAnchor {
        //                // nothing in the view, first scan recognize image and start loading video
        //                if (self.imageAnchor == nil) {
        //                    self.imageAnchor = imageAnchors
        //
        //                    // @todo send to analytics server for countinng the number of times an image has been recognized by the app
        //                    self.imageAnchor?.setValue(imageAnchors.referenceImage.name, forKey: "name")
        //                    self.addVideoToAnchor(imageAnchors: imageAnchors)
        //                   // self.forcefullyClosedVideo = false
        //                  //  self.isVideoPausedByUser = false
        //                }
        // if imageNode is already visible and its achor is same as previous one
        //                else if (self.imageAnchor?.referenceImage.name == imageAnchors.referenceImage.name) {
        //                    if (self.forcefullyClosedVideo) {
        //                        self.imageAnchor = imageAnchors
        //                        self.addVideoToAnchor(imageAnchors: imageAnchors)
        //                        self.forcefullyClosedVideo = false
        //                        self.isVideoPausedByUser = false
        //                    } else {
        //                        self.hideOverlayVideo()
        //                    }
        //
        //                } else if (self.imageAnchor?.referenceImage.name != imageAnchors.referenceImage.name) {
        //                    DispatchQueue.main.async {
        //                        if (self.overlayView.isHidden) {
        //                            self.addVideoToAnchor(imageAnchors: imageAnchors)
        //                            self.forcefullyClosedVideo = false
        //                            self.isVideoPausedByUser = false
        //                            self.imageAnchor = imageAnchors
        //                        } else {
        //                            self.sceneView.session.remove(anchor: anchor)
        //                        }
        //                    }
        //
        //                }
        
        //            } else {
        //               // self.isVideoLoaded = false
        //            }
        findImageAnchorsForVideo(anchor: anchor)
        return self.imageNode
    }
    
}
