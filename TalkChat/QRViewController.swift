//
//  QrViewController.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/05/30.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import UIKit

class QrViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        //文字列をNSDataに変換し、QRコードを作成します。
//        //Converts a string to NSData.
//        let str = "トークチャットだよ！"
//        let data = str.data(using: String.Encoding.utf8)!
        
        //URLをNSDataに変換し、QRコードを作成します。
        //Converts; a url to NSData.
        let url = "https://www.yahoo.co.jp/"
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
        //Display QR code
        let qrImageView = UIImageView()
        qrImageView.contentMode = .scaleAspectFit
        qrImageView.frame = self.view.frame
        qrImageView.image = uiImage
        self.view.addSubview(qrImageView)

    }

}
