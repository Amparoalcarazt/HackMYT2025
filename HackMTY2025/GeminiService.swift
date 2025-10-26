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
    
    private let apiKey = "TU_GEMINI_API_KEY" // ← Obtén gratis en https://makersuite.google.com/app/apikey
    private lazy var model: GenerativeModel = {
        GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey)
    }()
    
    // MARK: - Categorize Purchase
    func categorizePurchase(description: String, amount: Double) async throws -> SpendingCategory {
        let prompt = """
        Categoriza la siguiente compra en UNA de estas categorías: groceries, gas, bills, dining, other
        
        Compra: \(description)
        Monto: $\(amount)
        
        Reglas:
        - groceries: supermercados, tiendas de abarrotes, Oxxo, Walmart, etc.
        - gas: gasolineras, combustible
        - bills: servicios (luz, agua, internet, teléfono)
        - dining: restaurantes, cafeterías, comida para llevar
        - other: cualquier otra cosa
        
        Responde SOLO con una palabra: groceries, gas, bills, dining, o other
        """
        
        let response = try await model.generateContent(prompt)
        
        guard let text = response.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else {
            return .other
        }
        
        // Parsear respuesta
        switch text {
        case let t where t.contains("groceries"):
            return .groceries
        case let t where t.contains("gas"):
            return .gas
        case let t where t.contains("bills"):
            return .bills
        case let t where t.contains("dining"):
            return .dining
        default:
            return .other
        }
    }
    
    // MARK: - Batch Categorization (más eficiente)
    func categorizePurchases(_ purchases: [NessiePurchase]) async throws -> [String: SpendingCategory] {
        let purchaseList = purchases.map { "\($0._id): \($0.description ?? "Unknown") - $\($0.amount)" }.joined(separator: "\n")
        
        let prompt = """
        Categoriza estas compras. Para cada ID, responde con el ID seguido de dos puntos y la categoría.
        
        Categorías válidas: groceries, gas, bills, dining, other
        
        Compras:
        \(purchaseList)
        
        Formato de respuesta (una por línea):
        ID: categoria
        ID: categoria
        
        Ejemplo:
        abc123: groceries
        def456: dining
        """
        
        let response = try await model.generateContent(prompt)
        
        guard let text = response.text else {
            throw GeminiError.invalidResponse
        }
        
        return parseBatchResponse(text, purchases: purchases)
    }
    
    // MARK: - Parse Batch Response
    private func parseBatchResponse(_ text: String, purchases: [NessiePurchase]) -> [String: SpendingCategory] {
        var results: [String: SpendingCategory] = [:]
        
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let parts = line.components(separatedBy: ":")
            guard parts.count >= 2 else { continue }
            
            let id = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let categoryText = parts[1].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            let category: SpendingCategory
            switch categoryText {
            case let t where t.contains("groceries"):
                category = .groceries
            case let t where t.contains("gas"):
                category = .gas
            case let t where t.contains("bills"):
                category = .bills
            case let t where t.contains("dining"):
                category = .dining
            default:
                category = .other
            }
            
            results[id] = category
        }
        
        return results
    }
}

enum GeminiError: Error {
    case invalidResponse
}
