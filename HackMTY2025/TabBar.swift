//
//  TabBar.swift
//  CrumbTrail
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//


import SwiftUI
import SwiftData

struct TabBar: View {
    @State private var searchText = ""
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    
            }
            .tabItem { Label("Dashboard", systemImage: "house.fill") }
            
            NavigationStack {
                RemindersList()
                    .navigationTitle("Reminders")
            }
            .tabItem { Label("Reminders", systemImage: "bell.fill") }
            
            NavigationStack {
                TDashboardView()
                    .navigationTitle("ChatBot")
            }
            .tabItem { Label("ChatBot", systemImage: "bubble.left.fill") }
            
            // configurations
            NavigationStack {
                TPerfilView()
                    .navigationTitle("Settings")
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(coolRed)
    }
}

struct TDashboardView: View {
    @State private var searchText = ""
    var body: some View {
        Text("dashboard")
    }
}
struct TFincasView: View {
    @State private var searchText = ""
    var body: some View {
        Text("Fincas")
    }
}

struct TPerfilView: View {
    @State private var searchText = ""
    var body: some View {
        Text("Perfil")
    }
}
#Preview {
    TabBar()
        .modelContainer(for: Reminder.self, inMemory: true)
}
