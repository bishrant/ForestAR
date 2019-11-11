//
//  CustomVideoPlayer.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/4/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import UIKit
import AVKit

class CustomVideoPlayer {
    private var player: AVPlayer
    private var playPauseBtn: UIButton
    private var videoSlider: UISlider
    private var totalTimeLbl: UILabel
    private var currentTimeLbl: UILabel
    private var totalTime: Double!
    private var timeObserver: Any!
    private var stringUtils: StringUtils = StringUtils()
    dynamic var isVideoPlaying: Bool = false
    
    init(player: AVPlayer, playPauseBtn: UIButton, videoSlider: UISlider, totalTimeLbl: UILabel,
         currentTimeLbl: UILabel
    ) {
        self.player = player
        self.playPauseBtn = playPauseBtn
        self.videoSlider = videoSlider
        self.totalTimeLbl = totalTimeLbl
        self.currentTimeLbl = currentTimeLbl
    }
    func setPlayPauseButtonImage() {
        DispatchQueue.main.async {
            var buttonImage: UIImage?
            switch self.player.timeControlStatus {
            case .playing:
                buttonImage = UIImage(named: "pause")
            case .paused, .waitingToPlayAtSpecifiedRate:
                buttonImage = UIImage(named: "play")
            @unknown default:
                buttonImage = UIImage(named: "play")
                return
            }
            guard let image = buttonImage else { return }
            self.playPauseBtn.setBackgroundImage(image, for: UIControl.State.normal)
        }
    }
    
    func setVideoPlaybackTime() {
        if let currentItem = self.player.currentItem {
            let duration = currentItem.asset.duration.seconds
            self.totalTime = duration
            DispatchQueue.main.async {
                self.videoSlider.setValue(0, animated: false)
                self.totalTimeLbl.text = self.stringUtils.stringFromTimeInterval(interval: duration)
            }
        }
        
        DispatchQueue.main.async {
            self.addPeriodicTimeObserver()
            self.videoSlider.removeTarget(self, action: #selector(self.sliderChanged), for: UIControl.Event.valueChanged)
            self.videoSlider.addTarget(self, action: #selector(self.sliderChanged), for: UIControl.Event.valueChanged)
        }
    }
    
    @objc func sliderChanged() {
        let currentSlidedTime = Int(self.videoSlider.value * Float(self.totalTime))
        let cmTime =  CMTimeMakeWithSeconds(Float64(currentSlidedTime), preferredTimescale: 10)
        self.player.seek(to: cmTime)
    }
    
    func removePeriodicTimeObserver() {
        // If a time observer exists, remove it
        if let token = timeObserver {
            self.player.removeTimeObserver(token)
            timeObserver = nil
        }
    }
    
    func removeVideoSliderTarget() {
        DispatchQueue.main.async {
            self.videoSlider.setValue(0, animated: false)
            self.videoSlider.removeTarget(self, action: #selector(self.sliderChanged), for: UIControl.Event.valueChanged)
            
        }
    }
    func addPeriodicTimeObserver() {
        // Invoke callback every half second
        let interval = CMTime(seconds: 1,  preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Queue on which to invoke the callback
        let mainQueue = DispatchQueue.main
        
        // Add time observer
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
            [weak self] time in
            let t = self?.totalTime
            let sliderVal = Float (time.seconds / t!)
            
            self?.videoSlider.value = sliderVal
            self?.currentTimeLbl.text = self?.stringUtils.stringFromTimeInterval(interval: time.seconds)
            if (time.seconds >= t!) {
                self?.playerDidFinishPlaying()
            }
        }
    }
    
    @objc func playerDidFinishPlaying() {
        //        self.closeOverlayVideo(nil)
        //  self.playerLayer.player?.pause()
        let currentSlidedTime = 1
        let cmTime =  CMTimeMakeWithSeconds(Float64(currentSlidedTime), preferredTimescale: 10)
        self.player.seek(to: cmTime, completionHandler: {_ in
            //  self.playerLayer.player?.pause()
            self.isVideoPlaying.toggle()
        })
        
    }
    
    func togglePlayPause() {
        if (!self.isVideoPlaying) {
            self.player.play()
        } else {
            self.player.pause()
        }
        self.isVideoPlaying.toggle()
    }
}

