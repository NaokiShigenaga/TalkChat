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

class BrowseViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    //ルームID
    //var roomId:String  = "-LgBsmK1LHOTpSA_YieC"
    //var roomId:String!
    var roomId: String! = ""
    
    // データベースへの参照を定義
    var ref: DatabaseReference!
    
    // メッセージ内容に関するプロパティ
    var snapshotKeys: [String]?
    
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
            
            snapshotKeys = []
            
            // 最新のデータが追加されるたびに最新データを取得する
            ref.observe(DataEventType.childAdded, with: { (snapshot) -> Void in
                let snapshotValue = snapshot.value as! NSDictionary
                if let text = snapshotValue["text"] as? String,
                    let name = snapshotValue["name"] as? String {
                    print("テキスト：\(self.textView.text)")
                    print("名前：\(name)")
                    print("コメント：\(text)")
                    if self.textView.text != nil && !self.textView.text!.isEmpty {
                        self.textView.text = "\(self.textView.text!)\n\(name) : \(text)"
                    } else {
                        self.textView.text = "\(name) : \(text)"
                    }
                    //self.textView.simple_scrollToBottom()
                    let range = NSMakeRange(self.textView.text.count - 1, 0)
                    self.textView.scrollRangeToVisible(range)
                }
                
            })
            
            ref.queryLimited(toLast: 25).observe(DataEventType.childChanged, with: { (snapshot) -> Void in
                //編集
                
                guard let index = self.snapshotKeys?.index(where: {$0 == snapshot.key}) else { return }
                // 差し替えるため一度削除する
                self.snapshotKeys?.remove(at: index)
                //self.messages?.remove(at: index)
                
                let snapshotValue = snapshot.value as! NSDictionary
                if let text = snapshotValue["text"] as? String,
                    let name = snapshotValue["name"] as? String {
                    print("テキスト：\(self.textView.text)")
                    print("名前：\(name)")
                    print("コメント：\(text)")
                    if self.textView.text != nil && !self.textView.text!.isEmpty {
                        self.textView.text = "\(self.textView.text!)\n\(name) : \(text)"
                    } else {
                        self.textView.text = "\(name) : \(text)"
                    }
                }
            })
            
            
            ref.queryLimited(toLast: 25).observe(DataEventType.childRemoved, with: { (snapshot) -> Void in
                //削除
                guard let index = self.snapshotKeys?.index(where: {$0 == snapshot.key}) else { return }
                
                self.snapshotKeys?.remove(at: index)
            })

        }
        
    }
    
    //閉じる処理
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//extension UITextView {
//    func simple_scrollToBottom() {
//        let textCount: Int = text.count
//        guard textCount >= 1 else { return }
//        scrollRangeToVisible(NSMakeRange(textCount - 1, 1))
//    }
//}
