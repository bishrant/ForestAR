//
//  Service.swift
//  dashboard
//
//  Created by Adhikari, Bishrant on 10/29/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation
import ARKit
struct AppService {
    static let sharedAppService: AppService = AppService();
    public var config: AppConfigJSON!;
    private init() {}
    
    public mutating func SetAppConfig(config: AppConfigJSON) {
        self.config = config;
    }
}


