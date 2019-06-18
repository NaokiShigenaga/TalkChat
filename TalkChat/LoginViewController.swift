//
//  LoginViewController.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/05/22.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import SlideMenuControllerSwift


class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var AccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ログインボタンのカスタム
        LoginButton.backgroundColor = UIColor.lightGray
        LoginButton.layer.cornerRadius = 5.0
        
        //アカウント作成ボタンのカスタム
        AccountButton.backgroundColor = UIColor.lightGray
        AccountButton.layer.cornerRadius = 5.0
        
        //ナビゲーションバー設定＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
        //NavigationBarが半透明かどうか
        navigationController?.navigationBar.isTranslucent = false
        //NavigationBarの色を変更します
        navigationController?.navigationBar.barTintColor = UIColor(red: 129/255, green: 212/255, blue: 78/255, alpha: 1)
        //NavigationBarに乗っている部品の色を変更します
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    

    //ログインボタン
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            //アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty {
                SVProgressHUD.showError(withStatus: "メールアドレスを入力して下さい")
                return
            }else if password.isEmpty {
                SVProgressHUD.showError(withStatus: "パスワードを入力して下さい")
                return
            }
            
            //HUDで処理中を表示
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: address, password: password) { user, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "ログインに成功しました。")
                print("DEBUG_PRINT: ログインに成功しました。")
                
                //HUDを消す
                SVProgressHUD.dismiss()
                
//                //画面を閉じてホーム画面に遷移
//                let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home")
//                self.present(ViewController!, animated: true, completion: nil)
                
                let slideMenuController = self.slideMenuController()
                let navigationController = slideMenuController!.mainViewController as! UINavigationController
                let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                navigationController.setViewControllers([ViewController!], animated: true)
            }
        }
    }
    
    //アカウント作成ボタン
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
            
            //アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty {
                print("DEBUG_PRINT: アドレスが空文字です。")
                SVProgressHUD.showError(withStatus: "メールアドレスが空です。")
                return
            }else if password.isEmpty{
                print("DEBUG_PRINT: パスワードが空文字です。")
                SVProgressHUD.showError(withStatus: "パスワードが空です。")
                return
            }else if displayName.isEmpty {
                print("DEBUG_PRINT: 名前が空文字です。")
                SVProgressHUD.showError(withStatus: "名前が空です。")
                return
            }
            
            //HUDで処理中を表示
            SVProgressHUD.show()
            
            //アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { user, error in
                if let error = error {
                    //エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。\n\(error.localizedDescription)")
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "ユーザー作成に成功しました。")
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                //表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            //プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                            return
                        }
                        SVProgressHUD.showSuccess(withStatus: "\(user.displayName!)の設定に成功しました。")
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        //HUDを消す
                        SVProgressHUD.dismiss()
                        
                        //画面を閉じてホーム画面へ遷移
                        let slideMenuController = self.slideMenuController()
                        let navigationController = slideMenuController!.mainViewController as! UINavigationController
                        let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "Home")
                        navigationController.setViewControllers([ViewController!], animated: true)
                    }
                }
            }
        }
    }
    
}
