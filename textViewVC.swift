//
//  usernameTextViewVC.swift
//  PetSelector
//
//  Created by 刘月 on 8/18/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse

class textViewVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = titleTransfer
        //declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        if titleTransfer == "电话" {
            textField.keyboardType = .numberPad
        }
        
        if titleTransfer == "邮箱" {
            textField.keyboardType = .emailAddress
        }
        
       
        
        textField.text = content
       
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == " " {
            return false
        }
        return true
        
    }

    @IBAction func saveBtn_clicked(_ sender: Any) {
        
        if titleTransfer == "邮箱" &&  !validateEmail(candidate: self.textField.text!){
            JJHUD.showText(text: "请输入有效的邮箱", delay: 1)
            
        } else {
        
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
            
            JJHUD.showLoading(text: "正在保存")

            query?.getFirstObjectInBackground(block: { (object, error) in
                
                if error == nil {
                    
                    if titleTransfer == "用户名" {
                        object?["username"] = self.textField.text
                    
                    } else if titleTransfer == "电话" {
                        
                        object?["tel"] = self.textField.text

                    } else if titleTransfer == "邮箱" {
                        object?["email"] = self.textField.text
                    }
                    
                    object?.saveInBackground(block: { (success, error) in
                        if success {
                            JJHUD.hide()
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil, userInfo:["key": titleTransfer, "value": self.textField.text!])
                            
                            self.navigationController?.popViewController(animated: true)
                            
                        } else {
                             JJHUD.hide()
                            if error!.localizedDescription == "Account already exists for this username." {
                               
                                JJHUD.showText(text: "此用户名已被占用, 换个用户名试试", delay: 1.25, enable: false)
                            
                            } else if error!.localizedDescription == "Account already exists for this email address." {
                                
                                JJHUD.showText(text: "此邮箱已被占用, 换个邮箱试试", delay: 1.25, enable: false)
                            } else {
                                JJHUD.showError(text: "修改未成功", delay: 1, enable: false)
                            }
                        
                        }
                    })

                    
                } else {
                    print(error!.localizedDescription)
                
                }
            })
            
        }
        
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
