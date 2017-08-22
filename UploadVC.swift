//
//  UploadVC.swift
//  LocationSelector
//
//  Created by 刘月 on 7/15/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var contact: UITextView!
 
  
    let green = UIColor.init(red: 34/255.0, green: 158/255.0, blue: 55/255.0, alpha: 1)
    
    @IBAction func neuterBtn_click(_ sender: UIButton) {
        setDefaultButtonColors(neuterBtn)
        if sender.tag == 0 {
            sender.setTitleColor(green, for: UIControlState())
        } else {
            sender.setTitleColor(.red, for: UIControlState())
            
        }
        sender.backgroundColor = .white
        
    }
    
    @IBAction func dewormBtn_click(_ sender: UIButton) {
        setDefaultButtonColors(dewormBtn)
        if sender.tag == 0 {
            sender.setTitleColor(green, for: UIControlState())
        } else {
            sender.setTitleColor(.red, for: UIControlState())
            
        }
        sender.backgroundColor = .white
        
    }
    
    @IBAction func shotBtn_click(_ sender: UIButton) {
        setDefaultButtonColors(shotBtn)
        if sender.tag == 0 {
            sender.setTitleColor(green, for: UIControlState())
        } else {
            sender.setTitleColor(.red, for: UIControlState())
        }
        sender.backgroundColor = .white
        
    }
    

        
    @IBAction func selectGender(_ sender: UIButton) {
        setDefaultButtonColors(genderBtn)
        sender.setTitleColor(.black, for: UIControlState())
        sender.backgroundColor = .white
        
    }
        
    @IBAction func slectAge(_ sender: UIButton) {
            
        setDefaultButtonColors(ageBtn)
        sender.setTitleColor(.black, for: UIControlState())
        sender.backgroundColor = .white
    }
        
    @IBAction func selectSize(_ sender: UIButton) {
        setDefaultButtonColors(sizeBtn)
        sender.setTitleColor(.black, for: UIControlState())
        sender.backgroundColor = .white
        
    }
        
    @IBAction func selectColor(_ sender: UIButton) {
        setDefaultButtonColors(colorBtn)
        sender.setTitleColor(.black, for: UIControlState())
        sender.backgroundColor = .white
        
    }
    
            
    override func viewWillAppear(_ animated: Bool) {
        
        if UserDefaults.standard.string(forKey: "username") == nil {
            let signIn = self.storyboard!.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            self.navigationController!.pushViewController(signIn, animated: false)
            
        }
        navigationController?.navigationBar.isTranslucent = false
        
    }
    
    //update button color according to data from uploaded data
    func setButtonColor(_ data: String, _ buttons: [UIButton]) {
    
        for button in buttons {
            if data == button.title(for: UIControlState()) {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: UIControlState())
            }
            
        }
    }
    
    

    
    //save data chose into the server
    func saveButtonTitle(_ buttons: [UIButton]) -> String {
        var data = ""
        for button in buttons {
             if button.backgroundColor == .white {
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
            
           
            
            setDefaultButtonBorders(ageBtn)
            setDefaultButtonBorders(genderBtn)
            setDefaultButtonBorders(sizeBtn)
            setDefaultButtonBorders(ageBtn)
            setDefaultButtonBorders(colorBtn)
            setDefaultButtonBorders(neuterBtn)
            setDefaultButtonBorders(dewormBtn)
            setDefaultButtonBorders(shotBtn)
            
            /*
            setDefaultButtonColors(ageBtn)
            setDefaultButtonColors(genderBtn)
            setDefaultButtonColors(sizeBtn)
            setDefaultButtonColors(ageBtn)
            setDefaultButtonColors(colorBtn)
            setDefaultButtonColors(neuterBtn)
            setDefaultButtonColors(dewormBtn)
            setDefaultButtonColors(shotBtn)
            */
            

             /*
          // for gender in genderFilter {
            
            setButtonColor(genderUpload, genderBtn)
            setButtonColor(ageUpload, ageBtn)
            setButtonColor(sizeUpload, sizeBtn)
            setButtonColor(colorUpload, colorBtn)

 */
            /*
            
                if genderUpload == "公" {
             genderBtn[0].backgroundColor = .white
             genderBtn[0].setTitleColor(.black, for: UIControlState())
             }
                if genderUpload == "母" {genderBtn[1].backgroundColor = .white
             genderBtn[1].setTitleColor(.black, for: UIControlState())}
            //}
            
            
           // for age in ageFilter {
                
                if ageUpload == "幼年" {ageBtn[0].backgroundColor = .white}
                if ageUpload == "成年" {ageBtn[1].backgroundColor = .white}
                if ageUpload == "老年" {ageBtn[2].backgroundColor = .white}

           // }
            
           // for size in sizeFilter {
                if sizeUpload == "迷你" {sizeBtn[0].backgroundColor = .white}
                if sizeUpload == "小型" {sizeBtn[1].backgroundColor = .white}
                if sizeUpload == "中型" {sizeBtn[2].backgroundColor = .white}
                if sizeUpload == "大型" {sizeBtn[3].backgroundColor = .white}
                
           // }
            
         
           // for color in colorFilter {
                if colorUpload == "黑" {colorBtn[0].backgroundColor = .white}
                if colorUpload == "白" {colorBtn[1].backgroundColor = .white}
                if colorUpload == "花" {colorBtn[2].backgroundColor = .white}
                if colorUpload == "棕" {colorBtn[3].backgroundColor = .white}
                if colorUpload == "黄" {colorBtn[4].backgroundColor = .white}
                if colorUpload == "其他" {colorBtn[5].backgroundColor = .white}

           // }
 
            */
            
            //判断是否选择地区和种类
            /*
        
            storyTxt.text! = storyUpload
            adavantageTxt.text! = adavantageUpload
            */
            //自定义导航按钮
          
            //  let leftBarBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(back))
          //  self.navigationItem.leftBarButtonItem = leftBarBtn
            
            let saveBtn = UIBarButtonItem(title: "下一步", style: .plain, target: self, action:#selector(nextStep))
            self.navigationItem.rightBarButtonItem = saveBtn
            
            let backBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action:#selector(back))
            self.navigationItem.leftBarButtonItem = backBtn
            
            // check notifications of keyboard - shown or not
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
           
           // storyTxt.delegate = self
            //likeTxt.delegate = self
 
   
        }
    
    
       func back() {
            self.dismiss(animated: true, completion: nil)

        }

        func nextStep(){
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

 
            /*
            
            for button in genderBtn {
                if button.backgroundColor == .white {
                    if button.tag == 0 {genderUpload = "公"}
                    else if button.tag == 1 {genderUpload = "母"}
                }
            }
            
            for button in ageBtn {
                if button.backgroundColor == .white {
                    if button.tag == 0 {ageUpload = "幼年"}
                    else if button.tag == 1 {ageUpload = "成年"}
                    else if button.tag == 2 {ageUpload = "老年"}
                }
            }
            
            for button in sizeBtn {
                if button.backgroundColor == .white {
                    if button.tag == 0 {sizeUpload = "迷你"}
                    else if button.tag == 1 {sizeUpload = "小型"}
                    else if button.tag == 2 {sizeUpload = "中型"}
                    else if button.tag == 3 {sizeUpload = "大型"}
                    
                }
            }
            
            for button in colorBtn {
                if button.backgroundColor == .white {
                    if button.tag == 0 {colorUpload = "黑"}
                    else if button.tag == 1 {colorUpload = "白"}
                    else if button.tag == 2 {colorUpload = "花"}
                    else if button.tag == 3 {colorUpload = "棕"}
                    else if button.tag == 4 {colorUpload = "黄"}
                    else if button.tag == 5 {colorUpload = "其他"}
                    
                }
            }
            */
     
      
            petnameUpload = petName.text!
            storyUpload = storyTxt.text!
            likeUpload = likeTxt.text!
            storyUpload = contact.text!

            
           
            if petnameUpload == "" {alert("请填写","它的姓名")}
            if genderUpload == "" {alert("请选择","性别")}
            if ageUpload == "" {alert("请选择","年龄")}
            if sizeUpload == "" {alert("请选择","体型")}
            if colorUpload == "" {alert("请选择","颜色")}
            if neuterUpload == nil {alert("请选择","绝育状况")}
            if dewormUpload == nil {alert("请选择","驱虫状况")}
            if shotUpload == nil {alert("请选择","疫苗状况")}
            if contactUpload == "" {alert("请填写","联系方式")}
            if storyUpload == "" {alert("请填写","它的故事")}
            if likeUpload == "" {alert("请填写","它的喜好")}

            
            self.view.endEditing(true)
            let UploadPhotos = self.storyboard?.instantiateViewController(withIdentifier: "UploadPhotos") as! UploadPhotos
            
            //隐藏tab bar
            UploadPhotos.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(UploadPhotos, animated: true)

            // send notification to homeVC to be reloaded
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "setFilter"), object: nil)
            
           // _ = self.navigationController?.popViewController(animated: true)
            
        
    }
        
        
    func setDefaultButtonColors(_ buttons: [UIButton]){
        
        for button in buttons {
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.darkGray, for: UIControlState())
        }
        
    }
    
    
    func setDefaultButtonBorders(_ buttons: [UIButton]){
        
        for button in buttons {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.darkGray.cgColor
        }
        
    }


    func alert(_ titleMessage: String, _ alertMessage: String) {
        let alert = UIAlertController(title: titleMessage, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        //let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.cancel, handler: nil)
        //alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
   
    
    /*
    
    var previusHeight: CGFloat!

    var currentOffset:CGFloat!
    
    func textViewDidChange(_ textView: UITextView) {
        
        
        if  textView.frame.size.height > 100 && textView.frame.size.height > previusHeight {
            
            // move up with animation
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                
             
                self.scrollView.contentOffset.y += 19
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.keyboard.height, 0);
    
            })


            print(self.scrollView.contentSize.height)
        } else if textView.frame.size.height > 100 && textView.frame.size.height < previusHeight {
           
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                
                self.scrollView.contentOffset.y -= 19

                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.keyboard.height, 0);

            })
            
        }
        
        previusHeight = textView.frame.size.height

 

    }
    */
    
    
    
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
    
 





