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
    
    var passedString: String!
    var RoomId: String!
    
    //メニュー
    let fruits = ["招待コード", "退室", "ログアウト"]
    
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
        //row=0が選択されたとき（招待コード）
        if indexPath.section == 0 && indexPath.row == 0 {
            
            print("「招待コード」が押されました")
        }
        
        //row=1が選択されたとき（退室）
        if indexPath.section == 0 && indexPath.row == 1 {
            
            //アラート表示
            let alertController = UIAlertController(title: "本当に退室しますか？", message: "※再度、入室する場合は\n招待を受けてください。", preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "はい", style: .default) { (action:UIAlertAction) in
                let slideMenuController = self.slideMenuController()
                let navigationController = slideMenuController!.mainViewController as! UINavigationController
                let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                navigationController.setViewControllers([ViewController!], animated: true)
                
                print("はいが押された")
            }
            
            let action2 = UIAlertAction(title: "いいえ", style: .default) { (action:UIAlertAction) in
                print("いいえが押された")
                return
            }
            
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)
            
            //メニューバーを閉じる
            closeLeft()
            print("「退室」が押されました")
        }
        
        //row=2が選択されたとき（ログアウト）
        if indexPath.section == 0 && indexPath.row == 2 {
            
            //アラート表示
            let alertController = UIAlertController(title: "本当にログアウトしますか？", message: "", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "はい", style: .default) { (action:UIAlertAction) in
                // ログアウトする
                try! Auth.auth().signOut()
                // ログイン画面を表示する
                let slideMenuController = self.slideMenuController()
                let navigationController = slideMenuController!.mainViewController as! UINavigationController
                let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                navigationController.setViewControllers([LoginViewController!], animated: true)
                print("はいが押された")
            }
            
            let action2 = UIAlertAction(title: "いいえ", style: .default) { (action:UIAlertAction) in
                print("いいえが押された")
                return
            }
            
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)
            
            
            
            
            
            
            //メニューバーを閉じる
            closeLeft()
            
            print("「ログアウト」が押されました")
        }
        
        //テーブル選択後の選択色解除
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
