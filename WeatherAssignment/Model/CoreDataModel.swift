//
//  CoreDataModel.swift
//  WeatherAssignment
//
//  Created by Deepti Walde on 23/05/18.
//  Copyright © 2018 Deepti Walde. All rights reserved.
//

import UIKit
import CoreData

class CoreDataModel: NSObject {
  
    let appDelegate =
        UIApplication.shared.delegate as? AppDelegate
    var managedContext : NSManagedObjectContext?
    
    
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
