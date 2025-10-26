//
//  ChatAIViewModel.swift
//  HackMTY2025
//
//  Created by FurryVale on 10/26/25.
//

import SwiftUI
import Combine
import GoogleGenerativeAI

@MainActor
class ChatBotViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    private let model = GenerativeModel(
        name: "gemini-2.5-flash",
        apiKey: APIKey.default
    )
    
    func send(message: String, isUser: Bool = true) async {
        // Agregar el mensaje del usuario
        messages.append(ChatMessage(text: message, isFromUser: isUser))
        
        // Llamar al modelo
        do {
            let response = try await model.generateContent(message)
            if let reply = response.text {
                messages.append(ChatMessage(text: reply, isFromUser: false))
            }
        } catch {
            messages.append(ChatMessage(text: "Error: \(error.localizedDescription)", isFromUser: false))
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
}


