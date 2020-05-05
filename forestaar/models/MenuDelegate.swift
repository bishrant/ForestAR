//
//  MenuProtocol.swift
//  forestaar
//
//  Created by Adhikari, Bishrant on 11/12/19.
//  Copyright © 2019 Adhikari, Bishrant. All rights reserved.
//

import Foundation

protocol MenuDelegate {
    func menuSelected(menuName: String)
    func menuClosed()
}
