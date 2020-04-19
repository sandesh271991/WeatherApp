//
//  Validator.swift
//  WeatherApps
//
//  Created by Sandesh on 19/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import Foundation
class Validator {
    
    //check text is empty
    func isEmptyOrNil(string: String?) -> Bool {
        guard let trimmedString = string?.trimmingCharacters(in: NSCharacterSet.whitespaces) else { return false }
        if (trimmedString.isEmpty || string == "") {
            return true
        }
        return false
    }
}
