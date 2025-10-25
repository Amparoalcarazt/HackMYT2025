//
//  HackMTY2025App.swift
//  HackMTY2025
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//

import SwiftUI
import FirebaseCore

@main
struct HackMTY2025App: App {
    
    init() {
            FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}
