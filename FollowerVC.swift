//
//  FollowerVC.swift
//  PetSelector
//
//  Created by 刘月 on 8/7/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import  Parse

var category = String()
var userFollow = String()


class FollowerVC: UITableViewController {
    
    let green = UIColor.init(red: 0/255.0, green: 153/255.0, blue: 102/255.0, alpha: 1)

    var usernameArray = [String]()
    var userIDArray = [String]()
    var useravaArray = [PFFile]()
    var typeArray = [String]()
    //array to show who we follow or who follows us
    var followArray = [String]()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = category
        
        //new back button
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        //load followers if tapped on followers label
        
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 99.5
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if category == "粉丝" {
            loadFollowees()
            
        }
        
        //load followings if tapped on followings label
        if category == "关注" {
            loadFollowers()
        }
        
        tableView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")

        
    }
    
    
        //load followers
        func loadFollowers() {
            
            //STEP 1. find in follow class people following user
            let followQuery = PFQuery(className: "Follow")
            followQuery.addDescendingOrder("createdAt")

            followQuery.whereKey("follower", equalTo: userFollow)
            followQuery.findObjectsInBackground (block: { (objects, error) in
                if error == nil {
                    
                    //clean up
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    
                    //STEP 2.  hold received data
                    //find related objects
                    for object in objects! {
                        self.followArray.append(object.value(forKey: "followee") as! String)
                    }
                    
                    //STEP 3. find in user class data of the users who is following the "user"
                    let query = PFUser.query()
                    query?.whereKey("objectId", containedIn: self.followArray)
                    
                    query?.findObjectsInBackground(block: { (objects, error) in
                        
                        if error == nil {
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.useravaArray.removeAll(keepingCapacity: false)
                            self.typeArray.removeAll(keepingCapacity: false)
                            self.userIDArray.removeAll(keepingCapacity: false)
                            
                            let sortedoObjects = objects?.sorted(by: { (obj1, obj2) -> Bool in
                                let index1 = self.followArray.index(of: obj1.objectId!)
                                    
                                let index2 = self.followArray.index(of: obj2.objectId!)
                                return index1! < index2!

                            })
                            
                            //根据 created at 排序
                            for object in sortedoObjects! {
                                
                                self.usernameArray.append(object.value(forKey: "username") as! String)
                                self.useravaArray.append(object.value(forKey: "ava") as! PFFile)
                                self.typeArray.append((object.value(forKeyPath: "type") as! Bool) == true ? "收容所" : "个人")
                                self.userIDArray.append(object.objectId!)
                                
                                self.tableView.reloadData()
                                
                            }
                        } else {
                            
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    
                    print(error!.localizedDescription)
                }
                
            })
            
            
        }
        
        
        //load followings
        func  loadFollowees() {
            
            
            let followQuery = PFQuery(className: "Follow")
            
            followQuery.whereKey("followee", equalTo: userFollow)
            followQuery.findObjectsInBackground (block: { (objects, error) in
                if error == nil {
                    
                    //clean up
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    //find related objects
                    for object in objects! {
                        self.followArray.append(object.value(forKey: "follower") as! String)
                    }
                    
                    let query = PFUser.query()
                    query?.whereKey("objectId", containedIn: self.followArray)
                    query?.addAscendingOrder("createdAt")
                    query?.findObjectsInBackground(block: { (objects, error) in
                        
                        if error == nil {
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.useravaArray.removeAll(keepingCapacity: false)
                            self.typeArray.removeAll(keepingCapacity: false)
                            self.userIDArray.removeAll(keepingCapacity: false)
                            
                            let sortedoObjects = objects?.sorted(by: { (obj1, obj2) -> Bool in
                                let index1 = self.followArray.index(of: obj1.objectId!)
                                let index2 = self.followArray.index(of: obj2.objectId!)
                                return index1! < index2!
                                
                            })
                            
                            for object in sortedoObjects! {
                                self.usernameArray.append(object.value(forKey: "username") as! String)
                                self.useravaArray.append(object.value(forKey: "ava") as! PFFile)
                                self.typeArray.append((object.value(forKeyPath: "type") as! Bool) == true ? "收容所" : "个人")
                                self.userIDArray.append(object.objectId!)

                                self.tableView.reloadData()
                            }
                        } else {
                            
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    
        
        // MARK: - Table view data source
            //cell number
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return userIDArray.count
        }
 
        
                //cell configuration
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            //define cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
            
            //get data from server
            useravaArray[indexPath.row].getDataInBackground { (data, error) in
                if error == nil {
                    
                    cell.userAva.image = UIImage(data: data!)
                    
                } else {
                    
                    print(error!.localizedDescription)
                }
            }
           
            // connect cell's objects with received infromation from server
            cell.usernameLbl.text = usernameArray[indexPath.row]
            cell.userTypeBtn.setTitle(typeArray[indexPath.row], for: UIControlState())
            cell.userIDLbl.text = userIDArray[indexPath.row]

         
            let query = PFQuery(className: "Follow")
            query.whereKey("followee", equalTo: userIDArray[indexPath.row])
            query.countObjectsInBackground { (count, error) in
                
                cell.followercountLbl.text = "\(count)"
        
            }

            
            // STEP 2. Hide follow button for current user
            if PFUser.current() == nil || cell.userIDLbl.text == PFUser.current()?.objectId {
                cell.followBtn.isHidden = true
            } else {
            
            // STEP 3. Show do current user following or do not if current user is not null
            
                let query = PFQuery(className: "Follow")
                query.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                query.whereKey("followee", equalTo: cell.userIDLbl.text!)
                query.countObjectsInBackground (block: { (count, error) -> Void in
                    if error == nil {
                        cell.followBtn.isHidden = false
                        if count == 0 {
                            cell.followBtn.setTitle("+ 关注", for: UIControlState.normal)
                            cell.followBtn.layer.borderColor = self.green.cgColor
                            cell.followBtn.setTitleColor(self.green, for: UIControlState())
                        } else {
                            cell.followBtn.setTitle("已关注", for: UIControlState.normal)
                            cell.followBtn.layer.borderColor = UIColor.lightGray.cgColor
                            cell.followBtn.setTitleColor(.lightGray, for: UIControlState())
                        }
                        
                    }
                    
                })
            
            }
            
            return cell
        }
        
        // selected some user
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            
            let cell = tableView.cellForRow(at: indexPath) as! UserCell
            
            // if user tapped on his name go home, else go guest
            //if cell.usernameLbl.text! == PFUser.current()?.username {
            //     let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            //      self.navigationController?.pushViewController(home, animated: true)
            // } else {
            
            userID.append(cell.userIDLbl.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            
            //隐藏tab bar
            guest.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(guest, animated: true)
            /*
            
            // recall cell to call further cell's data
            let cell = tableView.cellForRow(at: indexPath) as! UserCell
            
            // if user tapped on himself, go home, else go guest
            if cell.usernameLbl.text! == PFUser.current()!.username! {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                guestname.append(cell.usernameLbl.text!)
                let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
             */
        }
    
        
        func back() {
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        
    

}
