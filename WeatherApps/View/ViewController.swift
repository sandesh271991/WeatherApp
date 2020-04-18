//
//  ViewController.swift
//  WeatherApps
//
//  Created by Sandesh on 17/04/20.
//  Copyright © 2020 Sandesh. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, getCityDelegate {
    
    @IBOutlet weak var txtNewCityAdded: UITextField!
    var cityList = [AnyObject]()
    var newCityAdded: String?
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
        self.retrieveData()
        
        
        var newCity = storyboard?.instantiateViewController(identifier: "NewCityVC") as! NewCityVC
        
        newCity.delegate = self
    }
    //View LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 65.0
    }
    
    @IBAction func btnAddCity(_ sender: Any) {
        
        if let city  = txtNewCityAdded.text {
            newCityAdded = city
        }
        self.fetchData()
    }
    
    func getCity(cityName: String) {
        newCityAdded = cityName
        print("new city added \(newCityAdded)")
    }
    
    func updateView() {
        print("City name = \(self.weatherViewModel?.name ?? "No name")")
        print("Temp name = \(self.weatherViewModel?.temp.temp ?? 0.0)")
        
        // self.tableView?.reloadData()
    }
    @objc func fetchData() {
        
        if isConnectedToInternet() == true {
            let webserviceURLNew = webserviceURL + "q=\(newCityAdded!)" + "&" + "appid=\(appid)"
            
            Webservice.shared.getData(with: webserviceURLNew) { (countryData, error) in
             
                if error != nil {
                    
                    return
                }
                guard let countryData = countryData else {return}
                self.weatherData = countryData
                self.createData()
                DispatchQueue.main.async {
                    self.retrieveData()
                    self.tableView.reloadData()
                }
            }
        } else {
            showAlert(title: "No Internet Connection", message: "Please check your internet connection")
        }
    }
    
    func createData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "WeatherLocalData", in: managedContext)!
        
        //final, we need to add some data to our newly created record for each keys using
        //here adding 5 data with loop
        
        
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue( weatherViewModel?.name , forKeyPath: "cityName")
        user.setValue(weatherViewModel?.temp.temp, forKeyPath: "temp")
        
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    func retrieveData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherLocalData")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "cityName") as! String)
                print(data.value(forKey: "temp") as! Int)
                cityList.append(data)
            }
        } catch {
            print("Failed")
        }
    }
}


extension ViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 5))
        footerView.backgroundColor = UIColor.gray
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
        
        cityCell?.lblTemp.text = "\(cityList[indexPath.row].temp ?? 0)"
        
        //cityCell?.lblTime.text = "\(cityList[indexPath.row].timeZone ?? 0)"
        
        cityCell?.lblCityName.text = cityList[indexPath.row].cityName
        
        return cityCell!
    }
}


