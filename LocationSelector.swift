//
//  LocationSelector.swift
//  LocationSelector
//
//  Created by YW on 15/7/10.
//  Copyright (c) 2015年 Tianmaying. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook

enum LocationType {
    case state
    case city
    case area
}

protocol LocationSelectorDelegate {
    func locationSelected(_ location: String)
}



class LocationSelector: UITableViewController {
    
    var locationType = LocationType.state
    var locations: NSArray!
    var locationPath = ""
    var locationName = ""
    
    var delegate: LocationSelectorDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if locationType == .state {
            if let path = Bundle.main.path(forResource: "area", ofType: "plist") {
                locations = NSArray(contentsOfFile: path)
            }
           
        }
        
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "选择地区"

        //new back button
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backBtn

    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "locationCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "locationCell")
        }
        
        switch locationType {
        case .state:
           
            cell.textLabel?.text = (self.locations[indexPath.row] as! NSDictionary)["state"] as? String
            
        case .city:
            cell.textLabel?.text = (self.locations[indexPath.row] as! NSDictionary)["city"] as? String
            //case .area:
        //cell.textLabel?.text = self.locations[indexPath.row] as? String
        default: break
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if locationType == .state {
           
            return "全国"
            
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nextLocationSelector = LocationSelector()
        nextLocationSelector.delegate = self.delegate
        let currentLocation = tableView.cellForRow(at: indexPath)?.textLabel?.text
        nextLocationSelector.locationPath = "\(locationPath) \(currentLocation!)"
        
        switch locationType {
        case .state:
            
            nextLocationSelector.locations = (self.locations[indexPath.row] as! NSDictionary)["cities"] as! NSArray
            nextLocationSelector.locationType = .city
        case .city:
            nextLocationSelector.locations = (self.locations[indexPath.row] as! NSDictionary)["areas"] as! NSArray
            nextLocationSelector.locationType = .area
        default:
            nextLocationSelector.locations = []
            break
        }
        
        if (nextLocationSelector.locations.count > 0) {
            navigationController?.pushViewController(nextLocationSelector, animated: true)
        } else {
            let currentLocation = tableView.cellForRow(at: indexPath)?.textLabel?.text
            self.delegate?.locationSelected("\(locationPath) \(currentLocation!)")
        }
    }

    func back(){
        _ = self.navigationController?.popViewController(animated: true)
    
    }

}



