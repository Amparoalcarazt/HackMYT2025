//
//  AddCategorySheet.swift
//  HackMTY2025
//

import SwiftUI

struct AddCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var categories: [CustomCategory]
    
    @State private var categoryName = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = Color.blue
    @State private var showError = false
    
    let availableIcons = [
        "star.fill", "heart.fill", "house.fill", "book.fill",
        "gamecontroller.fill", "cart.fill", "car.fill", "airplane",
        "bicycle", "tram.fill", "fork.knife", "cup.and.saucer.fill",
        "bag.fill", "backpack.fill", "figure.run", "dumbbell.fill",
        "pawprint.fill", "tree.fill", "leaf.fill", "flame.fill",
        "bolt.fill", "drop.fill", "snowflake", "sparkles"
    ]
    
    let availableColors: [Color] = [
        .blue, .red, .green, .orange, .purple,
        .pink, .yellow, .indigo, .cyan, .mint
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header con preview
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(selectedColor.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 50))
                                    .foregroundColor(selectedColor)
                            }
                            
                            Text("Create Category")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 20)
                        
                        // Category Name
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Category Name", systemImage: "tag.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("e.g., Entertainment, Fitness, Travel", text: $categoryName)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .gray.opacity(0.1), radius: 3)
                                )
                                .autocapitalization(.words)
                        }
                        .padding(.horizontal)
                        
                        // Icon Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Choose Icon", systemImage: "photo.on.rectangle")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            selectedIcon = icon
                                        }
                                    }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedIcon == icon ? .white : selectedColor)
                                            .frame(width: 50, height: 50)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedIcon == icon ? selectedColor : Color(.systemBackground))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedIcon == icon ? selectedColor : Color.gray.opacity(0.3), lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .gray.opacity(0.1), radius: 3)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Choose Color", systemImage: "paintpalette.fill")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            selectedColor = color
                                        }
                                    }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 3)
                                                    .opacity(selectedColor == color ? 1 : 0)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(color, lineWidth: 3)
                                                    .scaleEffect(1.2)
                                                    .opacity(selectedColor == color ? 1 : 0)
                                            )
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .gray.opacity(0.1), radius: 3)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Error Message
                        if showError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("Please enter a category name")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                        
                        // Create Button
                        Button(action: createCategory) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Category")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [selectedColor, selectedColor.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: selectedColor.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(categoryName.isEmpty)
                        .opacity(categoryName.isEmpty ? 0.6 : 1.0)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func createCategory() {
        guard !categoryName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError = true
            return
        }
        
        let newCategory = CustomCategory(
            id: UUID().uuidString,
            name: categoryName,
            icon: selectedIcon,
            color: selectedColor
        )
        
        categories.append(newCategory)
        dismiss()
    }
}

#Preview {
    AddCategorySheet(categories: .constant([]))
}
