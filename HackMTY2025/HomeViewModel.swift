//
//  HomeViewModel.swift
//  HackMTY2025
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var userName: String = "Loading..."
    @Published var categorySpending: [CategorySpending] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let nessieService = NessieService.shared
    private let geminiService = GeminiService.shared
    
    private let accountId = "TU_ACCOUNT_ID" // ← PON TU ACCOUNT ID
    
    // MARK: - Load All Data with AI
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Cargar balance
            let account = try await nessieService.getAccount(accountId: accountId)
            balance = account.balance
            
            // 2. Cargar purchases
            let purchases = try await nessieService.getPurchases(accountId: accountId)
            
            // 3. Categorizar con Gemini AI 🤖
            await categorizePurchasesWithAI(purchases)
            
        } catch {
            errorMessage = "Error loading data: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - AI Categorization
    private func categorizePurchasesWithAI(_ purchases: [NessiePurchase]) async {
        do {
            // Usar batch categorization (más eficiente - 1 sola llamada)
            let categories = try await geminiService.categorizePurchases(purchases)
            
            // Agrupar por categoría
            var categoryDict: [SpendingCategory: [NessiePurchase]] = [:]
            
            for purchase in purchases {
                let category = categories[purchase._id] ?? .other
                categoryDict[category, default: []].append(purchase)
            }
            
            // Crear CategorySpending
            categorySpending = SpendingCategory.allCases.map { category in
                let purchases = categoryDict[category] ?? []
                let total = purchases.reduce(0) { $0 + $1.amount }
                return CategorySpending(category: category, amount: total, purchases: purchases)
            }
            
        } catch {
            print("❌ AI Categorization error: \(error)")
            // Fallback a categorización manual si falla AI
            categorizePurchasesManually(purchases)
        }
    }
    
    // MARK: - Manual Categorization (Fallback)
    private func categorizePurchasesManually(_ purchases: [NessiePurchase]) {
        var categoryDict: [SpendingCategory: [NessiePurchase]] = [:]
        
        for purchase in purchases {
            let category = categorizeManually(purchase)
            categoryDict[category, default: []].append(purchase)
        }
        
        categorySpending = SpendingCategory.allCases.map { category in
            let purchases = categoryDict[category] ?? []
            let total = purchases.reduce(0) { $0 + $1.amount }
            return CategorySpending(category: category, amount: total, purchases: purchases)
        }
    }
    
    private func categorizeManually(_ purchase: NessiePurchase) -> SpendingCategory {
        let description = purchase.description?.lowercased() ?? ""
        
        if description.contains("grocery") || description.contains("walmart") || description.contains("oxxo") {
            return .groceries
        } else if description.contains("gas") || description.contains("pemex") {
            return .gas
        } else if description.contains("electric") || description.contains("internet") {
            return .bills
        } else if description.contains("restaurant") || description.contains("starbucks") {
            return .dining
        }
        
        return .other
    }
    
    // MARK: - Get Spending for Category
    func getSpending(for category: SpendingCategory) -> Double {
        categorySpending.first(where: { $0.category == category })?.amount ?? 0.0
    }
}
