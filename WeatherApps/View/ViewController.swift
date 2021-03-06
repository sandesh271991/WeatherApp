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
    @IBOutlet weak var lblTempType: UIButton!
    
    @IBOutlet weak var btnTempTypeCelcius: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnTempTypeFahrenheit: UIButton!
    
    var tempTypeCelcius: Bool =  true  // true = °C and false = °F
    
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
    
    //View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        btnTempTypeCelcius.setTitleColor(.blue, for: .normal)
        btnTempTypeFahrenheit.setTitleColor(.gray, for: .normal)
        self.retrieveData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 65.0
    }
    
    @IBAction func btnAddCity(_ sender: Any) {
        
        let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewCityVC") as! NewCityVC
        
        presentedViewController.delegate = self
        presentedViewController.providesPresentationContextTransitionStyle = true
        presentedViewController.definesPresentationContext = true
        presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        self.present(presentedViewController, animated: true, completion: nil)
    }
    
    //to get weather data from  API
    func getCity(cityName: String){
        
        newCityAdded = cityName
        
        if cityList.contains(where: { ($0.cityName)?.caseInsensitiveCompare(newCityAdded!) == .orderedSame}) {
            DispatchQueue.main.async {
                self.showAlert(title: "", message: "City Already added")
            }
        } else {
            self.fetchData()
        }
    }

    // To update view on data change
    func updateView() {
        self.cityList = [AnyObject]()
        
        DispatchQueue.main.async {
            self.retrieveData()
            self.tableView.reloadData()
        }
    }
    
    @objc func fetchData() {
        
        if isConnectedToInternet() == true {
            let webserviceURLNew = webserviceURL + "q=\(newCityAdded!)" + "&" + "appid=\(appid)"
            
            Webservice.shared.getData(with: webserviceURLNew) { (weatherData, error) in
                
                if error != nil {
                    return
                }
                guard let weatherData = weatherData else {return}
                self.weatherData = weatherData
                self.createData()
                
            }
        } else {
            showAlert(title: "No Internet Connection", message: "Please check your internet connection")
        }
    }
    
    @IBAction func btnTempTypeCelcius(_ sender: Any) {
        tempTypeCelcius = true
        btnTempTypeCelcius.setTitleColor(.blue, for: .normal)
        btnTempTypeFahrenheit.setTitleColor(.gray, for: .normal)
        tableView.reloadData()
    }
    
    @IBAction func btnTempTypeFahrenheit(_ sender: Any) {
        tempTypeCelcius = false
        btnTempTypeCelcius.setTitleColor(.gray, for: .normal)
        btnTempTypeFahrenheit.setTitleColor(.blue, for: .normal)
        tableView.reloadData()
    }
    
    
    func createDateTime(timestamp: String) -> String {
        var strDate = "undefined"
        
        if let unixTime = Double(timestamp) {
            let date = Date(timeIntervalSince1970: unixTime)
            let dateFormatter = DateFormatter()
            let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
            dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm" //Specify your format that you want
            strDate = dateFormatter.string(from: date)
        }
        
        return strDate
    }
    
    
    //CORE DATA CRUD
    func createData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: WeatherLocalDataEntity, in: managedContext)!
        
        //final, we need to add some data to our newly created record for each keys using
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue( weatherViewModel?.name , forKeyPath: "cityName")
        user.setValue(weatherViewModel?.temp.temp, forKeyPath: "temp")
        user.setValue(weatherViewModel?.time, forKeyPath: "timezone")
        
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: WeatherLocalDataEntity)
        
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
    
    func deleteData(cityName:String){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: WeatherLocalDataEntity)
        fetchRequest.predicate = NSPredicate(format: "cityName = %@", cityName )
        
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
    }
}


