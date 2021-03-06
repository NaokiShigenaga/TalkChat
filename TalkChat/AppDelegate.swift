//
//  AppDelegate.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/05/22.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import UIKit
import Firebase
import SlideMenuControllerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var roomid: String?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        sleep(2)
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //メニューバーの設定
        // Override point for customization after application launch.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "Home")
        let leftVC = storyboard.instantiateViewController(withIdentifier: "Left")
        let navigationController = UINavigationController(rootViewController: homeVC)
        let slideMenuController = SlideMenuController(mainViewController: navigationController, leftMenuViewController: leftVC)
        
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
        
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("url : \(url.absoluteString)")
        print("scheme : \(url.scheme!)")
        print("host : \(url.host!)")
        print("port : \(url.port!)")
        print("query : \(url.query!)")
        
        //遷移先指定
        if let slideMenuController = self.window?.rootViewController as? SlideMenuController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = slideMenuController.mainViewController as! UINavigationController
            if let mainVC = storyboard.instantiateViewController(withIdentifier: "Talk") as? TalkViewController{
                mainVC.roomData = url.query!
                navigationController.setViewControllers([mainVC], animated: true)
            }
        }
        
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

