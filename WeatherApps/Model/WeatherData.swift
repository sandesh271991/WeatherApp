//
//  WeatherData.swift
//  WeatherApps
//
//  Created by Sandesh on 17/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct WeatherData: Codable {
    let coord: Coord
    let main: Main
    let timezone: Int
    let name: String
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp: Double

    enum CodingKeys: String, CodingKey {
        case temp
    }
}

