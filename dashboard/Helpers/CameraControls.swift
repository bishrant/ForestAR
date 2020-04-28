//
//  CameraControls.swift
//  LivePortraitSimulator
//
//  Created by Adhikari, Bishrant on 6/27/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraControls {
    // toggle flash
    func toggleFlashFunc(senderBtn: UIButton) -> Bool{
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false}
        guard device.hasTorch else { return false}
        
        do {
            try device.lockForConfiguration()
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
        DispatchQueue.main.async {
            let imgName = self.isFlashActive() ? "flashOn" : "flashOff"
            senderBtn.setBackgroundImage(UIImage(named: imgName), for: UIControl.State.normal)
        }
        return device.torchMode == AVCaptureDevice.TorchMode.on
        
    }
    

    
    func isFlashActive() -> Bool {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false }
        guard device.hasTorch else { return false}
        return device.torchMode == AVCaptureDevice.TorchMode.on
    }
    

}
