//
//  ChatBubbles.swift
//  TestApp Watch App
//
//  Created by Dániel Szabó on 16/12/2023.
//

import Foundation
import SwiftUI

struct LeftChatBubbleView: View {
    var text: String
    
    var body: some View {
        HStack {
            Text(text)
                .padding(10)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(15)
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

struct RightChatBubbleView: View {
    var text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .padding(10)
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(15)
        }
        .padding(.horizontal, 10)
    }
}
