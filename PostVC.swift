//
//  postVC.swift
//  LocationSelector
//
//  Created by 刘月 on 7/6/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit
import Parse

var petID = [String]()

class postVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    //private var totalRowCount: Int = 0
    private var refreshFooter:  SDRefreshFooterView?
    weak var weakRefreshHeader: SDRefreshHeaderView?
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIView!
    
    // page size
    var page : Int!
    
    //arrays to hold info from Post
    var petavaArray = [PFFile]()
    var petnameArray = [String]()
    var breedArray = [String]()
    var genderArray = [String]()
    var ageArray = [String]()
    var sizeArray = [String]()
    var dateArray = [Date?]()
    var petIDArray = [String]()
    var ownerIDArray = [String]()

    var offset: CGPoint!

    enum type:UInt {
        case endHeader = 1
        case endFooter = 2
        case endLoading = 3
    }
    
    
    // default func
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //evey time the view will appear, set the page to 10.显示十项
        
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 99.5
        self.tableView.rowHeight=UITableViewAutomaticDimension
        
        // receive notification from uploadPhoto if picture is liked, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(uploadFail), name: Notification.Name(rawValue: "uploadFail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uploadSuccess), name: Notification.Name(rawValue: "uploadSuccess"), object: nil)
        
        //上传 indicator
        NotificationCenter.default.addObserver(self, selector: #selector(beginActivityIndicator), name: Notification.Name(rawValue: "beginActivityIndicator"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopActivityIndicator), name: Notification.Name(rawValue: "stopActivityIndicator"), object: nil)
        
        
        // calling function to load posts
        self.tableView.register(UINib.init(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "Cell")
         NotificationCenter.default.addObserver(self, selector: #selector(resetPage), name: NSNotification.Name(rawValue: "setFilter"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "setFilter"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "deletePost"), object: nil)

        
       page = 10
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "signIn"), object: nil)
        
        self.activityIndicator.isHidden = true
    
        setupHeader()
        setupFooter()

        
    }
    
    
    
    @IBAction func tapFllter(_ sender: Any) {
        let filter = self.storyboard?.instantiateViewController(withIdentifier: "filter")// as! navVC
        //filter.hidesBottomBarWhenPushed = true
        //self.navigationController?.pushViewController(filter, animated: true)
        self.present(filter!, animated: true, completion: nil)
    }
    
    func resetPage() {
        page = 10
    
    }
   
    
    func setupHeader() {
        
        let refreshHeader = SDRefreshHeaderView()
        refreshHeader.add(toScroll: self.tableView)
        //weak var weakRefreshHeader: SDRefreshHeaderView? = refreshHeader
        weakRefreshHeader = refreshHeader

        //weak var weakSelf = self
        refreshHeader.beginRefreshingOperation = {() -> Void in
            
            self.loadPets(.endHeader)
   
        }
        
        // 进入页面自动加载一次数据
        refreshHeader.autoRefreshWhenViewDidAppear()
    }
    
    
    func setupFooter() {
        let refreshFooter = SDRefreshFooterView()
        refreshFooter.add(toScroll: self.tableView)
        refreshFooter.addTarget(self, refreshAction: #selector(self.footerRefresh))
        self.refreshFooter = refreshFooter
    }
    
    func footerRefresh() {
        
        if page <= petIDArray.count {
            
            // increase page size to load +10 posts
            page = page + 10
            loadPets(.endFooter)
        } else {
            self.refreshFooter?.endRefreshing()

        }

    }
    
    
    func beginActivityIndicator()  {
        self.activityIndicator.isHidden = false
    }
    
    func stopActivityIndicator()  {
        self.activityIndicator.isHidden = true
    }
    
    
    // load posts
    func loadPosts() {
        JJHUD.showLoading(text: "正在加载")
        loadPets(.endLoading)
    }
  
    
    
    func loadPets(_ endfreshType: type) {
        
        // STEP 1. Find posts according to time updated
        let query = PFQuery(className: "Post")
        
        if !genderFilter.isEmpty {
            query.whereKey("gender", containedIn: genderFilter)
        }
        if !ageFilter.isEmpty {
            query.whereKey("age", containedIn: ageFilter)
        }
        if !colorFilter.isEmpty {
            query.whereKey("color", containedIn: colorFilter)
        }
        if !sizeFilter.isEmpty {
            query.whereKey("size", containedIn: sizeFilter)
        }
        if !breedFilter.contains("不限") && !breedFilter.isEmpty {
            query.whereKey("breed", containedIn: breedFilter)
        }
        if location != "不限"  && location != "" {
            query.whereKey("location".trimmingCharacters(in: NSCharacterSet.whitespaces), equalTo: location.trimmingCharacters(in: NSCharacterSet.whitespaces))
        }

        query.limit = self.page
        query.addDescendingOrder("updatedAt")
               query.findObjectsInBackground(block:{ (objects, error) -> Void in
            
            if error == nil {
                
                //clean up
                self.petnameArray.removeAll(keepingCapacity: false)
                self.breedArray.removeAll(keepingCapacity: false)
                self.genderArray.removeAll(keepingCapacity: false)
                self.ageArray.removeAll(keepingCapacity: false)
                self.sizeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.petavaArray.removeAll(keepingCapacity: false)
                self.petIDArray.removeAll(keepingCapacity: false)
                self.ownerIDArray.removeAll(keepingCapacity: false)
                
                
                //match result == 0 , print nothing found
                if objects?.count == 0 || objects == nil {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
                    let notFoundLbl = UILabel()
                    notFoundLbl.frame.size = CGSize(width: view.frame.size.width, height: view.frame.size.height)
                    notFoundLbl.center = view.center
                    notFoundLbl.text = "没有搜索结果"
                    notFoundLbl.font = UIFont.systemFont(ofSize: 19)
                    notFoundLbl.textAlignment = .center
                    view.addSubview(notFoundLbl)
                    self.tableView.tableFooterView = view
                    self.offset = self.tableView.contentOffset

                    self.tableView.reloadData()
                    self.endRefreshByType(endfreshType)
                    
                } else {
                    self.tableView.tableFooterView = UIView()
                    
                    for object in objects! {
                        self.petIDArray.append(object.objectId!)
                        self.petnameArray.append(object.value(forKey: "petname") as! String)
                        self.petavaArray.append(object.value(forKey: "petava") as! PFFile)
                        self.ageArray.append(object.value(forKey: "age") as! String)
                        self.dateArray.append(object.updatedAt)
                        self.genderArray.append(object.value(forKey: "gender") as! String)
                        self.sizeArray.append(object.value(forKey: "size") as! String)
                        self.breedArray.append(object.value(forKey: "breed") as! String)
                        self.ownerIDArray.append(object.value(forKey: "owner") as! String)
                        
                        self.offset = self.tableView.contentOffset

                        self.tableView.reloadData()
                        self.endRefreshByType(endfreshType)
                        
                    }
                }
                
            } else {
                
                if error!.localizedDescription == "似乎已断开与互联网的连接。" || error!.localizedDescription == "Network connection failed." || error!.localizedDescription == "The Internet connection appears to be offline."{
                    let alert = UIAlertController(title: "网络问题", message: "似乎已断开与互联网的连接。", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
            }
        })
        
    }


    
    func endRefreshByType(_ type: type){
        switch type {
            case .endHeader:
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    
                    // weakSelf!.totalRowCount += 10
                    //下拉刷行 loadpost
                    self.weakRefreshHeader?.endRefreshing()
                }
            
                break
            
            case .endFooter:
                self.refreshFooter?.endRefreshing()
                self.tableView.contentOffset = offset

                break

            case .endLoading:
                //隐藏正在加载图标
                JJHUD.hide()
                break
        }
    }
    
    
    
    // cell numb
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petIDArray.count
    }

    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        cell.ageLbl.text = ageArray[indexPath.row]
        let str = breedArray[indexPath.row]
        let index = str.index(str.startIndex, offsetBy: 1)
        cell.breedLbl.setTitle(str.substring(from: index), for: .normal)
        cell.sizeLbl.text = sizeArray[indexPath.row]
        cell.genderLbl.text = genderArray[indexPath.row]
        cell.petnameLbl.text = petnameArray[indexPath.row]
        cell.idLbl.text = petIDArray[indexPath.row]
        
        // place pet picture
        petavaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.petavaImg.image = UIImage(data: data!)
        }
        
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .month, .year]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second! <= 0 {
            cell.dateLbl.text = "现在"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(difference.second ?? 0)秒前"
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(difference.minute ?? 0)分钟前"
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(difference.hour ?? 0)小时前"
        }
        if difference.day! > 0 && difference.month! == 0 {
            cell.dateLbl.text = "\(difference.day ?? 0)天前"
        }
        if difference.month! > 0 && difference.year! == 0  {
            cell.dateLbl.text = "\(difference.month ?? 0)个月前"
        }
        if difference.year! > 0 {
            cell.dateLbl.text = "\(difference.year ?? 0)年前"
        }
        
        if PFUser.current() != nil {
            
            // record do current user like the pet or do not if current user is not null
            
            let likeQuery = PFQuery(className: "Like")
            likeQuery.whereKey("userId", equalTo: PFUser.current()!.objectId!)
            likeQuery.whereKey("petId", equalTo: cell.idLbl.text!)
            likeQuery.countObjectsInBackground { (count, error) in
                if error == nil {
                    if count == 0 {
                        
                        cell.likeBtn.isSelected = false
                    } else {
                        
                        cell.likeBtn.isSelected = true
                        
                    }
                }
            }
            
            //record do current user collect the pet or do not if current user is not null

            let query = PFQuery(className: "Collection")
            query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
            query.whereKey("petId", equalTo: cell.idLbl.text!)
            query.countObjectsInBackground (block: { (count, error) -> Void in
                if error == nil {
                    if count == 0 {
                        cell.collectLbl.text = "false"
                    } else {
                        cell.collectLbl.text = "true"
                    }
                }
                
            })
            
        }
        
      
        // count total likes of shown post
        let countLikes = PFQuery(className: "Like")
        countLikes.whereKey("petId", equalTo: cell.idLbl.text!)
        countLikes.countObjectsInBackground { (count, error) -> Void in
            cell.likeLbl.text = "\(count)"
        }

        
        return cell
        
        
        /*
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        cell.ageLbl.text = ageArray[indexPath.row]
        let str = breedArray[indexPath.row]
        let index = str.index(str.startIndex, offsetBy: 1)
        cell.breedLbl.setTitle(str.substring(from: index), for: .normal)
        
        
        cell.sizeLbl.text = sizeArray[indexPath.row]
        cell.genderLbl.text = genderArray[indexPath.row]
        cell.petnameLbl.text = petnameArray[indexPath.row]
        cell.idLbl.text = petIDArray[indexPath.row]
        
        // place pet picture
        petavaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.petavaImg.image = UIImage(data: data!)
        }
        
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .month, .year]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second! <= 0 {
            cell.dateLbl.text = "现在"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(difference.second ?? 0)秒前"
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(difference.minute ?? 0)分钟前"
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(difference.hour ?? 0)小时前"
        }
        if difference.day! > 0 && difference.month! == 0 {
            cell.dateLbl.text = "\(difference.day ?? 0)天前"
        }
        if difference.month! > 0 && difference.year! == 0  {
            cell.dateLbl.text = "\(difference.month ?? 0)个月前"
        }
        if difference.year! > 0 {
            cell.dateLbl.text = "\(difference.year ?? 0)年前"
        }
 
        
        
        if PFUser.current() != nil {
            
            // record do current user like the pet or do not if current user is not null

            let likeQuery = PFQuery(className: "Like")
            likeQuery.whereKey("userId", equalTo: PFUser.current()!.objectId!)
            likeQuery.whereKey("petId", equalTo: cell.idLbl.text!)
            likeQuery.countObjectsInBackground { (count, error) in
                if error == nil {
                    if count == 0 {
                        
                        cell.likeBtn.isSelected = false

                    } else {
                        
                        cell.likeBtn.isSelected = true

                    }
                }
            }
            
            
            
            //record do current user collect the pet or do not if current user is not null
            let query = PFQuery(className: "Collection")
            query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
            query.whereKey("petId", equalTo: cell.idLbl.text!)
            query.countObjectsInBackground (block: { (count, error) -> Void in
                if error == nil {
                    if count == 0 {
                        cell.collectLbl.text = "false"
                    } else {
                        cell.collectLbl.text = "true"
                    }
                }
                
            })
            
        }
      
        
        // count total likes of shown post
        let countLikes = PFQuery(className: "Like")
        countLikes.whereKey("petId", equalTo: cell.idLbl.text!)
        countLikes.countObjectsInBackground { (count, error) -> Void in
            cell.likeLbl.text = "\(count)"
        }
        
       
        
        return cell
 
  */
    }
    
    
    
    
    
    
    
    
    
    // selected a pet
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // recall cell to call further cell's data
        let cell = tableView.cellForRow(at: indexPath) as! PostCell
        petID.append(cell.idLbl.text!)
        
        let pet = self.storyboard?.instantiateViewController(withIdentifier: "PetInfoVC") as! PetInfoVC
        
        //隐藏tab bar
        pet.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(pet, animated: true)
        
        
    }
    
    /*
    // swipe cell for actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
                
        // call cell for calling further cell data
        let cell = tableView.cellForRow(at: indexPath) as! PostCell
        
        
        // ACTION 1. Delete
        let delete = UITableViewRowAction(style: .normal, title: "删除") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            
            let actionSheet = SRActionSheet.sr_actionSheetView(withTitle: "删除后将无法恢复", cancelTitle: "取消", destructiveTitle: nil, otherTitles: ["删除"], otherImages: nil) { (actionSheet, actionIndex) in
                if actionIndex == 0 {
                    
                    
                    // STEP 1. Delete comment from server
                    let post = PFQuery(className: "Post")
                    post.whereKey("objectId", equalTo: cell.idLbl.text!)
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
                            likequery.whereKey("petId", equalTo: cell.idLbl.text!)
                            likequery.findObjectsInBackground(block: { (objects, error) in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                } else {
                                    print(error!.localizedDescription)
                                }
                            })
                            
                            //delete likes on the pet
                            let collectquery = PFQuery(className: "Collection")
                            collectquery.whereKey("petId", equalTo: cell.idLbl.text!)
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
                            
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                    
                    // close cell
                    self.tableView.setEditing(false, animated: true)
                    self.petavaArray.remove(at: indexPath.row)
                    self.petnameArray.remove(at: indexPath.row)
                    self.breedArray.remove(at: indexPath.row)
                    self.genderArray.remove(at: indexPath.row)
                    self.ageArray.remove(at: indexPath.row)
                    self.sizeArray.remove(at: indexPath.row)
                    self.dateArray.remove(at: indexPath.row)
                    self.petIDArray.remove(at: indexPath.row)
                    self.ownerIDArray.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    
                } else {
                    //点击取消
                    self.tableView.setEditing(false, animated: true)
                }
            }
            
            actionSheet?.show()
            
        }
        
        // ACTION 2. Collect
        let collect = UITableViewRowAction(style: .normal, title: "收藏") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            //add favorites to Collection
            let collectObj = PFObject(className: "Collection")
            collectObj["userId"] = PFUser.current()!.objectId!
            collectObj["petId"] = cell.idLbl.text!
            collectObj.saveInBackground(block: { (success, error) -> Void in
                if success {
                    
                    JJHUD.showSuccess(text: "已收藏", delay: 1 ,enable: false)
                } else {
                    JJHUD.showError(text: "收藏未成功", delay: 1)
                }
            })
            cell.collectLbl.text = "true"
            // close cell
            tableView.setEditing(false, animated: true)
        }
        
        
        // ACTION 3. unCollect
        let uncollect = UITableViewRowAction(style: .normal, title: "取消收藏") { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            //add favorites to Collection
            let collectObj = PFQuery(className: "Collection")
            collectObj.whereKey("userId", equalTo: PFUser.current()!.objectId!)
            collectObj.whereKey("petId", equalTo: cell.idLbl.text!)
            
            collectObj.getFirstObjectInBackground(block: { (object, error) in
                if error == nil {
                    object?.deleteInBackground(block: { (success, error) in
                        if success {
                            JJHUD.showSuccess(text: "已取消收藏", delay: 1 ,enable: false)
                        } else {
                            JJHUD.showError(text: "取消收藏未成功", delay: 1)
                        }
                    })
                }
            })
            cell.collectLbl.text = "false"
            
            // close cell
            tableView.setEditing(false, animated: true)
        }
        
        delete.backgroundColor = .red
        collect.backgroundColor = .gray
        uncollect.backgroundColor = .gray
        
        
        if cell.collectLbl.text == "true" {
            
            if self.ownerIDArray[indexPath.row]  == PFUser.current()!.objectId! {
                return [delete, uncollect]
            } else {
                return [uncollect]
            }
            
        } else {
            
            if self.ownerIDArray[indexPath.row]  == PFUser.current()!.objectId! {
                return[delete, collect]
            } else {
                return [collect]
            }
            
        }
        
    }
 
    
    //if current is nil(not logged in), user cannot edit the row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if PFUser.current() != nil {
            return true
        } else {
            return false
        }
    }
    
    */
    
   func uploadSuccess() {
    
        loadPosts()
        JJHUD.showSuccess(text: "上传成功", delay: 1.25)
        
        
    }
    
    func uploadFail() {
        JJHUD.showError(text: "上传失败", delay: 1.25)
    }
    
 
}
