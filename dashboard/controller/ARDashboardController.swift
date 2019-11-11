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

extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
    var firstCapitalized: String {
        return String(prefix(1)).capitalized + dropFirst()
    }
}

class ARDashboardController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    private var spriteKitScene: SKScene!
    
    private var imageNode: SCNNode!
    private var videoHolder: SCNNode!
    private var imageAnchor: ARImageAnchor!
    private var videoPlayerNode: SKVideoNode?
    
    private var configuration: ARImageTrackingConfiguration!
    
    
    @IBOutlet weak var favBtn: UIButton!
    private var playerLayer: AVPlayerLayer = AVPlayerLayer()
    private var videoUtils: VideoUtils = VideoUtils()
    private var imageUtils: ImageUtils = ImageUtils()
    private var appUpdate: AppUpdate = AppUpdate()
    private var animationUtils: AnimationUtils = AnimationUtils()
    private var cameraControls: CameraControls = CameraControls()
    private var database: SqliteDatabase = SqliteDatabase()
    private var jsonUtils: JSONUtils = JSONUtils()
    @IBOutlet weak var overlayView: UIView!
    private var showHideControlsTask: DispatchWorkItem?
    @IBOutlet weak var videoControls: UIView!
    @IBOutlet weak var scanningActiveView: UIView!
    @IBOutlet weak var videoControlsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // spritekit and position
        self.spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        self.spriteKitScene.scaleMode = .aspectFit
        
        self.showHideControlsTask = DispatchWorkItem {
            self.toogleControlsWithAnimations(videoControlsView: self.videoControls)
        }
    }
    
    @IBAction func closePlayingVideo(_ sender: UIButton) {
        self.animationUtils.hideWithAnimation(myView: self.videoControlsView, delay: 0.2)
        self.animationUtils.showWithAnimation(myView: self.scanningActiveView, delay: 0.2)
        self.imageAnchor = nil
        self.sceneView.session.run(self.configuration, options: [.removeExistingAnchors, .resetTracking])
        
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
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        self.cameraControls.toggleFlashFunc(senderBtn: sender)
    }
    
    @IBAction func closeBtnWhileScanning(_ sender: UIButton) {
        self.videoPlayerNode?.pause()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goToHelpPage(_ sender: UIButton) {
        self.videoPlayerNode?.pause()
        
        let storyboard = UIStoryboard(name: "Help", bundle: Bundle.main)
        let destination1 = storyboard.instantiateViewController(withIdentifier: "Help") as! HelpController
        navigationController?.pushViewController(destination1, animated: true)
        
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
    public func postToInstagram(imageName: String) {
        let instaImage = imageUtils.getImageFromFileName(name: imageName)
        UIImageWriteToSavedPhotosAlbum(instaImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    @IBAction func shareVideo(_ sender: UIButton) {
        let shareVideoCls = ShareVideo(imageName:self.imageAnchor.referenceImage.name!, parentView: self.view )
        let activityVC: UIActivityViewController = shareVideoCls.createShareUI()
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configuration = ARImageTrackingConfiguration()
        self.configuration.trackingImages = Service.sharedInstance.getARImageSet()
        self.configuration.maximumNumberOfTrackedImages = 1
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
        
        let serverURL = "https://txfipdev.tfs.tamu.edu/treeselector/"
        let currentImgJson = self.jsonUtils.getImageDetailsFromJSON(json: Service.sharedInstance.appConfiguration, imageName: imageName!)
        //        print(imageName!, "found");
        //        print(UIDevice().identifierForVendor?.uuidString ?? "", "Device name")
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
    
    func checkIfVideoIsFavourited(imageName: String) {
        if(self.database.getFavouritesCount(photoName: imageName + ".png") > 0) {
            self.setBackgroundImage(button: self.favBtn, imageName: "favBtnActive")
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
                
                self.checkIfVideoIsFavourited(imageName: imageAnchors.referenceImage.name!)
                
                // self.forcefullyClosedVideo = false
                //  self.isVideoPausedByUser = false
            }
        }
    }
    func setBackgroundImage(button: UIButton, imageName: String) {
        DispatchQueue.main.async {
            button.setBackgroundImage(UIImage(named: imageName), for: UIControl.State.normal)
        }
    }
    
    @IBAction func favouriteVideoAction(_ sender: UIButton) {
        let btnName = sender.backgroundImage(for: UIControl.State.normal) == UIImage(named: "favBtn") ? "favBtnActive": "favBtn"
        self.setBackgroundImage(button: sender, imageName: btnName)
        
        let imageName = self.imageAnchor.referenceImage.name
        let currentJson: JSONUtils.imagesEntry = self.jsonUtils.getImageDetailsFromJSON(json: Service.sharedInstance.appConfiguration, imageName: imageName!)
        self.database.toggleFavEntry(n: currentJson.title, l: currentJson.url, p: currentJson.imageName, v: currentJson.videoLink)
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
        
        //        if let imageAnchors = anchor as? ARImageAnchor {
        //            // nothing in the view, first scan recognize image and start loading video
        //            if (self.imageAnchor == nil) {
        //                self.imageAnchor = imageAnchors
        //
        //                // @todo send to analytics server for countinng the number of times an image has been recognized by the app
        //                self.imageAnchor?.setValue(imageAnchors.referenceImage.name, forKey: "name")
        //                self.addVideoToAnchor(imageAnchors: imageAnchors)
        //               // self.forcefullyClosedVideo = false
        //              //  self.isVideoPausedByUser = false
        //            }
        //            //if imageNode is already visible and its achor is same as previous one
        //            else if (self.imageAnchor?.referenceImage.name == imageAnchors.referenceImage.name) {
        ////                if (self.forcefullyClosedVideo) {
        ////                    self.imageAnchor = imageAnchors
        ////                    self.addVideoToAnchor(imageAnchors: imageAnchors)
        ////                    self.forcefullyClosedVideo = false
        ////                    self.isVideoPausedByUser = false
        ////                } else {
        ////                    self.hideOverlayVideo()
        ////                }
        //
        //            } else if (self.imageAnchor?.referenceImage.name != imageAnchors.referenceImage.name) {
        ////                DispatchQueue.main.async {
        ////                    if (self.overlayView.isHidden) {
        ////                        self.addVideoToAnchor(imageAnchors: imageAnchors)
        ////                        self.forcefullyClosedVideo = false
        ////                        self.isVideoPausedByUser = false
        ////                        self.imageAnchor = imageAnchors
        ////                    } else {
        ////                        self.sceneView.session.remove(anchor: anchor)
        ////                    }
        ////                }
        //
        //            }
        //
        //        } else {
        //           // self.isVideoLoaded = false
        //        }
        findImageAnchorsForVideo(anchor: anchor)
        return self.imageNode
    }
    
}
