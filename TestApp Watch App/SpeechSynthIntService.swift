//
//  SpeechSynthesiserService.swift
//  TestApp Watch App
//
//  Created by Dániel Szabó on 08/12/2023.
//

import Foundation
import AVFoundation

class SpeechSynthIntService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    var synthesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: "")
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(input: String) {
        synthesizer.stopSpeaking(at: .immediate)
        utterance = AVSpeechUtterance(string: input)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-UK")
        synthesizer.speak(utterance)
    }
    
    func toggleAVSpeechSynthesizerDelegate(isDelegateSet: Bool) {
        if isDelegateSet {
            synthesizer.delegate = self
        }
        else {
            synthesizer.delegate = nil
        }
    }

}
