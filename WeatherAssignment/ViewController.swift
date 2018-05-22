//
//  ViewController.swift
//  WeatherAssignment
//
//  Created by Deepti Walde on 22/05/18.
//  Copyright © 2018 Deepti Walde. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

struct WeatherReport: Decodable
{
    let coord: Coord?
    let weather : [Weather]?
    let base : String?
    let main : Main?
    let visibility : Int?
    let wind : Wind?
    let clouds : Cloud?
    let dt     : Int?
    let sys    : Sys?
    let id     : Int?
    let name   : String?
    let cod    : Int
}

struct Coord : Codable {
    let lon : Float?
    let lat : Float?
}

struct Weather : Codable {
    let id : Int
    let main : String
    let description : String
    let icon : String
}

struct Main : Codable {
    let temp : Float?
    let pressure : Int?
    let humidity : Int?
    let temp_min : Int?
    let temp_max : Int?
}

struct Wind : Codable {
    let speed : Float?
    let deg   : Int?
}

struct Cloud : Codable {
    let all : Int?
}

struct Sys : Codable {
    let type    : Int?
    let id      : Int?
    let message : Double?
    let country : String?
    let sunrise : Int?
    let sunset  : Int?
}


//MARK:- Custom Cell
class CustomCell : UITableViewCell{
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var temp: UILabel!
    
}

//MARK:- Controller Class
class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var weatherArrayList : NSMutableArray = []
//    var weatherArrayList = [Any].self

    var fetchDetails: [NSManagedObject] = []
    
    let appDelegate =
        UIApplication.shared.delegate as? AppDelegate
    var managedContext : NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedContext = appDelegate?.persistentContainer.viewContext
        tableView.tableFooterView = UIView()
        
        self.fetchFromCoreData(completion: {_ in
            
            if self.fetchDetails.count > 0{
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }else{
                self.callApis()
            }
            
            /*self.coreDataImplement(completion: {_ in
                self.fetchFromCoreData(completion: {_ in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            })*/
            
            
        })
        
        
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
                if checkInternet() {
                    self.callApis()
                } else{
                    self.present(showAlertForNoInternet(), animated: true, completion: nil)
                }
            }
        }
        
        
        let backgroundView = UIView(frame: tableView.bounds)
        backgroundView.layer.insertSublayer(gradient(frame: tableView.bounds), at: 0)
        tableView.backgroundView = backgroundView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func gradient(frame:CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = [
            UIColor.gray.cgColor,UIColor.cyan.cgColor]
        return layer
    }
}



//MARK:- Table View
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchDetails.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        let weather = fetchDetails[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.name.text = weather.value(forKeyPath: "name") as? String
        cell.temp.text = weather.value(forKeyPath: "temp") as? String
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.fetchDetails = fetchDetails[indexPath.row]
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

//MARK:- Core Data
extension ViewController{
    func coreDataImplement(completion:@escaping (Bool)-> Void)  {
        
        let weatherEntity = NSEntityDescription.entity(forEntityName: "WeatherDetails", in: managedContext!)!
        
        for details in weatherArrayList{
            let details = details as! WeatherReport
            
            let weatherDetails = NSManagedObject(entity: weatherEntity, insertInto: managedContext)
            weatherDetails.setValue("\(details.visibility ?? 0)", forKeyPath: "visibility")
            weatherDetails.setValue(details.weather![0].description, forKeyPath: "desc")
            weatherDetails.setValue("\(details.main?.humidity ?? 0)", forKey: "humidity")
            weatherDetails.setValue(details.weather![0].icon, forKey: "icon")
            weatherDetails.setValue(details.weather![0].main, forKey: "main")
            weatherDetails.setValue(details.name, forKey: "name")
            weatherDetails.setValue("\(details.main?.pressure ?? 0)", forKey: "pressure")
            weatherDetails.setValue("\(details.sys?.sunrise ?? 0)", forKey: "sunrise")
            weatherDetails.setValue("\(details.sys?.sunset ?? 0)", forKey: "sunset")
            weatherDetails.setValue("\(details.main?.temp ?? 0)", forKeyPath: "temp")
            weatherDetails.setValue("\(details.main?.temp_max ?? 0)", forKey: "tempMax")
            weatherDetails.setValue("\(details.main?.temp_min ?? 0)", forKey: "tempMin")
            
            do {
                try managedContext?.save()
               
            } catch let error as NSError {
                print("Could not save. \(error)")
            }
        }
        
         completion(true)
    }
    
    //
    func fetchFromCoreData(completion:@escaping (Bool)-> Void)  {
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "WeatherDetails")
        
        //3
        do {
            fetchDetails = []
            fetchDetails = (try managedContext?.fetch(fetchRequest))!
            completion(true)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func removeDetailsFromCoreData(completion:@escaping (Bool)-> Void)  {
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherDetails"))
        do {
            try managedContext?.execute(DelAllReqVar)
            completion(true)
        }
        catch {
            print(error)
        }
        
    }
    
}

//MARK:- Handle Api
extension ViewController{
    func apiCall(cityID  : String, completion:@escaping (Bool)-> Void)  {
        SVProgressHUD.show()
        // Set up the URL request
        let apiString: String = "http://api.openweathermap.org/data/2.5/weather?id=\(cityID)&units=metric&APPID=db10370b4f40fc37677d1d2153a344b5"
        guard let url = URL(string: apiString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(WeatherReport.self, from: data)

                self.weatherArrayList.add(jsonData)
                completion(true)
            } catch let err {
                print("Err", err)
            }
            }.resume()
    }
    
    func callApis() {
        let operation1 = BlockOperation{
            
            SVProgressHUD.show()
            
            let group = DispatchGroup()
            group.enter()
            self.weatherArrayList.removeAllObjects()
            self.apiCall(cityID: "4163971", completion: {_ in
                group.leave()
            })
            
            group.enter()
            self.apiCall(cityID: "2147714", completion: {_ in
                group.leave()
            })
            
            group.enter()
            self.apiCall(cityID: "2174003", completion: {_ in
                group.leave()
            })
            
            group.wait()
        }
        
        operation1.completionBlock = {
            
            self.fetchFromCoreData(completion: {_ in
                if self.fetchDetails.count > 0{
                    self.removeDetailsFromCoreData(completion: {_ in
                        self.fetchDetails.removeAll()
                    })
                }
            })
            
            self.coreDataImplement(completion: {_ in
                self.fetchFromCoreData(completion: {_ in
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.tableView.reloadData()
                    }
                })
            })
            
        }
        
        operation1.start()
    }
    
}
