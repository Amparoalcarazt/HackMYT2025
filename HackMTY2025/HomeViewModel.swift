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
    @Published var categorySpending: [CategorySpending] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    
    // MARK: - Load All Data
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Cargar balance
            balance = try await firebaseService.getUserBalance()
            
            // 2. Cargar purchases
            let purchases = try await firebaseService.getPurchases()
            
            // 3. Categorizar purchases
            categorizePurchases(purchases)
            
        } catch {
            errorMessage = "Error loading data: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isLoading = false
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
    }
    
    // MARK: - Get Spending for Category
    func getSpending(for category: SpendingCategory) -> Double {
        categorySpending.first(where: { $0.category == category })?.amount ?? 0.0
    }
    
    // MARK: - Add Purchase
    func addPurchase(merchantName: String, amount: Double, category: SpendingCategory) async {
        do {
            try await firebaseService.addPurchase(
                merchantName: merchantName,
                amount: amount,
                category: category.rawValue
            )
            
            // Recargar datos
            await loadData()
        } catch {
            errorMessage = "Error adding purchase: \(error.localizedDescription)"
        }
    }
}
