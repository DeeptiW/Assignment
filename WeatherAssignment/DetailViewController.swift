//
//  DetailViewController.swift
//  WeatherAssignment
//
//  Created by Deepti Walde on 22/05/18.
//  Copyright © 2018 Deepti Walde. All rights reserved.
//

import UIKit
import CoreData


//MARK:- Custom Cell
class DetailCell : UITableViewCell{
    @IBOutlet weak var details: UILabel!
}

//MARK:- Controller Class
class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView!
    var fetchDetails: NSManagedObject?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fetchDetails?.value(forKeyPath: "name") as? String
        detailTableView.tableFooterView = UIView()
    
        let backgroundView = UIView(frame: detailTableView.bounds)
        backgroundView.layer.insertSublayer(gradient(frame: detailTableView.bounds), at: 0)
        detailTableView.backgroundView = backgroundView
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
extension DetailViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailCell
        cell.backgroundColor = UIColor.clear
        switch indexPath.row {
        case 0:
            cell.details?.text = "Description : \(fetchDetails?.value(forKeyPath: "desc") as? String ?? "NA") "
        case 1:
            cell.details?.text = "Type : \(fetchDetails?.value(forKeyPath: "main") as? String ?? "NA")"
        case 2:
            cell.details?.text = "Sunrise : \(fetchDetails?.value(forKeyPath: "sunrise" )as? String ?? "NA")"
        case 3:
            cell.details?.text = "Sunset : \(fetchDetails?.value(forKeyPath: "sunset") as? String ?? "NA")"
        case 4:
            cell.details?.text = "Humidity : \(fetchDetails?.value(forKeyPath: "humidity") as? String ?? "NA")%"
        case 5:
            cell.details?.text = "Pressure : \(fetchDetails?.value(forKeyPath: "pressure") as? String ?? "NA")"
        case 6:
            cell.details?.text = "Temp : \(fetchDetails?.value(forKeyPath: "temp") as? String ?? "NA")°C"
        case 7:
            cell.details?.text = "Min : \(fetchDetails?.value(forKeyPath: "tempMin") as? String ?? "NA")°C"
        case 8:
            cell.details?.text = "Max : \(fetchDetails?.value(forKeyPath: "tempMax") as? String ?? "NA")°C"
        case 9:
            cell.details?.text = "Visibility : \(fetchDetails?.value(forKeyPath: "visibility") as? String ?? "NA")"
        default:
            break
        }
        return cell
    }
}
