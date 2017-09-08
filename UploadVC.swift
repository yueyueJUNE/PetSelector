//
//  UploadVC.swift
//  LocationSelector
//
//  Created by 刘月 on 7/15/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit
import Parse

var genderUpload = ""
var ageUpload = ""
var colorUpload = ""
var sizeUpload = ""
var storyUpload = ""
var contactUpload = ""
var likeUpload = ""
var neuterUpload: Bool?
var dewormUpload: Bool?
var shotUpload: Bool?
var petnameUpload = ""


class UploadVC: UIViewController {

   
    //value to hold keyboard frmae size
    var keyboard = CGRect()
    var wasKeyboardDidShow: Bool = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentSize: UIView!
        
    @IBOutlet weak var petName: UITextField!
    //gender button
    @IBOutlet var genderBtn: [UIButton]!
    //age button
    @IBOutlet var ageBtn: [UIButton]!
    //size button
    @IBOutlet var sizeBtn: [UIButton]!
    //color button
    @IBOutlet var colorBtn: [UIButton]!
    //neuter button
    @IBOutlet var neuterBtn: [UIButton]!
    //deworm button
    @IBOutlet var dewormBtn: [UIButton]!
    //shot button
    @IBOutlet var shotBtn: [UIButton]!
    //story textView
    @IBOutlet weak var storyTxt: UITextView!
    //like textView
    @IBOutlet weak var likeTxt: UITextView!
    //contact textView
    @IBOutlet weak var contact: UITextView!
 
  
    let green = UIColor.init(red: 34/255.0, green: 158/255.0, blue: 55/255.0, alpha: 1)
        
    @IBAction func neuterBtn_click(_ sender: UIButton) {
        setDefaultButtonColors(neuterBtn)
        if sender.tag == 0 {
            sender.backgroundColor = green
            sender.layer.borderColor = green.cgColor
        } else {
            sender.backgroundColor = .red
            sender.layer.borderColor = UIColor.red.cgColor

        }
        sender.setTitleColor(.white, for: UIControlState())
        
    }
    
    @IBAction func dewormBtn_click(_ sender: UIButton) {
        setDefaultButtonColors(dewormBtn)
        if sender.tag == 0 {
            sender.backgroundColor = green
            sender.layer.borderColor = green.cgColor

        } else {
            sender.backgroundColor = .red
            sender.layer.borderColor = UIColor.red.cgColor

            
        }
        sender.setTitleColor(.white, for: UIControlState())
        
    }
    
    @IBAction func shotBtn_click(_ sender: UIButton) {
        setDefaultButtonColors(shotBtn)
        if sender.tag == 0 {
            sender.backgroundColor = green
            sender.layer.borderColor = green.cgColor
            
        } else {
            sender.backgroundColor = .red
            sender.layer.borderColor = UIColor.red.cgColor

        }
        sender.setTitleColor(.white, for: UIControlState())
        
    }
    

        
    @IBAction func selectGender(_ sender: UIButton) {
        setDefaultButtonColors(genderBtn)
        sender.setTitleColor(.white, for: UIControlState())
        sender.backgroundColor = .darkGray
        
    }
        
    @IBAction func slectAge(_ sender: UIButton) {
            
        setDefaultButtonColors(ageBtn)
        sender.setTitleColor(.white, for: UIControlState())
        sender.backgroundColor = .darkGray
    }
        
    @IBAction func selectSize(_ sender: UIButton) {
        setDefaultButtonColors(sizeBtn)
        sender.setTitleColor(.white, for: UIControlState())
        sender.backgroundColor = .darkGray
        
    }
        
    @IBAction func selectColor(_ sender: UIButton) {
        setDefaultButtonColors(colorBtn)
        sender.setTitleColor(.white, for: UIControlState())
        sender.backgroundColor = .darkGray
    }
    
    
    var fakeview: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
        
        if PFUser.current() == nil {
            
            fakeview = UIView()
            fakeview?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            fakeview?.backgroundColor = .black
            fakeview?.alpha = 0.3
            self.view.addSubview(fakeview!)
            
            // tap to hide keyboard
            let showAlert = UITapGestureRecognizer(target: self, action: #selector(showAlertSheet))
            showAlert.numberOfTapsRequired = 1
            fakeview?.isUserInteractionEnabled = true
            fakeview?.addGestureRecognizer(showAlert)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fakeview?.removeFromSuperview()
    }
    
    
    func showAlertSheet() {
       
        JJHUD.showText(text: "请先登录", delay: 1)
    
    }
    /*
    //update button color according to data from uploaded data
    func setButtonColor(_ data: String, _ buttons: [UIButton]) {
    
        for button in buttons {
            if data == button.title(for: UIControlState()) {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: UIControlState())
            }
        }
    }
 */
    
    //save data chose into the server
    func saveButtonTitle(_ buttons: [UIButton]) -> String {
        var data = ""
        for button in buttons {
             if button.titleColor(for: .normal) == .white {
                data = button.title(for: UIControlState())!
            }
        }
        return data
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
                    
        setDefaultButtonColors(ageBtn)
        setDefaultButtonColors(genderBtn)
        setDefaultButtonColors(sizeBtn)
        setDefaultButtonColors(ageBtn)
        setDefaultButtonColors(colorBtn)
        setDefaultButtonColors(neuterBtn)
        setDefaultButtonColors(dewormBtn)
        setDefaultButtonColors(shotBtn)
        
        self.navigationItem.title = "填写资料"
        
        let saveBtn = UIBarButtonItem(title: "下一步", style: .plain, target: self, action:#selector(nextStep))
        self.navigationItem.rightBarButtonItem = saveBtn
        
        // receive notification 发布
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: "beginActivityIndicator"), object: nil)
        
        // check notifications of keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
       
    }
 
    
    func reload() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
        
        
        setDefaultButtonColors(ageBtn)
        setDefaultButtonColors(genderBtn)
        setDefaultButtonColors(sizeBtn)
        setDefaultButtonColors(colorBtn)
        setDefaultButtonColors(neuterBtn)
        setDefaultButtonColors(dewormBtn)
        setDefaultButtonColors(shotBtn)
        
        setDefaultButtonColors(ageBtn)
        setDefaultButtonColors(genderBtn)
        setDefaultButtonColors(sizeBtn)
        setDefaultButtonColors(colorBtn)
        setDefaultButtonColors(neuterBtn)
        setDefaultButtonColors(dewormBtn)
        setDefaultButtonColors(shotBtn)

        petName.text = ""
        storyTxt.text = ""
        likeTxt.text = ""
        contact.text = ""
        
        
        // switch to another ViewController at 0 index of tabbar
        let app: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
        let controller: UIViewController? = app?.window?.rootViewController
        let rvc: TabBarVC? = (controller as? TabBarVC)
        rvc?.selectedIndex = 0
        
    }
    
    func nextStep(){
        
        if PFUser.current() == nil {
            JJHUD.showText(text: "请先登录", delay: 1)
            
        } else {
            //clear the variables
            petnameUpload = ""
            genderUpload = ""
            ageUpload = ""
            colorUpload = ""
            sizeUpload = ""
            storyUpload = ""
            contactUpload = ""
            likeUpload = ""
            neuterUpload = nil
            dewormUpload = nil
            shotUpload = nil
            
            
            genderUpload = saveButtonTitle(genderBtn)
            ageUpload = saveButtonTitle(ageBtn)
            sizeUpload = saveButtonTitle(sizeBtn)
            colorUpload = saveButtonTitle(colorBtn)
            
            if saveButtonTitle(neuterBtn) != "" {
                neuterUpload = saveButtonTitle(neuterBtn) == "已绝育" ? true : false
            }
            if saveButtonTitle(dewormBtn) != "" {
                dewormUpload = saveButtonTitle(dewormBtn) == "已驱虫" ? true : false
            }
            if saveButtonTitle(shotBtn) != "" {
                shotUpload = saveButtonTitle(shotBtn) == "已注射" ? true : false
            }

      
            petnameUpload = petName.text!
            storyUpload = storyTxt.text!
            likeUpload = likeTxt.text!
            contactUpload = contact.text!
           
            if petnameUpload == "" {JJHUD.showText(text: "请填写宠物姓名", delay: 1.25, enable: false)}
            else if genderUpload == "" {JJHUD.showText(text: "请选择性别", delay: 1.25, enable: false)}
            else if ageUpload == "" {JJHUD.showText(text: "请选择年龄", delay: 1.25, enable: false)}
            else if sizeUpload == "" {JJHUD.showText(text: "请选择体形", delay: 1.25, enable: false)}
            else if colorUpload == "" {JJHUD.showText(text: "请选择颜色", delay: 1.25, enable: false)}
            else if neuterUpload == nil {JJHUD.showText(text: "请选择绝育状况", delay: 1.25, enable: false)}
            else if dewormUpload == nil {JJHUD.showText(text: "请选择驱虫状况", delay: 1.25, enable: false)}
            else if shotUpload == nil {JJHUD.showText(text: "请选择疫苗状况", delay: 1.25, enable: false)}
            else if contactUpload == "" {JJHUD.showText(text: "请填写联系方式", delay: 1.25, enable: false)}
            else if storyUpload == "" {JJHUD.showText(text: "请填写它的故事", delay: 1.25, enable: false)}
            else if likeUpload == "" {JJHUD.showText(text: "请填写它的喜好", delay: 1.25, enable: false)}
            else {
                self.view.endEditing(true)
                let UploadPhotos = self.storyboard?.instantiateViewController(withIdentifier: "UploadPhotos") as! UploadPhotos
            
                //隐藏tab bar
                UploadPhotos.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(UploadPhotos, animated: true)
            }
        }
    }
    
    func setDefaultButtonColors(_ buttons: [UIButton]){
        
        for button in buttons {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.darkGray.cgColor
            button.setTitleColor(.darkGray, for: .normal)
            button.backgroundColor = .white
        }
    }

    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    
    // func when keyboard is shown
   
    func keyboardWillShow(_ notification: NSNotification){
        
        // define keyboard frame size
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move up with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
           
            self.scrollView.contentSize.height = self.contentSize.frame.height + self.keyboard.height

        })
    }
    
    // func when keyboard is hidden
    func keyboardWillHide(_ notification: NSNotification) {
        
        // move down with animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.contentSize.height = self.contentSize.frame.height
            
       })
    }
    
    
    
}
    
 





