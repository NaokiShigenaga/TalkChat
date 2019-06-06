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
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        requestRecognizerAuthorization()
    }
    
    func requestRecognizerAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
        }
    }
    
    func start() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = recognitionRequest
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let `self` = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.delegate?.speechEnd(text: result.bestTranscription.formattedString)
                print(result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stop() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}
