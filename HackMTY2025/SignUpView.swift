//
//  SignUpView.swift
//  HackMTY2025
//
//  Created by AGRM  on 25/10/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var signUpSuccess = false
    
    var body: some View {
        ZStack {
            lightBlue
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Image("HormigaLogo")
                        .frame(height: 100)
                        .foregroundStyle(darkBlue)
                        .padding(.top, 40)
                    
                    Text("Join CrumbTrail")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(darkBlue)
                    
                    VStack(spacing: 15) {
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 40)
                        
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 40)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 40)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 40)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 40)
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 40)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: signUp) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign up")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(10)
                    .padding(.horizontal, 20)
                    .background(midBlue)
                    .cornerRadius(20)
                    .disabled(isLoading)
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Account Created!", isPresented: $signUpSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your account has been created successfully. You can now sign in.")
        }
    }
    
    func signUp() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        isLoading = true
        showError = false
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            print("✅ User created: \(result?.user.email ?? "")")
            signUpSuccess = true
        }
    }
}

#Preview {
    SignUpView()
}
