//
//  signUpVC.swift
//  liketagram
//
//  Created by 刘月 on 6/28/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse
import Foundation

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    var isShelter = false

    //textfileds
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!

    @IBOutlet weak var shelterBtn: UIButton!
    @IBOutlet weak var individualBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    
    
    
    @IBAction func individualBtn_clicked(_ sender: Any) {
        isShelter = false
        
        self.individualBtn.backgroundColor = .orange
        self.individualBtn.setTitleColor(.white, for: .normal)
        self.shelterBtn.backgroundColor = .white
        self.shelterBtn.setTitleColor(.orange, for: .normal)
        
    }
    
    
    @IBAction func shelterBtn_clicked(_ sender: Any) {
        
        isShelter = true
        self.shelterBtn.backgroundColor = .orange
        self.shelterBtn.setTitleColor(.white, for: .normal)
        
        self.individualBtn.backgroundColor = .white
        self.individualBtn.setTitleColor(.orange, for: .normal)

    }
   
    
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    //click signup
    @IBAction func signUpBtn_click(_ sender: Any) {
        
        //dismiss keyboard
        self.view.endEditing(true)
        
        
        if !validateEmail(candidate: emailTxt.text!) {
            JJHUD.showText(text: "请输入有效的邮箱", delay: 1.25, enable: false)
            
        } else if passwordTxt.text != repeatPassword.text {
            JJHUD.showText(text: "两次密码不匹配", delay: 1.25, enable: false)
        } else {
        
        JJHUD.showLoading(text: "正在注册", enable: false)
        //send data to server to related columns
        let user = PFUser()
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        
        //while editing profile, it is gonna be assinged be default
        if isShelter {
            
            user["address"] = ""
            user["tel"] = ""
            
        }
        
        user["socialAccount"] = "微信 " + "" + "\n" + "微博 " + ""
        user["location"] = ""
        user["bio"] = ""
        user["gender"] = ""
        user["birth"] = ""
        user["type"] = isShelter
            
        //convert our image for sending to server
        let backgroundData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "homeBackgroundImage"),1)
        let backgroundFile = PFFile(name: "backgroundImage.jpeg", data: backgroundData!)
    
        user["backgroundImage"] = backgroundFile

        //convert our image for sending to server
        let avaData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "avaImg"),1)
        let avaFile = PFFile(name: "ava.jpeg", data: avaData!)
        user["ava"] = avaFile
        
        //save data in server
        user.signUpInBackground { (success, error) in
            JJHUD.hide()
            if success {

                //remember logged user
                UserDefaults.standard.set(user.objectId, forKey: "userID")
                UserDefaults.standard.synchronize()
                
                //call log in from AppDelegate.swift class
               // let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
               // appDelegate.login()
                
                
                self.navigationController?.popViewController(animated: false)
                //self.login()
                
            } else {
                if error!.localizedDescription == "Email address format is invalid." {
                    
                    JJHUD.showText(text: "请输入有效的邮箱", delay: 1.25, enable: false)
                    //self.alert("请输入", "有效的邮箱")

                } else if error!.localizedDescription == "Account already exists for this username." {
                     JJHUD.showText(text: "此用户名已被占用, 换个用户名试试", delay: 1.25, enable: false)
                    //self.alert("此用户名已被占用", "换个名字试试")
                    
                } else if error!.localizedDescription == "Account already exists for this email address." {
                    //self.alert("此邮箱已被占用", "换个邮箱试试")
                    JJHUD.showText(text: "此邮箱已被占用, 换个邮箱试试", delay: 1.25, enable: false)
                }
            }
        }
            
            
        }
        
        
    }
    
    
    
    func alert(_ titleMessage: String, _ alertMessage: String) {
        let alert = UIAlertController(title: titleMessage, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
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
        

        
        //在非编辑状态下是否为空
        if (textField != self.usernameTxt && self.usernameTxt.text!.isEmpty) {
            isValid = false
        }else if(textField != self.emailTxt && self.emailTxt.text!.isEmpty){
            isValid = false
        }else if(textField != self.passwordTxt && self.passwordTxt.text!.isEmpty){
            isValid = false
        } else if(textField != self.repeatPassword && self.repeatPassword.text!.isEmpty){
            isValid = false
        } else if range.location == 0 && (string == "") {
            isValid = false

        }

        
        if (isValid) {
            self.signupBtn.alpha = 1
            self.signupBtn.isEnabled = true
        }else{
            self.signupBtn.alpha = 0.5
            self.signupBtn.isEnabled = false
        }
        
       
        let characterCountLimit: Int = 10
        
        if textField == passwordTxt {
            
            // 先计算出改变之后的字符串总长度
            let startingLength = textField.text!.characters.count
            let lengthToAdd = string.characters.count
            let lengthToReplace = range.length
            
            let newLength = startingLength + lengthToAdd - lengthToReplace
            
            return newLength <= characterCountLimit
        
        
        } else if textField == repeatPassword {
            
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
    
    
          /*
    func login(){
        //remember user's login
        let username: String? = UserDefaults.standard.string(forKey: "username")
        
        //if loged in
        if  username != nil {
            let userInfo = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoVC") as! UserInfoVC
            self.navigationController!.pushViewController(userInfo, animated: true)
            
        }
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
              
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
    }

    
    func back() {
        _ = self.navigationController!.popViewController(animated: true)
        self.view.endEditing(true)
    }
   
    
    //hide keyboard if tapped
    func hideKeyboardTap (recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    
    
}
