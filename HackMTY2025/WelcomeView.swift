//
//  WelcomeView.swift
//  CrumbTrail
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//


import SwiftUI

struct WelcomeView: View {
    @State private var user = ""
    @State private var password = ""
    var body: some View {
        NavigationStack{
            ZStack{
                lightBlue
                    .ignoresSafeArea()
                VStack {
                    Image("HormigaLogo")
                        .frame(height: 120)
                        .foregroundStyle(darkBlue)
                        .padding(30)
                    
                    Text("Welcome to CrumbTrail")
                    
                    VStack(alignment: .center, spacing: 20) {
                        TextField("Username", text: $user)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    
                    NavigationLink(destination: ContentView()){
                        HStack(){
                            Text("Forgot your password?")
                                .foregroundStyle(midBlue)
                            Spacer()
                        }
                    }
                    
                    NavigationLink(destination: ContentView()){
                        Text("Sign in")
                            .padding(10)
                            .padding(.horizontal, 10)
                            .foregroundStyle(.white)
                            .background(midBlue)
                            .cornerRadius(20)
                    }
                    .padding()
                    NavigationLink(destination: ContentView()){
                        Text("Dont have an accound? Sign up!")
                            .foregroundStyle(midBlue)
                    }
                }
                .padding(.horizontal, 50)
            }
        }
        
    }
}

#Preview {
    WelcomeView()
}
