//
//  ViewController+TableViewExtension.swift
//  WeatherApps
//
//  Created by Sandesh on 19/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import Foundation
import UIKit

extension ViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 5))
        footerView.backgroundColor = UIColor.black
        return footerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cityCell: WeatherInfoCell? = tableView.dequeueReusableCell(withIdentifier: weatherCellId, for: indexPath) as? WeatherInfoCell
        
        if cityCell == nil {
            cityCell = WeatherInfoCell.init(style: .default, reuseIdentifier: weatherCellId)
        }
        
        if tempTypeCelcius {
            cityCell?.lblTemp.text = convertTemp(temp: Double(cityList[indexPath.row].temp), from: .kelvin, to: .celsius)
        }
        else{
            cityCell?.lblTemp.text = convertTemp(temp: Double(cityList[indexPath.row].temp), from: .kelvin, to: .fahrenheit)
        }
        
        cityCell?.lblTime.text = createDateTime(timestamp:"\(Float(cityList[indexPath.row].timezone))")
        cityCell?.lblCityName.text = cityList[indexPath.row].cityName
        
        return cityCell!
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteData(cityName: cityList[indexPath.row].cityName!)
            cityList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

