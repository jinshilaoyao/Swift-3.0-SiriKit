//
//  SpeechTranscriber.swift
//  siriKit
//
//  Created by yesway on 2016/11/1.
//  Copyright © 2016年 joker. All rights reserved.
//

import Speech



class SpeechTranscriber {
    
    private(set) var isTranscribing: Bool = false
    
    var onTranscriptionCompletion: ((String) -> ())?
    
    private var recongnitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    
    init() {
        SFSpeechRecognizer.requestAuthorization { (status) in
            if status == .authorized {
                print("We're good to go!")
            } else {
                fatalError("Sorry, this demo is a bit pointless if you disable dictation")
            }
        }
    }
    
    func start() {
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        do {
            try createAudioSession(onNewBufferReceived: { (buffer) in
                self.recongnitionRequest?.append(buffer)
            })
        }
        catch {
            fatalError("Error setting up microphone input listener!")
        }
        
        speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [unowned self] (result, error) in
            
            guard let result = result else {
                print(error?.localizedDescription)
                return
            }
            
            if result.isFinal {
                self.onTranscriptionCompletion?(result.bestTranscription.formattedString)
            }
        })
        self.recongnitionRequest = recognitionRequest
        isTranscribing = true
    }
    
    func stop() {
        recongnitionRequest?.endAudio()
        audioEngine.stop()
        audioEngine.inputNode?.removeTap(onBus: 0)
        isTranscribing = false

    }
    
    private func createAudioSession(onNewBufferReceived: @escaping (AVAudioPCMBuffer) -> ())
    throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            onNewBufferReceived(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
}
