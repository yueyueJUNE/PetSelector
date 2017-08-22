//
//  resetPasswordVC.swift
//  liketagram
//
//  Created by 刘月 on 6/28/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordVC: UIViewController, UITextFieldDelegate {

    //textField
    @IBOutlet weak var emailTxt: UITextField!
    
    //buttons
    @IBOutlet weak var resetBtn: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        

        
    }
    //click reset button
    @IBAction func resetBtn_click(_ sender: Any) {
        
        //hide keyboard
        self.view.endEditing(true)
        
        //email is invalid
    if !validateEmail(candidate: emailTxt.text!) {
            alert("请输入", "有效的邮箱")
        
        
        }else {
            
   
            PFUser.requestPasswordResetForEmail(inBackground: self.emailTxt.text!, block: { (success, error) in
                                
            if success {
                                    
                //show alert
                let alert = UIAlertController(title: "邮件", message: "已发送至您的邮箱", preferredStyle: UIAlertControllerStyle.alert)
                                    
                //if pressed ok call self.dismiss() function
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                                    
                
            } else {
                                    
                
                if error!.localizedDescription == "Email address format is invalid." {
                    self.alert("请输入", "有效的邮箱地址")
                } else if error!.localizedDescription.contains("No user found with email") {
                    self.alert("请输入正确的邮箱", "\(self.emailTxt.text!)未与任何用户名关联")
                }
                
            }
        })


            
        }
            
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var isValid = true
        
        if string == " " {
            // Returning no here to restrict whitespace
            return false
        }
        
        
        if range.location == 0 && (string == "") {
            isValid = false
            
        }
        
        
        if (isValid) {
            self.resetBtn.alpha = 1
            self.resetBtn.isEnabled = true
        }else{
            self.resetBtn.alpha = 0.5
            self.resetBtn.isEnabled = false
        }
        
        return true
        
    }
        
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    
   
    
    func alert(_ titleMessage: String, _ alertMessage: String) {
        let alert = UIAlertController(title: titleMessage, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    //hide keyboard if tapped
    func hideKeyboardTap (recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }


}
