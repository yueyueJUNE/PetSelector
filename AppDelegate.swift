

//
//  AppDelegate.swift
//  LocationSelector
//
//  Created by YW on 15/7/10.
//  Copyright (c) 2015年 Tianmaying. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabbar: TabBarVC = TabBarVC()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {


        
        //configuration of using parse
        let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) in
            //accesing back4app app via id and keys
            
            /*
            ParseMutableClientConfiguration.applicationId = "VNhp1vvxPicoJKgjX5OG8Z5fY1XMK0yChsS9fuk2"
            ParseMutableClientConfiguration.clientKey = "MgKbZ4nNR3dCybtLRYigmrL35S3MleCaVTvo1Dqy"
             */
            
            ParseMutableClientConfiguration.applicationId = "VNhp1vvxPicoJKgjX5OG8Z5fY1XMK0yChsS9fuk2"
            ParseMutableClientConfiguration.clientKey = "MgKbZ4nNR3dCybtLRYigmrL35S3MleCaVTvo1Dqy"
            ParseMutableClientConfiguration.server = "https://parseapi.back4app.com/"
        }
        
        Parse.initialize(with: parseConfig)
        //call log in function
        //login()
        
        ShareSDK.registerActivePlatforms([SSDKPlatformType.typeSinaWeibo.rawValue, SSDKPlatformType.typeWechat.rawValue],
            onImport: { (platform) in
                
                switch platform
                {
                case SSDKPlatformType.typeSinaWeibo:
                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                case SSDKPlatformType.typeWechat:
                    ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                default:
                    break
                }
        }, onConfiguration:  {(platform : SSDKPlatformType , appInfo : NSMutableDictionary?) -> Void in
            switch platform
            {
            case SSDKPlatformType.typeSinaWeibo:
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                appInfo?.ssdkSetupSinaWeibo(byAppKey: "2987161806",
                                            appSecret: "182cb4fdab99c38a8bd36e51b1576225",
                                            redirectUri: "https://api.weibo.com/oauth2/default.html",
                                            authType: SSDKAuthTypeBoth)

                
            case SSDKPlatformType.typeWechat:
                //设置微信应用信息
                appInfo?.ssdkSetupWeChat(byAppId: "wxc3a6e2843f81c552",
                                         appSecret: "a393a662513b5f187094f776daab4288")
           
            default:
                break
            }
                        
        })
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let myTapbBar = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
        window?.rootViewController = myTapbBar
        
 
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
  

}

