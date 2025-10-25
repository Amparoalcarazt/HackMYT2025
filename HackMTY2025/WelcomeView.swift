//
//  WelcomeView.swift
//  CrumbTrail
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//


import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack{
            lightBlue
                .ignoresSafeArea()
            VStack {
                Image(systemName: "circle.fill")
                    .font(.system(size: 120, weight: .semibold))
                    .foregroundStyle(darkBlue)
                
                Text("Welcome to CrumbTrail")
                NavigationLink(destination: ContentView()){
                    Text("Sign in")
                        .padding(10)
                        .background(midBlue)
                        .cornerRadius(5)
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
