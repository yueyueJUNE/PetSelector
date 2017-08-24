

import UIKit
import Parse


protocol UserTableVCDelegate{
    func tableViewDidScrollPassY(_ tableviewScrollY:CGFloat)
    func tableViewDidSelect()

}


class UserTableVC: UITableViewController {
    
    var delegate:UserTableVCDelegate?
    var tags: String!
    var userObjectID: String!
    var styles: UITableViewStyle?
    
    // page size
    var page: Int! = 10
    //arrays to hold info from server
    var petavaArray = [PFFile]()
    var petnameArray = [String]()
    var breedArray = [String]()
    var genderArray = [String]()
    var ageArray = [String]()
    var sizeArray = [String]()
    var dateArray = [Date?]()
    var petIDArray = [String]()
    var ownerArray = [String]()
    var adoptedArray = [Bool]()


    var collectArray = [String]()
    var scroll: Bool = true
    var offset: CGPoint!
    //刷新控件
    private var refreshFooter:  SDRefreshFooterView?
    weak var weakRefreshHeader: SDRefreshHeaderView?

    enum type:UInt {
        case endHeader = 1
        case endFooter = 2
        case endLoading = 3

    }
    init(tags: String, userObjectID: String){
        self.tags = tags
        self.userObjectID = userObjectID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        setHeaderView()
        self.tableView.register(UINib.init(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "Cell")
        self.tableView.estimatedRowHeight = 99.5
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
        setupHeader()
        setupFooter()
    }
    
    
    
    
    func setHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width:
            self.view.frame.size.width, height: 25))
        
        headerView.backgroundColor = UIColor.groupTableViewBackground
       
        let titleLabel = UILabel(frame: CGRect(x:10, y:0, width: self.view.frame.size.width, height: 25))
        
        titleLabel.textColor = UIColor.gray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .left
        if tags == "收藏" {
            let collectionQuery = PFQuery(className: "Collection")
            collectionQuery.whereKey("userId", equalTo: userObjectID)
            collectionQuery.countObjectsInBackground(block: { (count, error) in
                if error == nil {
                    titleLabel.text = "\(count)条"
                }
            })
            
        } else if tags == "待领养" {
            let query = PFQuery(className: "Post")
            query.whereKey("owner", equalTo: userObjectID)
            query.whereKey("adopted", equalTo: false)
            query.countObjectsInBackground(block: { (count, error) in
                if error == nil {
                    titleLabel.text = "\(count)条"
                }
            })
            
        } else {
            let query = PFQuery(className: "Post")
            query.whereKey("owner", equalTo: userObjectID)
            query.whereKey("adopted", equalTo: true)
            query.countObjectsInBackground(block: { (count, error) in
                if error == nil {
                    titleLabel.text = "\(count)条"
                }
            })
        
        }

        headerView.addSubview(titleLabel)
        self.tableView.tableHeaderView = headerView

    }
    
    /*
    // swipe cell for actions
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
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
                    self.ownerArray.remove(at: indexPath.row)
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
                            JJHUD.showError(text: "取消收藏未成功", delay: 1,enable: false)
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
            
            if self.ownerArray[indexPath.row]  == PFUser.current()!.objectId! {
                return [delete, uncollect]
            } else {
                return [uncollect]
            }
            
        } else {
            
            if self.ownerArray[indexPath.row]  == PFUser.current()!.objectId! {
                return[delete, collect]
            } else {
                return [collect]
            }
            
        }
        
    }
    
    */
    
    // load posts
    func loadPosts() {
        JJHUD.showLoading(text: "正在加载")
        loadPets(.endLoading)
    }

    // load posts
    func loadPets(_ endfreshType: type) {
        let query = PFQuery(className: "Post")
        if tags == "收藏" {
            let collectionQuery = PFQuery(className: "Collection")
            collectionQuery.limit = self.page
            collectionQuery.addDescendingOrder("createdAt")
            collectionQuery.whereKey("userId", equalTo: self.userObjectID)
            collectionQuery.findObjectsInBackground(block: { (objects, error) in
    
                if error == nil {
                    
                    //clean up
                    self.collectArray.removeAll(keepingCapacity: false)
                    
                    //find related objects
                    for object in objects! {
                        self.collectArray.append(object.value(forKey: "petId") as! String)
                    }

                    query.whereKey("objectId", containedIn: self.collectArray)
                    self.runQuery(query, endfreshType)
                    
                } else {
                
                    if error!.localizedDescription == "似乎已断开与互联网的连接。" || error!.localizedDescription == "Network connection failed." || error!.localizedDescription == "The Internet connection appears to be offline."{
                        let alert = UIAlertController(title: "网络问题", message: "似乎已断开与互联网的连接。", preferredStyle: UIAlertControllerStyle.alert)
                        let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        } else {
        

            // STEP 1. Find posts according to time updated
            query.whereKey("owner", equalTo: userObjectID)
            query.addDescendingOrder("updatedAt")
            query.limit = self.page
            if tags == "待领养" {
                query.whereKey("adopted", equalTo: false)
            } else if tags == "已送养" {
                query.whereKey("adopted", equalTo: true)
            }
            self.runQuery(query, endfreshType)

        }
 
    }
    

    func runQuery(_ query:PFQuery<PFObject>, _ endfreshType: type) {
        
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
                self.ownerArray.removeAll(keepingCapacity: false)
                self.adoptedArray.removeAll(keepingCapacity: false)
                
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
                    var sortedoObjects: [PFObject]!
                    if self.tags == "收藏" {

                       sortedoObjects  = objects?.sorted(by: { (obj1, obj2) -> Bool in
                            let index1 = self.collectArray.index(of: obj1.objectId!)
                            let index2 = self.collectArray.index(of: obj2.objectId!)
                            return index1! < index2!
                            
                        })
                    } else {
                        sortedoObjects = objects
                    }

                    for object in sortedoObjects! {
                        self.petIDArray.append(object.objectId!)
                        self.adoptedArray.append(object.value(forKey: "adopted") as! Bool)
                        self.petnameArray.append(object.value(forKey: "petname") as! String)
                        self.petavaArray.append(object.value(forKey: "petava") as! PFFile)
                        self.ageArray.append(object.value(forKey: "age") as! String)
                        self.dateArray.append(object.updatedAt)
                        self.genderArray.append(object.value(forKey: "gender") as! String)
                        self.sizeArray.append(object.value(forKey: "size") as! String)
                        self.breedArray.append(object.value(forKey: "breed") as! String)
                        self.ownerArray.append(object.value(forKey: "owner") as! String)
                        
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

    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.delegate?.tableViewDidScrollPassY(scrollView.contentOffset.y)
        
        //if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
        //    loadMore()
        //}
    }
    
    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petIDArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        cell.redCicle.isHidden = !adoptedArray[indexPath.row]
        cell.redLbl.isHidden = !adoptedArray[indexPath.row]
        
        cell.sizeLbl.text = self.sizeArray[indexPath.row]
        cell.genderLbl.text = self.genderArray[indexPath.row]
        cell.petnameLbl.text = self.petnameArray[indexPath.row]
        cell.idLbl.text = self.petIDArray[indexPath.row]
        cell.ageLbl.text = self.ageArray[indexPath.row]
        let str = self.breedArray[indexPath.row]
        let start = str.index(str.startIndex, offsetBy: 1)
        cell.breedLbl.setTitle(str.substring(from: start), for: .normal)
        
        
        // place pet picture
        self.petavaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.petavaImg.image = UIImage(data: data!)
        }
        
        
        // calculate post date
        let from = self.dateArray[indexPath.row]
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
            cell.dateLbl.text = "\(difference.minute ?? 0)分前"
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(difference.hour ?? 0)时前"
        }
        if difference.day! > 0 && difference.month! == 0 {
            cell.dateLbl.text = "\(difference.day ?? 0)天前"
        }
        if difference.month! > 0 && difference.year! == 0 {
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




    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // recall cell to call further cell's data
        let cell = tableView.cellForRow(at: indexPath) as! PostCell
        petID.append(cell.idLbl.text!)
        self.delegate?.tableViewDidSelect()

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
            page = page + 10
            loadPets(.endFooter)
        } else {
            self.refreshFooter?.endRefreshing()
        }
    }

    /*
     
    //if current is nil(not logged in), user cannot edit the row
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if PFUser.current() != nil {
            return true
        } else {
            return false
        }
    }
 */
    
    
    func endRefreshByType(_ type: type){
        switch type {
        case .endHeader:
            self.setHeaderView()

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                //下拉刷行
                self.weakRefreshHeader?.endRefreshing()
            }
            
            break
            
        case .endFooter:
            self.refreshFooter?.endRefreshing()
            // Force layout so things are updated before resetting the contentOffset.
            self.tableView.contentOffset = offset
            break
        case .endLoading:
            //隐藏正在加载图标
            JJHUD.hide()
            break
            
        }
        
    }
    
   
}
