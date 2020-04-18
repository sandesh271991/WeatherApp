//
//  WeatherViewModel.swift
//  WeatherApps
//
//  Created by Sandesh on 18/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import Foundation
import UIKit


class WeatherViewModel: NSObject {
    var weatherData: WeatherData?
    
    var name: String {
        return weatherData?.name ?? "Name Unknown"
    }
    
    var coord: Coord {
        return weatherData?.coord ?? Coord(lon: 0.0, lat: 0.0)
    }
    
    var temp: Main {
        return weatherData?.main ?? Main(temp: 0.0)
    }
    
    var time: Int {
        return weatherData?.timezone ?? 0
    }
    
    
    init(weatherData: WeatherData) {
        self.weatherData = weatherData
    }
}
