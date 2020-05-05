//
//  VideoUtils.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 10/25/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import SceneKit
import UIKit
import ARKit

class VideoUtils {
    
    init() {
        
    }
    func createVideoHolderOverImage(referenceImage: ARReferenceImage, spriteKitScene: SKScene) -> SCNNode {
    //        let referenceImage = imageAnchorVal.referenceImage
            let width = CGFloat(referenceImage.physicalSize.width)
            let height = CGFloat(referenceImage.physicalSize.height)
            
            let videoHolder = SCNNode()
            videoHolder.name = "videoHolder"
            let videoHolderGeometry = SCNPlane(width: width, height: height)
            videoHolder.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            videoHolder.geometry = videoHolderGeometry
            videoHolder.position = SCNVector3(0, 0, 0)
            videoHolder.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
            
            return videoHolder
        }
    
    func createVideoPlayerNode(videoPlayer: AVPlayer, spriteKitScene: SKScene) -> SKVideoNode {
        let videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        videoPlayerNode.size = spriteKitScene.size
        videoPlayerNode.zPosition = 1000000
        videoPlayerNode.name = "videoNode"
        return videoPlayerNode
                    
    }
}
