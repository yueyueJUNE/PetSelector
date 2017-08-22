//
//  usersVC.swift
//  liketagram
//
//  Created by 刘月 on 7/3/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse


class searchVC: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    // declare search bar
    var searchBar = UISearchBar()
    
    // tableView arrays to hold information from User
    var usernameArray = [String]()
    var userIDArray = [String]()
    var useravaArray = [PFFile]()
    var typeArray = [String]()
    var followDict: [String: String] = [:]
    
    
    // tableView arrays to hold information from Post
    var petavaArray = [PFFile]()
    var petnameArray = [String]()
    var breedArray = [String]()
    var genderArray = [String]()
    var ageArray = [String]()
    var sizeArray = [String]()
    var dateArray = [Date?]()
    var idArray = [String]()
    var ownerArray = [String]()
    var collectDict: [String: Bool] = [:]

    //@IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var tableView: UITableView!
    
    let refresher = UIRefreshControl()
    
    // collectionView UI
    var collectionView : UICollectionView!
    
    // collectionView arrays to hold infromation from server
    var picArray = [PFFile]()
    var petIDArray = [String]()
    var page : Int = 15
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        (self.tabBarController as! TabBarVC).postBtn.isHidden = self.hidesBottomBarWhenPushed
        (self.tabBarController as! TabBarVC).view.bringSubview(toFront: (self.tabBarController as! TabBarVC).postBtn)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // implement search bar
       //searchBar.delegate = self
        //searchBar = UISearchBar()
       //searchBar.sizeToFit()
        //searchBar.scopeButtonTitles = ["用户", "宠物"]
        //searchBar.showsScopeBar = true
       // searchBar.tintColor = UIColor.groupTableViewBackground
        //searchBar.frame.size.width = self.view.frame.size.width
       ////let searchItem = UIBarButtonItem(customView: searchBar)
        //self.navigationItem.leftBarButtonItem = searchItem
       // let selectedIndex = searchBar.selectedScopeButtonIndex
        searchBar.selectedScopeButtonIndex = 0
        
        //self.navigationItem.titleView = searchBar

        tableView.register(UINib.init(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        // calling function to load posts
        self.tableView.register(UINib.init(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "Cell")
        

        tableView.estimatedRowHeight=100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        // call functions
        loadUsers("username", "")
        
        // call collectionView
        collectionViewLaunch()
        
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            loadUsers("username", "")
        
        } else {
            loadPets("petname", "")

        }
    }
    
    
    // SEARCHING CODE
    // load users function
    func loadUsers(_ key: String, _ value: String) {
        
        let usersQuery = PFUser.query()
        usersQuery?.addDescendingOrder("updatedAt")

        usersQuery?.limit = 20
        usersQuery?.whereKey(key, matchesRegex: value)

        usersQuery?.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.useravaArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.userIDArray.removeAll(keepingCapacity: false)
                self.followDict = [:]
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.useravaArray.append(object.value(forKey: "ava") as! PFFile)
                    self.typeArray.append((object.value(forKeyPath: "type") as! Bool) == true ? "收容所" : "个人")
                    self.userIDArray.append(object.objectId!)
                    
                    if PFUser.current() != nil {
                        let followQuery = PFQuery(className: "Follow")
                        followQuery.whereKey("followee", equalTo: object.objectId!)
                        followQuery.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                        followQuery.countObjectsInBackground(block: { (count, error) in
                            if error == nil {
                                if count == 0 {
                                    self.followDict[object.objectId!] = "+ 关注"
                                    
                                } else {
                                    self.followDict[object.objectId!] = "已关注"
                                }
                                
                                if self.followDict.count == objects!.count {
                                    // reload
                                    self.tableView.reloadData()
                                    
                                }
                                
                            } else {
                                print(error!.localizedDescription)
                            }
                            

                        })

                    } else {
                        if self.usernameArray.count == objects?.count {
                            
                            // reload
                            self.tableView.reloadData()

                        }
                    }

                }
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    

    func loadPets(_ key: String, _ value: String) {
        
        let petsQuery = PFQuery(className: "Post")

        petsQuery.limit = self.page
        petsQuery.addDescendingOrder("updatedAt")
        petsQuery.whereKey(key, matchesRegex: value)

        petsQuery.findObjectsInBackground {
            (objects, error) -> Void in
            
            //clean up
            self.petnameArray.removeAll(keepingCapacity: false)
            self.breedArray.removeAll(keepingCapacity: false)
            self.genderArray.removeAll(keepingCapacity: false)
            self.ageArray.removeAll(keepingCapacity: false)
            self.sizeArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.petavaArray.removeAll(keepingCapacity: false)
            self.idArray.removeAll(keepingCapacity: false)
            self.ownerArray.removeAll(keepingCapacity: false)
            self.collectDict = [:]
            
            
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
                self.tableView.reloadData()
                
            } else {
                self.tableView.tableFooterView = UIView()
            }
            
            if error == nil {
                
                // find related objects
                for object in objects! {
                    
                    self.idArray.append(object.objectId!)
                    self.petnameArray.append(object.value(forKey: "petname") as! String)
                    self.petavaArray.append(object.value(forKey: "petava") as! PFFile)
                    self.ageArray.append(object.value(forKey: "age") as! String)
                    self.dateArray.append(object.updatedAt)
                    self.genderArray.append(object.value(forKey: "gender") as! String)
                    self.sizeArray.append(object.value(forKey: "size") as! String)
                    self.breedArray.append(object.value(forKey: "breed") as! String)
                    self.ownerArray.append(object.value(forKey: "owner") as! String)
                    
                    if PFUser.current() != nil {
                        //find whether in Collection
                        let collectObj = PFQuery(className: "Collection")
                        collectObj.whereKey("userId", equalTo: PFUser.current()!.objectId!)
                        collectObj.whereKey("petId", equalTo: object.objectId!)
                        
                        collectObj.countObjectsInBackground(block: { (count, error) in
                            if error == nil {
                                
                                
                                if count == 0 {
                                    self.collectDict[object.objectId!] = true
                                    
                                } else {
                                    self.collectDict[object.objectId!] = false
                                }
                                
                                if self.collectDict.count == objects?.count {
                                    
                                    self.tableView.reloadData()
                                    
                                }
                                
                            } else {
                                
                                print(error!.localizedDescription)
                    
                            }
                        })
                        
                    } else {
                        if self.idArray.count == objects?.count {
                            
                            self.tableView.reloadData()
     
                        }
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
        }

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.selectedScopeButtonIndex == 0 {
            loadUsers("username", "(?i)" + searchBar.text!)
        } else {
        
            loadPets("petname", "(?i)" + searchBar.text!)

        }
            
    }

  
    
    // tapped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // hide collectionView when started search
        collectionView.isHidden = true
        
        // show cancel button
        searchBar.showsCancelButton = true
    }
    
    
    // clicked cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // unhide collectionView when tapped cancel button
        collectionView.isHidden = false
        
        // dismiss keyboard
        searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        if searchBar.selectedScopeButtonIndex == 0 {
        
            // reset shown users
            loadUsers("username", "")
        } else {
            
            // reset shown users
            loadUsers("petname", "")
        }
    }
    
   
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // TABLEVIEW CODE
    // cell numb
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBar.selectedScopeButtonIndex == 0{
            return usernameArray.count
        } else {
            
            return petnameArray.count
        }
    }
    
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchBar.selectedScopeButtonIndex == 0 {
        
          let cell  = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
            // connect cell's objects with received infromation from server
            cell.usernameLbl.text = usernameArray[indexPath.row]
            cell.userTypeLbl.text = typeArray[indexPath.row]
            cell.userIDLbl.text = userIDArray[indexPath.row]
        
            if PFUser.current() != nil {
            
                if userIDArray[indexPath.row] == PFUser.current()!.objectId {
                    cell.followBtn.isHidden = true
                } else {
                    cell.followBtn.isHidden = false

                }

                cell.followBtn.setTitle(followDict[userIDArray[indexPath.row]], for: UIControlState.normal)
                        
                if followDict[userIDArray[indexPath.row]] == "+ 关注" {
                    cell.followBtn.layer.borderColor = UIColor.orange.cgColor
                    cell.followBtn.setTitleColor(.orange, for: UIControlState())
                
                
                } else if followDict[userIDArray[indexPath.row]] == "已关注" {
                    cell.followBtn.layer.borderColor = UIColor.lightGray.cgColor
                    cell.followBtn.setTitleColor(.lightGray, for: UIControlState())
                
                }
            
            } else if PFUser.current() == nil {
                // hide follow button
                cell.followBtn.isHidden = true
            }
        
            useravaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                cell.userAva.image = UIImage(data: data!)
                }
                
            }
            
            return cell

        } else {
            // define cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
            
            cell.ageLbl.text = ageArray[indexPath.row]
            let str = breedArray[indexPath.row]
            let index = str.index(str.startIndex, offsetBy: 1)
            cell.breedLbl.setTitle(str.substring(from: index), for: .normal)
            cell.sizeLbl.text = sizeArray[indexPath.row]
            cell.genderLbl.text = genderArray[indexPath.row]
            cell.petnameLbl.text = petnameArray[indexPath.row]
            cell.idLbl.text = idArray[indexPath.row]
            
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
                            
                            cell.likeBtn.setTitle("unlike", for: .normal)
                            cell.likeBtn.setBackgroundImage(#imageLiteral(resourceName: "unlike"), for: .normal)
                        } else {
                            
                            cell.likeBtn.setTitle("like", for: .normal)
                            cell.likeBtn.setBackgroundImage(#imageLiteral(resourceName: "like"), for: .normal)
                            
                        }
                    }
                }
                
                // count total likes of shown post
                let countLikes = PFQuery(className: "Like")
                countLikes.whereKey("petId", equalTo: cell.idLbl.text!)
                countLikes.countObjectsInBackground { (count, error) -> Void in
                    cell.likeLbl.text = "\(count)"
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
                
            } else if PFUser.current() == nil {
                // hide follow button
                cell.likeBtn.isHidden = true
                cell.likeLbl.isHidden = true
            }
            
            return cell

        
        
        }
 
    }
    
    
    // selected tableView cell - selected user／pets
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchBar.selectedScopeButtonIndex == 0 {
        
            // calling cell again to call cell data
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
            //}
        } else {
        
            // recall cell to call further cell's data
            let cell = tableView.cellForRow(at: indexPath) as! PostCell
            petID.append(cell.idLbl.text!)
            
            let pet = self.storyboard?.instantiateViewController(withIdentifier: "PetInfoVC") as! PetInfoVC
            //隐藏tab bar
            pet.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pet, animated: true)
        
        
        }
    }
    
    
    
    // COLLECTION VIEW CODE
    func collectionViewLaunch() {
        
        // layout of collectionView
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // item size
        layout.itemSize = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        // direction of scrolling
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        // define frame of collectionView
        let frame = CGRect(x: 0, y: tableView.frame.origin.y - 44, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - 64)
        
        // declare collectionView
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        // define cell for collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        refresher.addTarget(self, action: #selector(loadPosts), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refresher)
        
        // call function to load posts
        loadPosts()
    }
    
    
    // cell line spasing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // cell inter spasing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // cell numb
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // create picture imageView in cell to show loaded pictures
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        cell.addSubview(picImg)
        
        // get loaded images from array
        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    // cell's selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // take relevant unique id of post to load post in postVC
        petID.append(petIDArray[indexPath.row])
        
        // present postVC programmaticaly
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PetInfoVC") as! PetInfoVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    // load posts
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.limit = page
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.picArray.removeAll(keepingCapacity: false)
                self.petIDArray.removeAll(keepingCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.picArray.append(object.object(forKey: "pic") as! PFFile)
                    self.petIDArray.append(object.object(forKey: "uuid") as! String)
                }
                
                // reload collectionView to present images
                self.collectionView.reloadData()
                self.refresher.endRefreshing()
                
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // scrolled down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            self.loadMore()
        }
    }
    
    // pagination
    func loadMore() {
        
        // if more posts are unloaded, we wanna load them
        if page <= picArray.count {
            
            // increase page size
            page = page + 15
            
            // load additional posts
            let query = PFQuery(className: "posts")
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.picArray.removeAll(keepingCapacity: false)
                    self.petIDArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.picArray.append(object.object(forKey: "pic") as! PFFile)
                        self.petIDArray.append(object.object(forKey: "uuid") as! String)
                    }
                    
                    // reload collectionView to present loaded images
                    self.collectionView.reloadData()
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    }
    
}
