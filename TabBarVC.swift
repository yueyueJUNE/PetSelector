//
//  TabBarVC.swift
//  LocationSelector
//
//  Created by 刘月 on 7/9/17.
//  Copyright © 2017 Tianmaying. All rights reserved.
//

import UIKit




class TabBarVC: UITabBarController {
    
    //var modalView: UIView!
    var postBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // color of item
        //self.tabBar.tintColor = .white
        
        // color of background
        //self.tabBar.barTintColor = UIColor(red: 37.0 / 255.0, green: 39.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
        
        // disable translucent
        self.tabBar.isTranslucent = false
        //modalView = UIView()
        postBtn = UIButton()

        let WINDOW_HEIGHT = self.view.frame.height
        let TAB_HEIGHT = self.tabBar.frame.height
        let GRID_WIDTH = self.view.frame.width / 5
        let MARGIN_X = CGFloat(2)
        let MARGIN_Y = CGFloat(5)
        let BTN_WIDTH = TAB_HEIGHT - MARGIN_X * 2
        let BTN_HEIGHT = TAB_HEIGHT - MARGIN_Y * 2
        
      
       // modalView.frame = CGRect(x: GRID_WIDTH * 2, y: WINDOW_HEIGHT - TAB_HEIGHT, width: GRID_WIDTH, height: TAB_HEIGHT)
       // self.view.addSubview(modalView)
    
        
        postBtn.frame = CGRect(x: GRID_WIDTH * 2 + (GRID_WIDTH - BTN_WIDTH) / 2, y: WINDOW_HEIGHT - TAB_HEIGHT + MARGIN_Y, width: BTN_WIDTH, height: BTN_HEIGHT)
        postBtn.setBackgroundImage(#imageLiteral(resourceName: "post_btn"), for: UIControlState())
         self.view.addSubview(postBtn)

        postBtn.addTarget(self, action: #selector(postButtonClicked), for: .touchUpInside)
        
       
 
}

    func postButtonClicked(_ sender: UIButton) {
    

        //let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let uploadVC = self.storyboard?.instantiateViewController(withIdentifier: "upload") as! navVC
  
        self.viewControllers?[selectedIndex].present(uploadVC, animated: false, completion: nil)
        
        //self.selectedIndex = 0
    }
    
}

