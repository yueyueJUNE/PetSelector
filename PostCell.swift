//
//  PostCell.swift
//  LocationSelector
//
//  Created by 刘月 on 7/6/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit
import Parse

class PostCell: UITableViewCell {

    //@IBOutlet weak var postCell: UIView!
    @IBOutlet weak var petavaImg: UIImageView!
    @IBOutlet weak var petnameLbl: UILabel!
    @IBOutlet weak var breedLbl: UIButton!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var collectLbl: UILabel!
    @IBOutlet weak var likeBtn: DOFavoriteButton!
    @IBOutlet weak var likeLbl: UILabel!
    
    
    
    func likeBtn_clicked(_ sender: DOFavoriteButton) {
        // declare title of button
        //let title = (sender as AnyObject).title(for: UIControlState.normal)
        if PFUser.current() != nil {
            // to like
            if sender.isSelected == false {
                
                let object = PFObject(className: "Like")
                object["userId"] = PFUser.current()!.objectId!
                object["petId"] = idLbl.text
                object.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        //self.likeBtn.setTitle("like", for: .normal)
                       // self.likeBtn.setBackgroundImage(#imageLiteral(resourceName: "like"), for: .normal)
                        sender.select()

                        self.likeLbl.text = "\(Int(self.likeLbl.text!)! + 1)"

                        // send notification if we liked to refresh TableView
                        //NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                        /*
                        // send notification as like
                        if self.usernameBtn.titleLabel?.text != PFUser.current()?.username {
                            let newsObj = PFObject(className: "news")
                            newsObj["by"] = PFUser.current()?.username
                            newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                            newsObj["to"] = self.usernameBtn.titleLabel!.text
                            newsObj["owner"] = self.usernameBtn.titleLabel!.text
                            newsObj["uuid"] = self.uuidLbl.text
                            newsObj["type"] = "like"
                            newsObj["checked"] = "no"
                            newsObj.saveEventually()
                        }
                        */
                        
                    }
                })
                
                // to dislike
            } else {
                
                // request existing likes of current user to show post
                let query = PFQuery(className: "Like")
                query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
                query.whereKey("petId", equalTo: idLbl.text!)
                query.findObjectsInBackground { (objects, error) -> Void in
                    
                    // find objects - likes
                    for object in objects! {
                        
                        // delete found like(s)
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                //self.likeBtn.setTitle("unlike", for: .normal)
                                //self.likeBtn.setBackgroundImage(#imageLiteral(resourceName: "unlike"), for: .normal)
                                sender.deselect()
                                self.likeLbl.text = "\(Int(self.likeLbl.text!)! - 1)"
                                // send notification if we liked to refresh TableView
                                //NotificationCenter.default.post(name: Notification.Name(rawValue: "liked"), object: nil)
                                /*
                                // delete like notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newsQuery.whereKey("to", equalTo: self.usernameBtn.titleLabel!.text!)
                                newsQuery.whereKey("uuid", equalTo: self.uuidLbl.text!)
                                newsQuery.whereKey("type", equalTo: "like")
                                newsQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })
                                
                                
                                */
                            }
                        })
                    }
                }
                
            }
        } else {
            
            JJHUD.showText(text: "登录后才能为它点赞哦", delay: 1.25)
        
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        idLbl.isHidden = true
        collectLbl.isHidden = true
        
        // round ava
        petavaImg.layer.cornerRadius = petavaImg.frame.size.width / 2
        petavaImg.clipsToBounds = true
        
        breedLbl.layer.cornerRadius = 4
        breedLbl.layer.borderColor = UIColor.darkGray.cgColor
        breedLbl.layer.borderWidth = 1
        
        likeBtn.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        likeBtn.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        likeBtn.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        likeBtn.addTarget(self, action: #selector(likeBtn_clicked), for: .touchUpInside)
    }

    
}
