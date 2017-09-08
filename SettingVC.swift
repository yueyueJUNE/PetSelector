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
       
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "adviceCell", for: indexPath)
            return cell
        
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            return cell
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if indexPath.section == 0 {
            content = ""
            titleTransfer = "意见反馈"
            let textView = self.storyboard?.instantiateViewController(withIdentifier: "bioTextViewVC") as! bioTextViewVC
            textView.navigationItem.rightBarButtonItem?.title = "上传"
            textView.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(textView, animated: true)
            
        } else {
            
            let deleteactionSheet = SRActionSheet.sr_actionSheetView(withTitle: nil, cancelTitle: "取消", destructiveTitle: nil, otherTitles: ["退出登录"], otherImages: nil) { (actionSheet, index) in
                if index == 0 {
                    
                    PFUser.logOutInBackground { (error) in
                        if error == nil {
                            //remove logged in user from memory
                            UserDefaults.standard.removeObject(forKey: "userID")
                            UserDefaults.standard.synchronize()
                            userID.removeAll(keepingCapacity: false)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
                            
                            self.popViewControllers()
                            
                        }
                    }
                }
            }
            deleteactionSheet?.show()
        }
    }
    
    
    func popViewControllers() {
        
        // switch to another ViewController at 3 index of tabbar
        let app: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
        let controller: UIViewController? = app?.window?.rootViewController
        let rvc: TabBarVC? = (controller as? TabBarVC)
        rvc?.selectedIndex = 3
        self.tabBarController?.selectedIndex = 3
        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }

}
