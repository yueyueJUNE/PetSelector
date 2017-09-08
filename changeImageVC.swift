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
    var user = userID.last

    
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
            _backgroundImageManager?.singleSelected = true;
            _backgroundImageManager?.singleSelecteClip = false
            _backgroundImageManager?.isOriginal = true
            _backgroundImageManager?.cameraType = HXPhotoManagerCameraTypeSystem

        }
        return _backgroundImageManager
    }
    

    private var _avaImageManager: HXPhotoManager?
    var avaManage: HXPhotoManager? {
        if _avaImageManager == nil {
            _avaImageManager = HXPhotoManager(type: HXPhotoManagerSelectedTypePhoto)
            _avaImageManager?.openCamera = true
            _avaImageManager?.isOriginal = true
            _avaImageManager?.singleSelected = true
            _avaImageManager?.singleSelecteClip = true
            _avaImageManager?.cameraType = HXPhotoManagerCameraTypeFullScreen
        }
        return _avaImageManager
    }
    
    func photoViewControllerDidNext(_ allList: [HXPhotoModel]!, photos: [HXPhotoModel]!, videos: [HXPhotoModel]!, original: Bool) {
        
        
        var fetchType: HXPhotoToolsFetchType!
        if original {
            fetchType = HXPhotoToolsFetchOriginalImageTpe
        } else {
            fetchType = HXPhotoToolsFetchHDImageType
        }
        
        HXPhotoTools.getImageForSelectedPhoto(photos, type: fetchType) { (images:[UIImage]?) in
            
            JJHUD.showLoading(text: "正在上传图片")
            // send picture to server
            //let imageData = UIImageJPEGRepresentation((images?.first)!, 1)
            let imageData = images!.first!.compressTo(2)!
            let imageFile = PFFile(name: "userImage.jpg", data: imageData)
            
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
            
            query?.getFirstObjectInBackground(block: { (object, error) in
                
                if error == nil {
                    
                    if self.type == "ava" {
                        
                        object?["ava"] = imageFile
                        object?.saveInBackground(block: { (success, error) in
                            if success {
                               
                                self.imageView.image = UIImage(data: imageData)
                                JJHUD.hide()
                                JJHUD.showSuccess(text: "修改成功", delay: 1)
                                
                                // send notification 发布成功
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadImageSuccess"), object: nil, userInfo:["type": "ava", "image": self.imageView.image!])
                            }
                        })
                    } else {
                        
                        object?["backgroundImage"] = imageFile
                        object?.saveInBackground(block: { (success, error) in
                            if success {
                                self.imageView.image = UIImage(data: imageData)
                                JJHUD.hide()
                                JJHUD.showSuccess(text: "修改成功", delay: 1)
                                
                                // send notification 发布成功
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadImageSuccess"), object: nil, userInfo:["type": "background", "image": self.imageView.image!])
                            }
                        })
                    }
                }
                
            })

            
        }
        
        
    }
    
    func photoViewControllerDidCancel() {}

}
