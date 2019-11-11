//
//  VideoPlayerController.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/1/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import WebKit

class VideoPlayerController: UIViewController {
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var videoSlider: CustomSlider!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var videoControls: UIView!
    var photoName: String = "fpd.png"
    var player: AVPlayer = AVPlayer()
    var playerLayer: AVPlayerLayer!
    var avpController = AVPlayerViewController()
    var observationVideoPlay: NSKeyValueObservation?
    var jsonUtils: JSONUtils = JSONUtils()
    
    var customWebV: UIView = UIView()
    var customWebView: WKWebView = WKWebView()
    
    @IBOutlet weak var webViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var myWebView: MyWebView!

    private var showHideControlsTask: DispatchWorkItem?
    private var stringUtils: StringUtils = StringUtils()
    private var customVideoPlayer: CustomVideoPlayer!
    private var totalTime: Double!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showHideControlsTask = DispatchWorkItem {
            self.toogleControlsWithAnimations(videoControlsView: self.videoControls)
        }
        self.setupVideo()
        view.isUserInteractionEnabled = true
        initWebViewBtns()
        
    }
    
    @objc func closeWebView() {
        UIView.animate(withDuration: 1.0,
                       animations: {self.webViewBottomConstraint.constant = -1 * self.view.frame.height
        })

    }
    
    func initWebViewBtns() {
        self.webViewBottomConstraint.constant = -1 * self.view.frame.height
        self.myWebView.closeWebViewBtn.target = self
        self.myWebView.closeWebViewBtn.action = #selector(closeWebView)
    }
    

    
    func showWebPage() {
        let im = self.photoName.components(separatedBy: ".png")[0]
        let currentJson: JSONUtils.imagesEntry = self.jsonUtils.getImageDetailsFromJSON(json: Service.sharedInstance.appConfiguration, imageName: im)
         
//
//        let currentURL = URL(string: currentJson.url)!
//        webView.load(URLRequest(url: currentURL))
        self.myWebView.loadUrl(url: currentJson.url, title: currentJson.title)
        UIView.animate(withDuration: 1.0,
                      delay: 0.0,
                      options: [],
                      animations: {
                       self.webViewBottomConstraint.constant = 0
       })
    }
    
    @IBAction func openWebPage(_ sender: Any) {
        self.player.pause()
        self.showWebPage()
//        self.webPage.show(webPageView: self.webPage, view: self.view, imageName: self.photoName)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.player.pause()
        self.player = AVPlayer()
    }
    
    @IBAction func shareVideo(_ sender: Any) {
        self.customVideoPlayer.togglePlayPause()
        
        let shareVideoCls = ShareVideo(imageName:self.photoName, parentView: self.view )
        let activityVC: UIActivityViewController = shareVideoCls.createShareUI()
        self.present(activityVC, animated: true, completion: nil)
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
        let url = URL(string: serverURL + "fpd.mp4")
        self.player.replaceCurrentItem(with: AVPlayerItem(url: url!))
        self.player = AVPlayer(url: url!)
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
        
        self.showWebPage()
    }
    
    @objc func togglePlaybackControlsVisibility(sender : UITapGestureRecognizer) {
        self.showHideControlsTask?.perform()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
        }) { (context) in
            self.playerLayer.frame.size = size
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