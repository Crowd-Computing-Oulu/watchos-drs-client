//
//  SpeechSynthExtService.swift
//  TestApp Watch App
//
//  Created by Dániel Szabó on 16/12/2023.
//

import Foundation
import AVFoundation

class SpeechSynthExtService: NSObject, ObservableObject, AVAudioPlayerDelegate {

    var utterance = AVSpeechUtterance(string: "")
    
    var avAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    override init() {
        super.init()
        avAudioPlayer.delegate = self
    }
    
    func speak(input: String) {
        
        print("sending \"" + input + "\" to external speech synthesiser")
        let url = URL(string: "http://192.168.1.32:59125/api/tts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = input.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error while sending \" \(input) \" to external speech synthesiser \(error)")
            } else if let data = data {
                print("received audio from external speech synthesiser")
                // Assuming the response data is the audio content
                do {
                    print("saving audio file")
                    // You can handle the audio data here
                    try data.write(to: self.getAudioURL())
                    
                    print("playing audio file")
                    let session = AVAudioSession.sharedInstance()

                    do {
                        try? session.setCategory(.playAndRecord, mode: .default)
                        try? session.setActive(true)
                        try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.spokenAudio,
                                                policy: AVAudioSession.RouteSharingPolicy.default, options: [])
                    } catch {
                        print("audiosession cannot be set")
                    }


                    // Play the audio
                    do {
                        self.avAudioPlayer = try AVAudioPlayer(contentsOf: self.getAudioURL())
                        self.avAudioPlayer.prepareToPlay()
                        self.avAudioPlayer.enableRate = true
                        self.avAudioPlayer.rate = 1.4
                        self.avAudioPlayer.play()
                        
                    } catch let error as NSError {
                        print(error.description)
                    }
                    
                    // Remove the temporary audio file
//                    try? FileManager.default.removeItem(at: self.getAudioURL())
                } catch {
                    print("Error handling audio data: \(error)")
                }
            }
        }

        task.resume()
    }
    
    func getDirectory()-> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getAudioURL() -> URL {
        return getDirectory().appendingPathComponent("output.wav")
    }
    
}

