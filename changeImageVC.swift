//
//  changImageVC.swift
//  PetSelector
//
//  Created by 刘月 on 8/15/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse

class changeImageVC: UIViewController, HXPhotoViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var changeImageBtn: UIButton!
    
    @IBOutlet weak var cancel: UIButton!
    var type: String!

    
    @IBAction func cancel(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeImageBtn_clicked(_ sender: Any) {
        
        let vc = HXPhotoViewController()
        
        if self.type == "ava" {
              vc.manager = avaManage
        } else {
              vc.manager = backgroundManage
        }
      
        vc.delegate = self
        present(UINavigationController(rootViewController: vc as UIViewController), animated: true) { _ in }
    }
    
    var user = userID.last

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeImageBtn.layer.borderWidth = 1
        changeImageBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        cancel.layer.borderWidth = 1
        cancel.layer.borderColor = UIColor.lightGray.cgColor

        NotificationCenter.default.addObserver(self, selector: #selector(showImageByType), name: Notification.Name(rawValue: "showImage"), object: nil)
        

        if user == nil && PFUser.current() != nil {
            user = PFUser.current()!.objectId!
        }
        
        if PFUser.current() == nil || user != PFUser.current()?.objectId {
        
           changeImageBtn.isHidden = true
        }
        

        let avaImgTap = UITapGestureRecognizer(target:self, action:#selector(back))
        avaImgTap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(avaImgTap)
        
    }
    
    func back() {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    
    func showImageByType(_ notification: Notification) {
        
        type = notification.userInfo?["type"] as! String
        imageView.image = notification.userInfo?["image"] as? UIImage
        
    }
     
    private var _backgroundImageManager: HXPhotoManager?
    var backgroundManage: HXPhotoManager? {
        if _backgroundImageManager == nil {
            _backgroundImageManager = HXPhotoManager(type: HXPhotoManagerSelectedTypePhoto)
            _backgroundImageManager?.openCamera = true
            _backgroundImageManager?.showFullScreenCamera = true
            _backgroundImageManager?.photoMaxNum = 1
             _backgroundImageManager?.videoMaxNum = 0
            _backgroundImageManager?.maxNum = 1
            _backgroundImageManager?.rowCount = 4
        }
        return _backgroundImageManager
    }
    

    private var _avaImageManager: HXPhotoManager?
    var avaManage: HXPhotoManager? {
        if _avaImageManager == nil {
            _avaImageManager = HXPhotoManager(type: HXPhotoManagerSelectedTypePhoto)
            _avaImageManager?.openCamera = true
            _avaImageManager?.singleSelected = true
            _avaImageManager?.showFullScreenCamera = true
            
        }
        return _avaImageManager
    }
    
    func photoViewControllerDidNext(_ allList: [HXPhotoModel]!, photos: [HXPhotoModel]!, videos: [HXPhotoModel]!, original: Bool) {
        let model: HXPhotoModel? = photos.first
        JJHUD.showLoading(text: "正在上传图片")

        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
       
        query?.getFirstObjectInBackground(block: { (object, error) in
            
            if error == nil {
                
                // send ava picture to server
                let imageData = UIImageJPEGRepresentation((model?.thumbPhoto)!, 1)
                let imageFile = PFFile(name: "petava.jpg", data: imageData!)
                
                if self.type == "ava" {
                
                    object?["ava"] = imageFile
                    object?.saveInBackground(block: { (success, error) in
                        if success {
                            self.imageView.image = model?.thumbPhoto
                            JJHUD.hide()
                            JJHUD.showSuccess(text: "修改成功", delay: 1)
                            
                            // send notification 发布成功
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadImageSuccess"), object: nil, userInfo:["image": self.imageView.image!])
                        }
                    })
                } else {
                
                    object?["backgroundImage"] = imageFile
                    object?.saveInBackground(block: { (success, error) in
                        if success {
                            self.imageView.image = model?.thumbPhoto
                            JJHUD.hide()
                            JJHUD.showSuccess(text: "修改成功", delay: 1)
                            
                            // send notification 发布成功
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadImageSuccess"), object: nil, userInfo:["image": self.imageView.image!])
                        }
                    })
                
                
                }
            }

            
        })
        
        
    }
    
    
    
    func photoViewControllerDidCancel() {}

}
