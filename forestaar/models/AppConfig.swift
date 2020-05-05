//
//  AppConfig.swift
//  forestaar
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
    let title: String
    let imageName: String
    let url: String
    let videoLink: String
    let physicalHeight: Float
    let physicalWidth: Float
    let updateDate: String
    let sharingText: String
    let description: String
    let folderName: String
    let userEmail: String
}
