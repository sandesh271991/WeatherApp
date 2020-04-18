//
//  NewCityVC.swift
//  WeatherApps
//
//  Created by Sandesh on 18/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import UIKit

protocol getCityDelegate:AnyObject {
    func getCity(cityName: String)
}

class NewCityVC: UIViewController {

    @IBOutlet weak var txtAddCity: UITextField!
    weak var delegate: getCityDelegate?

        
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    @IBAction func btnDone(_ sender: Any) {
        if txtAddCity.text != "" {
            self.delegate?.getCity(cityName: txtAddCity.text!)
        }
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
