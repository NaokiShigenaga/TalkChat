//
//  SpeechFramework.swift
//  TalkChat
//
//  Created by 繁永 直希 on 2019/06/06.
//  Copyright © 2019 naoki.shigenaga. All rights reserved.
//

import Foundation
import UIKit
import Speech

@objc protocol SpeechDelegate: AnyObject {
    func speechEnd(text: String)
}

class SpeechToText {
    
    weak var delegate: SpeechDelegate?
    
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var audioEngine: AVAudioEngine!
    var startCount = 0
    
    
    init() {
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    func start() {
        startCount += 1
        print(startCount)
        guard let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP")) else { return }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        audioEngine = AVAudioEngine()
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest.append(buffer)
        }
        do {
            try audioEngine.start()
        } catch {
            // エラー処理
            return
        }
        
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            //self.stop()
            self.delegate?.speechEnd(text: result?.bestTranscription.formattedString ?? "")
            print("resultHandler")
            print(result?.bestTranscription.formattedString ?? "")
            
            
            if let error = error {
                print("ERROR!")
                print(error.localizedDescription)
            }
        }
        
                DispatchQueue.main.asyncAfter(deadline: .now() + 59.0, execute: {
                    self.recognitionTask?.cancel()
                    self.recognitionTask?.finish()
                    self.audioEngine.stop()
                    print("RESTART")
                    self.start()
                })
    }
    
    func stop(){
        self.audioEngine?.stop()
        print("停止ボタンが押されました！")
    }
}
