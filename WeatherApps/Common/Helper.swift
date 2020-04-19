//
//  Helper.swift
//  WeatherApps
//
//  Created by Sandesh on 17/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//


import Foundation
import Alamofire

func isConnectedToInternet() -> Bool {
    return NetworkReachabilityManager()!.isReachable
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}


let mf = MeasurementFormatter()
func convertTemp(temp: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> String {
    mf.numberFormatter.maximumFractionDigits = 0
    mf.unitOptions = .providedUnit
    let input = Measurement(value: temp, unit: inputTempType)
    let output = input.converted(to: outputTempType)
    return mf.string(from: output)
}


