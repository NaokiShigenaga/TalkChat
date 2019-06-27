//
//  ViewController.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/05/22.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import Firebase
import FirebaseAuth
import UIKit
import SVProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var TalkButton: UIButton!
    @IBOutlet weak var SettingButton: UIButton!
    @IBOutlet weak var LogoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //トークチャットボタンのカスタム
        TalkButton.backgroundColor = UIColor.lightGray
        TalkButton.layer.cornerRadius = 5.0
        
        //設定ボタンのカスタム
        SettingButton.backgroundColor = UIColor.lightGray
        SettingButton.layer.cornerRadius = 5.0
        
        
        //ログアウトボタンのカスタム
        LogoutButton.backgroundColor = UIColor.lightGray
        LogoutButton.layer.cornerRadius = 5.0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ///currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            //ログインしていないときの処理
//            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
//            self.present(loginViewController!, animated: true, completion: nil)
            
            let slideMenuController = self.slideMenuController()
            let navigationController = slideMenuController!.mainViewController as! UINavigationController
            let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            navigationController.setViewControllers([LoginViewController!], animated: true)
            
        }
        
        //ナビゲーションバー設定＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
        //NavigationBarが半透明かどうか
        navigationController?.navigationBar.isTranslucent = false
        //NavigationBarの色を変更します
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 122/255, blue: 254/255, alpha: 1)
        //NavigationBarに乗っている部品の色を変更します
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    //トークチャットボタン
    @IBAction func handleTalkChatButton(_ sender: Any) {
    }
    
    //設定ボタン
    @IBAction func handleSettingButton(_ sender: Any) {
    }
    
    //ログアウトボタン
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        //ログインしていないときの処理
//        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
//        self.present(loginViewController!, animated: true, completion: nil)
        
        let slideMenuController = self.slideMenuController()
        let navigationController = slideMenuController!.mainViewController as! UINavigationController
        let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        navigationController.setViewControllers([LoginViewController!], animated: true)
    }

}

