//
//  MenuViewController.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/05/22.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import Firebase
import FirebaseAuth
import UIKit
import SVProgressHUD
import SlideMenuControllerSwift

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //メニュー
    let fruits = ["招待QR", "QR読取み", "招待コード", "ホーム", "ログアウト"]
    
    ///セルの個数を指定するデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fruits.count
    }
    
    ///セルに値を設定するデータソースメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        // セルに表示する値を設定する
        cell.textLabel!.text = fruits[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //row=0が選択されたとき（招待QR）
        if indexPath.section == 0 && indexPath.row == 0 {
            
            //招待QR画面へ遷移
            let slideMenuController = self.slideMenuController()
            let navigationController = slideMenuController!.mainViewController as! UINavigationController
            let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "Qr")
            navigationController.setViewControllers([ViewController!], animated: true)
            //メニューバーを閉じる
            closeLeft()
            
            print("「招待QR」が押されました")
        }
        
        //row=1が選択されたとき（QR読取み）
        if indexPath.section == 0 && indexPath.row == 1 {
            
            //QR読込み画面へえ遷移
            let slideMenuController = self.slideMenuController()
            let navigationController = slideMenuController!.mainViewController as! UINavigationController
            let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "Camera")
            navigationController.setViewControllers([ViewController!], animated: true)
            //メニューバーを閉じる
            closeLeft()
            
            print("「QR読込み」が押されました")
        }
        
        //row=2が選択されたとき（招待コード）
        if indexPath.section == 0 && indexPath.row == 2 {
            print("「招待コード」が押されました")
        }
        
        //row=3が選択されたとき（ホーム）
        if indexPath.section == 0 && indexPath.row == 3 {
            let slideMenuController = self.slideMenuController()
            let navigationController = slideMenuController!.mainViewController as! UINavigationController
            let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home")
            navigationController.setViewControllers([ViewController!], animated: true)
            //メニューバーを閉じる
            closeLeft()
            print("「ホーム」が押されました")
        }
        
        //row=4が選択されたとき（ログアウト）
        if indexPath.section == 0 && indexPath.row == 4 {
            // ログアウトする
            try! Auth.auth().signOut()
            
            // ログイン画面を表示する
            let slideMenuController = self.slideMenuController()
            let navigationController = slideMenuController!.mainViewController as! UINavigationController
            let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            navigationController.setViewControllers([LoginViewController!], animated: true)
            //メニューバーを閉じる
            closeLeft()
            
            print("「ログアウト」が押されました")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
