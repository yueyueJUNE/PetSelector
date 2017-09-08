
//
//  UserCell.swift
//  LocationSelector
//
//  Created by 刘月 on 7/9/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit
import Parse

class UserCell: UITableViewCell {
    @IBOutlet weak var userAva: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var userIDLbl: UILabel!
    @IBOutlet weak var followercountLbl: UILabel!
    @IBOutlet weak var userTypeBtn: UIButton!
    
    let green = UIColor.init(red: 0/255.0, green: 153/255.0, blue: 102/255.0, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userIDLbl.isHidden = true
        
        userAva.layer.masksToBounds = true
        //设置圆角半径(宽度的一半)，显示成圆形。
        userAva.layer.cornerRadius = 25
        
        followBtn.layer.borderWidth = 1
        
        userTypeBtn.layer.cornerRadius = 4
        userTypeBtn.layer.borderWidth = 1
        userTypeBtn.layer.borderColor = UIColor.darkGray.cgColor

    }
    
    @IBAction func followBtn_clicked(_ sender: Any) {

        let tilte = followBtn.title(for: UIControlState.normal)
        
        if tilte == "+ 关注" {
            let object = PFObject(className: "Follow")
            object["follower"] = PFUser.current()!.objectId!
            object["followee"] = userIDLbl.text
            object.saveInBackground(block: { (success, error) in
                if success {
                    self.followBtn.setTitle("已关注", for: UIControlState.normal)
                    self.followBtn.layer.borderColor = UIColor.lightGray.cgColor
                    self.followBtn.setTitleColor(.lightGray, for: UIControlState())
                    self.followercountLbl.text = "\(Int(self.followercountLbl.text!)! + 1)"
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshFollow"), object: nil)

                } else {
                    
                    print(error!.localizedDescription)
                }
                
            })
        } else {
            
            let actionSheet = SRActionSheet.sr_actionSheetView(withTitle: "确定不再关注此人？", cancelTitle: "取消", destructiveTitle: nil, otherTitles: ["确定"], otherImages: nil) { (actionSheet, index) in
                if index == 0 {
                
                    let query = PFQuery(className: "Follow")
                    query.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                    query.whereKey("followee", equalTo: self.userIDLbl.text!)
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            for object in objects! {
                                object.deleteInBackground(block: { (success, error) in
                                    if success {
                                        self.followBtn.setTitle("+ 关注", for: UIControlState.normal)
                                        self.followBtn.layer.borderColor = self.green.cgColor
                                        self.followBtn.setTitleColor(self.green, for: UIControlState())
                                        self.followercountLbl.text = "\(Int(self.followercountLbl.text!)! - 1)"
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshFollow"), object: nil)

                                        
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                                
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                
                }
            }

            actionSheet?.show()

        }
        
    }

}
