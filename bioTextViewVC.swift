//
//  showTextViewVC.swift
//  PetSelector
//
//  Created by 刘月 on 8/17/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse

class bioTextViewVC: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var wordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.textViewEditChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
      
        self.navigationItem.title = titleTransfer

        textView.text = content
        wordLabel.text = "\(300 - textView.text.characters.count)"
        
        //declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap(recognizer:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)

    }
    
    func textViewEditChanged(_ obj: Notification) {
        let textView: UITextView? = self.textView
        let textStr: String? = textView?.text
        var fontNum: Int = 300 - (textStr?.characters.count ?? 0)
        fontNum = fontNum < 0 ? 0 : fontNum
        wordLabel.text = "\(fontNum)"
        if (textStr?.characters.count ?? 0) > 300 {
            textView?.text = (textStr as NSString?)?.substring(to: 300)
        }
    }
    
    
    @IBAction func saveBtn_clicked(_ sender: Any) {
        
        if titleTransfer == "意见反馈" {
            JJHUD.showLoading(text: "正在上传")
            let object = PFObject(className: "Advice")
            object["user"] = PFUser.current()!.objectId!
            object["advice"] = self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            object.saveInBackground(block: {(success, error) in
                if success {
                    JJHUD.hide()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    JJHUD.showError(text: "反馈失败", delay: 1)
                }
            })
            
        
        } else {

            let query = PFUser.query()
            query?.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
            
            JJHUD.showLoading(text: "正在保存")
            
            query?.getFirstObjectInBackground(block: { (object, error) in
                
                if error == nil {
                    
                    if titleTransfer == "简介" {
                    
                        object?["bio"] = self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    } else {
                        
                        object?["address"] = self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    }
                    
                    object?.saveInBackground(block: { (success, error) in
                        if success {
                            JJHUD.hide()
                            
                            // send notification refresh
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil, userInfo:["key":titleTransfer, "value":self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)])
                            self.navigationController?.popViewController(animated: true)
     
                        }
                    })
                    
                } else {
                    print(error!.localizedDescription)
                    
                }
            })
        }
        
    }
    
    
    
    //hide keyboard if tapped
    func hideKeyboardTap (recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
}
