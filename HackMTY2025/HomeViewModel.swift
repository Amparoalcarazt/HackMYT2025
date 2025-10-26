//
//  HomeViewModel.swift
//  HackMTY2025
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var userFullName: String = "User"
    @Published var categorySpending: [CategorySpending] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    
    // MARK: - Load All Data
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        print("Loading data...")
        
        do {
            // 1. Cargar perfil (esto crea datos mock si no existen)
            let profile = try await firebaseService.getUserProfile()
            userFullName = profile.fullName
            balance = profile.balance
            
            print("✅ User: \(userFullName), Balance: $\(balance)")
            
            // 2. Cargar purchases
            let purchases = try await firebaseService.getPurchases()
            print("✅ Loaded \(purchases.count) purchases")
            
            // 3. Categorizar
            categorizePurchases(purchases)
            
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            print("❌ Error loading data: \(error)")
            
            // Fallback: usar datos mock locales
            loadMockData()
        }
        
        isLoading = false
    }
    
    // MARK: - Load Mock Data (fallback)
    private func loadMockData() {
        print("Using local mock data")
        
        userFullName = "John Pork"
        balance = 1572.33
        
        let mockPurchases = [
            Purchase(userId: "mock", merchantName: "Oxxo", amount: 704.12, category: "Groceries", date: Date()),
            Purchase(userId: "mock", merchantName: "CFE", amount: 1200.00, category: "Bills", date: Date()),
            Purchase(userId: "mock", merchantName: "Pemex", amount: 340.33, category: "Gas", date: Date()),
            Purchase(userId: "mock", merchantName: "Starbucks", amount: 272.02, category: "Dining", date: Date())
        ]
        
        categorizePurchases(mockPurchases)
    }
    
    // MARK: - Categorize Purchases
    private func categorizePurchases(_ purchases: [Purchase]) {
        var categoryDict: [SpendingCategory: [Purchase]] = [:]
        
        for purchase in purchases {
            if let category = SpendingCategory(rawValue: purchase.category) {
                categoryDict[category, default: []].append(purchase)
            }
        }
        
        categorySpending = SpendingCategory.allCases.map { category in
            let purchases = categoryDict[category] ?? []
            let total = purchases.reduce(0) { $0 + $1.amount }
            return CategorySpending(category: category, amount: total, purchases: purchases)
        }
        
        print("✅ Categorized spending: Groceries=$\(getSpending(for: .groceries)), Gas=$\(getSpending(for: .gas)), Bills=$\(getSpending(for: .bills)), Dining=$\(getSpending(for: .dining))")
    }
    
    // MARK: - Get Spending for Category
    func getSpending(for category: SpendingCategory) -> Double {
        categorySpending.first(where: { $0.category == category })?.amount ?? 0.0
    }
}
