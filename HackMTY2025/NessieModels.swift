//
//  NessieModels.swift
//  HackMTY2025
//
//  Created by AGRM on 26/10/25.
//

import Foundation

// MARK: - Account
struct NessieAccount: Codable, Identifiable {
    let _id: String
    let type: String
    let nickname: String?
    let rewards: Int?
    let balance: Double
    let account_number: String
    let customer_id: String
    
    var id: String { _id }
}

// MARK: - Purchase
struct NessiePurchase: Codable, Identifiable {
    let _id: String
    let merchant_id: String
    let medium: String?
    let purchase_date: String
    let amount: Double
    let status: String?
    let description: String?
    
    var id: String { _id }
    
    var date: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: purchase_date) ?? Date()
    }
}

// MARK: - Merchant
struct NessieMerchant: Codable, Identifiable {
    let _id: String
    let name: String
    let category: [String]?
    
    var id: String { _id }
}

// MARK: - Spending Category
enum SpendingCategory: String, CaseIterable {
    case groceries = "Groceries"
    case gas = "Gas"
    case bills = "Bills"
    case dining = "Dining"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .groceries: return "cart.fill"
        case .gas: return "car.fill"
        case .bills: return "creditcard.fill"
        case .dining: return "cup.and.saucer.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Category Spending Data
struct CategorySpending: Identifiable {
    let id = UUID()
    let category: SpendingCategory
    var amount: Double
    var purchases: [NessiePurchase]
}
