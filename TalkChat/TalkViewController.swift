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

class TalkViewController: JSQMessagesViewController{
    
    //メニューバーの設定
    @objc private func didTapLeftMenuIcon() {
        self.slideMenuController()?.openLeft()
    }
    
    //var RoomId:String  = "-LgBsmK1LHOTpSA_YieC"
    //var RoomId: String!
    var RoomId:String = ""
    
    // データベースへの参照を定義
    var ref: DatabaseReference!
    
    // メッセージ内容に関するプロパティ
    var messages: [JSQMessage]?
    // 背景画像に関するプロパティ
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    // アバター画像に関するプロパティ
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    
    
    var speechToText:SpeechToText!
    
    
    var onbutton: UIButton!
    var offbutton: UIButton!
    
    func setupFirebase() {
        // DatabaseReferenceのインスタンス化
        if RoomId != "" {
            ref = Database.database().reference().child("Talk").child(RoomId)
            print("確認よう：\(RoomId)")
        }else{
            ref = Database.database().reference().child("Talk").childByAutoId()
            print("確認よう：取得できてないよ！")
        }
        //ref = Database.database().reference().child("Talk").childByAutoId()
        //ref = Database.database().reference().child("Talk").child(RoomId)
        
        print("ルームID：\(ref)")
        
        //room_id: uid
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
        navigationController?.navigationBar.barTintColor = UIColor(red: 129/255, green: 212/255, blue: 78/255, alpha: 1)
        //NavigationBarに乗っている部品の色を変更します
        navigationController?.navigationBar.tintColor = UIColor.white
        //バーの左側にボタンを配置します(ライブラリ特有)
        addLeftBarButtonWithImage(UIImage(named: "menu")!)
        
        //OQコード用のメニューバー
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "QR招待", style: .plain, target: self, action: #selector(showQRCode))
        
        //        //音声認識SWボタン(ON)
        //        onbutton =  UIButton(type: .custom)
        //        onbutton.setImage(UIImage(named:"mike0"), for: .normal)
        //        //UIButton(type: .infoDark)
        //        inputToolbar!.contentView!.leftBarButtonItem = onbutton
        
        //音声認識SWボタン(OFF)
        offbutton =  UIButton(type: .custom)
        offbutton.setImage(UIImage(named:"mike02"), for: .normal)
        //UIButton(type: .infoDark)
        inputToolbar!.contentView!.leftBarButtonItem = offbutton
        
    }
    
    //QRコード呼び出し
    @objc func showQRCode() {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "Qr") as? QrViewController else { return }
        //viewController.passedString = RoomId
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
        //let post1 = ["from": senderId, "name": "名無しの権兵衛", "text":"ああああああ"]
        let post1Ref = ref.childByAutoId()
        post1Ref.setValue(post1)
        self.finishSendingMessage(animated: true)
        
        //キーボードを閉じる
        self.view.endEditing(true)
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
    
    //タップイベント（発言者の更新処理）
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {

        print("タップされたよ！")

        let message = messages?[indexPath.item]

        //アラート表示
        let alert = UIAlertController(title: "発言内容の更新", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField:UITextField) -> Void in
            textField.text = message!.text
        })
        alert.addAction(UIAlertAction(title: "更新", style: .default, handler: { (action:UIAlertAction) -> Void in

            let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text)")

        }))
        alert.addAction(UIAlertAction(title: "削除", style: .default, handler: { (action:UIAlertAction) -> Void in
            print("Text field: 削除")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) -> Void in
            print("Text field: cancel")
        }))
        self.present(alert, animated: true, completion: nil)

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
    }
    
}

extension TalkViewController: SpeechDelegate {
    func speechEnd(text: String) {
        print("音声結果：\(text)")
        //自動投稿
        if text != ""{
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
