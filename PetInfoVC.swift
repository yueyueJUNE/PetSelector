//
//  PetInfoVC.swift
//  LocationSelector
//
//  Created by 刘月 on 7/8/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit
import Parse

var userID = [String]()

class PetInfoVC: UITableViewController {
    
    var timer:Timer!
    var photoIdArray = [String]()
    var owner: String!
    var petImageArray = [PFFile]()
    var ownerAvaImage : PFFile!
    var petname: String!
    var breed: String!
    var location: String!
    var gender: String!
    var age: String!
    var size: String!
    var shareImage: UIImage!
    
    var neuter: String?
    var shot: String?
    var deworm: String?
    var collected: Bool?
    var ownername: String!
    var ownerType: String!
    
    var contact: String!
    var story: String!
    var like: String!
    var follow: String?
    
    var pageControl: UIPageControl!
    var photoGallery: UIScrollView?
    var backgroundscrollview : UIScrollView?
    
    let green = UIColor.init(red: 0/255.0, green: 153/255.0, blue: 102/255.0, alpha: 1)

    override func viewWillAppear(_ animated: Bool) {
        
       // (self.tabBarController as! TabBarVC).postBtn.isHidden = self.hidesBottomBarWhenPushed
       // (self.tabBarController as! TabBarVC).view.bringSubview(toFront: (self.tabBarController as! TabBarVC).postBtn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.subviews.first?.alpha = 1

      
        self.tableView.register(UINib.init(nibName: "txtCell", bundle: nil), forCellReuseIdentifier: "txtCell")
        
        self.tableView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        navigationItem.title = "详情"
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        
        //new back button
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let moreBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "more"), style: .plain, target: self, action: #selector(moreBtn_clicked))
        self.navigationItem.rightBarButtonItem = moreBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        self.tableView.estimatedRowHeight=100
        self.tableView.rowHeight=UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20))
        
        loadData()
        
    }
    
    func moreBtn_clicked() {
        var otherTitles: [String]!

        if PFUser.current() == nil {
        
            JJHUD.showText(text: "请先登录", delay: 1.25, enable: false)

        } else {
            
            let query = PFQuery(className: "Collection")
            query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
            query.whereKey("petId", equalTo: petID.last!)
            query.countObjectsInBackground (block: { (count, error) -> Void in
                if error == nil {
                    //如果是本人发布的post
                    if PFUser.current()!.objectId == self.owner {

                        if count == 0 {

                            let postQuery = PFQuery(className: "Post")
                            postQuery.whereKey("objectId", equalTo: petID.last!)
                            postQuery.getFirstObjectInBackground(block: { (object, error) in
                                if error == nil {
                                    let adopted = object?.value(forKey: "adopted") as! Bool
                                    
                                    if adopted {
                                        otherTitles = ["收藏","分享","设为待领养","删除"]
                                    } else {
                                        otherTitles = ["收藏","分享","设为已送养","删除"]
                                    }
                                    self.showActionSheet(otherTitles)
                                }
                            })
                        } else {
                            let postQuery = PFQuery(className: "Post")
                            postQuery.whereKey("objectId", equalTo: petID.last!)
                            postQuery.getFirstObjectInBackground(block: { (object, error) in
                                if error == nil {
                                    let adopted = object?.value(forKey: "adopted") as! Bool
                                    
                                    if adopted {
                                        otherTitles = ["取消收藏","分享","设为待领养","删除"]
                                    } else {
                                        otherTitles = ["取消收藏","分享","设为已送养","删除"]
                                    }
                                    self.showActionSheet(otherTitles)
                                }
                            })
                        }
                    //如果不是本人发布的
                    } else {
                    
                        if count == 0 {
                            otherTitles = ["收藏","分享"]
                        } else {
                            otherTitles = ["取消收藏","分享"]
                        }
                        self.showActionSheet(otherTitles)
                    
                    }
                }
            })
        
        }
    }
    
    
    func showActionSheet(_ otherTitles: [String]!) {
        let actionSheet = SRActionSheet.sr_actionSheetView(withTitle: nil, cancelTitle: "取消", destructiveTitle: nil, otherTitles: otherTitles, otherImages: nil) { (actionSheet, index) in
            
            if index == 0 {
                if otherTitles[index] == "取消收藏" {
                     let collectionSheet = SRActionSheet.sr_actionSheetView(withTitle: "取消后将无法恢复", cancelTitle: "取消", destructiveTitle: nil, otherTitles: ["取消收藏"], otherImages: nil) { (actionSheet, actionIndex) in
                    
                        if actionIndex == 0 {
                            //add favorites to Collection
                            let collectObj = PFQuery(className: "Collection")
                            collectObj.whereKey("userId", equalTo: PFUser.current()!.objectId!)
                            collectObj.whereKey("petId", equalTo: petID.last!)
                            collectObj.getFirstObjectInBackground(block: { (object, error) in
                                if error == nil {
                                    object?.deleteInBackground(block: { (success, error) in
                                        if success {
                                            JJHUD.showSuccess(text: "已取消收藏", delay: 1, enable: false)
                                        } else {
                                            JJHUD.showError(text: "取消收藏未成功", delay: 1, enable: false)
                                        }
                                    })
                                }
                            })
                        }
                    }
                    collectionSheet?.show()
                    
                } else {
                    
                    //add favorites to Collection
                    let collectObj = PFObject(className: "Collection")
                    collectObj["userId"] = PFUser.current()!.objectId!
                    collectObj["petId"] = petID.last!
                    collectObj.saveInBackground(block: { (success, error) -> Void in
                        if success {
                            JJHUD.showSuccess(text: "已收藏", delay: 1, enable: false)
                        } else {
                            JJHUD.showError(text: "收藏未成功", delay: 1, enable: false)
                        }
                    })
                }
 
            } else if index == 1 {
                
                
                // 1.创建分享参数
                let shareParames = NSMutableDictionary()
                shareParames.ssdkEnableUseClientShare()
                
                SSUIShareActionSheetStyle.setShareActionSheetStyle(ShareActionSheetStyle.simple)
        
                
                shareParames.ssdkSetupShareParams(byText: "分享内容test",
                                                  images : self.shareImage,
                                                  url : NSURL(string:"http://mob.com") as URL!,
                                                  title : "分享标题hhh",
                                                  type : SSDKContentType.app)

                ShareSDK.showShareActionSheet(nil, items: nil, shareParams: shareParames, onShareStateChanged: { (state, type, userdata, entity, error, end) in
                    switch state{
                        
                    case SSDKResponseState.success: print("分享成功")
                    case SSDKResponseState.fail:    print("分享失败,错误描述:\(error!)")
                    case SSDKResponseState.cancel:  print("分享取消")
                        
                    default:
                        break
                    }
                    
                })
                
                /*
                ShareSDK.showShareActionSheet(nil, items: nil, shareParams: shareParames, onShareStateChanged: {(_ state: SSDKResponseState, _ platformType: SSDKPlatformType, _ userData: [AnyHashable: Any], _ contentEntity: SSDKContentEntity, _ error: Error?, _ end: Bool) -> Void in
                    switch state {
                    case SSDKResponseStateSuccess:
                        var alertView = UIAlertView(title: "Share Success!", message: "", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
                        alertView.show()
                    case SSDKResponseStateFail:
                        var alert = UIAlertView(title: "Share Fail", message: "\(error)", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
                        alert.show()
                    default:
                        break
                    }
                    
                } as! SSUIShareStateChangedHandler)
                */
                /*
                ShareSDK.showShareActionSheet(nil, items: [SSDKPlatformType.typeSinaWeibo, SSDKPlatformType.typeWechat], shareParams: shareParames, onShareStateChanged: { (state : SSDKResponseState, platformType : SSDKPlatformType, userdata: [AnyHashable : Any]?, contentEnity : SSDKContentEntity?, error : Error?, end : Bool) in
                    
                    switch state{
                        
                    case SSDKResponseState.success: print("分享成功")
                    case SSDKResponseState.fail:    print("分享失败,错误描述:\(error)")
                    case SSDKResponseState.cancel:  print("分享取消")
                        
                    default:
                        break
                    }
                })
                
            */
                
                
              
                /*
                
                //2.进行分享
                ShareSDK.share(SSDKPlatformType.typeSinaWeibo, parameters: shareParames) { (state : SSDKResponseState, nil, entity : SSDKContentEntity?, error :Error?) in
                    
                    switch state{
                        
                    case SSDKResponseState.success: print("分享成功")
                    case SSDKResponseState.fail:    print("授权失败,错误描述:\(error!)")
                    case SSDKResponseState.cancel:  print("操作取消")
                        
                    default:
                        break
                    }
                }
 
 */
            } else if index == 2 {
                 if otherTitles[index] == "设为待领养" {
                    //adopted
                    let adoptionObj = PFQuery(className: "Post")
                    adoptionObj.whereKey("objectId", equalTo: petID.last!)
                    adoptionObj.getFirstObjectInBackground(block: { (object, error) in
                        if error == nil {
                            
                            object?["adopted"] = false
                            object?.saveInBackground(block: { (success, error) in
                                if success {

                                    JJHUD.showSuccess(text: "设置成功", delay: 1, enable: false)
                                    //NotificationCenter.default.post(name: Notification.Name(rawValue: "deletePost"), object: nil)

                                } else {
                                    JJHUD.showError(text: "设置未成功", delay: 1, enable: false)
                                }
                            })
                        
                        }
                    })
                 } else {
                    //adopted
                    let adoptionObj = PFQuery(className: "Post")
                    adoptionObj.whereKey("objectId", equalTo: petID.last!)
                    adoptionObj.getFirstObjectInBackground(block: { (object, error) in
                        if error == nil {
                            
                            object?["adopted"] = true
                            object?.saveInBackground(block: { (success, error) in
                                if success {
                                    JJHUD.showSuccess(text: "设置成功", delay: 1, enable: false)
                                    //NotificationCenter.default.post(name: Notification.Name(rawValue: "deletePost"), object: nil)

                                } else {
                                    JJHUD.showError(text: "设置未成功", delay: 1, enable: false)
                                }
                            })
                            
                        }
                    })
                }
                
            } else if index == 3 {
                
                let deleteactionSheet = SRActionSheet.sr_actionSheetView(withTitle: "删除后将无法恢复", cancelTitle: "取消", destructiveTitle: nil, otherTitles: ["删除"], otherImages: nil) { (actionSheet, actionIndex) in
                    if actionIndex == 0 {
                        
                       
                        // STEP 1. Delete comment from server
                        let post = PFQuery(className: "Post")
                        post.whereKey("objectId", equalTo: petID.last!)
                        post.getFirstObjectInBackground(block: { (object, error) in
                            if error == nil {
                                
                                let petphotos = PFQuery(className: "object")
                                petphotos.whereKey("objectId", containedIn: object?.value(forKey: "petphotos") as! [String])
                                //delete related photos
                                petphotos.findObjectsInBackground(block: { (objects, error) in
                                    
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                                //delete likes on the pet
                                let likequery = PFQuery(className: "Like")
                                likequery.whereKey("petId", equalTo: petID.last!)
                                likequery.findObjectsInBackground(block: { (objects, error) in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                                
                                //delete collection on the pet
                                let collectquery = PFQuery(className: "Collection")
                                collectquery.whereKey("petId", equalTo: petID.last!)
                                collectquery.findObjectsInBackground(block: { (objects, error) in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                                
                                object?.deleteEventually()
                                self.back()
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "deletePost"), object: nil)

                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                }
                
                deleteactionSheet?.show()
            
            }
        }
        actionSheet?.show()
    
    }
  
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let basiccell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! PetHeaderCell
            basiccell.ageLbl.text = age
            basiccell.petnameLbl.text = petname
            basiccell.locationLbl.text = location
            basiccell.genderLbl.text = gender
            basiccell.ageLbl.text = age
            basiccell.sizeLbl.text = size
            basiccell.neuterBtn.setTitle(neuter, for: .normal)
            basiccell.shotBtn.setTitle(shot, for: .normal)
            basiccell.dewormBtn.setTitle(deworm, for: .normal)
            basiccell.breedBtn.setTitle(breed, for: .normal)
            
           
            
            let green = UIColor.init(red: 0/255.0, green: 128/255.0, blue: 0/255.0, alpha: 1)
            
            if neuter == "已绝育" {
                basiccell.neuterBtn.setTitleColor(green, for: UIControlState())
            } else if neuter == "未绝育" {
                basiccell.neuterBtn.setTitleColor(.red, for: UIControlState())
            }
            
            if shot == "已注射疫苗" {
                basiccell.shotBtn.setTitleColor(green, for: UIControlState())
            
            } else if shot == "未注射疫苗" {
                basiccell.shotBtn.setTitleColor(.red, for: UIControlState())
            }
            
            if deworm == "已驱虫" {
                basiccell.dewormBtn.setTitleColor(green, for: UIControlState())
                
            } else if deworm == "未驱虫" {
                basiccell.dewormBtn.setTitleColor(.red, for: UIControlState())
            }

            self.backgroundscrollview = basiccell.backgroundscrollview
            self.pageControl = basiccell.pageControl
            self.photoGallery = basiccell.photoGallery
            
            pictureGallery()
            return basiccell
            
        } else if indexPath.section == 1 {
        
            let usercell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
            usercell.usernameLbl.text = ownername

            usercell.userTypeBtn.setTitle(ownerType, for: UIControlState())
            usercell.userIDLbl.text = owner
            
            if owner != nil {
                let query = PFQuery(className: "Follow")
                query.whereKey("followee", equalTo: owner)
                query.countObjectsInBackground { (count, error) in
                    
                    usercell.followercountLbl.text = "\(count)"
                }
            }
            
            
            if PFUser.current() != nil {
                
                if owner == PFUser.current()!.objectId {
                    usercell.followBtn.isHidden = true
                } else {
                    usercell.followBtn.isHidden = false
                    usercell.followBtn.setTitle(follow, for: UIControlState.normal)
                    
                    if follow == "+ 关注" {
                        usercell.followBtn.layer.borderColor = green.cgColor
                        usercell.followBtn.setTitleColor(green, for: UIControlState())
                        
                    } else if follow == "已关注" {
                        usercell.followBtn.layer.borderColor = UIColor.lightGray.cgColor
                        usercell.followBtn.setTitleColor(.lightGray, for: UIControlState())
                        
                    }
                }
                
            } else if PFUser.current() == nil {
                // hide follow button
                usercell.followBtn.isHidden = true
            }
            
            self.ownerAvaImage?.getDataInBackground(block: { (data, error) in
                
                if error == nil {
                    usercell.userAva.image = UIImage(data: data!)
                } else {
                
                    print(error!.localizedDescription)
                
                }
                
            })
        
            return usercell
        } else if indexPath.section == 2 {
            
            let txtCell = tableView.dequeueReusableCell(withIdentifier: "txtCell", for: indexPath) as! txtCell
            txtCell.txtLbl.text = contact
            return txtCell
            
        } else if indexPath.section == 3  {
        
            let txtCell = tableView.dequeueReusableCell(withIdentifier: "txtCell", for: indexPath) as! txtCell
            txtCell.txtLbl.text = story
            return txtCell
            
        } else if indexPath.section == 4 {
            
            let txtCell = tableView.dequeueReusableCell(withIdentifier: "txtCell", for: indexPath) as! txtCell
            txtCell.txtLbl.text = like
            return txtCell
        }
        
        return UITableViewCell()
        
    }
    
    

    
    // selected the user cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        userID.append(owner!)
        // if user tapped on himself, go home, else go guest
        if indexPath.section == 1 {
            let user = self.storyboard!.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            user.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(user, animated: true)
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
            
        let myView = UIView(frame: CGRect(x: 0, y: 0, width:
            self.view.frame.size.width, height: 40))
        
        myView.backgroundColor = UIColor.clear
        let backgrounfView = UIView (frame: CGRect(x:0, y:10, width: self.view.frame.size.width, height: 29.5))
        let titleLabel = UILabel(frame: CGRect(x:0, y:0, width: self.view.frame.size.width, height: 29.5))
        
        let line = UILabel(frame: CGRect(x: 10, y: 29.5, width:
            self.view.frame.size.width, height: 0.5))
        
        backgrounfView.addSubview(titleLabel)
        backgrounfView.addSubview(line)
        backgrounfView.backgroundColor = .white
        line.backgroundColor = .lightGray
        
        titleLabel.textColor = green
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.backgroundColor = UIColor.white
        titleLabel.textAlignment = .center
        if petname == nil {petname = "它"}
        if section == 2 {
            titleLabel.text = "联系方式"
            myView.addSubview(backgrounfView)
            return myView
        
        }
        if section == 3 {
            
            titleLabel.text = "\(petname!)的故事"
            myView.addSubview(backgrounfView)
            return myView
        }
        else if section == 4 {
            titleLabel.text = "\(petname!)的喜好"
            myView.addSubview(backgrounfView)
            return myView
        }
       
        return UIView()
       
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0
        }
        return 40
    }

    
    // load posts
    func loadData() {
        // STEP 1. Find posts according to petID
        let query = PFQuery(className: "Post")
        query.whereKey("objectId", equalTo: petID.last!)
        
        query.getFirstObjectInBackground {
            (object, error) in
            if error == nil {
                
                //clean up
                self.photoIdArray.removeAll(keepingCapacity: false)
                
                //将照片ID存入array
                self.photoIdArray = object!.value(forKey: "petphotos") as! [String]
                (object!.value(forKey: "petava") as! PFFile).getDataInBackground(block: { (data, error) in
                    if error == nil {
                        self.shareImage = UIImage(data: data!)

                    }
                })

                self.owner = object!.value(forKey: "owner") as? String
                self.petname = object!.value(forKey: "petname") as! String
                let str = object!.value(forKey: "breed") as! String
                let index = str.index(str.startIndex, offsetBy: 1)
                self.breed = "\(str.substring(from: index))"
                self.location = object!.value(forKey: "location") as! String
                self.gender = object!.value(forKey: "gender") as! String
                self.age = object!.value(forKey: "age") as! String
                self.size = object!.value(forKey: "size") as! String
                self.neuter = (object!.value(forKey: "neuter") as! Bool) == true ? "已绝育" : "未绝育"
                self.shot = (object!.value(forKey: "shot") as! Bool) == true ? "已注射疫苗" : "未注射疫苗"
                self.deworm = (object!.value(forKey: "deworm") as! Bool) == true ? "已驱虫" : "未驱虫"
                self.contact = object!.value(forKey: "contact") as! String
                self.story = object!.value(forKey: "story") as! String
                self.like = object!.value(forKey: "like") as! String
                self.tableView.reloadData()
                
                let photoQuery = PFQuery(className: "petphotos")
                photoQuery.whereKey("objectId", containedIn: self.photoIdArray)
                
                photoQuery.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        
                        //clean up
                        self.petImageArray.removeAll(keepingCapacity: false)
                        
                        for i in 0..<objects!.count {
                            
                            //将照片存入imageArray
                            self.petImageArray.append(objects![i].value(forKey: "petphoto") as! PFFile)
                        }
                        
                        self.tableView.reloadData()

                    } else {
                        
                        print(error!.localizedDescription)
                    }
                })
                
                let ownerQuery = PFUser.query()
                ownerQuery!.whereKey("objectId", equalTo: self.owner!)
                ownerQuery!.getFirstObjectInBackground(block: { (object, error) in
                    if error == nil {
                        
                        self.ownername = object!.value(forKeyPath: "username") as! String
                        self.ownerType = (object!.value(forKeyPath: "type") as! Bool) == true ? "收容所" : "个人"
                        self.ownerAvaImage = object!.value(forKeyPath: "ava") as! PFFile
                        
                        
                        if PFUser.current() != nil {
                            let followQuery = PFQuery(className: "Follow")
                            followQuery.whereKey("followee", equalTo: object!.objectId!)
                            followQuery.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                            followQuery.countObjectsInBackground(block: { (count, error) in
                                if error == nil {
                                    
                                    if count == 0 {
                                        self.follow = "+ 关注"
                                        
                                    } else {
                                        self.follow = "已关注"
                                    }
                                    if self.follow != nil {
                                        
                                        // reload
                                        self.tableView.reloadData()
                                        
                                    }
                                } else {
                                    print(error!.localizedDescription)
                                }
                                
                            })
                            
                        } else {
                                // reload
                                self.tableView.reloadData()
                        }
                        
                        
                        if PFUser.current() != nil {
                            let followQuery = PFQuery(className: "Follow")
                            followQuery.whereKey("followee", equalTo: self.owner!)
                            followQuery.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                            followQuery.getFirstObjectInBackground(block: {(object, error) in
                                if error == nil {
                                    self.follow = "已关注"
                                } else {
                                    self.follow = "+ 关注"

                                }
                                self.tableView.reloadData()
                            })
                        
                        } else {
                        
                        
                            self.tableView.reloadData()

                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
                
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    
    func pictureGallery(){   //实现图片滚动播放；
        //image width
        let imageW:CGFloat = UIScreen.main.bounds.size.width //获取屏幕的宽作为图片的宽；
       
        let totalCount:Int = petImageArray.count//轮播的图片数量；

        for index in 0..<totalCount{
            let backgroungView: UIImageView = UIImageView()
            backgroungView.contentMode = .scaleToFill
            
            let imageView: UIImageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .clear
            let imageX: CGFloat = CGFloat(index) * imageW
            backgroungView.frame = CGRect(x:imageX, y:0, width: imageW, height: imageW)//设置图片的大小
            imageView.frame = CGRect(x:imageX, y:0, width: imageW, height: imageW)//设置图片的大小
            imageView.tag = index
            //添加单击监听
            let tapSingle=UITapGestureRecognizer(target:self, action:#selector(imageViewTap(_:)))
            tapSingle.numberOfTapsRequired = 1
            tapSingle.numberOfTouchesRequired = 1
            imageView.addGestureRecognizer(tapSingle)
            
            //add image to imageview
            self.petImageArray[index].getDataInBackground(block: { (data, error) in
                if error == nil {
                    imageView.image = UIImage(data: data!)
                    backgroungView.image = UIImage(data: data!)

                }
            })
            
            imageView.isUserInteractionEnabled = true
            //self.view.addSubview(imageView)
            
            backgroundscrollview?.addSubview(backgroungView)
            photoGallery?.addSubview(imageView)//把图片加入到ScrollView中去，实现轮播的效果；

        }
       
        
        //需要非常注意的是：ScrollView控件一定要设置contentSize;包括长和宽；
        let contentW:CGFloat = imageW * CGFloat(totalCount)//这里的宽度就是所有的图片宽度之和；
        photoGallery?.contentSize = CGSize(width: contentW, height: imageW)
        photoGallery?.isPagingEnabled = true
        photoGallery?.delegate = self
        
        self.pageControl.numberOfPages = totalCount//下面的页码提示器；
        
    }
    
   
    
    
       
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            if scrollView == self.photoGallery {
                
                let scrollviewW: CGFloat = photoGallery!.frame.size.width
                let x: CGFloat = photoGallery!.contentOffset.x
                backgroundscrollview?.contentOffset.x = x
                let page: Int = (Int)((x + scrollviewW / 2) / scrollviewW)
                self.pageControl.currentPage = page
            }

    }
        //这里的代码是在ScrollView滚动后执行的操作，并不是执行ScrollView的代码；
        //这里只是为了设置下面的页码提示器；该操作是在图片滚动之后操作的；
        
    
    //缩略图imageView点击
    func imageViewTap(_ recognizer:UITapGestureRecognizer) {
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: petImageArray, index: index)
        self.navigationController!.pushViewController(previewVC, animated: true)
    }
    
    
    func back() {
        _ = self.navigationController!.popViewController(animated: true)
        
        if !petID.isEmpty {
            petID.removeLast()
        }
    }
    

}
