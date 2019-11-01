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

class VideoPlayerController: UIViewController {
    var serverURL: String = "https://txfipdev.tfs.tamu.edu/treeselector/"
    var photoName: String = "fpd.png"
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var avpController = AVPlayerViewController()
    var isVideoPlaying: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVideo()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func togglePlayPause(_ sender: Any) {
        if (!self.isVideoPlaying) {
            self.player.play()
        } else {
            self.player.pause()
        }
        self.isVideoPlaying = !self.isVideoPlaying
    }
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func setupVideo() {
        let url = URL(string: serverURL + "fpd.mp4")
        self.player = AVPlayer(url: url!)
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer.frame = self.view.bounds
        self.playerLayer.zPosition = 10
        self.view.layer.addSublayer(playerLayer)
        self.view.layer.zPosition = 10
        self.player.play()
        self.isVideoPlaying = true
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
        }) { (context) in
            self.playerLayer.frame.size = size
        }
    }
    
}
