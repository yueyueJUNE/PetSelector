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
extension UIImage {
    func imageByCropToRect(rect:CGRect, scale:Bool) -> UIImage {
        
        var rect = rect
        var scaleFactor: CGFloat = 1.0
        if scale  {
            scaleFactor = self.scale
            rect.origin.x *= scaleFactor
            rect.origin.y *= scaleFactor
            rect.size.width *= scaleFactor
            rect.size.height *= scaleFactor
        }
        
        var image: UIImage? = nil;
        if rect.size.width > 0 && rect.size.height > 0 {
            let imageRef = self.cgImage!.cropping(to: rect)
            image = UIImage(cgImage: imageRef!, scale: scaleFactor, orientation: self.imageOrientation)
        }
        
        return image!
    }
}

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
    
    //保存可见的front imageview
    var VisibleFrontImageViews:NSMutableSet!=NSMutableSet()
    //保存可重用的front imageview
    var ReusedFrontImageViews:NSMutableSet!=NSMutableSet()
    //保存可见的back imageview
    var VisibleBackImageViews:NSMutableSet!=NSMutableSet()
    //保存可重用的back imageview
    var ReusedBackImageViews:NSMutableSet!=NSMutableSet()
    
  
    
    let green = UIColor.init(red: 0/255.0, green: 153/255.0, blue: 102/255.0, alpha: 1)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.subviews.first?.alpha = 1

        
        if userID.last == nil || userID.last == PFUser.current()?.objectId {
            NotificationCenter.default.addObserver(self, selector: #selector(resetimImage), name: Notification.Name(rawValue: "uploadImageSuccess"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        }
      
        self.tableView.register(UINib.init(nibName: "txtCell", bundle: nil), forCellReuseIdentifier: "txtCell")
        self.tableView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        navigationItem.title = "详情"
        //UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        
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
    
    
    func resetimImage(_ notification: Notification) {
        let type = notification.userInfo?["type"] as! String
        if type == "ava" {
            
            let image = notification.userInfo?["image"] as! UIImage
            let imageData = UIImageJPEGRepresentation(image, 1)
            let imageFile = PFFile(name: "userAva.jpg", data: imageData!)

            self.ownerAvaImage = imageFile
        }
        self.tableView.reloadData()
    }
    
    
    func refresh(_ notification: Notification) {
        let key = (notification.userInfo?["key"]) as! String
        
        if key == "用户名" {
            ownername = (notification.userInfo?["value"]) as? String
        }
        self.tableView.reloadData()

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
    
    
    
    func capture(_ scrollView: UIScrollView) -> UIImage {
        var image: UIImage? = nil
        
         UIGraphicsBeginImageContextWithOptions(CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height), false, UIScreen.main.scale)
        do {
            let savedContentOffset = scrollView.contentOffset
            let savedFrame = scrollView.frame
            scrollView.contentOffset = .zero
            
            scrollView.frame = CGRect(x: 0, y:0 , width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
            image = UIGraphicsGetImageFromCurrentImageContext()
            scrollView.contentOffset = savedContentOffset
            scrollView.frame = savedFrame
        }
        UIGraphicsEndImageContext()
        if image != nil {
            return image!
        }
        return UIImage()
    }


    
    func compose(withHeader header: UIImage, content: UIImage, footer: UIImage) -> UIImage {
        let size = CGSize(width: content.size.width, height: self.view.frame.size.width + content.size.height + footer.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        header.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width))
        content.draw(in: CGRect(x: 0, y: self.view.frame.size.width, width: content.size.width, height: content.size.height))
        footer.draw(in: CGRect(x: 0, y: self.view.frame.size.width + content.size.height, width: footer.size.width, height: footer.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
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
                let originalImage = self.capture(self.tableView)
                let width = originalImage.size.width
                let height = originalImage.size.height
                let content = originalImage.imageByCropToRect(rect: CGRect(x: 0, y: width, width: width, height: height - width), scale: true)

                shareParames.ssdkSetupShareParams(byText: "帮帮它App 专注领养 快来看看有没有心仪的那个它！",
                                                  images : self.compose(withHeader: self.shareImage, content: content, footer: UIImage()),
                                                  url : NSURL(string:"http://mob.com") as URL!,
                                                  title : "宠物信息分享",
                                                  type : SSDKContentType.image)

                ShareSDK.showShareActionSheet(nil, items: nil, shareParams: shareParames, onShareStateChanged: { (state, type, userdata, entity, error, end) in
                    switch state{
                        
                    case SSDKResponseState.success: print("分享成功")
                    case SSDKResponseState.fail:    print("分享失败,错误描述:\(error!)")
                    case SSDKResponseState.cancel:  print("分享取消")
                        
                    default:
                        break
                    }
                    
                })
                

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
                        
                       
                        // STEP 1. Delete post from server
                        let post = PFQuery(className: "Post")
                        post.whereKey("objectId", equalTo: petID.last!)
                        post.getFirstObjectInBackground(block: { (object, error) in
                            if error == nil {
                                
                                let petphotos = PFQuery(className: "petphotos")
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
            
            Generate_ScrollView()
            //pictureGallery()
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

    
    func Generate_ScrollView()  {
        let totalCount:Int = petImageArray.count
        //image width
        let imageW:CGFloat = UIScreen.main.bounds.size.width //获取屏幕的宽作为图片的宽；
        let contentW:CGFloat = imageW * CGFloat(totalCount)//这里的宽度就是所有的图片宽度之和；
        photoGallery?.contentSize = CGSize(width: contentW, height: imageW)
        photoGallery?.isPagingEnabled = true
        photoGallery?.delegate = self
        
        self.pageControl.numberOfPages = totalCount//下面的页码提示器
        if totalCount > 0 {
            ShowImageViewAtIndex(index: 0)  //显示第一张照片
        }
        self.pageControl.numberOfPages = totalCount
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.photoGallery {
            ShowImage()
            let scrollviewW: CGFloat = photoGallery!.frame.size.width
            let x: CGFloat = photoGallery!.contentOffset.x
            backgroundscrollview?.contentOffset.x = x
            let page: Int = (Int)((x + scrollviewW / 2) / scrollviewW)
            self.pageControl.currentPage = page
        }
        
    }

    func ShowImage() {
        
        let bounds:CGRect = self.photoGallery!.bounds
        let minX:CGFloat = bounds.minX
        let maxX:CGFloat = bounds.maxX
        let width = UIScreen.main.bounds.size.width
        
        var first_index:NSInteger = (NSInteger)(minX / width)
        var last_index:NSInteger = (NSInteger)(maxX / width)
        
        if first_index < 0 {
            first_index = 0
        }
        
        if(last_index >= self.petImageArray.count) {
            last_index = self.petImageArray.count - 1
        }
        
        
        var index:NSInteger = 0
        
        for imageview in self.VisibleFrontImageViews {
            index = (imageview as AnyObject).tag
            
            // 不在显示范围内
            if (index < first_index || index > last_index) {
                self.ReusedFrontImageViews.add(imageview)
                (imageview as AnyObject).removeFromSuperview()
            }
        }
        
        for imageview in self.VisibleBackImageViews {
            index = (imageview as AnyObject).tag
            
            // 不在显示范围内
            if (index < first_index || index > last_index) {
                self.ReusedBackImageViews.add(imageview)
                (imageview as AnyObject).removeFromSuperview()
            }
        }

        
        //minusSet,求差集,所有属于A且不属于B的元素构成的集合
        self.VisibleFrontImageViews.minus(self.ReusedFrontImageViews as Set<NSObject>)
        self.VisibleBackImageViews.minus(self.ReusedBackImageViews as Set<NSObject>)

        
        // 是否需要显示新的视图
        for INDEX in first_index...last_index {
            var isShow:Bool = false
            
            for imgv in self.VisibleFrontImageViews {
                if (imgv as AnyObject).tag == INDEX {
                    isShow = true
                }
            }
            
            for imgv in self.VisibleBackImageViews {
                if (imgv as AnyObject).tag == INDEX {
                    isShow = true
                }
            }
            
            if(!isShow) {
                ShowImageViewAtIndex(index: INDEX)
            }
        }
    }
    
    func ShowImageViewAtIndex(index:NSInteger){
        
        var frontimageview:UIImageView? = self.ReusedFrontImageViews.anyObject() as! UIImageView!
        var backimageview:UIImageView? = self.ReusedBackImageViews.anyObject() as! UIImageView!

        if frontimageview != nil {
            self.ReusedFrontImageViews.remove(frontimageview!)  //imageview在重用集合中，则移除。
        } else {  //imageview不在重用集合，则创建
        
            frontimageview = UIImageView()
            frontimageview?.contentMode = UIViewContentMode.scaleAspectFit
            frontimageview?.backgroundColor = .clear
        }
        
        if backimageview != nil {
            self.ReusedBackImageViews.remove(backimageview!)  //imageview在重用集合中，则移除。
        } else {  //imageview不在重用集合，则创建
            
            backimageview = UIImageView()
            backimageview?.contentMode = UIViewContentMode.scaleAspectFill
            
        }

        let imageW:CGFloat = UIScreen.main.bounds.size.width //获取屏幕的宽作为图片的宽；
        //计算imageview显示的位置
        let imageX: CGFloat = CGFloat(index) * imageW

        frontimageview?.frame = CGRect(x:imageX, y:0, width: imageW, height: imageW)//设置图片的大小
        frontimageview?.tag = index
        backimageview?.frame = CGRect(x:imageX, y:0, width: imageW, height: imageW)//设置图片的大小
        backimageview?.tag = index
        
        //add image to imageview
        self.petImageArray[index].getDataInBackground(block: {(data, error) in
            if error == nil {
                frontimageview?.image = UIImage(data: data!)
                backimageview?.image = UIImage(data: data!)
            }
        })

        self.VisibleFrontImageViews.add(frontimageview!)  //imageview正显示，则将imageview添加进VisibleImageViews
        self.photoGallery?.addSubview(frontimageview!)
        
        self.VisibleBackImageViews.add(backimageview!)
        self.backgroundscrollview?.addSubview(backimageview!)
        
        //添加单击监听
        let tapSingle = UITapGestureRecognizer(target:self, action:#selector(imageViewTap(_:)))
        tapSingle.numberOfTapsRequired = 1
        frontimageview?.isUserInteractionEnabled = true
        frontimageview?.addGestureRecognizer(tapSingle)
    
    }
    /*
      func pictureGallery(){   //实现图片滚动播放；
        //image width
        let imageW:CGFloat = UIScreen.main.bounds.size.width //获取屏幕的宽作为图片的宽；
       
        let totalCount:Int = petImageArray.count

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
             backgroundscrollview?.addSubview(backgroungView)
            photoGallery?.addSubview(imageView)//把图片加入到ScrollView中去，实现轮播的效果；
        }
        
        //需要非常注意的是：ScrollView控件一定要设置contentSize;包括长和宽；
        let contentW:CGFloat = imageW * CGFloat(totalCount)//这里的宽度就是所有的图片宽度之和；
        photoGallery?.contentSize = CGSize(width: contentW, height: imageW)
        photoGallery?.isPagingEnabled = true
        photoGallery?.delegate = self
        
        self.pageControl.numberOfPages = totalCount//下面的页码提示器
        
    }
       */
       
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
