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
    
    var tempTypeCelcius: Bool =  true  // true = °C and false = °F
    @IBOutlet weak var txtNewCityAdded: UITextField!
    @IBOutlet weak var lblTempType: UIButton!
    
    @IBOutlet weak var btnTempTypeCelcius: UIButton!
    
    @IBOutlet weak var btnTempTypeFahrenheit: UIButton!
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
        btnTempTypeCelcius.setTitleColor(.blue, for: .normal)
        btnTempTypeFahrenheit.setTitleColor(.gray, for: .normal)
        self.retrieveData()
    }
    
    //View LifeCycle
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
    
    
    func createData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "WeatherLocalData", in: managedContext)!
        
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
    
    func deleteData(cityName:String){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherLocalData")
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


