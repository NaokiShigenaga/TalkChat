//
//  QrViewController.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/05/30.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class QrViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var share: UIButton!
    
    
    var passedString: String!
    var UserName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if passedString != nil {
            print("招待コード：\(passedString!)")
        }
        
        //文字列をNSDataに変換し、QRコードを作成します。
        //Converts a string to NSData.
        //let str = "-LgBsmK1LHOTpSA_YieC
//        let str = passedString!
//        let data = str.data(using: String.Encoding.utf8)!
//
//        print("QRコード取得データ：\(str)")
            
        //URLをNSDataに変換し、QRコードを作成します。
        //Converts; a url to NSData.
        let url = "talk-chat://localhost:8080/roomid?" + passedString!
        //let url = "https://www.yahoo.co.jp/"
        let data = url.data(using: String.Encoding.utf8)!
        
        //QRコードを生成します。
        //Generate QR code.
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])!
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        let qrImage = qr.outputImage!.transformed(by: sizeTransform)
        let context = CIContext()
        let cgImage = context.createCGImage(qrImage, from: qrImage.extent)
        let uiImage = UIImage(cgImage: cgImage!)
        
        //作成したQRコードを表示します
        qrImageView.image = uiImage
        
        
        //ナビゲーションバー設定＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
        //NavigationBarが半透明かどうか
        navigationController?.navigationBar.isTranslucent = false
        //NavigationBarの色を変更します
        navigationController?.navigationBar.barTintColor = UIColor(red: 129/255, green: 212/255, blue: 78/255, alpha: 1)
        //NavigationBarに乗っている部品の色を変更します
        navigationController?.navigationBar.tintColor = UIColor.white
        
        //閉じる
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "閉じる", style: .plain , target: self, action: #selector(close))
        
        //OQカメラ
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "QRカメラ", style: .plain, target: self, action: #selector(showCamera))

    }
    
    //閉じる
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //QRコード呼び出し
    @objc func showCamera() {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "Camera") as? CameraViewController else { return }
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    //その他の共有用ぶボタン
    @IBAction func ShareButton(_ sender: Any) {

        //ユーザ名
        let userName = Auth.auth().currentUser
        if let userName = userName {
            UserName = userName.displayName!
        }
        let shareText = "\(UserName)さんからの招待が来ています。\n"
        let shareWebsite = NSURL(string: "talk-chat://localhost:8080/roomid?" + passedString!)!
        //let shareImage = UIImage(named: "")!
        
        //let activityItems = [shareText, shareWebsite, shareImage] as [Any]
        let activityItems = [shareText, shareWebsite] as [Any]
        
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivity.ActivityType.saveToCameraRoll,
        ]
        
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        // UIActivityViewControllerを表示
        self.present(activityVC, animated: true, completion: nil)
    }

}
