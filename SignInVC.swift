//
//  SignInVC.swift
//  LocationSelector
//
//  Created by 刘月 on 7/14/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit
import Parse

class SignInVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if UserDefaults.standard.string(forKey: "userID") != nil {
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "signIn"), object: nil)
            self.navigationController?.popViewController(animated: false)
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
    }
    

 
    @IBAction func signInBtn_click(_ sender: Any) {
        
        //hide keyboard
        self.view.endEditing(true)
        
              
        
        //login function with username
        PFUser.logInWithUsername(inBackground: usernameTxt.text!.lowercased(), password: passwordTxt.text!) { (user: PFUser?, error) in
            if error == nil {
                
                UserDefaults.standard.setValue(user?.objectId, forKey: "userID")
                UserDefaults.standard.synchronize()
                
                //call log in function from AppDelegate.swift class
                //let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                //appDelegate.login()
                //self.login()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "signIn"), object: nil)
                self.navigationController?.popViewController(animated: false)
                
                
            } else {
                JJHUD.showError(text: "用户名或密码不正确", delay: 1.25, enable: false)

            }
        }
        
    }
    
    /*
   
    @IBAction func forgetPassword_click(_ sender: Any) {
        let resetPassword = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        self.navigationController?.pushViewController(resetPassword, animated: false)
    }

 */
    /*
    func login(){
        //remember user's login
        let username: String? = UserDefaults.standard.string(forKey: "username")
        
        //if loged in
        if  username != nil {
            
            
            
            //let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let userInfo = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as! UserInfoVC
            //window?.rootViewController = userInfo
            self.navigationController!.pushViewController(userInfo, animated: false)
            
        }
    }
    
 */
    func alert(_ titleMessage: String, _ alertMessage: String) {
        let alert = UIAlertController(title: titleMessage, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    /*
    @IBAction func registerBtn_click(_ sender: Any) {
        
        let register = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(register, animated: false)
        
    }
    */
    
    //hide keyboard if tapped
    func hideKeyboardTap (recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var isValid = true
        
        
        if string == " " {
            // Returning no here to restrict whitespace
            return false
        }
        
        
        
        //在非编辑状态下是否为空
        if (textField != self.usernameTxt && self.usernameTxt.text!.isEmpty) {
            isValid = false
        }else if(textField != self.passwordTxt && self.passwordTxt.text!.isEmpty){
            isValid = false
        } else if range.location == 0 && (string == "") {
            isValid = false
            
        }
        
        
        if (isValid) {
            self.signInBtn.alpha = 1
            self.signInBtn.isEnabled = true
        }else{
            self.signInBtn.alpha = 0.5
            self.signInBtn.isEnabled = false
        }
        
        
        let characterCountLimit: Int = 10
        
        if textField == passwordTxt {
            
            // 先计算出改变之后的字符串总长度
            let startingLength = textField.text!.characters.count
            let lengthToAdd = string.characters.count
            let lengthToReplace = range.length
            
            let newLength = startingLength + lengthToAdd - lengthToReplace
            
            return newLength <= characterCountLimit
            
            
        } else {
            
            return true
        }
    }

 
}
