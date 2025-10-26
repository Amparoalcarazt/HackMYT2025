//
//  ChatBotView.swift
//  HackMTY2025
//
//  Created by FurryVale on 10/25/25.
//

import SwiftUI

struct ChatBotView: View {
    var body: some View {
        VStack(spacing:24){
            
            Text("Welcome John Pork").font(.largeTitle).padding(.bottom, 26)
            
            VStack(spacing: 16){
                ChatBotItem(
                    message: "Hey", isFromUser: false, avatarimg: "HormigaChatBot"
                )
                ChatBotItem(message: "Hey yo", isFromUser: true, avatarimg: "ChatIcon")
            }
            
            
            VStack(spacing:16){
                Text("Some frequently asked questions").foregroundColor(Color.midBlue).font(.body)
                ForEach(1...3, id: \.self){ i in
                    Button(action: {}){
                        Text("Frequently asked question \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.lightBlue.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(22)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x:0, y:4)
                    
                }
                
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

#Preview {
    ChatBotView()
}

