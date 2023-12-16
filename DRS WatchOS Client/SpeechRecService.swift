//
//  SpeechRecService.swift
//  TestApp Watch App
//
//  Created by Dániel Szabó on 08/12/2023.
//

import Foundation

import Foundation
import AVFoundation

class SpeechRecService: NSObject, ObservableObject, AVAudioRecorderDelegate {

    private var audioRecorder: AVAudioRecorder = AVAudioRecorder();
    
    override init() {

        super.init()
    }
    
    func startRecording() {
        
        let recordSettings = [
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey : 16000.0,
        ] as [String : Any]
        
        let dirsPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirsPaths[0] as String
        let soundFilePath = docsDir + "/recording.wav"
        print("Saving recorded audio file in \(soundFilePath)")
                AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool) -> Void
        in
        if granted {
            let soundFileURL = NSURL(string: soundFilePath)
            if let soundFileURL = soundFileURL {
                do {
                    let recorder = try AVAudioRecorder(url: soundFileURL as URL, settings: recordSettings)
                    recorder.isMeteringEnabled = true
                    recorder.prepareToRecord()
                    recorder.record(forDuration: 10.0)
                    self.audioRecorder = recorder
                    
                    if(!recorder.isRecording) {
                        self.startRecording()
                        return
                    }
//                    sleep(5)
//                    recorder.stop()
                    print("recorder.isRecording: \(recorder.isRecording)")
//                    
                } catch {
                   
                }
            }
        }
    })
        
//        print("asking permission")
//        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
//            if granted {
//                print("recording permission granted")
//                let pathArray = [self.getDirectory(), "recording.wav"]
//                let audioURL = URL(string: pathArray.joined(separator: "/"))!
//                
//                
//                let settings = [
////                  AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue,
//                  AVNumberOfChannelsKey: 1,
//                  AVSampleRateKey : 12000
//                  
//                ]
//                
//                do {
//                    let audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
//                    
//                    print(audioRecorder)
//                    
//                    audioRecorder.delegate = self
//                    print("Recording starting")
//                    audioRecorder.isMeteringEnabled = true
//                    let prepared = audioRecorder.prepareToRecord()
//                    
//                    self.audioRecorder = audioRecorder
//                    print("prepared to record = \(String(describing: prepared))")
//                    
//                    audioRecorder.record()
//                    print("Recording started")
//                } catch {
//                    print("Recording failed")
//                }
//            } else{
//                print("not granted")
//            }
//         })
    }
    
    func stopRecording( callback: @escaping (String) -> Void) {
        print("Stopping recording")
        self.audioRecorder.stop()
        print("Recording finished")
        self.sendAudioToAPI(callback: callback)
    }
    
    private func sendAudioToAPI( callback: @escaping (String) -> Void) {
        
        play()
        do {
            let audioData = try Data(contentsOf: self.getRecordingURL())
            uploadAudioToAPI(audioData: audioData, callback: callback)
        } catch {
            print("Error converting audio file to data: \(error.localizedDescription)")
            print(error)
        }
        
    }

    private func uploadAudioToAPI(audioData: Data, callback: @escaping (String) -> Void) {
        // Replace "YOUR_API_ENDPOINT" with the actual endpoint of your API
        let apiEndpoint = "http://192.168.1.32:9001/api/v1/transcribe/?model=tiny.en.q5"
//        let apiEndpoint = "http://192.168.1.243:9001/api/v1/transcribe/?model=ggml-model-whisper-base.en-q5_1.bin"

        let request = NSMutableURLRequest(url: URL(string: apiEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")
        request.setValue("5e5ab95c454b43dc84be18a866680cffWih9FMxo8LoMREwuHScWT1QKVKwE9viv", forHTTPHeaderField: "Authentication")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = NSMutableData()
        body.append(("--\(boundary)\r\n" as NSString).data(using: NSUTF8StringEncoding)!)
        body.append(("Content-Disposition: form-data; name=\"file\"; filename=\"recording.wav\"\r\n" as NSString).data(using: NSUTF8StringEncoding)!)
        body.append(("Content-Type: audio/wav\r\n\r\n" as NSString).data(using: NSUTF8StringEncoding)!)
        body.append(audioData)
        body.append(("\r\n" as NSString).data(using: NSUTF8StringEncoding)!)
        body.append(("--\(boundary)--\r\n" as NSString).data(using: NSUTF8StringEncoding)!)

        request.httpBody = body as Data

        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data, error == nil else {
                print(error)
                return
            }
            
            let result = String(data: data, encoding: String.Encoding.utf8)!
                .replacingOccurrences(of: "{\"text\":\" ", with: "")
                .replacingOccurrences(of: "\\n\",\"filename\":\"recording.wav\"}", with: "")
                .replacingOccurrences(of: "\\n [BLANK_AUDIO]", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("User input: " + result)
            callback(result)
        }
        task.resume()
    }
    
    func play() {
        let url: URL = getRecordingURL()
        let playerItem = AVPlayerItem(url: url)
        print(url)

        let player = AVPlayer(playerItem:playerItem)
        player.volume = 1.0
        player.play()
    }
    
    func getDirectory()-> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getRecordingURL() -> URL {
        return getDirectory().appendingPathComponent("recording.wav")
    }
    
}
