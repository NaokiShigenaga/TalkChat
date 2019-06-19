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
    //var RoomId:String  = "-LgBsmK1LHOTpSA_YieC"
    var RoomId:String = ""
    
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
        
        // DatabaseReferenceのインスタンス化
        //ref = Database.database().reference().child("Talk").child(RoomId)
        ref = Database.database().reference().child("Talk").child("-LhhLMvoWxqgNQTuVQrK")
        
        print("ルームID：\(ref)")
        
        snapshotKeys = []
        
        
        
        
        
        // 最新のデータが追加されるたびに最新データを取得する
        ref.observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let snapshotValue = snapshot.value as! NSDictionary
            if let text = snapshotValue["text"] as! String?,
                let sender = snapshotValue["from"] as! String?,
                let name = snapshotValue["name"] as! String? {
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
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    //閉じる処理
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
