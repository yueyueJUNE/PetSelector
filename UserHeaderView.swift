
import UIKit
import Parse


protocol UserHeaderViewDelegate{
    func pushFollowerVC()
    func loginVC()
    func showChangeImageVC(_ type: String)
    func pushEditInfoVC()
    
}

class UserHeaderView: UIView {
    
    var user = userID.last
    var delegate:UserHeaderViewDelegate?
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var followers: UIButton!
    @IBOutlet weak var followees: UIButton!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!

    
    @IBAction func button_clicked(_ sender: Any) {
        
        let tilte = button.title(for: UIControlState.normal)
        if tilte == "+ 关注" {
            let object = PFObject(className: "Follow")
            object["follower"] = PFUser.current()!.objectId!
            object["followee"] = user
            object.saveInBackground(block: { (success, error) in
                if success {
                    self.button.setTitle("已关注", for: UIControlState.normal)
                    self.button.layer.borderColor = UIColor.white.cgColor
                    self.button.setTitleColor(.white, for: UIControlState())
                    self.followers.setTitle("\(Int(self.followers.title(for: UIControlState())!)! + 1)", for: .normal)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshFollow"), object: nil)

                } else {
                    print(error!.localizedDescription)
                }
            })
        } else if tilte == "已关注"{
            
            let actionSheet = SRActionSheet.sr_actionSheetView(withTitle: "确定不再关注此人？", cancelTitle: "取消", destructiveTitle: nil, otherTitles: ["确定"], otherImages: nil) { (actionSheet, index) in
                if index == 0 {
                    
                    let query = PFQuery(className: "Follow")
                    query.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                    query.whereKey("followee", equalTo: self.user!)
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            for object in objects! {
                                object.deleteInBackground(block: { (success, error) in
                                    if success {
                                        self.button.setTitle("+ 关注", for: UIControlState.normal)
                                        self.button.layer.borderColor = UIColor.lightGray.cgColor
                                        self.button.setTitleColor(.lightGray, for: UIControlState())
                                        self.followers.setTitle("\(Int(self.followers.title(for: UIControlState())!)! - 1)", for: .normal)
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
            
        } else if tilte == "登录" {
        
            delegate?.loginVC()
        
        } else {
            delegate?.pushEditInfoVC()
        
        }
    }
    
    @IBAction func followeeBtn_clicked(_ sender: Any) {
        userFollow = user!
        category = "关注"
        
        delegate?.pushFollowerVC()

        
    }
   
    @IBAction func followerBtn_clicked(_ sender: Any) {
        
        userFollow = user!
        category = "粉丝"
        delegate?.pushFollowerVC()
        
    }
    
   
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        avaImg.layer.borderColor = UIColor.white.cgColor
        avaImg.layer.borderWidth = 1
        
        if user == nil && PFUser.current() != nil {
            user = PFUser.current()!.objectId!
        }
        
        if PFUser.current() != nil || user != nil {
            setavaImage()
            setBackgroundImage()
            setFollowers()
            setFollowings()
            setBio()

            //tap followers
            let avaImgTap = UITapGestureRecognizer(target:self, action:#selector(showavaImage))
            avaImgTap.numberOfTapsRequired = 1
            avaImg.isUserInteractionEnabled = true
            avaImg.addGestureRecognizer(avaImgTap)
            
            //tap followings
            let backgroundviewTap = UITapGestureRecognizer(target: self, action: #selector(backgroundImageTaped))
            backgroundviewTap.numberOfTapsRequired = 1
            backgroundView.isUserInteractionEnabled = true
            backgroundView.addGestureRecognizer(backgroundviewTap)
            
        } else {
            followers.isUserInteractionEnabled = false
            followees.isUserInteractionEnabled = false
            
       }
        
        setButton()

        
    }
    
    func backgroundImageTaped(sender: UITapGestureRecognizer) {
        
        delegate?.showChangeImageVC("background")
    }
    
    
    func showavaImage(sender: UITapGestureRecognizer) {
        
        delegate?.showChangeImageVC("ava")
    }
    
    func hideavaImage(sender: UITapGestureRecognizer) {
        let background = sender.view as UIView?
        if let view = background {
            UIView.animate(withDuration: 0.3, animations:{ () in
                let imageView = view.viewWithTag(1) as! UIImageView
                imageView.frame = self.avaImg.frame
                imageView.alpha = 0
            },completion: {(finished:Bool) in
                view.alpha = 0
                view.superview?.removeFromSuperview()
                view.removeFromSuperview()
            })
        }
    }

    
    
    func setavaImage() {
        
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: user!)
        query?.getFirstObjectInBackground(block: { (object, error) in
            if error == nil {
                (object?.value(forKey: "ava") as! PFFile).getDataInBackground { (data, error) -> Void in
                    self.avaImg.image = UIImage(data: data!)
                }

            }
        })
       
    }
    
    func setBackgroundImage() {
        
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: user!)
        query?.getFirstObjectInBackground(block: { (object, error) in
            if error == nil {
                (object?.value(forKey: "backgroundImage") as! PFFile).getDataInBackground { (data, error) -> Void in
                    self.backgroundImage.image = UIImage(data: data!)
                }
                
            }
        })
    }

    
    //关注
    func setFollowings() {

        let query = PFQuery(className: "Follow")
        query.whereKey("follower", equalTo: user!)
        query.countObjectsInBackground { (count, error) in
            if error == nil {
                self.followees.setTitle("\(count)", for: .normal)
            }
        }
 
        
    }
    
    //粉丝
    func setFollowers() {

        let query = PFQuery(className: "Follow")
        query.whereKey("followee", equalTo: user!)
        query.countObjectsInBackground { (count, error) in
            self.followers.setTitle("\(count)", for: .normal)
        }
     
    }
    
    
    func setBio() {
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: user!)
        query?.getFirstObjectInBackground(block: { (object, error) in
            if error == nil {
                self.bioLbl.text = object?.value(forKey: "bio") as? String 
            }
        })

    }
    
    func setButton() {
    
        if PFUser.current() != nil {
            
            if  user == PFUser.current()!.objectId! {
                
                self.button.setTitle("修改资料", for: UIControlState.normal)
                self.button.layer.borderColor = UIColor.white.cgColor
                self.button.setTitleColor(.white, for: UIControlState())
                
            } else {
                
                let followQuery = PFQuery(className: "Follow")
                followQuery.whereKey("followee", equalTo: user!)
                followQuery.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                followQuery.countObjectsInBackground(block: { (count, error) in
                    if error == nil {
                        if count == 0 {
                            self.button.setTitle("+ 关注", for: UIControlState.normal)
                            self.button.layer.borderColor = UIColor.lightGray.cgColor
                            self.button.setTitleColor(.lightGray, for: UIControlState())
                        } else {
                            self.button.setTitle("已关注", for: UIControlState.normal)
                            self.button.layer.borderColor = UIColor.white.cgColor
                            self.button.setTitleColor(.white, for: UIControlState())
                        }
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        } else {
            if user == nil {
                self.button.setTitle("登录", for: UIControlState.normal)
                self.button.layer.borderColor = UIColor.white.cgColor
                self.button.setTitleColor(.white, for: UIControlState())
            
            } else {
            
                self.button.isHidden = true
            }
        }
    }
    

}
