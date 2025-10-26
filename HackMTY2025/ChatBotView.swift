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
    @State private var hasUserInteracted = false
    
    var body: some View {
        VStack(spacing: 12) {
            
            // WELCOME TEXT
            Text("Welcome")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top, 8)
                .padding(.horizontal)
            
            // CHAT MESSAGES
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            ChatBotItem(
                                message: message.text,
                                isFromUser: message.isFromUser,
                                avatarimg: message.isFromUser ? "ChatIcon" : "HormigaChatBot"
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .onChange(of: viewModel.messages.count) { _ in
             
                    if let last = viewModel.messages.last?.id {
                        withAnimation {
                            scrollProxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }
            
           
            HStack(alignment: .bottom) {
                TextField("Type your message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4) 
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .animation(.easeInOut(duration: 0.2), value: inputText)
                
                Button("Send") {
                    Task {
                        hasUserInteracted = true
                        await viewModel.send(message: inputText)
                        inputText = ""
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
        
            if viewModel.messages.isEmpty {
                viewModel.messages.append(
                    ChatMessage(
                        text: "Hi, I’m Antsy, your financial assistant. Feel free to ask anything!",
                        isFromUser: false
                    )
                )
            }
        }
    }
}
