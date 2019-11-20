//
//  ARVideoControlsDelegate.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 11/13/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import AVKit

protocol ARVideoControlsDelegate {
    func closeVideo()
    func togglePlayPause()
    func toggleFavorite()
    func openShareUI()
    func openLink()
    func playerSeekTo(time: CMTime)
    func goToHome()
}
