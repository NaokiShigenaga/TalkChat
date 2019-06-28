//
//  TalkViewController.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/05/22.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseAuth
import SlideMenuControllerSwift
import SVProgressHUD

@objc protocol MenuDelegate: AnyObject {
    func menuEnd(text: String)
}

class TalkViewController: JSQMessagesViewController{
    
    //メニューバーの設定
    @objc private func didTapLeftMenuIcon() {
        self.slideMenuController()?.openLeft()
    }
    
    //ルームID
    //var roomData:String  = "-LgBsmK1LHOTpSA_YieC"
    var roomData:String = ""
    
    // データベースへの参照を定義
    var ref: DatabaseReference!
    
    // メッセージ内容に関するプロパティ
    var messages: [JSQMessage]?
    var snapshotKeys: [String]?
    
    // 背景画像に関するプロパティ
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    // アバター画像に関するプロパティ
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    
    var speechToText:SpeechToText!
    var isSpeechStop = false
    
    var onbutton: UIButton!
    var offbutton: UIButton!
    
    
    //UserDefaults データ保存(roomData)
    var roomIdData:String = ""
    
    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    
    func setupFirebase() {
        
        // デフォルト値
        userDefaults.register(defaults: ["DataStore": ""])
        
        // DatabaseReferenceのインスタンス化
        if roomData != "" {
            ref = Database.database().reference().child("Talk").child(roomData)
            print("確認よう：\(roomData)")
        }else{
            ref = Database.database().reference().child("Talk").childByAutoId()
            print("確認よう：取得できてないよ！")
        }
        //ref = Database.database().reference().child("Talk").childByAutoId()
        //ref = Database.database().reference().child("Talk").child(roomData)
        
        print("ルームID：\(ref)")
        
        //BrowseViewControllerへルームIDを渡す
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.roomid = ref.key!
        
        snapshotKeys = []

        // 最新25件のデータをデータベースから取得する
        // 最新のデータが追加されるたびに最新データを取得する
        ref.queryLimited(toLast: 25).observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let snapshotValue = snapshot.value as! NSDictionary
            let text = snapshotValue["text"] as! String
            let sender = snapshotValue["from"] as! String
            let name = snapshotValue["name"] as! String
            print(snapshot.value!)
            let message = JSQMessage(senderId: sender, displayName: name, text: text)
            
            self.messages?.append(message!)
            self.snapshotKeys?.append(snapshot.key)
            self.finishSendingMessage()
        })
        
        ref.queryLimited(toLast: 25).observe(DataEventType.childChanged, with: { (snapshot) -> Void in
            //編集
            guard let index = self.snapshotKeys?.index(where: {$0 == snapshot.key}) else { return }
            
            // 差し替えるため一度削除する
            self.snapshotKeys?.remove(at: index)
            self.messages?.remove(at: index)
            
            let snapshotValue = snapshot.value as! NSDictionary
            let text = snapshotValue["text"] as! String
            let sender = snapshotValue["from"] as! String
            let name = snapshotValue["name"] as! String
            print(snapshot.value!)
            let message = JSQMessage(senderId: sender, displayName: name, text: text)
            // 削除したところに更新済みのデータを追加する
            self.snapshotKeys?.insert(snapshot.key, at: index)
            self.messages?.insert(message!, at: index)
            
            // collectionViewを再表示する
            self.finishSendingMessage()
            //self.collectionView.reloadData()
        })
        
        
        ref.queryLimited(toLast: 25).observe(DataEventType.childRemoved, with: { (snapshot) -> Void in
            //削除
            guard let index = self.snapshotKeys?.index(where: {$0 == snapshot.key}) else { return }
            
            // 削除する
            self.snapshotKeys?.remove(at: index)
            self.messages?.remove(at: index)
            
            //リロード
            self.finishSendingMessage()
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // クリーンアップツールバーの設定
        inputToolbar!.contentView!.leftBarButtonItem = nil
        // 新しいメッセージを受信するたびに下にスクロールする
        automaticallyScrollsToMostRecentMessage = true
        
        //self.canPerformAction(<#T##action: Selector##Selector#>, withSender: <#T##Any?#>)
        //inputToolbar!.contentView!.textView.c
        // 自分のsenderId, senderDisplayNameを設定
        //ユーザID
        let userId = Auth.auth().currentUser
        if let userId = userId {
            self.senderId = userId.uid
        }
        //ユーザ名
        let userName = Auth.auth().currentUser
        if let userName = userName {
            self.senderDisplayName = userName.displayName
        }
        
        // 吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        // アバターの設定
        //self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "Swift-Logo")!, diameter: 64)
        //self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "Swift-Logo")!, diameter: 64)
        
        //メッセージデータの配列を初期化
        self.messages = []
        setupFirebase()
        
        //ナビゲーションバー＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
        //NavigationBarが半透明かどうか
        navigationController?.navigationBar.isTranslucent = false
        //NavigationBarの色を変更します
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 122/255, blue: 254/255, alpha: 1)
        //NavigationBarに乗っている部品の色を変更します
        navigationController?.navigationBar.tintColor = UIColor.white
        //バーの左側にボタンを配置します(ライブラリ特有)
        addLeftBarButtonWithImage(UIImage(named: "menu")!)
        
        //OQコード用のメニューバー
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "QR招待", style: .plain, target: self, action: #selector(showQRCode))
        
        //音声認識SWボタン(OFF)
        offbutton =  UIButton(type: .custom)
        offbutton.setImage(UIImage(named:"mike02"), for: .normal)
        //UIButton(type: .infoDark)
        inputToolbar!.contentView!.leftBarButtonItem = offbutton
        
    }
    
    //QRコード呼び出し
    @objc func showQRCode() {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "Qr") as? QrViewController else { return }
        //viewController.passedString = roomData
        viewController.passedString = ref.key!
        print("ルーーーーーーーーーーーーーーームID：\(ref.key!)")
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //音声認識ボタン
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        if inputToolbar!.contentView!.leftBarButtonItem == offbutton{
            speechRecognition()
            //音声認識SWボタン(ON)
            onbutton =  UIButton(type: .custom)
            onbutton.setImage(UIImage(named:"mike01"), for: .normal)
            //UIButton(type: .infoDark)
            inputToolbar!.contentView!.leftBarButtonItem = onbutton
        }else{
            speechStop()
            //音声認識SWボタン(OFF)
            offbutton =  UIButton(type: .custom)
            offbutton.setImage(UIImage(named:"mike02"), for: .normal)
            //UIButton(type: .infoDark)
            inputToolbar!.contentView!.leftBarButtonItem = offbutton
            return
        }
    }
    
    // Sendボタンが押された時に呼ばれるメソッド
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessage(animated: true)
        
        //firebaseにデータを送信、保存する
        let post1 = ["from": senderId, "name": senderDisplayName, "text":text]
        let post1Ref = ref.childByAutoId()
        post1Ref.setValue(post1)
        
        self.finishSendingMessage(animated: true)
        
        //キーボードを閉じる
        //self.view.endEditing(true)
    }
    
    // アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages![indexPath.item]
    }
    
    // アイテムごとのMessageBubble(背景)を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    // アイテムごとにアバター画像を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    // アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages!.count
    }
    
    //名前の表示
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let message = messages![indexPath.item]
        
        if message.senderId == senderId {
            return nil
        } else {
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
            
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        //return 17.0
        let message = messages?[indexPath.item]
        
        if message!.senderId == senderId {
            return 0.0
        } else {
            
            return 17.0
            
        }
    }
    
    //タップイベント挙動対策
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView.isUserInteractionEnabled = false
        return cell
    }
    
    //タップイベント（発言者の更新処理）
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        print("タップされたよ！")
        
        let message = messages?[indexPath.item]
        
        //更新用
        func updateValue(text: String) {
            guard let key = snapshotKeys?[indexPath.item] else { return }
            
            if text.isEmpty {
                SVProgressHUD.showError(withStatus: "発言内容が空です")
                return
            }else{
                
                let post1 = ["from": message!.senderId, "name": message!.senderDisplayName, "text": text] as [String: String]
                
                let post1Ref = ref.child(key)
                post1Ref.updateChildValues(post1)
                self.finishSendingMessage(animated: true)
                SVProgressHUD.showSuccess(withStatus: "発言内容を更新しました")
            }
        }
        
        //削除用
        func removeValue() {
            
            guard let key = snapshotKeys?[indexPath.item] else { return }
            let post1Ref = ref.child(key)
            post1Ref.removeValue()
            self.finishSendingMessage(animated: true)
            SVProgressHUD.showSuccess(withStatus: "削除しました")
        }
        
        //アラート表示
        let alert = UIAlertController(title: "発言内容の更新", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField:UITextField) -> Void in
            textField.text = message!.text
        })
        
        //更新メニュー
        alert.addAction(UIAlertAction(title: "更新", style: .default, handler: { (action:UIAlertAction) -> Void in
            
            let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text)")
            updateValue(text: textField.text!)
            
            //キーボードを閉じる
            self.view.endEditing(true)
        }))
        
        //削除メニュー
        alert.addAction(UIAlertAction(title: "削除", style: .default, handler: { (action:UIAlertAction) -> Void in
            
            
            //アラート表示
            let alertController = UIAlertController(title: "本当に削除しますか？", message: "", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "はい", style: .default) { (action:UIAlertAction) in
                
                print("Text field: 削除")
                removeValue()
                
                print("はいが押された")
            }
            
            let action2 = UIAlertAction(title: "いいえ", style: .default) { (action:UIAlertAction) in
                print("いいえが押された")
                return
            }
            
            alertController.addAction(action1)
            alertController.addAction(action2)
            self.present(alertController, animated: true, completion: nil)
            
            
        }))
        
        //キャンセルメニュー
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) -> Void in
            print("Text field: cancel")
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("performAction")
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    //音声認識呼び出し処理＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    func speechRecognition() {
        speechToText = SpeechToText()
        speechToText.delegate = self
        speechToText.start()
    }
    
    
    //音声認識呼び出し処理（STOP）
    func speechStop() {
        speechToText?.stop()
        speechToText = nil
        isSpeechStop = true
    }
    
    //メニューバーのアクション処理
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //退室時に音声認識を止める
        speechToText?.stop()
        //音声認識SWボタン(OFF)
        offbutton =  UIButton(type: .custom)
        offbutton.setImage(UIImage(named:"mike02"), for: .normal)
        //UIButton(type: .infoDark)
        inputToolbar!.contentView!.leftBarButtonItem = offbutton
    }
    
}

//音声データの投稿
extension TalkViewController: SpeechDelegate {
    func speechEnd(text: String) {
        print("音声結果：\(text)")
        
        if !isSpeechStop {
            speechToText = SpeechToText()
            speechToText.delegate = self
            speechToText.start()
        }
        
        //自動投稿
        if text != ""{
            
            //inputToolbar.contentView.textView.text = text
            //Firebaseに登録
            let post1 = ["from": senderId!, "name": senderDisplayName, "text":text] as [String : Any]
            let post1Ref = ref.childByAutoId()
            post1Ref.setValue(post1)
            self.finishSendingMessage(animated: true)
        }else{
            return
        }
        
    }
}

//セーフエリアの設定
extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else { return }
        if #available(iOS 11.0, *) {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
        }
    }
}
