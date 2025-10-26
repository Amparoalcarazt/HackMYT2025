//
//  NessieService.swift
//  HackMTY2025
//
//  Created by AGRM on 26/10/25.
//

import Foundation

class NessieService: ObservableObject {
    static let shared = NessieService()
    
    private let apiKey = "TU_API_KEY_AQUI" // ← PON TU API KEY
    private let baseURL = "http://api.nessieisreal.com"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Get Account Balance
    func getAccount(accountId: String) async throws -> NessieAccount {
        let urlString = "\(baseURL)/accounts/\(accountId)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let account = try JSONDecoder().decode(NessieAccount.self, from: data)
        return account
    }
    
    // MARK: - Get All Purchases
    func getPurchases(accountId: String) async throws -> [NessiePurchase] {
        let urlString = "\(baseURL)/accounts/\(accountId)/purchases?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let purchases = try JSONDecoder().decode([NessiePurchase].self, from: data)
        return purchases
    }
    
    // MARK: - Get Merchant Info
    func getMerchant(merchantId: String) async throws -> NessieMerchant {
        let urlString = "\(baseURL)/merchants/\(merchantId)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let merchant = try JSONDecoder().decode(NessieMerchant.self, from: data)
        return merchant
    }
    
    // MARK: - Get Accounts for Customer
    func getCustomerAccounts(customerId: String) async throws -> [NessieAccount] {
        let urlString = "\(baseURL)/customers/\(customerId)/accounts?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let accounts = try JSONDecoder().decode([NessieAccount].self, from: data)
        return accounts
    }
}
