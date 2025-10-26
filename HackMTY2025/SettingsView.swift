//
//  SettingsView.swift
//  HackMTY2025
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var language = "English"
    @State private var currency = "American dollar"
    @State private var notificationsEnabled = true
    let languages = ["Spanish", "English", "French", "German"]
    let currencies = ["Mexican peso", "American dollar", "Canadian dollar", "Euros", "Pounds"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink(destination: ProfileView()) {
                        Label("Account settings", systemImage: "person.circle.fill")
                            .foregroundColor(midBlue)
                    }
                }
                
                Section(header: Text("Adaptability")) {
                    Picker("Select a language", selection: $language) {
                        ForEach(languages, id: \.self) { language in
                            Text(language)
                        }
                    }
                    
                    Picker("Select a currency", selection: $currency) { 
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .tint(midBlue)
                }
                
                Section {
                    NavigationLink(destination: WelcomeView().navigationBarBackButtonHidden(true)) {
                        Text("Log out")
                            .foregroundColor(.red)
                            .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Profile configuration")
        }
    }
}

#Preview {
    SettingsView()
}
