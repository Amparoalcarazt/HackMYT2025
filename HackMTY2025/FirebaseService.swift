//
//  FirebaseService.swift
//  HackMTY2025
//
//  Created by AGRM on 26/10/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    // MARK: - Get User Balance
    func getUserBalance() async throws -> Double {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseError.noUser
        }
        
        let doc = try await db.collection("users").document(userId).getDocument()
        
        if let data = doc.data(), let balance = data["balance"] as? Double {
            return balance
        }
        
        // Si no existe, crear con balance inicial
        try await createUserData(userId: userId)
        return 1572.33 // Balance inicial
    }
    
    // MARK: - Update Balance
    func updateBalance(_ newBalance: Double) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseError.noUser
        }
        
        try await db.collection("users").document(userId).setData([
            "balance": newBalance,
            "lastUpdated": Timestamp(date: Date())
        ], merge: true)
    }
    
    // MARK: - Get All Purchases
    func getPurchases() async throws -> [Purchase] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseError.noUser
        }
        
        let snapshot = try await db.collection("purchases")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Purchase.self)
        }
    }
    
    // MARK: - Add Purchase
    func addPurchase(merchantName: String, amount: Double, category: String, description: String? = nil) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseError.noUser
        }
        
        let purchase = Purchase(
            userId: userId,
            merchantName: merchantName,
            amount: amount,
            category: category,
            date: Date(),
            description: description
        )
        
        try db.collection("purchases").addDocument(from: purchase)
        
        // Actualizar balance
        let currentBalance = try await getUserBalance()
        try await updateBalance(currentBalance - amount)
    }
    
    // MARK: - Create User Data
    private func createUserData(userId: String) async throws {
        let userData: [String: Any] = [
            "balance": 1572.33,
            "lastUpdated": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userId).setData(userData)
        
        // Crear purchases de ejemplo
        let samplePurchases = [
            Purchase(userId: userId, merchantName: "Oxxo", amount: 45.50, category: "Groceries", date: Date()),
            Purchase(userId: userId, merchantName: "Starbucks", amount: 98.00, category: "Dining", date: Date()),
            Purchase(userId: userId, merchantName: "Pemex", amount: 340.33, category: "Gas", date: Date()),
            Purchase(userId: userId, merchantName: "CFE", amount: 1200.00, category: "Bills", date: Date())
        ]
        
        for purchase in samplePurchases {
            try db.collection("purchases").addDocument(from: purchase)
        }
    }
    
    // MARK: - Delete Purchase
    func deletePurchase(id: String) async throws {
        try await db.collection("purchases").document(id).delete()
    }
}

enum FirebaseError: Error {
    case noUser
    case dataNotFound
}
