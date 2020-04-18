//
//  ViewController.swift
//  WeatherApps
//
//  Created by Sandesh on 17/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var weatherViewModel: WeatherViewModel?
    var weatherData: WeatherData? {
        
        didSet {
        guard let weatherData = weatherData else { return }
            weatherViewModel = WeatherViewModel.init(weatherData: weatherData)
                
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    //View LifeCycle
    override func viewWillAppear(_ animated: Bool) {
    
        self.fetchData()
//        tableView?.rowHeight = UITableView.automaticDimension
//        tableView?.estimatedRowHeight = 65.0

    }
    
    
    func updateView() {
        print("City name = \(self.weatherViewModel?.name ?? "No name")")
        print("Temp name = \(self.weatherViewModel?.temp.temp ?? 0.0)")

       // self.tableView?.reloadData()
    }

    @objc func fetchData() {
        if isConnectedToInternet() == true {
            Webservice.shared.getData(with: webserviceURL) { (countryData, error) in
                if error != nil {
                    return
                }
                guard let countryData = countryData else {return}
                self.weatherData = countryData
            }
        } else {
            showAlert(title: "No Internet Connection", message: "Please check your internet connection")
        }
    }

}

