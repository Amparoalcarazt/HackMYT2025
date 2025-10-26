//
//  ChatBotView.swift
//  HackMTY2025
//
//  Created by FurryVale on 10/25/25.
//

import SwiftUI

struct ChatBotView: View {
    @StateObject private var viewModel = ChatBotViewModel()
    @State private var inputText = ""
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Welcome John Pork")
                .font(.largeTitle)
                .padding(.bottom, 26)
            
            // Mensajes del chat
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        ChatBotItem(
                            message: message.text,
                            isFromUser: message.isFromUser,
                            avatarimg: message.isFromUser ? "ChatIcon" : "HormigaChatBot"
                        )
                    }
                }
            }
            .frame(maxHeight: 300)

            // Entrada de texto para enviar mensajes
            HStack {
                TextField("Type your message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    Task {
                        await viewModel.send(message: inputText)
                        inputText = ""
                    }
                }
            }

            // Preguntas frecuentes
            VStack(spacing: 16) {
                Text("Some frequently asked questions")
                    .foregroundColor(Color.blue)
                    .font(.body)
                
                ForEach(1...3, id: \.self) { i in
                    Button(action: {
                        Task {
                            await viewModel.send(message: "Frequently asked question \(i)")
                        }
                    }) {
                        Text("Frequently asked question \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(22)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 4)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}
