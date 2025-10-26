//
//  HackMTY2025App.swift
//  HackMTY2025
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import SwiftData

@main
struct HackMTY2025App: App {
    
    init() {
        FirebaseApp.configure()
        
        // habilitar persistencia offline
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .modelContainer(for: Reminder.self)

        }
    }
}
