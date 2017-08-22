//
//  socialMediaVC.swift
//  PetSelector
//
//  Created by 刘月 on 8/18/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse
extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
}


class socialMediaVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var wechat: UITextField!
    @IBOutlet weak var weibo: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = titleTransfer
        
        //declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let fulltext = content
        var textArray = fulltext?.components(separatedBy: "\n")
        
        
        wechat.text = textArray?[0].chopPrefix(3)
        
        if textArray?.count == 1 {
            
            weibo.text = ""
        } else {
            weibo.text = textArray?[1].chopPrefix(3)
        
        }
 
        
    }
    
    
    @IBAction func saveBtn_clicked(_ sender: Any) {
        
            
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
        
        JJHUD.showLoading(text: "正在保存")
        
        query?.getFirstObjectInBackground(block: { (object, error) in
            
            if error == nil {
                
              
                object?["socialAccount"] = "微信 " + self.wechat.text! + "\n" + "微博 " + self.weibo.text!
                    
                
                object?.saveInBackground(block: { (success, error) in
                    if success {
                        JJHUD.hide()
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil, userInfo:["key": titleTransfer, "value": "微信 " + self.wechat.text! + "\n" + "微博 " + self.weibo.text!])
                        
                        self.navigationController?.popViewController(animated: true)
                        
                    } else {
                        JJHUD.hide()
                        
                        JJHUD.showError(text: "修改未成功", delay: 1, enable: false)

                    }
                })
                
                
            } else {
                print(error!.localizedDescription)
                
            }
        })
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == " " {
            return false
        }
        return true
        
    }

    
    //hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //hide keyboard if tapped
    func hideKeyboardTap (recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    
}
