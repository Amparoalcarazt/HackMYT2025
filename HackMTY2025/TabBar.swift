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
                TDashboardView()
                    .navigationTitle("Dashboard")
                
            }
            .tabItem { Label("Dashboard", systemImage: "house.fill") }
            
            NavigationStack {
                RemindersList()
                    .navigationTitle("Reminders")
            }
            .tabItem { Label("Reminders", systemImage: "map.fill") }
            
            NavigationStack {
                TDashboardView()
                    .navigationTitle("Lotes")
            }
            .tabItem { Label("Lotes", systemImage: "mappin") }
            
            // configurations
            NavigationStack {
                TPerfilView()
                    .navigationTitle("Perfil")
            }
            .tabItem { Label("Perfil", systemImage: "person") }
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
