//
//  SettingVC.swift
//  PetSelector
//
//  Created by 刘月 on 8/21/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse

class SettingVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "设置"
        self.tableView.tableFooterView = UIView()
       
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
            
            let deleteactionSheet = SRActionSheet.sr_actionSheetView(withTitle: nil, cancelTitle: "取消", destructiveTitle: nil, otherTitles: ["退出登录"], otherImages: nil) { (actionSheet, index) in
                if index == 0 {
                    
                    PFUser.logOutInBackground { (error) in
                        if error == nil {
                            //remove logged in user from memory
                            UserDefaults.standard.removeObject(forKey: "userID")
                            UserDefaults.standard.synchronize()

                            NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
                            
                            self.popViewControllers()
                            //let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as!                             HomeVC

                            //let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            //appDelegate.window?.rootViewController = homeVC
                        }
                    }
                }
            }
            
            deleteactionSheet?.show()
        
    }
    
    
    func popViewControllers() {
        
        self.navigationController?.popToRootViewController(animated: true)
       // while (vc?.parent != nil) {
         //   print("运行")

         //   vc = vc?.parent
        //}
        
        
        
       // vc?.tabBarController?.selectedIndex = 3
        //vc?.navigationController?.popViewController(animated: false)
        
        // switch to another ViewController at 0 index of tabbar
        let app: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
        let controller: UIViewController? = app?.window?.rootViewController
        let rvc: TabBarVC? = (controller as? TabBarVC)
        rvc?.selectedIndex = 3
        
    }

    
    
   

}
