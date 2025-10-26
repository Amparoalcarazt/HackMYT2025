//
//  FirebaseService.swift
//  HackMTY2025
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    // MARK: - Get User Profile
    func getUserProfile() async throws -> UserProfile {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No user authenticated")
            throw FirebaseError.noUser
        }
        
        print("🔍 Fetching profile for user: \(userId)")
        
        do {
            let doc = try await db.collection("users").document(userId).getDocument()
            
            if doc.exists {
                if let profile = try? doc.data(as: UserProfile.self) {
                    print("✅ Profile found: \(profile.fullName)")
                    return profile
                }
            }
            
            // Si no existe, crear perfil con datos mock
            print("⚠️ Profile not found, creating new one with mock data...")
            return try await createUserProfile(userId: userId)
            
        } catch {
            print("❌ Error fetching profile: \(error.localizedDescription)")
            
            // Si falla por estar offline, crear perfil local
            print("📱 Creating local profile with mock data...")
            return try await createUserProfile(userId: userId)
        }
    }
    
    // MARK: - Create User Profile con datos MOCK
    private func createUserProfile(userId: String) async throws -> UserProfile {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseError.noUser
        }
        
        print("🎨 Creating mock data for user: \(userId)")
        
        // Obtener nombre del usuario
        let displayName = currentUser.displayName ?? currentUser.email ?? "User"
        let nameParts = displayName.components(separatedBy: " ")
        let firstName = nameParts.first ?? "John"
        let lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : "Doe"
        
        // Crear perfil con datos mock
        let profile = UserProfile(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            email: currentUser.email ?? "",
            balance: 1572.33,
            lastUpdated: Date()
        )
        
        // Intentar guardar en Firestore
        do {
            try db.collection("users").document(userId).setData(from: profile)
            print("✅ Profile saved to Firestore")
        } catch {
            print("⚠️ Could not save to Firestore (might be offline): \(error.localizedDescription)")
        }
        
        // Crear purchases mock
        await createMockPurchases(userId: userId)
        
        return profile
    }
    
    // MARK: - Create Mock Purchases
    private func createMockPurchases(userId: String) async {
        let samplePurchases = [
            Purchase(
                userId: userId,
                merchantName: "Oxxo",
                amount: 704.12,
                category: "Groceries",
                date: Date().addingTimeInterval(-86400 * 2),
                description: "Grocery shopping"
            ),
            Purchase(
                userId: userId,
                merchantName: "CFE",
                amount: 1200.00,
                category: "Bills",
                date: Date().addingTimeInterval(-86400 * 5),
                description: "Electricity bill"
            ),
            Purchase(
                userId: userId,
                merchantName: "Pemex",
                amount: 340.33,
                category: "Gas",
                date: Date().addingTimeInterval(-86400 * 1),
                description: "Gas refill"
            ),
            Purchase(
                userId: userId,
                merchantName: "Starbucks",
                amount: 272.02,
                category: "Dining",
                date: Date().addingTimeInterval(-86400 * 3),
                description: "Coffee and breakfast"
            )
        ]
        
        for purchase in samplePurchases {
            do {
                try db.collection("purchases").addDocument(from: purchase)
                print("✅ Purchase created: \(purchase.merchantName)")
            } catch {
                print("⚠️ Could not save purchase (might be offline): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Get User Balance
    func getUserBalance() async throws -> Double {
        let profile = try await getUserProfile()
        return profile.balance
    }
    
    // MARK: - Get Purchases
    func getPurchases() async throws -> [Purchase] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw FirebaseError.noUser
        }
        
        print("🔍 Fetching purchases for user: \(userId)")
        
        do {
            let snapshot = try await db.collection("purchases")
                .whereField("userId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .getDocuments()
            
            let purchases = snapshot.documents.compactMap { doc in
                try? doc.data(as: Purchase.self)
            }
            
            print("✅ Found \(purchases.count) purchases")
            return purchases
            
        } catch {
            print("❌ Error fetching purchases: \(error.localizedDescription)")
            return []
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
    
    // MARK: - Delete Purchase
    func deletePurchase(id: String) async throws {
        try await db.collection("purchases").document(id).delete()
    }
}

enum FirebaseError: Error {
    case noUser
    case dataNotFound
}
