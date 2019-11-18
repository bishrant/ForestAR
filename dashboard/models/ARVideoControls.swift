//
//  ARVideoControls.swift
//  dashboard
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
    
    private var showHideControlsTask: DispatchWorkItem?
    private var database: SqliteDatabase = Service.sharedInstance.getDatabase()
    private var stringUtils: StringUtils = StringUtils()
    
    var arDelegate: ARVideoControlsDelegate?
    var videoPlaying: Bool = false
    var totalTime: Double!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    @IBAction func closeVideo(_ sender: Any) {
        self.arDelegate?.closeVideo()
    }
    
    @IBAction func toggleFavorite(_ sender: UIButton) {
        let btnName = sender.backgroundImage(for: UIControl.State.normal) == UIImage(named: "favBtn") ? "favBtnActive": "favBtn"
        self.setBackgroundImage(button: sender, imageName: btnName)
        
        self.arDelegate?.toggleFavorite()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    @IBAction func togglePlayPause(_ sender: UIButton) {
        let newImage = self.videoPlaying ? "play" : "pause"
        sender.setBackgroundImage(UIImage(named: newImage), for: UIControl.State.normal)
        self.videoPlaying.toggle()
        self.arDelegate?.togglePlayPause()
    }
    
    private func commonInit() {
        self.showHideControlsTask = DispatchWorkItem {
            self.toogleControlsWithAnimations()
        }
        Bundle.main.loadNibNamed("ARVideoControls", owner: self, options: nil)
        guard let content = videoControlsView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    func toogleControlsWithAnimations() {
        if (videoControlsView.isHidden) {
            UIView.animate(withDuration: 0.2, animations: {
                self.videoControlsView.alpha = 100;
            }, completion: { _ in
                self.videoControlsView.isHidden = false
            })
            self.showHideControlsTask!.cancel()
            // execute task in 10 seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: self.showHideControlsTask!)
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.videoControlsView.alpha = 0;
            }, completion: { _ in
                self.videoControlsView.isHidden = true // Here you hide it when animation done
            })
            self.showHideControlsTask!.cancel()
        }
    }
    
    func checkIfVideoIsFavourited(imageName: String) {
        if(self.database.getFavouritesCount(photoName: imageName + ".png") > 0) {
            self.setBackgroundImage(button: self.favBtn, imageName: "favBtnActive")
        }
        
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
        //        self.closeOverlayVideo(nil)
        //  self.playerLayer.player?.pause()
        let currentSlidedTime = 1
        let cmTime =  CMTimeMakeWithSeconds(Float64(currentSlidedTime), preferredTimescale: 10)
        self.arDelegate?.playerSeekTo(time: cmTime)
//        self.player.seek(to: cmTime, completionHandler: {_ in
//            //  self.playerLayer.player?.pause()
//            self.isVideoPlaying.toggle()
//        })
        
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        let currentSlidedTime = Int(self.videoSlider.value * Float(self.totalTime))
        let cmTime =  CMTimeMakeWithSeconds(Float64(currentSlidedTime), preferredTimescale: 10)
        self.arDelegate?.playerSeekTo(time: cmTime)
    }
    
}
