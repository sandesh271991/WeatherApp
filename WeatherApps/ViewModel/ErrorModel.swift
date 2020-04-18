//
//  ErrorModel.swift
//  WeatherApps
//
//  Created by Sandesh on 18/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import Foundation

// MARK: - Error
struct Errors: Codable {
    let cod, message: String
}
