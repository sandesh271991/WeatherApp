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

