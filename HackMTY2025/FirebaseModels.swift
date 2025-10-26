//
//  FirebaseModels.swift
//  HackMTY2025
//
//  Created by AGRM on 26/10/25.
//

import Foundation
import FirebaseFirestore

// MARK: - User Profile Data
struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var firstName: String
    var lastName: String
    var email: String
    var balance: Double
    var lastUpdated: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case firstName
        case lastName
        case email
        case balance
        case lastUpdated
    }
}

// MARK: - Purchase
struct Purchase: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var merchantName: String
    var amount: Double
    var category: String
    var date: Date
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case merchantName
        case amount
        case category
        case date
        case description
    }
}

// MARK: - Spending Category
enum SpendingCategory: String, CaseIterable, Codable {
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
    var purchases: [Purchase]
}
