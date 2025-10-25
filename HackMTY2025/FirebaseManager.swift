//
//  FirebaseManager.swift
//  HackMTY2025
//
//  Created by AGRM  on 25/10/25.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    
    private init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
    }
}
