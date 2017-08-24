import UIKit
import Parse

class GuestVC: UIViewController,UIScrollViewDelegate,UserTableVCDelegate,ZEMenuViewDelegate, UserHeaderViewDelegate {
    
    func pushEditInfoVC() {
    
        let editVC = self.storyboard?.instantiateViewController(withIdentifier: "EditInfoVC") as! EditInfoVC
        //editVC.hidesBottomBarWhenPushed = true
        // present
        self.navigationController?.pushViewController(editVC, animated: true)
    }


    func loginVC() {
        
    }

    
    /** 偏移方法操作枚举 */
    enum headerMenuShowType:UInt {
        case up = 1 // 固定在navigation上面
        case buttom = 2 // 固定在navigation下面
    }
    
    
    var tableViewArr:Array<UserTableVC> = []// 存放tableView
    var backgroundScrollView:UIScrollView?// 底部scrollView
    var menuView:ZEMenuView!// 菜单
  
    var titlesArr = ["待领养","已送养","收藏"]// 存放菜单的内容
    
    /** 屏幕宽度高度 */
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    /** header和menu的高度 */
    let menuHeight:CGFloat = 30
    var headerHeight:CGFloat = 0
    let navigationHeight:CGFloat = 64
    var headerView:UserHeaderView!

    var headerOriginY: CGFloat = 0
    var viewAppearAlpa: CGFloat = 0 //记录navigation bar alpa
    var hideNav: Bool = true

    var scrollHorizY: CGFloat = 0
    var scrollY:CGFloat = 0// 记录当偏移量
    var scrollX:CGFloat = 0// 记录当偏移量

    override func viewWillAppear(_ animated: Bool) {
        // didAppear隐藏,不会让整个页面向上移动64
        //self.navigationController?.navigationBar.subviews.first?.alpha = 0
        //hiddenNav(true)
        
       // (self.tabBarController as! TabBarVC).postBtn.isHidden = self.hidesBottomBarWhenPushed
       // (self.tabBarController as! TabBarVC).view.bringSubview(toFront: (self.tabBarController as! TabBarVC).postBtn)
        
        self.navigationController?.navigationBar.subviews.first?.alpha = CGFloat(viewAppearAlpa)
        hiddenNav(hideNav)

    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(resetimImage), name: Notification.Name(rawValue: "uploadImageSuccess"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
       
        //new back button
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let moreBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "more"), style: .plain, target: self, action: #selector(moreBtn_clicked))
        self.navigationItem.rightBarButtonItem = moreBtn
      
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        setUI()
    }
    
    
    func moreBtn_clicked() {
        
        if PFUser.current() == nil || userID.last != PFUser.current()?.objectId {
        
            // make references to EditInfoVC
            let editVC = self.storyboard?.instantiateViewController(withIdentifier: "EditInfoVC") as! EditInfoVC
            editVC.hidesBottomBarWhenPushed = true
            // present
            self.navigationController?.pushViewController(editVC, animated: true)

        } else {
            let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            settingVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingVC, animated: true)
        
        }

    }
    
    var type: String!
    func showChangeImageVC(_ type: String) {
        self.type = type
        
        let changeImageVC = self.storyboard!.instantiateViewController(withIdentifier: "changeImageVC") as! changeImageVC
        
        self.present(changeImageVC, animated: true, completion: nil)
        
        if type == "ava" {
            // send notification
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showImage"), object: nil, userInfo:["type": type,"image": headerView.avaImg.image!])
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showImage"), object: nil, userInfo:["type": type,"image": headerView.backgroundImage.image!])
            
        }
    }
    
    
    func resetimImage(_ notification: Notification) {
        
        if type == "ava" {
            headerView.avaImg.image! = notification.userInfo?["image"] as! UIImage
        } else {
            headerView.backgroundImage.image! = notification.userInfo?["image"] as! UIImage
            
        }
        
    }
 
    
    func refresh(_ notification: Notification) {
        let key = (notification.userInfo?["key"]) as! String
        if key == "简介" {
            headerView.bioLbl.text = (notification.userInfo?["value"]) as? String
        }
        
        if key == "用户名" {
            self.navigationItem.title = (notification.userInfo?["value"]) as? String
        }
    }
    
    func back() {
        _ = self.navigationController!.popViewController(animated: true)
        
        if !userID.isEmpty {
            userID.removeLast()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.subviews.first?.alpha = 1
        hiddenNav(false)
 
    }
    
    func setUI(){
        headerHeight = 200
        scrollHorizY = menuHeight+headerHeight
        self.automaticallyAdjustsScrollViewInsets = false
        layoutBackgroundScrollView()
        layoutHeaderMenuView()
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: userID.last!)
        query?.getFirstObjectInBackground(block: { (object, error) in
            self.navigationItem.title = (object?.value(forKey: "username") as! String)
            //self.navigationController?.navigationBar.topItem?.title = (object?.value(forKey: "username") as! String)
        })
    }
    
    /*创建底部scrollView,并将tableViewController添加到上面 */
    func layoutBackgroundScrollView(){
        // 需要创建到高度0上,所以backgroundScrollView.y要等于-64
        self.backgroundScrollView = UIScrollView(frame:CGRect(x: 0,y: -navigationHeight,width: screenWidth,height: screenHeight+navigationHeight))
        self.backgroundScrollView?.isPagingEnabled = true
        self.backgroundScrollView?.bounces = false
        self.backgroundScrollView?.delegate = self
        
        //let floatArrCount = CGFloat(titlesArr.count)
        self.backgroundScrollView?.contentSize = CGSize(width: CGFloat(titlesArr.count)*screenWidth, height: screenHeight-navigationHeight)
        
        // 给scrollY赋初值避免一上来滑动就乱
        scrollY = -scrollHorizY // tableView自己持有的偏移量和赋值时给的偏移量符号是相反的
        for  i in 0 ..< titlesArr.count  {
            let floatI = CGFloat(i)
            

            let tableViewVC = UserTableVC(tags: titlesArr[i], userObjectID: userID.last!)
            // tableView顶部流出HeaderView和MenuView的位置
            tableViewVC.tableView.contentInset = UIEdgeInsetsMake(scrollHorizY, 0, 0, 0 )
            tableViewVC.delegate = self
            
            tableViewVC.view.frame = CGRect(x: floatI * screenWidth,y:navigationHeight, width: screenWidth, height: screenHeight)
            
            // 将tableViewVC添加进数组方便管理
            tableViewArr.append(tableViewVC)
            self.addChildViewController(tableViewVC)
        }
        
        // 需要用到的时候再添加到view上
        backgroundScrollView?.addSubview(tableViewArr[0].view)
        backgroundScrollView?.addSubview(tableViewArr[1].view)
        backgroundScrollView?.addSubview(tableViewArr[2].view)
        self.view.addSubview(backgroundScrollView!)
        
    }
    
    /** 创建HeaderView和MenuView */
    func layoutHeaderMenuView(){
        // 通过Xib导入headerView
        headerView = Bundle.main.loadNibNamed("UserHeaderView", owner: self, options: nil)?.first as! UserHeaderView
        headerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: headerHeight)
        headerView.delegate = self
        self.view.addSubview(headerView)
        
        // MenuView
        menuView = ZEMenuView(frame:CGRect(x: 0,y: headerHeight, width: screenWidth,height: menuHeight))
        menuView.delegate = self
              menuView.setUIWithArr(titlesArr)
        self.view.addSubview(self.menuView)
    }
    
    /*
    //创建MenuView
    func layoutMenuView() {
        // MenuView
        menuView = ZEMenuView(frame:CGRect(x: 0,y: headerHeight,width: screenWidth,height: menuHeight))
        menuView.delegate = self
        menuView.setUIWithArr(titlesArr)
        self.view.addSubview(self.menuView)
    }
    */
    //因为频繁用到header和menu的固定
    func headerMenuViewShowType(_ showType:headerMenuShowType){
        switch showType {
        case .up:
            menuView.frame.origin.y = navigationHeight
            headerView.frame.origin.y = -headerHeight + navigationHeight
            self.navigationController?.navigationBar.subviews.first?.alpha = 1

            hiddenNav(false)
            
            break
        case .buttom:
            headerView.frame.origin.y = 0
            menuView.frame.origin.y = headerView.frame.size.height
            self.navigationController?.navigationBar.subviews.first?.alpha = 0
            hiddenNav(true)
            break
        }
    }
    
    // DELEGATE
    
    func pushFollowerVC() {
        
        // make references to followersVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "FollowerVC") as! FollowerVC
        followings.hidesBottomBarWhenPushed = true

        // present
        self.navigationController?.pushViewController(followings, animated: true)
        
        
    }
    
    func tableViewDidScrollPassY(_ tableviewScrollY: CGFloat) {
        // 计算每次改变的值
        let seleoffSetY = tableviewScrollY - scrollY
        // 将scrollY的值同步
        scrollY = tableviewScrollY
        
        // 偏移量超出Navigation之上
        if scrollY >= -menuHeight-navigationHeight {
            hideNav = false
            headerMenuViewShowType(.up)
        }else if  scrollY <= -scrollHorizY {
            // 偏移量超出Navigation之下
            hideNav = true
            headerMenuViewShowType(.buttom)
        }else{
            // 剩下的只有需要跟随的情况了
            // 将headerView的y值按照偏移量更改
            
           // if seleoffSetY<0 {
            //    headerView.frame.origin.y -= 0
            //} else {
                headerView.frame.origin.y -= seleoffSetY
            //}
            menuView.frame.origin.y = headerView.frame.maxY
            // 基准线 用于当做计算0-1的..被除数..分母...
            let datumLine = -menuHeight-navigationHeight + scrollHorizY
            // 计算当前的值..除数...分子..
            let nowY = scrollY + menuHeight+navigationHeight
            // 一个0-1的值
            let nowAlpa = 1+nowY/datumLine
            
            // 以0.5为基础 改变字体和状态栏的颜色
            if nowAlpa > 0.5 {
                hideNav = false

                hiddenNav(false)
            }else{
                hideNav = true

                hiddenNav(true)
            }
            self.navigationController?.navigationBar.subviews.first?.alpha = nowAlpa

        }
        viewAppearAlpa = (self.navigationController?.navigationBar.subviews.first?.alpha)!
        headerOriginY = headerView.frame.origin.y
        
    }
    
    func tableViewDidSelect() {
    
        let pet = self.storyboard?.instantiateViewController(withIdentifier: "PetInfoVC") as! PetInfoVC
        pet.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pet, animated: true)

    }
    
    func menuViewSelectIndex(_ index: Int) {
        // 0.3秒的动画为了显得不太突兀
        UIView.animate(withDuration: 0.3, animations: {
            
            //self.view.contentOffset = CGPoint(x: self.screenWidth*CGFloat(index),y: 0)
            self.backgroundScrollView!.contentOffset = CGPoint(x: self.screenWidth*CGFloat(index),y: 0)
        })
    }
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 判断是否有X变动,这里只处理横向滑动
        if scrollX == scrollView.contentOffset.x{
            return;
        }
        // 当tableview滑动到很靠上的时候,下一个tableview出现时只用在menuView之下
        if scrollY >= -menuHeight-navigationHeight {
            scrollY = -menuHeight-navigationHeight
        }
        
        for tableViewVC in tableViewArr {
            tableViewVC.tableView.contentOffset = CGPoint(x: 0, y: scrollY)
        }
        
        // 用于改变menuView的状态
        let rate = (scrollView.contentOffset.x/screenWidth)
        self.menuView.scrollToRate(rate)
        
        // +0.7的意思是 当滑动到30%的时候加载下一个tableView
        backgroundScrollView?.addSubview(tableViewArr[Int(rate+0.7)].view)
        
        // 记录x
        scrollX = scrollView.contentOffset.x
    }
    */
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 判断是否有X变动,这里只处理横向滑动
        if scrollX == scrollView.contentOffset.x{
            return;
        }
        // 当tableview滑动到很靠上的时候,下一个tableview出现时只用在menuView之下
        
        if scrollY >= -menuHeight-navigationHeight {
            
            
            for tableViewVC in tableViewArr {
                if tableViewVC.tableView.contentOffset == CGPoint(x: 0, y: -scrollHorizY) {
                    tableViewVC.tableView.contentOffset = CGPoint(x: 0, y: -menuHeight-navigationHeight)
                }
            }
            
        }
        
        if scrollY == -scrollHorizY {
            for tableViewVC in tableViewArr {
                tableViewVC.tableView.contentOffset = CGPoint(x: 0, y: scrollY)
            }
        }
        
        // 用于改变menuView的状态
        let rate = (scrollView.contentOffset.x/screenWidth)
        self.menuView.scrollToRate(rate)
        
        // +0.7的意思是 当滑动到30%的时候加载下一个tableView
        //backgroundScrollView?.addSubview(tableViewArr[Int(rate+0.7)].view)
        
        // 记录x
        scrollX = scrollView.contentOffset.x
    }
    
    
    func hiddenNav(_ hidden:Bool){
        
        if hidden {
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            self.navigationController?.navigationBar.tintColor = .white

        }else{
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            self.navigationController?.navigationBar.tintColor = .darkGray

            
        }
    }
    
}
