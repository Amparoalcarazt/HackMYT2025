//
//  WelcomeView.swift
//  CrumbTrail
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//

import SwiftUI
import FirebaseAuth
import SwiftData

struct WelcomeView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                lightBlue
                    .ignoresSafeArea()
                
                Image("LoginBg")
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo
                    Image("HormigaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .foregroundStyle(darkBlue)
                    
                    VStack(spacing: 4) {
                        Text("Welcome to")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(darkBlue.opacity(0.7))
                        
                        Text("CrumbTrail")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [darkBlue, midBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: midBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Text("Follow the trail to better habits")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(darkBlue.opacity(0.6))
                            .italic()
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // Input fields with icons
                    VStack(alignment: .center, spacing: 16) {
                        // Email field
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(midBlue)
                                .frame(width: 20)
                            
                            TextField("Email", text: $email)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(midBlue.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Password field
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(midBlue)
                                .frame(width: 20)
                            
                            SecureField("Password", text: $password)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(midBlue.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 40)
                    
                    // Error message
                    if showError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            Text(errorMessage)
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    }
                    
                    // Forgot password
                    HStack {
                        NavigationLink(destination: ContentView()) {
                            Text("Forgot your password?")
                                .font(.system(size: 14))
                                .foregroundStyle(midBlue)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 12)
                    
                    // Sign in button
                    Button(action: signIn) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            HStack(spacing: 8) {
                                Text("Sign in")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 18))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                    }
                    .background(
                        LinearGradient(
                            colors: [midBlue, darkBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: midBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                    .disabled(isLoading)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    // Sign up link
                    NavigationLink(destination: SignUpView()) {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundStyle(.gray)
                            Text("Sign up!")
                                .foregroundStyle(midBlue)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                ContentView()
            }
        }
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        showError = false
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            print("User signed in: \(result?.user.email ?? "")")
            isLoggedIn = true
        }
    }
}

#Preview {
    WelcomeView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
