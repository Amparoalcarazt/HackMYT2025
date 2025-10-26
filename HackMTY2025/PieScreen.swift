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
        AntSpending(merchantName: "Oxxo", amount: 45.50, date: Date(), frequency: 5, iconName: "cart.fill"),
        AntSpending(merchantName: "Starbucks Tec", amount: 98.00, date: Date(), frequency: 4, iconName: "cup.and.saucer.fill"),
        AntSpending(merchantName: "H&M", amount: 195.00, date: Date(), frequency: 3, iconName: "bag.fill")
    ]
    
    @State private var selectedSort: SortOption = .price
    @State private var currentPieIndex = 0
    
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
            
            VStack(spacing: 20) {
                // Header con toggle
                HStack {
                    Spacer()
                    
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                        .tint(Color(red: 0.2, green: 0.4, blue: 0.5))
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(90))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Título
                Text("Microspending")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Gráfica de Pay ANIMADA
                AnimatedPieView(
                    pieImages: pieImages,
                    currentIndex: $currentPieIndex,
                    totalAmount: totalSpending
                )
                .frame(width: 320, height: 320)
                .padding()
                
                // Línea divisoria
                Divider()
                    .padding(.horizontal)
                
                // Segmented control
                HStack(spacing: 0) {
                    Button(action: { selectedSort = .latest }) {
                        Text("Latest")
                            .fontWeight(selectedSort == .latest ? .semibold : .regular)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedSort == .latest ?
                                       Color(red: 0.4, green: 0.7, blue: 0.8) :
                                       Color(red: 0.3, green: 0.6, blue: 0.7))
                    }
                    
                    Button(action: { selectedSort = .price }) {
                        HStack {
                            Text("Price")
                            Image(systemName: "arrow.up")
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
                
                // Lista de gastos hormiga
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(sortedSpendings) { spending in
                            AntSpendingCard(spending: spending)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .onAppear {
            updatePieImage()
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
    
    // Actualizar imagen del pay según el gasto total
    func updatePieImage() {
        let total = totalSpending
        
        // Calcular qué imagen mostrar según el total
        if total < 50 {
            currentPieIndex = 0  // Pay completo
        } else if total < 100 {
            currentPieIndex = 1
        } else if total < 150 {
            currentPieIndex = 2
        } else if total < 200 {
            currentPieIndex = 3
        } else if total < 250 {
            currentPieIndex = 4
        } else if total < 300 {
            currentPieIndex = 5
        } else if total < 350 {
            currentPieIndex = 6
        } else if total < 400 {
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
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Imagen del pay
            Image(pieImages[currentIndex])
                .resizable()
                .scaledToFit()
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: currentIndex)
        }
        .onAppear {
            // Animación automática opcional (cambia cada 3 segundos)
            startAutoAnimation()
        }
    }
    
    func startAutoAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
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
                
                Text("Date: 10.17.2025")
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
