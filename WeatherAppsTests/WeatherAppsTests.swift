//
//  WeatherAppsTests.swift
//  WeatherAppsTests
//
//  Created by Sandesh on 19/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import XCTest
@testable import WeatherApps

class WeatherAppsTests: XCTestCase {
    
    var weatherDataModel:  WeatherData!
    var weatherViewModel: WeatherViewModel!
    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        weatherDataModel = WeatherData(coord: Coord(lon: 0.0, lat: 0.0), main: Main(temp: 0.0), timezone: 1300, name: "Delhi")
               
        weatherViewModel = WeatherViewModel.init(weatherData: weatherDataModel)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInitializationWithModel() {
     
         XCTAssertNotNil(weatherViewModel, "Weather View model should not be nil")
     
        XCTAssertTrue(weatherViewModel.name == weatherDataModel.name, "Weather View model city name should be equal to weather data model name" )
     }

}
