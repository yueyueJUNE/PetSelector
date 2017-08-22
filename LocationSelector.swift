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


}


/*
 //自动定位
class LocationSelector: UITableViewController, CLLocationManagerDelegate {
    
    var locationType = LocationType.state
    var locations: NSArray!
    var locationPath = ""
    var locationName = ""
    
    var delegate: LocationSelectorDelegate?
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if locationType == .state {
            if let path = Bundle.main.path(forResource: "area", ofType: "plist") {
                locations = NSArray(contentsOfFile: path)
            }
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            checkLocationAuthorizationStatus()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if locationType == .state {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locationType == .state && section == 0 {
            return 1
        }
        
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "locationCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "locationCell")
        }
        
        switch locationType {
        case .state:
            if indexPath.section == 0 {
                cell.textLabel?.text = "正在定位..."
            } else {
                cell.textLabel?.text = (self.locations[indexPath.row] as! NSDictionary)["state"] as? String
            }
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
            switch section {
            case 0: return "当前地区"
            case 1: return "全国"
            default: break
            }
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
            if indexPath.section == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
                if !locationName.isEmpty {
                    self.delegate?.locationSelected(locationName)
                }
                return
            }
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
    
   
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    //获取位置信息
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 保存 Device 的现语言 (英语 法语 ，，，)
       //let userDefaultLanguages: NSArray = UserDefaults.standard.object(forKey: "AppleLanguages") as! NSArray
       
       // print(userDefaultLanguages.object(at: 0))
        // 强制 成 简体中文
        //UserDefaults.standard.set(["zh-Hans"], forKey: "AppleLanguages")
        
        if (!locations.isEmpty) {
            let location = locations.last!
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
                
                var result = "无法获取位置信息"
            
                if (placeMarks?.count)! > 0 {
                    result = self.getLocationFromPlaceMark((placeMarks?[0])!)
                }
                
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                self.locationName = result
                cell?.textLabel?.text = result
            })
            
        }
        
       // UserDefaults.standard.set([userDefaultLanguages.object(at: 0)], forKey: "AppleLanguages")

        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.textLabel?.text = "无法获取位置信息"
    }
    
    func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            openAlertWhenNotAuthorized()
        }
    }
    
    func openAlertWhenNotAuthorized() {
        let alertController = UIAlertController(
            title: "无法访问定位功能",
            message: "为了定位到当前城市，请打开定位功能",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "设置", style: .default) { (action) in
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                //UIApplication.shared.openURL(url)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //将位置信息转换为城市信息
    func getLocationFromPlaceMark(_ placeMark: CLPlacemark) -> String {
        
       


        let  country = placeMark.country
        let state = placeMark.administrativeArea
        let city = placeMark.locality
        var result = ""
        
        
        if country == "China" || country == "中国" {
        
            //处理直辖市
            if state == "上海市" || state == "北京市" || state == "天津市" || state == "重庆市" || state == "Beijing" || state == "Shanghai" || state == "Tianjin" || state == "Chongqing" {
                result = city!
                print(state)

            } else {
                
                result = "\(state!) \(city!)"
            }

        
        } else {
            
            //result = ""
            let alert = UIAlertController(title: "暂不支持自动定位", message: "您所在的地区", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
 
           
        }
        
        

        
        return result
    }
 
    
    
    
}
*/
