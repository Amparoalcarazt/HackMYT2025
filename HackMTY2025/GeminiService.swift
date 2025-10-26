//
//  GeminiService.swift
//  HackMTY2025
//
//  Created by AGRM on 26/10/25.
//

import Foundation
import GoogleGenerativeAI

class GeminiService {
    static let shared = GeminiService()
    
    private let apiKey = "AIzaSyD0uiIeSvINv9fqS2mg7G_F3RnK4alM528"
    private lazy var model: GenerativeModel = {
        GenerativeModel(name: "gemini-2.5-flash", apiKey: apiKey)
    }()
    
    // MARK: - Categorize Single Purchase
    func categorizePurchase(merchantName: String, amount: Double, description: String? = nil) async throws -> SpendingCategory {
        let purchaseInfo = description ?? merchantName
        
        let prompt = """
        Categoriza la siguiente compra en UNA de estas categorías: Groceries, Gas, Bills, Dining, Other
        
        Compra: \(purchaseInfo)
        Comercio: \(merchantName)
        Monto: $\(amount)
        
        Reglas:
        - Groceries: supermercados, tiendas de abarrotes, Oxxo, Walmart, Soriana, HEB, etc.
        - Gas: gasolineras, combustible, Pemex, Shell, Mobil
        - Bills: servicios (luz, agua, internet, teléfono), CFE, Telmex, Totalplay
        - Dining: restaurantes, cafeterías, comida para llevar, Starbucks, McDonald's
        - Other: cualquier otra cosa
        
        Responde SOLO con una palabra exacta: Groceries, Gas, Bills, Dining, o Other
        """
        
        let response = try await model.generateContent(prompt)
        
        guard let text = response.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return .other
        }
        
        // Parsear respuesta (case-insensitive)
        let lowercased = text.lowercased()
        
        if lowercased.contains("groceries") {
            return .groceries
        } else if lowercased.contains("gas") {
            return .gas
        } else if lowercased.contains("bills") {
            return .bills
        } else if lowercased.contains("dining") {
            return .dining
        } else {
            return .other
        }
    }
    
    // MARK: - Batch Categorization (más eficiente)
    func categorizePurchases(_ purchases: [Purchase]) async throws -> [String: SpendingCategory] {
        guard !purchases.isEmpty else {
            return [:]
        }
        
        // Crear lista de compras para el prompt
        let purchaseList = purchases.map { purchase in
            let id = purchase.id ?? UUID().uuidString
            let desc = purchase.description ?? purchase.merchantName
            return "\(id): \(desc) - $\(purchase.amount)"
        }.joined(separator: "\n")
        
        let prompt = """
        Categoriza estas compras. Para cada ID, responde con el ID seguido de dos puntos y la categoría.
        
        Categorías válidas: Groceries, Gas, Bills, Dining, Other
        
        Reglas de categorización:
        - Groceries: supermercados, tiendas, Oxxo, Walmart, Soriana, HEB
        - Gas: gasolineras, combustible, Pemex, Shell
        - Bills: servicios públicos, CFE, Telmex, agua, luz, internet
        - Dining: restaurantes, cafés, Starbucks, comida rápida
        - Other: todo lo demás
        
        Compras:
        \(purchaseList)
        
        Formato de respuesta (una por línea, sin texto adicional):
        ID: categoria
        ID: categoria
        
        Ejemplo:
        abc123: Groceries
        def456: Dining
        ghi789: Gas
        """
        
        let response = try await model.generateContent(prompt)
        
        guard let text = response.text else {
            throw GeminiError.invalidResponse
        }
        
        return parseBatchResponse(text, purchases: purchases)
    }
    
    // MARK: - Parse Batch Response
    private func parseBatchResponse(_ text: String, purchases: [Purchase]) -> [String: SpendingCategory] {
        var results: [String: SpendingCategory] = [:]
        
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            // Skip empty lines
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            let parts = line.components(separatedBy: ":")
            guard parts.count >= 2 else { continue }
            
            let id = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let categoryText = parts[1].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            // Parse category
            let category: SpendingCategory
            if categoryText.contains("groceries") {
                category = .groceries
            } else if categoryText.contains("gas") {
                category = .gas
            } else if categoryText.contains("bills") {
                category = .bills
            } else if categoryText.contains("dining") {
                category = .dining
            } else {
                category = .other
            }
            
            results[id] = category
        }
        
        // Fallback: Si no se parseó alguna purchase, usar .other
        for purchase in purchases {
            if let purchaseId = purchase.id, results[purchaseId] == nil {
                results[purchaseId] = .other
            }
        }
        
        return results
    }
    
    // MARK: - Chatbot (para futura implementación)
    func chat(message: String, userContext: String = "") async throws -> String {
        let prompt = """
        Eres "Hormiguita", un asistente financiero amigable y útil.
        Ayudas a los usuarios a entender sus gastos y dar consejos financieros inteligentes.
        
        Contexto del usuario:
        \(userContext)
        
        Usuario pregunta: \(message)
        
        Responde de manera amigable, clara y útil. Si das consejos financieros, sé práctico y realista.
        Usa emojis ocasionalmente 🐜 para ser más amigable.
        """
        
        let response = try await model.generateContent(prompt)
        return response.text ?? "Lo siento, no pude procesar tu mensaje. ¿Puedes intentar de nuevo?"
    }
}

enum GeminiError: Error {
    case invalidResponse
    case emptyPurchaseList
}
