
import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var selectedView = 0 // 0 = Home, 1 = Stats
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom toggle style for Home/Stats
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
                        .background(selectedView == 0 ? Color.blue : Color.clear)
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
                        .background(selectedView == 1 ? Color.blue : Color.clear)
                        .clipShape(Capsule())
                }
            }
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.3))
                    .frame(height: 40)
            )
            .padding(.horizontal, 80)
            .padding(.vertical, 15)
            
            if selectedView == 0 {
                HomeView()
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
            } else {
                PieScreen()
                    .transition(
                        .asymmetric(
                            
                            insertion: .move(edge: .trailing).combined(with: .opacity),
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
    @StateObject private var viewModel = HomeViewModel() // ← CORRECCIÓN: usar @StateObject
    @State private var selectedCategory = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Welcome message con nombre real de Firebase
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
                        // ← CORRECCIÓN: usar viewModel (instancia) no HomeViewModel (clase)
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("$\(viewModel.balance, specifier: "%.2f")")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Balance")
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.top, -40)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 3)
                    .frame(width: 340)
                    .padding(.top, -35)
                
                Text("Your trail")
                    .font(.system(size: 27, weight: .semibold))
                    .padding(.bottom, 15)
                
                // Category selector
                HStack {
                    HStack(spacing: 0) {
                        CategoryButton(icon: "cart.fill", isSelected: selectedCategory == 0) {
                            withAnimation { selectedCategory = 0 }
                        }
                        CategoryButton(icon: "car.fill", isSelected: selectedCategory == 1) {
                            withAnimation { selectedCategory = 1 }
                        }
                        CategoryButton(icon: "creditcard.fill", isSelected: selectedCategory == 2) {
                            withAnimation { selectedCategory = 2 }
                        }
                        CategoryButton(icon: "cup.and.saucer.fill", isSelected: selectedCategory == 3) {
                            withAnimation { selectedCategory = 3 }
                        }
                    }
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.3))
                            .frame(height: 50)
                    )
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)
                    
                    // Plus button
                    Button(action: {
                        // TODO: Add new purchase
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 40)
                    .padding(.bottom, 20)
                }
                
                // Spending amounts grid - CON DATOS REALES
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    SpendingCard(
                        icon: "cart.fill",
                        amount: "$\(viewModel.getSpending(for: .groceries), default: "%.2f")"
                    )
                    SpendingCard(
                        icon: "creditcard.fill",
                        amount: "$\(viewModel.getSpending(for: .bills), default: "%.2f")"
                    )
                    SpendingCard(
                        icon: "car.fill",
                        amount: "$\(viewModel.getSpending(for: .gas), default: "%.2f")"
                    )
                    SpendingCard(
                        icon: "cup.and.saucer.fill",
                        amount: "$\(viewModel.getSpending(for: .dining), default: "%.2f")"
                    )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
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
                
                // Insights button
                NavigationLink(destination: PieScreen()) {
                    Text("Insights")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(25)
                }
                .padding(.bottom, 20)
            }
        }
        .task {
            // ← Carga los datos cuando aparece la vista
            await viewModel.loadData()
        }
        .refreshable {
            // ← Pull to refresh
            await viewModel.loadData()
        }
    }
    
    // Obtener nombre del usuario de Firebase
    private var userName: String {
        if let user = Auth.auth().currentUser {
            return user.displayName ?? user.email?.components(separatedBy: "@").first?.capitalized ?? "User"
        }
        return "User"
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
