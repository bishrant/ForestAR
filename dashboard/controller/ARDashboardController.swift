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


class ARDashboardController: UIViewController, ARSCNViewDelegate {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        let appUpdate: AppUpdate = AppUpdate()
        _ = appUpdate.checkAppUpdate()
        self.appConfiguration = appUpdate.getAppJSON()
        let arImageUtils: ARImageUtils = ARImageUtils()
        self.arImageSet = arImageUtils.loadedImagesFromDirectoryContents()
        
        // spritekit and position
        self.spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        self.spriteKitScene.scaleMode = .aspectFit
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configuration = ARImageTrackingConfiguration()
        self.configuration.trackingImages = self.arImageSet
        self.configuration.maximumNumberOfTrackedImages = 1
//        // Run the view's session
        sceneView.session.run(self.configuration, options: [.resetTracking, .removeExistingAnchors])
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
                
                self.videoPlayerNode = self.videoUtils.createVideoPlayerNode(videoPlayer: videoPlayer, spriteKitScene: self.spriteKitScene)

                
                self.spriteKitScene.addChild(self.videoPlayerNode!)
                self.spriteKitScene.name = "spriteKitScene"
                
                let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.togglePlaybackControlsVisibility))
                self.overlayView.addGestureRecognizer(gesture)
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
                self.addVideoToAnchor(imageAnchors: imageAnchors)
               // self.forcefullyClosedVideo = false
              //  self.isVideoPausedByUser = false
            }
        }
    }
    
    @objc func togglePlaybackControlsVisibility(sender : UITapGestureRecognizer) {
        print("toggle playback controls visibility");
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
