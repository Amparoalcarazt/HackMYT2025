//
//  PieScreen.swift
//  HackMTY2025
//
//  Created by AGRM on 25/10/25.
//

import SwiftUI

struct PieScreen: View {
    // Datos de ejemplo
    @State private var antSpendings: [AntSpending] = [
        AntSpending(merchantName: "7-Eleven", amount: 5.50, date: Date(), frequency: 5, iconName: "cart.fill"),
        AntSpending(merchantName: "Starbucks", amount: 8.00, date: Date(), frequency: 4, iconName: "cup.and.saucer.fill"),
        AntSpending(merchantName: "H&M", amount: 25.00, date: Date(), frequency: 3, iconName: "bag.fill")
    ]
    
    @State private var selectedSort: SortOption = .price
    @State private var currentPieIndex = 0
    @State private var showBudgetInfo = false
    @State private var showBudgetEditor = false
    @State private var monthlyBudget: Double = 500.0
    @State private var budgetInput: String = "500"
    
    enum SortOption: String, CaseIterable {
        case latest = "Latest"
        case price = "Price"
    }
    
    // Array con los nombres de tus imágenes
    let pieImages = [
        "1whole",  // Pay completo
        "1slice",  // Pocas hormiguitas
        "2slice",
        "3slice",
        "4slice",
        "5slice",
        "6slice",
        "7slice",
        "gone"   // Pay casi vacío
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header con solo el botón de menú
                    HStack {
                        Spacer()
                        
                        Button(action: { showBudgetInfo.toggle() }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Sección del Pay con contexto
                    VStack(spacing: 16) {
                        // Título descriptivo
                        VStack(spacing: 4) {
                            Text("Your Microspending")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                            
                            // Contador animado del total
                            Text("$\(totalSpending, specifier: "%.2f")")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(spendingColor)
                                .contentTransition(.numericText())
                        }
                        
                        // Gráfica de Pay ANIMADA
                        AnimatedPieView(
                            pieImages: pieImages,
                            currentIndex: $currentPieIndex,
                            totalAmount: totalSpending
                        )
                        .frame(width: 280, height: 280)
                        
                        // Barra de progreso del presupuesto
                        VStack(spacing: 8) {
                            HStack {
                                Text("Microspending Limit")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Button(action: {
                                    showBudgetEditor = true
                                }) {
                                    HStack(spacing: 4) {
                                        Text("\(Int(budgetPercentage))%")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.caption)
                                    }
                                    .foregroundColor(spendingColor)
                                }
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Fondo
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 12)
                                    
                                    // Progreso
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: budgetGradientColors,
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: min(geometry.size.width * CGFloat(budgetPercentage / 100), geometry.size.width), height: 12)
                                        .animation(.spring(response: 0.6), value: budgetPercentage)
                                }
                            }
                            .frame(height: 12)
                            
                            HStack {
                                Text("$0")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$\(monthlyBudget, specifier: "%.0f")")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        // Estado del presupuesto
                        if budgetPercentage >= 80 {
                            HStack(spacing: 8) {
                                Image(systemName: budgetPercentage >= 100 ? "exclamationmark.triangle.fill" : "exclamationmark.circle.fill")
                                Text(budgetPercentage >= 100 ? "Budget exceeded!" : "Getting close to budget limit")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(spendingColor)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(spendingColor.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 16)
                    
                    // Línea divisoria
                    Divider()
                        .padding(.horizontal)
                    
                    // Segmented control con mejor diseño
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSort = .latest
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 14))
                                Text("Latest")
                            }
                            .fontWeight(selectedSort == .latest ? .semibold : .regular)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedSort == .latest ?
                                        Color(red: 0.4, green: 0.7, blue: 0.8) :
                                            Color(red: 0.3, green: 0.6, blue: 0.7))
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSort = .price
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 14))
                                Text("Price")
                            }
                            .fontWeight(selectedSort == .price ? .semibold : .regular)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedSort == .price ?
                                        Color(red: 0.2, green: 0.4, blue: 0.5) :
                                            Color(red: 0.3, green: 0.6, blue: 0.7))
                        }
                    }
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
                    
                    // Contador de transacciones
                    HStack {
                        Text("\(antSpendings.count) Transactions")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 8)
                    
                    // Lista de gastos hormiga
                    VStack(spacing: 12) {
                        ForEach(sortedSpendings) { spending in
                            AntSpendingCard(spending: spending)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4), value: selectedSort)
                    
                    Spacer()
                }
            }
            .onAppear {
                updatePieImage()
            }
            .onChange(of: totalSpending) { _, _ in
                updatePieImage()
            }
            
            // Budget Editor Sheet
            if showBudgetEditor {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showBudgetEditor = false
                            }
                        }
                    
                    VStack(spacing: 20) {
                        HStack {
                            Text("Set Your Limit")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showBudgetEditor = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                        }
                        
                        Text("How much microspending are you willing to have per month?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        // Budget input
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Text("$")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                                
                                TextField("200", text: $budgetInput)
                                    .font(.system(size: 32, weight: .bold))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Quick presets
                            VStack(spacing: 8) {
                                Text("Quick Presets")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 12) {
                                    ForEach([30, 50, 100], id: \.self) { amount in
                                        Button(action: {
                                            budgetInput = "\(amount)"
                                        }) {
                                            Text("$\(amount)")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(budgetInput == "\(amount)" ? .white : Color(red: 0.2, green: 0.4, blue: 0.5))
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(budgetInput == "\(amount)" ? Color(red: 0.2, green: 0.4, blue: 0.5) : Color.gray.opacity(0.2))
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Save button
                        Button(action: {
                            if let newBudget = Double(budgetInput), newBudget > 0 {
                                withAnimation {
                                    monthlyBudget = newBudget
                                    showBudgetEditor = false
                                }
                            }
                        }) {
                            Text("Save Limit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.4, green: 0.7, blue: 0.8), Color(red: 0.2, green: 0.4, blue: 0.5)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .padding(.horizontal, 30)
                }
                .transition(.opacity)
            }
            
            // Info overlay
            if showBudgetInfo {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showBudgetInfo = false
                            }
                        }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("About the Pie Chart")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    showBudgetInfo = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "ant.fill")
                                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.5))
                                Text("The ants represent your microspending habits eating away at your budget")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(Color(red: 0.4, green: 0.7, blue: 0.8))
                                Text("As you spend more, the pie disappears - watch your budget!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "target")
                                    .foregroundColor(.orange)
                                Text("Keep your spending under $\(monthlyBudget, specifier: "%.0f") to maintain a healthy budget")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .padding(.horizontal, 30)
                }
                .transition(.opacity)
            }
        }
    }
    
    var sortedSpendings: [AntSpending] {
        switch selectedSort {
        case .latest:
            return antSpendings.sorted { $0.date > $1.date }
        case .price:
            return antSpendings.sorted { $0.amount > $1.amount }
        }
    }
    
    var totalSpending: Double {
        antSpendings.reduce(0) { $0 + $1.amount }
    }
    
    var budgetPercentage: Double {
        min((totalSpending / monthlyBudget) * 100, 100)
    }
    
    var spendingColor: Color {
        if budgetPercentage >= 100 {
            return .red
        } else if budgetPercentage >= 80 {
            return .orange
        } else {
            return Color(red: 0.2, green: 0.4, blue: 0.5)
        }
    }
    
    var budgetGradientColors: [Color] {
        if budgetPercentage >= 100 {
            return [.red, .red.opacity(0.7)]
        } else if budgetPercentage >= 80 {
            return [.orange, .yellow]
        } else {
            return [Color(red: 0.4, green: 0.7, blue: 0.8), Color(red: 0.2, green: 0.4, blue: 0.5)]
        }
    }
    
    // Actualizar imagen del pay según el gasto total
    func updatePieImage() {
        let percentage = budgetPercentage
        
        // Calcular qué imagen mostrar según el porcentaje del presupuesto
        if percentage < 12.5 {
            currentPieIndex = 0  // Pay completo
        } else if percentage < 25 {
            currentPieIndex = 1
        } else if percentage < 37.5 {
            currentPieIndex = 2
        } else if percentage < 50 {
            currentPieIndex = 3
        } else if percentage < 62.5 {
            currentPieIndex = 4
        } else if percentage < 75 {
            currentPieIndex = 5
        } else if percentage < 87.5 {
            currentPieIndex = 6
        } else if percentage < 100 {
            currentPieIndex = 7
        } else {
            currentPieIndex = 8  // Pay casi vacío
        }
    }
}

// Vista animada del pay
struct AnimatedPieView: View {
    let pieImages: [String]
    @Binding var currentIndex: Int
    let totalAmount: Double
    
    @State private var scale: CGFloat = 1.0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Círculo de fondo con sombra
            Circle()
                .fill(Color.gray.opacity(0.1))
                .shadow(color: .gray.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Imagen del pay
            Image(pieImages[currentIndex])
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentIndex)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.95
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
        }
        .onAppear {
            startAutoAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func startAutoAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation {
                // Ciclar a través de las imágenes
                if currentIndex < pieImages.count - 1 {
                    currentIndex += 1
                } else {
                    currentIndex = 0
                }
            }
        }
    }
}

// Card individual
struct AntSpendingCard: View {
    let spending: AntSpending
    
    var body: some View {
        HStack(spacing: 15) {
            // Icono
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconBackground)
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconImage)
                    .foregroundColor(iconColor)
                    .font(.title3)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(spending.merchantName)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(spending.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Precio
            Text("$\(spending.amount, specifier: "%.2f")")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color(red: 0.93, green: 0.93, blue: 0.93))
        .cornerRadius(15)
    }
    
    var iconImage: String {
        switch spending.merchantName {
        case "Oxxo", "Starbucks Tec":
            return "cup.and.saucer.fill"
        case "H&M":
            return "creditcard.fill"
        default:
            return "bag.fill"
        }
    }
    
    var iconColor: Color {
        switch spending.merchantName {
        case "Oxxo", "Starbucks Tec":
            return .orange
        case "H&M":
            return .green
        default:
            return .blue
        }
    }
    
    var iconBackground: Color {
        iconColor.opacity(0.2)
    }
}

// Modelo - AHORA CON EQUATABLE
struct AntSpending: Identifiable, Equatable {
    let id = UUID()
    let merchantName: String
    let amount: Double
    let date: Date
    let frequency: Int
    let iconName: String
    
    // Necesario para Equatable
    static func == (lhs: AntSpending, rhs: AntSpending) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    PieScreen()
}
