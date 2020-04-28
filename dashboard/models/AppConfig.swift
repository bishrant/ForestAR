//
//  AppConfig.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 4/27/20.
//  Copyright © 2020 Adhikari, Bishrant. All rights reserved.
//

import Foundation

struct AppConfigJSON: Decodable {
    let images: [ARImageEntry]
    let lastUpdated: Int
    let version: Int
}

// MARK: - Image
struct ARImageEntry: Decodable {
    let id: Int
    let title, imageName: String
    let url: String
    let videoLink: String
    let physicalHeight, physicalWidth: Float
    let updateDate, sharingText, description: String
    let folderName: String
    let userEmail: String
}
