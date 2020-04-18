//
//  WeatherLocalData+CoreDataProperties.swift
//  
//
//  Created by Sandesh on 18/04/20.
//
//

import Foundation
import CoreData


extension WeatherLocalData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherLocalData> {
        return NSFetchRequest<WeatherLocalData>(entityName: "WeatherLocalData")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var temp: Int16
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var timezone: Float

}
