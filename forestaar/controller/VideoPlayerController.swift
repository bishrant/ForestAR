//
//  VideoPlayerController.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 11/1/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import WebKit

class VideoPlayerController: UIViewController, WebViewDelegate {
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var videoSlider: CustomSlider!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var videoControls: UIView!
    @IBOutlet weak var webViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var myWebView: MyWebView!
    
    var imageName: String!
    var folderName: String!
    var videoLink: String!
    var sharingText: String!
    var player: AVPlayer = AVPlayer()
    var playerLayer: AVPlayerLayer!
    var avpController = AVPlayerViewController()
    var observationVideoPlay: NSKeyValueObservation?
    var jsonUtils: JSONUtils = JSONUtils()
    var customWebV: UIView = UIView()
    var customWebView: WKWebView = WKWebView()
    var currentJson: ARImageEntry!;
    
    private var showHideControlsTask: DispatchWorkItem?
    private var stringUtils: StringUtils = StringUtils()
    private var customVideoPlayer: CustomVideoPlayer!
    private var totalTime: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        self.showHideControlsTask = DispatchWorkItem {
            self.toogleControlsWithAnimations(videoControlsView: self.videoControls)
        }
        self.setupVideo();
        let im = self.folderName + "___" + self.imageName
        self.currentJson = self.jsonUtils.getImageDetailsFromJSON(json: Service.sharedInstance.appConfiguration, imageName: im)
        self.view.isUserInteractionEnabled = true
        initWebViewBtns()
        self.myWebView.webViewDelegate = self
    }
    
    @objc func closeWebView() {
        UIView.animate(withDuration: 1.0,
                       animations: {
                        self.webViewBottomConstraint.constant = -1 * self.view.frame.height
        })
    }
    
    @objc func shareURL(title: String, url: URL, sourceItem: UIBarButtonItem) {
        let objectsToShare: [Any] = [title, url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
        activityVC.popoverPresentationController?.barButtonItem = sourceItem
        present(activityVC, animated: true, completion: nil)        
    }
    
    
    func initWebViewBtns() {
        self.webViewBottomConstraint.constant = -1 * self.view.frame.height
    }
    
    @IBAction func openWebPage(_ sender: Any) {
        self.customVideoPlayer.pauseVideo()
        self.myWebView.loadUrl(url: currentJson.url, title: self.currentJson.title)
         UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       options: [],
                       animations: {
                        self.webViewBottomConstraint.constant = 0
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.customVideoPlayer.pauseVideo()
        self.player = AVPlayer()
    }
    
    @IBAction func shareVideo(_ sender: Any) {
        self.customVideoPlayer.pauseVideo();
        favCreateShareActionBar(imageName: self.imageName, message: self.sharingText, folderName: self.folderName, title: self.currentJson!.title)
        
        
//        let shareVideoCls = ShareVideo(imageName:self.imageName, folderName: self.folderName, videoLink: self.videoLink, sharingText: self.sharingText, parentView: self.view )
//        let activityVC: UIActivityViewController = shareVideoCls.createShareUI(pView: self.view);
//        activityVC.view.autoresizingMask = [.flexibleHeight, .flexibleBottomMargin];
//        self.view.autoresizingMask = [.flexibleHeight]
//        let items = [URL(string: "https://www.apple.com")!]
//        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//        ac.popoverPresentationController?.sourceView = self.view;
//        self.present(ac, animated: true)

        
//        self.present(activityVC, animated: true, completion: nil)
    }
    func startObserving() {
        self.observationVideoPlay =
            self.player.observe(\AVPlayer.timeControlStatus, options: [.initial, .new]) { [unowned self]
                (player, change) in
                self.customVideoPlayer!.setPlayPauseButtonImage()
        }
    }
    
    
    @IBAction func togglePlayPause(_ sender: Any) {
        self.customVideoPlayer.togglePlayPause()
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func setupVideo() {
        let urlString = Service.sharedInstance.serverURL + "public/" + self.folderName + "/" + self.videoLink;
        let url = URL(string: urlString)
        self.player.replaceCurrentItem(with: AVPlayerItem(url: url!))
        self.player = AVPlayer(url: url!)
        self.player.volume = 0.6
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer.frame = self.view.bounds
        self.playerLayer.zPosition = 10
        
        self.view.layer.addSublayer(playerLayer)
        self.view.layer.zPosition = 10
        self.player.play()
        self.customVideoPlayer = CustomVideoPlayer(player: self.player, playPauseBtn: self.playPauseBtn, videoSlider: self.videoSlider, totalTimeLbl: self.totalTimeLbl, currentTimeLbl: self.currentTimeLbl)
        self.startObserving()
        self.customVideoPlayer.setVideoPlaybackTime()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: self.showHideControlsTask!)
        self.customVideoPlayer.isVideoPlaying = true
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.togglePlaybackControlsVisibility))
        self.view.addGestureRecognizer(gesture)
        
        let tapGestureRecognizerVP = UITapGestureRecognizer(target: self, action: #selector(videoSliderTapped(gestureRecognizer:)))
        self.videoSlider.addGestureRecognizer(tapGestureRecognizerVP)
        
//        self.videoControlsView.videoSlider.addTarget(self, action: #selector(sliderValChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func videoSliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.videoSlider.superview)

        let positionOfSlider: CGPoint = self.videoSlider.frame.origin
        let widthOfSlider: CGFloat =  self.videoSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat( self.videoSlider.maximumValue) / widthOfSlider)

        self.videoSlider.setValue(Float(newValue), animated: true)
        self.customVideoPlayer.sliderChangedFunc()
//        self.videoControlsView.sliderChanged()
//
     }
    
    @objc func togglePlaybackControlsVisibility(sender : UITapGestureRecognizer) {
        self.showHideControlsTask?.perform()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
        }) { (context) in
            self.playerLayer.frame.size = size
            if (self.webViewBottomConstraint.constant < 0) {
                self.webViewBottomConstraint.constant = -1 * self.view.frame.height
            }
        }
    }
    
    
    func toogleControlsWithAnimations(videoControlsView: UIView) {
        if (videoControlsView.isHidden) {
            UIView.animate(withDuration: 0.2, animations: {
                videoControlsView.alpha = 100;
            }, completion: { _ in
                videoControlsView.isHidden = false
            })
            self.showHideControlsTask!.cancel()
            self.showHideControlsTask = DispatchWorkItem {
                self.toogleControlsWithAnimations(videoControlsView: self.videoControls)
            }
            // execute task in 10 seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: self.showHideControlsTask!)
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                videoControlsView.alpha = 0;
            }, completion: { _ in
                videoControlsView.isHidden = true // Here you hide it when animation done
            })
            self.showHideControlsTask!.cancel()
            self.showHideControlsTask = DispatchWorkItem {
                self.toogleControlsWithAnimations(videoControlsView: self.videoControls)
            }
        }
    }
    
}

extension NSLayoutConstraint {

    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
