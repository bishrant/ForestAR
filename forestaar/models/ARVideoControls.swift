//
//  ARVideoControls.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 11/13/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import AVKit

class ARVideoControls: UIView {
    @IBOutlet weak var videoControlsView: UIView!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var videoSlider: CustomSlider!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    
    @IBOutlet weak var videoPlayingFlashBtn: UIButton!
    
    private var showHideControlsTask: DispatchWorkItem?
    private var stringUtils: StringUtils = StringUtils()
    
    @IBOutlet weak var videoPlayerSlider: UISlider!
    
    var arDelegate: ARVideoControlsDelegate?
    var videoPlaying: Bool = false
    var totalTime: Double!
    private var isVideoFavorited: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setBackgroundImage(button: self.favBtn, imageName: "favBtn")
        self.commonInit()
        
    }
    
    @IBAction func gotoHome(_ sender: Any) {
        self.arDelegate!.goToHome()
    }
    
    @objc func videoSliderTapped(gestureRecognizer: UIGestureRecognizer) {
         let pointTapped: CGPoint = gestureRecognizer.location(in: self.videoPlayerSlider.superview)
         let positionOfSlider: CGPoint = self.videoPlayerSlider.frame.origin
         let widthOfSlider: CGFloat =  self.videoPlayerSlider.frame.size.width
         let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat( self.videoPlayerSlider.maximumValue) / widthOfSlider)

          self.videoPlayerSlider.setValue(Float(newValue), animated: true)
     }
    
    
    @IBAction func closeVideo(_ sender: Any) {
        self.playPauseBtn.setBackgroundImage(UIImage(named: "pause"), for: UIControl.State.normal)
        self.videoPlaying = false
        self.isVideoFavorited = false
        self.setBackgroundImage(button: self.favBtn, imageName: "favBtn")
        self.arDelegate?.closeVideo()
    }
    
    @IBAction func toggleFavorite(_ sender: UIButton) {
        let btnName = self.isVideoFavorited ? "favBtn": "favBtnActive"
        self.setBackgroundImage(button: sender, imageName: btnName)
        self.isVideoFavorited.toggle()
        self.arDelegate?.toggleFavorite()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func pauseFunc() {
        self.playPauseBtn.setBackgroundImage(UIImage(named: "play"), for: UIControl.State.normal)
        self.videoPlaying = false
    }
    
    @IBAction func togglePlayPause(_ sender: UIButton) {
        self.togglePlayPauseFunc()
    }
    
    func togglePlayPauseFunc() {
        let newImage = self.videoPlaying ? "play" : "pause"
        self.playPauseBtn.setBackgroundImage(UIImage(named: newImage), for: UIControl.State.normal)
        self.videoPlaying.toggle()
        self.arDelegate?.togglePlayPause()
    }

    
    @IBOutlet weak var shareVideoBtn: UIButton!
    private func commonInit() {
        self.showHideControlsTask = DispatchWorkItem {
            self.toogleControlsWithAnimations()
        }
        
        Bundle.main.loadNibNamed("ARVideoControls", owner: self, options: nil)
        guard let content = videoControlsView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: self.showHideControlsTask!)
    }
    
    func toogleControlsWithAnimations() {
        if (videoControlsView.isHidden) {
            UIView.animate(withDuration: 0.2, animations: {
                self.videoControlsView.alpha = 100;
            }, completion: { _ in
                self.videoControlsView.isHidden = false
            })
            self.showHideControlsTask!.cancel()
            self.showHideControlsTask = DispatchWorkItem {
                self.toogleControlsWithAnimations()
            }
            
            // execute task in 10 seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: self.showHideControlsTask!)
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.videoControlsView.alpha = 0;
            }, completion: { _ in
                self.videoControlsView.isHidden = true // Here you hide it when animation done
            })
            self.showHideControlsTask!.cancel()
            self.showHideControlsTask = DispatchWorkItem {
                self.toogleControlsWithAnimations()
            }
            
        }
    }
    
    func checkIfVideoIsFavourited(imageName: String) {
        var db: SqliteDatabase!
        db = SqliteDatabase()
        let imgSplit = imageName.components(separatedBy: "___")
        if(db.getFavouritesCount(imageName: imgSplit[1], folderName: imgSplit[0]) > 0) {
            self.isVideoFavorited = true
            self.setBackgroundImage(button: self.favBtn, imageName: "favBtnActive")
        }
        db = nil
    }
    
    func setBackgroundImage(button: UIButton, imageName: String) {
        DispatchQueue.main.async {
            button.setBackgroundImage(UIImage(named: imageName), for: UIControl.State.normal)
        }
    }
    
    @IBAction func openLink(_ sender: Any) {
        self.arDelegate?.openLink()
    }
    
    @IBAction func openShareUI(_ sender: Any) {
        self.arDelegate?.openShareUI()
    }
    
    func setTotalVideoTime(currentItem: AVPlayerItem) {
        let duration = currentItem.asset.duration.seconds
        self.totalTime = duration
        DispatchQueue.main.async {
            self.videoSlider.setValue(0, animated: true)
            self.totalTimeLbl.text = self.stringUtils.stringFromTimeInterval(interval: duration)
        }
    }
    
    func sliderObserver(time: CMTime) {
        let t = self.totalTime
        let sliderVal = Float (time.seconds / t!)
        self.videoSlider.value = sliderVal
        self.currentTimeLbl.text = self.stringUtils.stringFromTimeInterval(interval: time.seconds)
        if (time.seconds >= t!) {
            self.playerDidFinishPlaying()
        }
    }
    
    func removeVideoSliderTarget() {
        DispatchQueue.main.async {
            self.videoSlider.setValue(0, animated: true)
        }
    }
    
    func playerDidFinishPlaying() {
        let currentSlidedTime = 1
        let cmTime =  CMTimeMakeWithSeconds(Float64(currentSlidedTime), preferredTimescale: 10)
        self.arDelegate?.playerSeekTo(time: cmTime)
        self.togglePlayPauseFunc()
    }
    
    func sliderChanged() {
        let currentSlidedTime = Int(self.videoSlider.value * Float(self.totalTime))
        let cmTime =  CMTimeMakeWithSeconds(Float64(currentSlidedTime), preferredTimescale: 10)
        self.arDelegate?.playerSeekTo(time: cmTime)
    }
}
