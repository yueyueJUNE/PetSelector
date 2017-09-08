//
//  EditInfoVC.swift
//  PetSelector
//
//  Created by 刘月 on 8/16/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse

var content: String!
var titleTransfer: String!

class EditInfoVC: UITableViewController, STPickerAreaDelegate, STPickerSingleDelegate, STPickerDateDelegate {
    
    var info = [String:String]()
    var extraInfo = [String:String]()
    
    var user = userID.last
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.register(UINib.init(nibName: "editInfoCell", bundle: nil), forCellReuseIdentifier: "Cell")
        loadData()
        
        self.navigationItem.title = "资料"
    }
    
    
   
    func pickerArea(_ pickerArea: STPickerArea, province: String, city: String, area: String) {
        let text: String = "\(province) \(city)"
        save("所在地",text)

    }
    
    func pickerSingle(_ pickerSingle: STPickerSingle, selectedTitle: String) {
        let text: String = "\(selectedTitle)"
        save("性别",text)

    }
    
    func pickerDate(_ pickerDate: STPickerDate, year: Int, month: Int, day: Int) {
        let text: String = "\(year)年\(month)月\(day)日"
        save("生日",text)

    }
    
    
    func refresh(_ notification: Notification) {
        let key = (notification.userInfo?["key"]) as! String
        if key == "生日" || key == "电话" || key == "社交账号" {
            self.extraInfo[key] = (notification.userInfo?["value"]) as? String
        } else {
            self.info[key] = (notification.userInfo?["value"]) as? String

        }
        self.tableView.reloadData()
    
    }
    
    

    func save(_ titleSeleted: String, _ contentSelected: String) {
    
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
        
        JJHUD.showLoading(text: "正在保存")
        
        query?.getFirstObjectInBackground(block: { (object, error) in
            
            if error == nil {
                
                if titleSeleted == "生日" {
                    object?["birth"] = contentSelected
                    
                } else if titleSeleted == "性别" {
                    
                    object?["gender"] = contentSelected
                    
                } else if titleSeleted == "所在地" {
                    object?["location"] = contentSelected
                }
                
                object?.saveInBackground(block: { (success, error) in
                    if success {
                        JJHUD.hide()
                        // send notification 发布成功
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil, userInfo:["key":titleSeleted, "value":contentSelected])
                    }
                })
                
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    
    func loadData() {
        
        
        if user == nil && PFUser.current() != nil {

            user = PFUser.current()?.objectId
        }
        
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: user!)
        query?.getFirstObjectInBackground(block: { (object, error) in
            if error == nil {
               
                self.info = [String:String]()
                self.extraInfo = [String:String]()
                if !(object!.value(forKey: "type") as! Bool) {
                    
                    self.info["用户名"] = (object!.value(forKey: "username") as! String)
                    self.info["性别"] = (object!.value(forKey: "gender") as! String)
                    self.info["所在地"] = (object!.value(forKey: "location") as! String)
                    self.info["简介"] = (object!.value(forKey: "bio") as! String)

                    self.extraInfo["生日"] = (object!.value(forKey: "birth") as! String)
                    //self.extraInfo["邮箱"] = (object!.value(forKey: "email") as! String)
                    self.extraInfo["社交账号"] = (object!.value(forKey: "socialAccount") as! String)
                    self.tableView.reloadData()

                } else {
                    
                    self.info["用户名"] = (object!.value(forKey: "username") as! String)
                    self.info["性别"] = (object!.value(forKey: "gender") as! String)
                    self.info["所在地"] = (object!.value(forKey: "location") as! String)
                    self.info["地址"] = (object!.value(forKey: "address") as! String)
                    self.info["简介"] = (object!.value(forKey: "bio") as! String)
                    
                    self.extraInfo["生日"] = (object!.value(forKey: "birth") as! String)
                    self.extraInfo["电话"] = (object!.value(forKey: "tel") as! String)
                    //self.extraInfo["邮箱"] = (object!.value(forKey: "email") as! String)
                    self.extraInfo["社交账号"] = (object!.value(forKey: "socialAccount") as! String)
                    self.tableView.reloadData()

                }
                
            }
        })

    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if section == 0 {
                return info.count
            } else {
                
                return extraInfo.count
            }
        
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 20
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! editInfoCell
        
        if user == nil && PFUser.current() != nil {
            cell.accessoryType = .disclosureIndicator
            
        } else if user == PFUser.current()?.objectId {
             cell.accessoryType = .disclosureIndicator
        } else {
        
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }

        if indexPath.section == 0 {
            
            let key = Array(info.keys)[indexPath.row]
            cell.titleLbl.text = key
            cell.detailLbl.text = info[key]
           
        } else {
            let key = Array(extraInfo.keys)[indexPath.row]
            cell.titleLbl.text = key

            if key == "社交账号" {
                
                cell.detailLbl.text = extraInfo[key]
            
            } else {
            
                cell.detailLbl.text = extraInfo[key]
            }

        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (user == nil && PFUser.current() != nil) || user == PFUser.current()?.objectId {
       
            // recall cell to call further info
            let cell = tableView.cellForRow(at: indexPath) as! editInfoCell
            
            if cell.titleLbl.text == "生日" {
                let pickerDate = STPickerDate()
                pickerDate.yearLeast = 1918
                pickerDate.yearSum = 100
                pickerDate.delegate = self
                pickerDate.show()

            
            } else if cell.titleLbl.text == "所在地" {
                let pickerArea = STPickerArea()
                pickerArea.delegate = self
                pickerArea.isSaveHistory = true
                pickerArea.contentMode = STPickerContentMode.bottom
                pickerArea.show()

            } else if cell.titleLbl.text == "性别" {
                let pickerSingle = STPickerSingle()
                pickerSingle.arrayData = ["男","女"]
                pickerSingle.title = "请选择性别"
                pickerSingle.contentMode = STPickerContentMode.bottom
                pickerSingle.delegate = self
                pickerSingle.show()
            
            } else if cell.titleLbl.text == "简介" {

                let textView = self.storyboard?.instantiateViewController(withIdentifier: "bioTextViewVC") as! bioTextViewVC

                textView.hidesBottomBarWhenPushed = true
                content = cell.detailLbl.text!
                titleTransfer = "简介"
               
                textView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(textView, animated: true)

            } else if cell.titleLbl.text == "地址"{
                content = cell.detailLbl.text!
                titleTransfer = "地址"
                let textView = self.storyboard?.instantiateViewController(withIdentifier: "bioTextViewVC") as! bioTextViewVC
                
                textView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(textView, animated: true)
            
            }else if cell.titleLbl.text == "用户名"{
                content = cell.detailLbl.text!
                titleTransfer = "用户名"
                let textView = self.storyboard?.instantiateViewController(withIdentifier: "textViewVC") as! textViewVC
         
                textView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(textView, animated: true)
            
            } else if cell.titleLbl.text == "社交账号"{
                content = cell.detailLbl.text!
                titleTransfer = "社交账号"

                let textView = self.storyboard?.instantiateViewController(withIdentifier: "socialMediaVC") as! socialMediaVC

                textView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(textView, animated: true)
            
            } else if cell.titleLbl.text == "电话"{
                content = cell.detailLbl.text!
                titleTransfer = "电话"
                let textView = self.storyboard?.instantiateViewController(withIdentifier: "textViewVC") as! textViewVC
                textView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(textView, animated: true)
                
            } else if cell.titleLbl.text == "邮箱"{
                content = cell.detailLbl.text!
                titleTransfer = "邮箱"
                let textView = self.storyboard?.instantiateViewController(withIdentifier: "textViewVC") as! textViewVC
                //let item = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
                //self.navigationItem.backBarButtonItem = item
                textView.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(textView, animated: true)
                
            }

        }
    }
   
}
