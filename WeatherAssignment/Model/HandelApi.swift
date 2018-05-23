//
//  HandelApi.swift
//  WeatherAssignment
//
//  Created by Deepti Walde on 23/05/18.
//  Copyright © 2018 Deepti Walde. All rights reserved.
//

import UIKit
import SVProgressHUD

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
            
            weatherArrayList.add(jsonData)
            completion(true)
        } catch let err {
            print("Err", err)
        }
        }.resume()
}

func callApis(completion:@escaping (Bool)-> Void) {
    let operation1 = BlockOperation{
        
        SVProgressHUD.show()
        
        let group = DispatchGroup()
        group.enter()
        weatherArrayList.removeAllObjects()
        apiCall(cityID: "4163971", completion: {_ in
            group.leave()
        })
        
        group.enter()
        apiCall(cityID: "2147714", completion: {_ in
            group.leave()
        })
        
        group.enter()
        apiCall(cityID: "2174003", completion: {_ in
            group.leave()
        })
        
        group.wait()
    }
    
    operation1.completionBlock = {
        
        fetchFromCoreData(completion: {_ in
            if fetchDetails.count > 0{
                removeDetailsFromCoreData(completion: {_ in
                    fetchDetails.removeAll()
                })
            }
        })
        
        coreDataImplement(completion: {_ in
            fetchFromCoreData(completion: {_ in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    completion(true)
                }
            })
        })
        
    }
    
    operation1.start()
}
