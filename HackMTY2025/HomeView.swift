//
//  HomeView.swift
//  HackMTY2025
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var selectedView = 0 // 0 = Home, 1 = Stats
    
    var body: some View {
        VStack(spacing: 0) {
            // Toggle Home/Stats
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.spring()) {
                        selectedView = 0
                    }
                }) {
                    Text("Home")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedView == 0 ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(selectedView == 0 ? Color.darkBlue : Color.lightBlue)
                        .clipShape(Capsule())
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        selectedView = 1
                    }
                }) {
                    Text("Stats")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedView == 1 ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(selectedView == 1 ? Color.darkBlue : Color.lightBlue)
                        .clipShape(Capsule())
                }
            }
            .background(
                Capsule()
                    .fill(Color.midBlue.opacity(0.3))
                    .frame(height: 40)
                    
            )
            .padding(.horizontal, 80)
            .padding(.vertical, 15)
            
            if selectedView == 0 {
                    HomeContentView()
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                } else {
                    PieScreen()
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            )
                        )
                }
        }
        .animation(.easeInOut, value: selectedView)
    }
}

// MARK: - Home Content View
struct HomeContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedCategoryIndex: Int? = nil // nil = all categories
    @State private var showAddCategory = false
    @State private var customCategories: [CustomCategory] = []
    //@State private var showInsights = false
    private var hardcodedPurchases: [Purchase] = [
        Purchase(
            id: UUID().uuidString,
            userId: "1",
            merchantName: "Walmart",
            amount: 45.20,
            category: "Groceries",
            date: Date(),
            description: "Weekly groceries"
        ),
        Purchase(
            id: UUID().uuidString,
            userId: "2",
            merchantName: "Shell",
            amount: 60.00,
            category: "Gas",
            date: Date(),
            description: "Fuel for car"
        ),
        Purchase(
            id: UUID().uuidString,
            userId: "3",
            merchantName: "CFE",
            amount: 120.50,
            category: "Bills",
            date: Date(),
            description: "Electricity bill"
        ),
        Purchase(
            id: UUID().uuidString,
            userId: "4",
            merchantName: "Starbucks",
            amount: 12.75,
            category: "Dining",
            date: Date(),
            description: "Coffee with friends"
        ),
        Purchase(
            id: UUID().uuidString,
            userId: "5",
            merchantName: "Target",
            amount: 75.30,
            category: "Groceries",
            date: Date(),
            description: "Snacks"
        )
    ]


    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Welcome \(userName)!")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.top, 10)
                    .offset(y: 32)
                
                ZStack {
                    Image("trailHome2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 380, height: 380)
                    
                    VStack(spacing: 5) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text(String(format: "$%.2f", filteredBalance))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(selectedCategoryIndex == nil ? "Balance" : "Spent")
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, -40)
                
                Rectangle()
                    .fill(Color.darkBlue)
                    .frame(height: 3)
                    .frame(width: 340)
                    .padding(.top, -35)
                
                Text(selectedCategoryIndex == nil ? "Your trail" : "Filtered View")
                    .font(.system(size: 27, weight: .semibold))
                    .padding(.bottom, 15)
                
                // Category selector con scroll horizontal
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            // Botón "All" para mostrar todas las categorías
                            CategoryButton(
                                icon: "square.grid.2x2.fill",
                                isSelected: selectedCategoryIndex == nil
                            ) {
                                withAnimation { selectedCategoryIndex = nil }
                            }
                            
                            // Categorías por defecto
                            CategoryButton(
                                icon: "cart.fill",
                                isSelected: selectedCategoryIndex == 0
                            ) {
                                withAnimation { selectedCategoryIndex = 0 }
                            }
                            CategoryButton(
                                icon: "car.fill",
                                isSelected: selectedCategoryIndex == 1
                            ) {
                                withAnimation { selectedCategoryIndex = 1 }
                            }
                            CategoryButton(
                                icon: "creditcard.fill",
                                isSelected: selectedCategoryIndex == 2
                            ) {
                                withAnimation { selectedCategoryIndex = 2 }
                            }
                            CategoryButton(
                                icon: "fork.knife",
                                isSelected: selectedCategoryIndex == 3
                            ) {
                                withAnimation { selectedCategoryIndex = 3 }
                            }
                            
                            // Categorías personalizadas
                            // Categorías personalizadas
                            ForEach(Array(customCategories.enumerated()), id: \.element.id) { index, category in
                                CustomCategoryButton(
                                    category: category,
                                    isSelected: selectedCategoryIndex == (4 + index)
                                ) {
                                    withAnimation { selectedCategoryIndex = 4 + index }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteCategory(category)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .background(
                            Capsule()
                                .fill(Color.lightBlue.opacity(0.3))
                                .frame(height: 50)
                        )
                    }
                    .padding(.horizontal, 35)
                    
                    // Plus button
                    Button(action: {
                        showAddCategory = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 40)
                }
                .padding(.bottom, 20)
                
                // Filtered Purchases List
                if let selectedIndex = selectedCategoryIndex {
                    FilteredPurchasesView(
                        purchases: filteredPurchases,
                        categoryName: getCategoryName(for: selectedIndex)
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                } else {
                    // Spending amounts (mostrar todas las categorías)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        SpendingCard(
                            icon: "cart.fill",
                            /*amount: String(format: "$%.2f", viewModel.getSpending(for: .groceries))*/
                            amount: "$120.50"
                        )
                        SpendingCard(
                            icon: "creditcard.fill",
                            /*amount: String(format: "$%.2f", viewModel.getSpending(for: .bills))*/
                            amount: "$75.20"
                        )
                        SpendingCard(
                            icon: "car.fill",
                            /*amount: String(format: "$%.2f", viewModel.getSpending(for: .gas))*/
                            amount: "$45.00"
                        )
                        SpendingCard(
                            icon: "cup.and.saucer.fill",
                            /*amount: String(format: "$%.2f", viewModel.getSpending(for: .dining))*/
                            amount: "$30.75"
                        )
                        
                        // Custom categories cards
                        ForEach(customCategories) { category in
                            CustomSpendingCard(
                                category: category,
                                amount: String(format: "$%.2f", getCustomCategorySpending(category))
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                // Insights button (non-functional for now)
                Button(action: {
                    // action coming soon
                }) {
                    HStack(spacing: 8) {
                        Text("Insights")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.darkBlue)
                    .cornerRadius(25)
                    .shadow(radius: 5)
                }
                .padding(.bottom, 30)

                
                // Insights button
               /* Button(action: {
                    showInsights = true
                }) {
                    Text("Insights")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(25)
                }
                .padding(.bottom, 20)
                .sheet(isPresented: $showInsights) {
                    InsightsView()
                }*/
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategorySheet(categories: $customCategories)
        }
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
        .onAppear {
            loadCategories()
        }
        .onChange(of: customCategories) { _ in
            saveCategories()
        }
    }
    
    // MARK: - Computed Properties
    
    private var userName: String {
        if let user = Auth.auth().currentUser {
            return user.displayName ?? user.email?.components(separatedBy: "@").first?.capitalized ?? "User"
        }
        return "User"
    }
    
    // Inside HomeContentView

    private var filteredPurchases: [Purchase] {
        guard let index = selectedCategoryIndex else {
            // If no category selected, show all
            return hardcodedPurchases
        }

        let category = getCategoryForIndex(index)
        return hardcodedPurchases.filter { $0.category.lowercased() == category.lowercased() }
    }

    private var filteredBalance: Double {
        // Sum of filtered purchases
        filteredPurchases.reduce(0) { $0 + $1.amount }
    }

    private func getCategoryForIndex(_ index: Int) -> String {
        switch index {
        case 0: return SpendingCategory.groceries.rawValue
        case 1: return SpendingCategory.gas.rawValue
        case 2: return SpendingCategory.bills.rawValue
        case 3: return SpendingCategory.dining.rawValue
        default:
            let customIndex = index - 4
            if customIndex < customCategories.count {
                return customCategories[customIndex].name
            }
            return SpendingCategory.other.rawValue
        }
    }

    // MARK: - Delete Category
    private func deleteCategory(_ category: CustomCategory) {
        withAnimation {
            // Si la categoría eliminada está seleccionada, volver a "All"
            if let index = customCategories.firstIndex(where: { $0.id == category.id }),
               selectedCategoryIndex == (4 + index) {
                selectedCategoryIndex = nil
            }
            
            // Eliminar la categoría
            customCategories.removeAll { $0.id == category.id }
        }
    }
    
    private func getCategoryName(for index: Int) -> String {
        switch index {
        case 0: return "Groceries"
        case 1: return "Gas"
        case 2: return "Bills"
        case 3: return "Dining"
        default:
            let customIndex = index - 4
            if customIndex < customCategories.count {
                return customCategories[customIndex].name
            }
            return "Unknown"
        }
    }
    
    private func getCustomCategorySpending(_ category: CustomCategory) -> Double {
        let purchases = viewModel.getPurchases(for: category.name.lowercased())
        return purchases.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - UserDefaults
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "customCategories"),
           let decoded = try? JSONDecoder().decode([CustomCategory].self, from: data) {
            customCategories = decoded
        }
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(encoded, forKey: "customCategories")
        }
    }
}

// MARK: - Filtered Purchases View
struct FilteredPurchasesView: View {
    let purchases: [Purchase]
    let categoryName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("\(categoryName) Purchases")
                    .font(.headline)
                Spacer()
                Text("\(purchases.count) items")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if purchases.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No purchases in this category")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(purchases) { purchase in
                    PurchaseRow(purchase: purchase)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 5)
        )
    }
}

// MARK: - Purchase Row
struct PurchaseRow: View {
    let purchase: Purchase
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(purchase.merchantName)
                    .font(.headline)
                Text(purchase.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(String(format: "$%.2f", purchase.amount))
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Custom Category Button
struct CustomCategoryButton: View {
    let category: CustomCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 50, height: 50)
                .background(isSelected ? category.color : Color.clear)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Custom Spending Card
struct CustomSpendingCard: View {
    let category: CustomCategory
    let amount: String
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(category.color)
            
            Text(amount)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(category.color.opacity(0.2))
        .cornerRadius(15)
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isSelected ? Color.blue : Color.clear)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Spending Card
struct SpendingCard: View {
    let icon: String
    let amount: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.black)
            
            Text(amount)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(15)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
