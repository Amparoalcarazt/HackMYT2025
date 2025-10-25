//
//  TabBar.swift
//  CrumbTrail
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//


import SwiftUI

struct TabBar: View {
    @State private var searchText = ""
    var body: some View {
        TabView {
            NavigationStack {
                TDashboardView()
                    .navigationTitle("Dashboard")
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(midBlue, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Dashboard", systemImage: "house.fill") }
            
            NavigationStack {
                TDashboardView()
                    .navigationTitle("Fincas").toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(midBlue, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Fincas", systemImage: "map.fill") }
            
            NavigationStack {
                TDashboardView()
                    .navigationTitle("Lotes").toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(midBlue, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("Lotes", systemImage: "mappin") }
            
            // configurations
            NavigationStack {
                TPerfilView()
                    .navigationTitle("Perfil").toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(midBlue, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .navigationBarTitleDisplayMode(.inline)
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
}
