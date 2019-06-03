//
//  CameraViewController.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/05/22.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import UIKit
import AVFoundation
import SlideMenuControllerSwift

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    //カメラやマイクの入出力を管理するオブジェクトを生成
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //カメラやマイクのデバイスオブジェクトを生成
        let devices:[AVCaptureDevice] = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices
        
        //該当するデバイスのうち最初に取得したもの(背面カメラ)を利用する
        if let backCamera = devices.first {
            do {
                //QRコードの読み取りに背面カメラの映像を利用するための設定
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    
                    //背面カメラの映像からQRコードを検出するための設定
                    let metadataOutput = AVCaptureMetadataOutput()
                    
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        
                        //背面カメラの映像を画面に表示するためのレイヤーを生成
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.frame = self.view.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(previewLayer)
                        
                        //読み取り開始
                        self.session.startRunning()
                    }
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
        
        //ナビゲーションバー
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "閉じる", style: .plain , target: self, action: #selector(close))
        
        
        //OQコード用のメニューバー
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "QRコード", style: .plain, target: self, action: #selector(back))
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            //QRコードのデータかどうかの確認
            if metadata.type != .qr {
                continue
            }
            
            //QRコードの内容が空かどうかの確認
            if metadata.stringValue == nil {
                continue
            }
            
            //ここでQRコードから取得したデータで処理を行う
            //取得したデータは「metadata.stringValue」
            guard let viewController = storyboard?.instantiateViewController(withIdentifier: "Talk") as? TalkViewController else { return }
            //viewController.passedString = RoomId
            let dataID = metadata.stringValue!
            viewController.RoomId = dataID
            print("カメラViewでのID：\(dataID)")
            present(UINavigationController(rootViewController: viewController), animated: true)
        
        }
    }
    
    //ナビゲーションバー （閉じる）
    @objc func close() {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    //ナビゲーションバー （戻る）
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }

}
