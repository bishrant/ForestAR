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

extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
    var firstCapitalized: String {
        return String(prefix(1)).capitalized + dropFirst()
    }
}

class ARDashboardController: UIViewController, ARSCNViewDelegate , ARVideoControlsDelegate, WebViewDelegate {
    var sceneViews: ARSCNView!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var webViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var myWebView: MyWebView!
    @IBOutlet weak var scanningActiveView: UIView!
    @IBOutlet weak var videoControlsView: ARVideoControls!
    @IBOutlet weak var mainView: UIView!
    
    private var imageNode: SCNNode!
    private var videoHolder: SCNNode!
    private var imageAnchor: ARImageAnchor!
    private var videoPlayerNode: SKVideoNode?
    
    private var isVideoLoaded = false
    private var span: Double = 1
    
    private var playerLayer: AVPlayerLayer = AVPlayerLayer()
    private var videoUtils: VideoUtils = VideoUtils()
    private var imageUtils: ImageUtils = ImageUtils()
    private var appUpdate: AppUpdate = AppUpdate()
    private var animationUtils: AnimationUtils = AnimationUtils()
    private var cameraControls: CameraControls = CameraControls()
    private var database: SqliteDatabase = Service.sharedInstance.getDatabase()
    private var jsonUtils: JSONUtils = JSONUtils()
    private var stringUtils: StringUtils = StringUtils()
    private var timeObserver: Any!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scanningActiveView.layer.zPosition = 100
        self.videoControlsView.arDelegate = self
        self.webViewBottomConstraint.constant = -1 * self.view.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSceneView()
    }
    
    func initSceneView() {
        self.sceneViews = ARSCNView()
        self.sceneViews.frame = self.mainView.frame
        self.sceneViews.layer.zPosition = 50
        
        self.sceneViews.isUserInteractionEnabled = false
        self.mainView.addSubview(self.sceneViews)
        self.sceneViews.delegate = self
        self.myWebView.webViewDelegate = self
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = Service.sharedInstance.getARImageSet()
        configuration.maximumNumberOfTrackedImages = 1
        self.sceneViews.session.run(configuration, options: [.resetTracking, .removeExistingAnchors, .stopTrackedRaycasts])
        
        self.runTest()
    }
    
    func runTest() {    }
    
    @IBAction func closeBtnWhileScanning(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        self.imageNode = SCNNode()
        self.imageNode.name = "imageNode"
        findImageAnchorsForVideo(anchor: anchor)
        return self.imageNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd: SCNNode, for: ARAnchor){}
    //    Tells the delegate that a SceneKit node corresponding to a new AR anchor has been added to the scene.
    
    func renderer(_ renderer: SCNSceneRenderer, willUpdate: SCNNode, for: ARAnchor){}
    //    Tells the delegate that a SceneKit node's properties will be updated to match the current state of its corresponding anchor.
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate: SCNNode, for: ARAnchor){}
    //    Tells the delegate that a SceneKit node's properties have been updated to match the current state of its corresponding anchor.
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove: SCNNode, for: ARAnchor){}
    
    @objc func closeWebView() {
        UIView.animate(withDuration: 1.0,
                       animations: {
                        self.webViewBottomConstraint.constant = -1 * self.view.frame.height
        })
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        self.cameraControls.toggleFlashFunc(senderBtn: sender)
    }
    
    @IBAction func goToHelpPage(_ sender: UIButton) {
        self.videoPlayerNode?.pause()
        let storyboard = UIStoryboard(name: "Help", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "Help") as! HelpController
        navigationController?.pushViewController(destination1, animated: true)
    }
    //
    ////    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    ////        let fetchOptions = PHFetchOptions()
    ////        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    ////        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    ////
    ////        if let lastAsset = fetchResult.firstObject {
    ////            let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
    ////            UIApplication.shared.open(url)
    ////        }
    ////    }
    //
    //
    func openShareUI() {
        self.playerLayer.player!.pause()
        self.videoControlsView.pauseFunc()
        let shareVideoCls = ShareVideo(imageName:self.imageAnchor.referenceImage.name!, parentView: self.view )
        let activityVC: UIActivityViewController = shareVideoCls.createShareUI()
        
        activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                self.animationUtils.showWithAnimation(myView: self.videoControlsView, delay: 0.4)
                //                self.playerLayer.player!.play()
                return
            }
            // User completed activity
        }
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        
        
        self.present(activityVC, animated: true, completion: {
            print("view dismissed")
        })
    }
    
    func openLink() {
        self.playerLayer.player!.pause()
        self.videoControlsView.pauseFunc()
        let currentJson: JSONUtils.imagesEntry = self.jsonUtils.getImageDetailsFromJSON(json: Service.sharedInstance.appConfiguration, imageName: self.imageAnchor!.referenceImage.name!)
        print(self.imageAnchor!.referenceImage.name!)
        self.myWebView.loadUrl(url: currentJson.url, title: currentJson.title)
        UIView.animate(withDuration: 2.0,
                       delay: 0.0,
                       options: [],
                       animations: {
                        self.myWebView.isHidden = false
                        self.webViewBottomConstraint.constant = 0
        })
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.sceneViews.session.pause()
        self.sceneViews.removeFromSuperview()
        self.sceneViews = nil
    }
    
    func addVideoToAnchor(imageAnchors: ARImageAnchor) {
        let imageName = imageAnchors.referenceImage.name
        let currentImgJson = self.jsonUtils.getImageDetailsFromJSON(json: Service.sharedInstance.appConfiguration, imageName: imageName!)
        //        print(UIDevice().identifierForVendor?.uuidString ?? "", "Device name")
        self.setupVideo(videoURL: serverURL + currentImgJson.videoLink)
        self.isVideoLoaded = true
    }
    
    
    func setupVideo(videoURL: String) {
        let videoPlayer  = AVPlayer(url: URL(string: videoURL)!)
        videoPlayer.volume = 10
        self.playerLayer.player = videoPlayer
        
        DispatchQueue.main.async {
            self.playerLayer.frame = self.overlayView.bounds
            self.playerLayer.videoGravity = .resizeAspect
            self.overlayView.layer.addSublayer(self.playerLayer)
            
            var spriteKitScene: SKScene!
            spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
            spriteKitScene.scaleMode = .aspectFit
            
            //initialize video node
            self.videoPlayerNode = self.videoUtils.createVideoPlayerNode(videoPlayer: self.playerLayer.player!, spriteKitScene: spriteKitScene)
            let gesture1 = UITapGestureRecognizer(target: self, action:  #selector(self.togglePlaybackControlsVisibility))
            self.videoControlsView.addGestureRecognizer(gesture1)
            
            spriteKitScene.addChild(self.videoPlayerNode!)
            spriteKitScene.name = "spriteKitScene"
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.togglePlaybackControlsVisibility))
            self.overlayView.addGestureRecognizer(gesture)
            self.videoHolder = self.videoUtils.createVideoHolderOverImage(referenceImage: self.imageAnchor.referenceImage, spriteKitScene: spriteKitScene)
            
            self.videoPlayerNode?.play()
            self.videoControlsView.videoPlaying = true
            self.setVideoPlaybackTime()
            self.imageNode.addChildNode(self.videoHolder)
        }
    }
    
    func setVideoPlaybackTime() {
        if let currentItem = self.playerLayer.player?.currentItem {
            self.videoControlsView.setTotalVideoTime(currentItem: currentItem)
        }
        DispatchQueue.main.async {
            self.addPeriodicTimeObserver()
        }
    }

    func addPeriodicTimeObserver() {
        // Invoke callback every half second
        let interval = CMTime(seconds: 1,  preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Add time observer
        self.timeObserver = self.playerLayer.player!.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {
            [weak self] time in
            self?.videoControlsView.sliderObserver(time: time)
        }
    }
    
    func playerSeekTo(time: CMTime) {
        self.playerLayer.player!.seek(to: time)
    }
    
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
                self.animationUtils.hideWithAnimation(myView: self.scanningActiveView, delay: 0.5)
                self.animationUtils.showWithAnimation(myView: self.videoControlsView, delay: 0.4)
                
                self.videoControlsView.checkIfVideoIsFavourited(imageName: imageAnchors.referenceImage.name!)
            }
        }
    }
    //
    func toggleFavorite() {
        let imageName = self.imageAnchor.referenceImage.name
        let currentJson: JSONUtils.imagesEntry = self.jsonUtils.getImageDetailsFromJSON(json: Service.sharedInstance.appConfiguration, imageName: imageName!)
        let toggleSuccess = self.database.toggleFavEntry(n: currentJson.title, l: currentJson.url, p: currentJson.imageName, v: currentJson.videoLink)
        if (!toggleSuccess) {
            print("Error")
        }
    }
    
    @objc func togglePlaybackControlsVisibility(sender : UITapGestureRecognizer) {
        self.videoControlsView.toogleControlsWithAnimations()
    }
    //
    func closeVideo() {
        self.animationUtils.hideWithAnimation(myView: self.videoControlsView, delay: 0.2)
        self.animationUtils.showWithAnimation(myView: self.scanningActiveView, delay: 0.2)
        self.imageAnchor = nil
 
        self.playerLayer.player!.removeTimeObserver(self.timeObserver!)
        self.timeObserver = nil
        
        self.playerLayer.player?.pause() // 1. pause the player to stop it
        self.playerLayer.player = nil // 2. set the playerLayer's player to nil
        self.playerLayer.removeFromSuperlayer() // 3 remove the playerLayer from it's
        self.videoPlayerNode?.removeAllActions()
        self.videoPlayerNode?.removeAllChildren()
        self.imageNode.enumerateChildNodes(){
            (node, nil) in
            node.removeFromParentNode()
        }
        self.videoPlayerNode?.removeFromParent()
        
        self.sceneViews.session.pause()
        self.sceneViews.removeFromSuperview()
        self.sceneViews = nil
        self.initSceneView()
    }
    
    func togglePlayPause() {
        if (self.videoPlayerNode !== nil) {
            if (self.playerLayer.player != nil && self.playerLayer.player!.rate != 0){
                self.videoPlayerNode?.pause()
            } else {
                self.videoPlayerNode?.play()
            }
        }
        
    }
    
    //   Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if (self.isVideoLoaded) {
            if (span > 1) {
                if (self.imageNode != nil ) {
                    //&& self.imageNode.childNodes.count > 0
                    if let pointOfView = self.sceneViews.pointOfView {
                        let imgBbox = self.imageNode.boundingBox
                        let povBbox = pointOfView.boundingBox
                        let empty = SCNVector3Zero
                        let isImageAnchorHidden = SCNVector3EqualToVector3(imgBbox.max , empty) && SCNVector3EqualToVector3(imgBbox.min , empty) && SCNVector3EqualToVector3(povBbox.min , empty) &&  SCNVector3EqualToVector3(povBbox.max , empty)
                        
                        if (!isImageAnchorHidden){
                            self.hideOverlayVideo()
                            
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                                self.showOverlayVideo()
                            }
                        }
                    }
                }
                span = 0
            } else {
                span = span + 0.5
            }
        }
    }
    
    func hideOverlayVideo() {
        DispatchQueue.main.async {
            if (!self.overlayView.isHidden) {
                self.overlayView.isHidden = true
            }
        }
    }
    
    func showOverlayVideo() {
        DispatchQueue.main.async {
            if (self.overlayView.isHidden) {
                self.overlayView.isHidden = false
            }
        }
    }
    
}
