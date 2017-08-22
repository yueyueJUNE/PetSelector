//
//  UploadPhotos.swift
//  PetSelector
//
//  Created by 刘月 on 7/21/17.
//  Copyright © 2017 YueLiu. All rights reserved.
//

import UIKit
import Parse

class UploadPhotos: UIViewController, HXPhotoViewDelegate, HXPhotoViewControllerDelegate, LocationSelectorDelegate , BreedSelectorDelegate {
   
   
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var avaImage: UIImageView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var breedLbl: UILabel!
    
    //var breedUpload = ""
    //var locationUpload = ""
    //var avaFile: PFFile?
    var petPhotos = [PFFile]()
    //var petPhotoID = [String]()
    var photocount: Int?
    var scrollView: UIScrollView?

    var morePhotoView: HXPhotoView?

     private var _morePhotoManage: HXPhotoManager?
     var morePhotoManager: HXPhotoManager? {
     if _morePhotoManage == nil {
     _morePhotoManage = HXPhotoManager(type: HXPhotoManagerSelectedTypePhoto)
     _morePhotoManage?.openCamera = true
     //_morePhotoManage?.outerCamera = false
     _morePhotoManage?.showFullScreenCamera = true
     _morePhotoManage?.photoMaxNum = 9
    // _morePhotoManage?.videoMaxNum = 0
     _morePhotoManage?.maxNum = 9
     _morePhotoManage?.rowCount = 4
     }
     return _morePhotoManage
     }
    
    
    private var _avaManage: HXPhotoManager?
    var avaManager: HXPhotoManager? {
        if _avaManage == nil {
            _avaManage = HXPhotoManager(type: HXPhotoManagerSelectedTypePhoto)
            _avaManage?.openCamera = true
            _avaManage?.singleSelected = true
            _avaManage?.showFullScreenCamera = true
        }
        return _avaManage
    }
    
    var alertView: UIVisualEffectView!
     
     override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //首先创建一个模糊效果
        // let blurEffect = UIBlurEffect(style: .light)
        //接着创建一个承载模糊效果的视图
       // let alertView = UIVisualEffectView(effect: blurEffect)
        //设置模糊视图的大小
        //alertView.frame.size = CGSize(width: view.frame.width, height: 64)
        
        
        
        avaImage.layer.cornerRadius = avaImage.frame.size.width / 2
        avaImage.clipsToBounds = true
        

        
        // tap to choose location
        let locationTap = UITapGestureRecognizer(target: self, action: #selector(selectLocation))
        //locationLbl.numberOfTapsRequired = 1
        locationLbl.isUserInteractionEnabled = true
        locationLbl.addGestureRecognizer(locationTap)
        
        
        // tap to choose breed
        let breedTap = UITapGestureRecognizer(target: self, action: #selector(selectBreed))
        breedLbl.isUserInteractionEnabled = true
        breedLbl.addGestureRecognizer(breedTap)
        
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(loadAvaImage))
        avaImage.isUserInteractionEnabled = true
        avaImage.addGestureRecognizer(avaTap)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        view.addSubview(scrollView!)
        scrollView?.addSubview(upperView)
        
        morePhotoView = HXPhotoView(frame: CGRect(x: 20, y: (upperView?.frame.height)!, width: view.frame.size.width - 40, height: 0), with: morePhotoManager)
        morePhotoView?.delegate = self
        scrollView?.addSubview(morePhotoView!)
        
        navigationController?.navigationBar.isTranslucent = false
        //automaticallyAdjustsScrollViewInsets = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain, target: self, action: #selector(self.publish))
        //savePhotoThread = Thread(target: self, selector: #selector(savePetPhotos), object: nil)

     
    }
    //load 宠物的头像
    func loadAvaImage() {
        let vc = HXPhotoViewController()
        vc.manager = avaManager
        vc.delegate = self
        present(UINavigationController(rootViewController: vc as UIViewController), animated: false) { _ in }
    }
    
    //DELEGATE
    func photoViewUpdateFrame(_ frame: CGRect, with photoView: HXPhotoView) {
         if morePhotoView == photoView {
         morePhotoView?.frame = CGRect(x: 0, y: (upperView?.frame.height)!, width: view.frame.size.width, height: (morePhotoView?.frame.size.height)!)
         
         }
         
         scrollView?.contentSize = CGSize(width: view.frame.size.width, height: (upperView.frame.size.height + (morePhotoView?.frame.height)!) + 100)
        
    }
    
    func photoViewDeleteNetworkPhoto(_ networkPhotoUrl: String) {
        print("\(networkPhotoUrl)")
    }
    

    //点击选择宠物详情页照片
    func didNavBtnClick() {
        morePhotoView?.goController()
    }
    
    
    
    func photoViewChangeComplete(_ allList: [HXPhotoModel], photos: [HXPhotoModel], videos: [HXPhotoModel], original isOriginal: Bool) {
        print("所有:\(allList.count) - 照片:\(photos.count) - 视频:\(videos.count)")
        
        photocount = photos.count
        HXPhotoTools.getImageForSelectedPhoto(photos, type: HXPhotoToolsFetchHDImageType, completion: nil)
        
        HXPhotoTools.getImageForSelectedPhoto(photos, type: HXPhotoToolsFetchHDImageType) { (images: [UIImage]?) in
            
            self.petPhotos.removeAll(keepingCapacity: false)
            for image in images! {
                
                // send picture
                let petPhoto = UIImageJPEGRepresentation(image, 1)
                let photoFile = PFFile(name: "\(PFUser.current()!.objectId!)petphotos.jpg", data: petPhoto!)
                self.petPhotos.append(photoFile!)
            }
        }
    }


    func photoViewControllerDidNext(_ allList: [HXPhotoModel]!, photos: [HXPhotoModel]!, videos: [HXPhotoModel]!, original: Bool) {
        let model: HXPhotoModel? = allList.first
        avaImage.image = model?.thumbPhoto
    }
    
    func photoViewControllerDidCancel() {}
    
    
    func selectLocation() {
        let locationSelector = LocationSelector()
        locationSelector.delegate = self;
        self.navigationController?.pushViewController(locationSelector, animated: true)
    }
    
    
    func selectBreed() {
        let breedSelector = BreedSelector(false)
        breedSelector.delegate = self;
        self.navigationController?.pushViewController(breedSelector, animated: true)
        
    }
    
    
    func locationSelected(_ locations: String) {
        locationLbl.text = locations
        locationLbl.textColor = .black
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    
    func breedSelected(_ breeds: [String]) {
        var selectedBreeds = String()
        for breed in breeds {
            selectedBreeds += breed + "\n"
        }
        breedLbl.text = selectedBreeds.trimmingCharacters(in: NSCharacterSet.newlines)
        breedLbl.textColor = .black
        self.navigationController?.popToViewController(self, animated: true)
    }
    

    
    func alert(_ titleMessage: String, _ alertMessage: String) {
        let alert = UIAlertController(title: titleMessage, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        //let ok = UIAlertAction(title: "确定", style: UIAlertActionStyle.cancel, handler: nil)
        //alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.25) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    

 
    
    //保存信息到server
    func publish() {
        
        // send notification 发布失败
        NotificationCenter.default.post(name: Notification.Name(rawValue: "beginActivityIndicator"), object: nil)
       
        
        if locationLbl.text! == "点我选择..." {alert("请选择","地区")}
        if breedLbl.text! == "点我选择..." {alert("请选择","品种")}
        if avaImage.image == #imageLiteral(resourceName: "petAva") {alert("请选择","宠物头像")}
        if photocount == 0 || photocount == nil {alert("请选择","详情页照片")}
                
        if locationLbl.text! != "点我选择..." && breedLbl.text! != "点我选择..." && avaImage.image != #imageLiteral(resourceName: "petAva") &&  petPhotos.count == photocount {
            
        
            var petPhotoObject = [PFObject]()
            for photo in petPhotos {
                
                //save pet photos into server
                let photoobject = PFObject(className: "petphotos")
                photoobject["petphoto"] = photo
                petPhotoObject.append(photoobject)
            }
            
            PFObject.saveAll(inBackground: petPhotoObject, block: { (success, error) in
                if success {
                    var petPhotoID = [String]()
                    for object in petPhotoObject {
                        petPhotoID.append(object.objectId!)
                    }
                    
                    //save post to server
                    let postobject = PFObject(className: "Post")
                    postobject["location"] = self.locationLbl.text!.trimmingCharacters(in: .whitespaces)
                    postobject["breed"] = self.breedLbl.text!.replacingOccurrences(of: " ", with: "")
                    postobject["owner"] = PFUser.current()!.objectId
                    postobject["petname"] = petnameUpload
                    postobject["gender"] = genderUpload
                    postobject["age"] = ageUpload
                    postobject["size"] = sizeUpload
                    postobject["color"] = colorUpload
                    postobject["petphotos"] = petPhotoID
                    postobject["shot"] = shotUpload
                    postobject["neuter"] = neuterUpload
                    postobject["deworm"] = dewormUpload
                    postobject["adopted"] = false
                    postobject["story"] = storyUpload
                    postobject["like"] = likeUpload
                    postobject["contact"] = contactUpload
                    
                    // send ava picture to server
                    let avaData = UIImageJPEGRepresentation(self.avaImage.image!, 1)
                    let avaFile = PFFile(name: "petava.jpg", data: avaData!)
                    postobject["petava"] = avaFile
                    
                    postobject.saveInBackground (block: { (success, error) -> Void in
    
                
                       // var view: AlertView?
                        if error == nil {
                            
                            
                            // send notification 发布成功
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadSuccess"), object: nil)
                       
                        } else {
                            // send notification 发布失败
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadFail"), object: nil)
                            
                        }
                        
                    })
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "stopActivityIndicator"), object: nil)

                
                
            } else {
                     NotificationCenter.default.post(name: Notification.Name(rawValue: "stopActivityIndicator"), object: nil)
        
                    // send notification 发布失败
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "uploadFail"), object: nil)
                    

                            }
            })
            
            dismissToRootViewController()
        }
      
    }
    
    
    func dismissToRootViewController() {
        var vc: UIViewController? = self
        while ((vc?.presentingViewController) != nil) {
            vc = vc?.presentingViewController
        }
        vc?.dismiss(animated: true) { _ in }
        
        // switch to another ViewController at 0 index of tabbar
        let app: AppDelegate? = (UIApplication.shared.delegate as? AppDelegate)
        let controller: UIViewController? = app?.window?.rootViewController
        let rvc: TabBarVC? = (controller as? TabBarVC)
        rvc?.selectedIndex = 0
        
    }

}

