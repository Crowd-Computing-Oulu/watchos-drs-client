//
//  ContentView.swift
//  TestApp Watch App
//
//  Created by Dániel Szabó on 29/09/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var pepperResponse = ""
    @State private var userMessage = ""
    
    @State private var isSpeakButtonpressed = false
    @State private var speakButtonTimeOut = false
    @State private var speakButtonTint = Color.white
    @State private var waitingForASR = false
    @State private var waitingForResponse = false
    
    var sss = SpeechSynthExtService()
    var cas = ConvAgentService()
    var srs = SpeechRecService()
    
    var body: some View {
        VStack {
            Spacer()
            
            if(!userMessage.isEmpty){
                RightChatBubbleView(text: userMessage)
            }
            
            if(!pepperResponse.isEmpty){
                LeftChatBubbleView(text: pepperResponse)
            }
            
            Button(action: {}) {
//                Text(self.speakButtonText)
                // Create a system symbol image.
                if(!waitingForASR){
                    Image(systemName: "waveform")
                    //                    .symbolVariant(.circle.fill)
                        .imageScale(Image.Scale.large)
                        .font(.system(size: 24.0))
                } else {
                    ProgressView()
                        .controlSize(.large)
                }
            }
            .frame(maxHeight: 40)
            .padding(.top, 10)
            .tint(speakButtonTint)
            .modifier(PressActions(onPress: {
                if(!isSpeakButtonpressed && !speakButtonTimeOut){
                    speakButtonTint = Color.green
                    userMessage = ""
                    pepperResponse = ""
                    srs.startRecording()
                    isSpeakButtonpressed = true
                    speakButtonTimeOut = true
                    // Add a delay before allowing the button to be released or pressed again
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        speakButtonTimeOut = false
                    }
                }
                
            }, onRelease: {
                if(isSpeakButtonpressed && !speakButtonTimeOut){
                    speakButtonTint = Color.white
                    waitingForASR = true
                    srs.stopRecording(callback: { (recognisedSpeechText) -> () in
                        waitingForASR = false
                        waitingForResponse = true
                        userMessage = recognisedSpeechText
                        cas.sendUserMessage(message: recognisedSpeechText) { (response, error) in
                            if let error = error {
                                print("Error while sending text to CAS: \(error)")
                            } else if let response = response {
                                print("Chatbot Response: \(response)")
                                
                                // Handle the chatbot response here
                                if let text = response["text"] as? String {
//                                    DispatchQueue.main.async {
                                        sss.speak(input: text)
                                        self.pepperResponse = "\(text)"
                                        waitingForResponse = false
//                                    }
                                }
                            }
                        }
                    })

                    isSpeakButtonpressed = false
                    speakButtonTimeOut = true
                    // Add a delay before allowing the button to be pressed again
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        speakButtonTimeOut = false
                    }
                }
            }))
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
