//
//  BrowseViewController.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/06/19.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import JSQMessagesViewController

class BrowseViewController:UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    //ルームID
    //var roomId:String  = "-LgBsmK1LHOTpSA_YieC"
    //var roomId:String!
    var roomId: String! = ""
    
    // データベースへの参照を定義
    var ref: DatabaseReference!
    
    // メッセージ内容に関するプロパティ
    var snapshotKeys: [String]?
    //var messages: [JSQMessage]?
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //閉じるボタンの設置
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "閉じる", style: .plain , target: self, action: #selector(close))
        
        //TextViewの行間調整
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 70
        let attributes = [NSAttributedString.Key.paragraphStyle : style]
        textView!.attributedText = NSAttributedString(string: textView!.text,
                                                    attributes: attributes)
        
        //TextViewの編集を不可にする
        self.textView.isEditable = false
        self.textView.isSelectable = false
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let roomId = appDelegate.roomid {
            
            print("確認用ID：\(roomId)")
        
            // DatabaseReferenceのインスタンス化
            ref = Database.database().reference().child("Talk").child(roomId)
            
            print("ルームアイディー：\(roomId)")
            
            //メッセージデータの配列を初期化
            messages = []
            snapshotKeys = []
            
            // 最新のデータが追加されるたびに最新データを取得する
            ref.observe(DataEventType.childAdded, with: { (snapshot) -> Void in
                let snapshotValue = snapshot.value as! NSDictionary
                if  let text = snapshotValue["text"] as? String,
                    let sender = snapshotValue["from"] as? String,
                    let name = snapshotValue["name"] as? String {
                    print("テキスト：\(self.textView.text)")
                    print("名前：\(name)")
                    print("コメント：\(text)")
//                    if self.textView.text != nil && !self.textView.text!.isEmpty {
//                        self.textView.text = "\(self.textView.text!)\n\(name) : \(text)"
//                    } else {
//                        self.textView.text = "\(name) : \(text)"
//                    }
                    //let message = JSQMessage(senderId: sender, displayName: name, text: text)
                    
//                    self.messages.append(message!)
//                    self.snapshotKeys?.append(snapshot.key)
                    
                    self.messages.append("\(name) : \(text)")
                    self.textView.text = self.messages.joined(separator: "\n")
                    
                    print("messagesの中身：\(self.messages)")
                    
                    print("self.messages.joinedの中身：\(self.messages)")

                    //スクロール設定
                    self.textView.down_scrollToBottom()
                }
                
            })
            
            ref.observe(DataEventType.childChanged, with: { (snapshot) -> Void in
                //更新
                guard let index = self.snapshotKeys?.index(where: {$0 == snapshot.key}) else { return }
                //差し替えるため一度削除する
                self.snapshotKeys?.remove(at: index)
                self.messages.remove(at: index)

                let snapshotValue = snapshot.value as! NSDictionary
                if  let text = snapshotValue["text"] as? String,
                    let sender = snapshotValue["from"] as? String,
                    let name = snapshotValue["name"] as? String {
                    print("テキスト：\(self.textView.text)")
                    print("名前：\(name)")
                    print("コメント：\(text)")
                    if self.textView.text != nil && !self.textView.text!.isEmpty {
                        self.textView.text = "\(self.textView.text!)\n\(name) : \(text)"
                    } else {
                        self.textView.text = "\(name) : \(text)"
                    }
                    //let message = JSQMessage(senderId: sender, displayName: name, text: text)

                    self.messages.append("\(name) : \(text)")
                    self.textView.text = self.messages.joined(separator: "\n")
                    
                    print("messagesの中身（更新後）：\(self.messages)")

                    //スクロール設定
                    self.textView.down_scrollToBottom()
                }
            })
     
            
            ref.observe(DataEventType.childRemoved, with: { (snapshot) -> Void in
                //削除
                guard let index = self.snapshotKeys?.index(where: {$0 == snapshot.key}) else { return }
                self.snapshotKeys?.remove(at: index)
                self.messages.remove(at: index)
                
                //スクロール設定
                self.textView.down_scrollToBottom()
            })
            

        }
        
    }
    
    //閉じる処理
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//下への自動スクロール
extension UITextView {
    func down_scrollToBottom() {
        let textCount: Int = text.count
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSMakeRange(textCount - 1, 1))
    }
}
