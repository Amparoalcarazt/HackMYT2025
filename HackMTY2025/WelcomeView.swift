//
//  WelcomeView.swift
//  CrumbTrail
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//

import SwiftUI
import FirebaseAuth  // backend
import SwiftData

struct WelcomeView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false  // para backend
    @State private var errorMessage = ""  // para backend
    @State private var isLoading = false  // para backend
    @State private var isLoggedIn = false // para backend
    
    var body: some View {
        NavigationStack {
            ZStack {
                lightBlue
                    .ignoresSafeArea()
                Image("LoginBg")
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                VStack {
                    Image("HormigaLogo")
                        .frame(height: 120)
                        .foregroundStyle(darkBlue)
                        .padding(30)
                        .padding(.top, 40)
                    
                    Text("Welcome to CrumbTrail")
                    
                    VStack(alignment: .center, spacing: 20) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)  // backend
                            .keyboardType(.emailAddress)  // backend
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // mensaje de error
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // forgot password
                    NavigationLink(destination: ContentView()) {
                        HStack() {
                            Text("Forgot your password?")
                                .foregroundStyle(midBlue)
                            Spacer()
                        }
                    }
                    
                    // sign in button
                    Button(action: signIn) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign in")
                                .padding(10)
                                .padding(.horizontal, 10)
                                .foregroundStyle(.white)
                        }
                    }
                    .background(midBlue)
                    .cornerRadius(20)
                    .disabled(isLoading)
                    .padding()
                    
                    // sign up link
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign up!")
                            .foregroundStyle(midBlue)
                    }
                }
                .padding(.horizontal, 50)
            }
            .scrollDismissesKeyboard(.interactively)
            // NAVEGACION CUANDO LOGIN EXITOSO
            .navigationDestination(isPresented: $isLoggedIn) {
                ContentView()  // pantalla principal después del login -> home
            }
        }
    }
    
    // backend
    func signIn() {
        // validar que los campos no estén vacíos
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        showError = false
        
        // llamar a Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                // mostrar error
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            // usuario logueado
            print("User signed in: \(result?.user.email ?? "")")
            isLoggedIn = true
        }
    }
}

#Preview {
    WelcomeView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
