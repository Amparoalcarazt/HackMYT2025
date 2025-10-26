//
//  ProfileView.swift
//  HackMTY2025
//
//  Created by AGRM on 26/10/25.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

struct ProfileView: View {
    @State private var userName = "Loading..."
    @State private var userEmail = ""
    @State private var profileImage: UIImage?
    @State private var showEditSheet = false
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // header azul con foto de perfil
                ZStack {
                    // fndo azul
                    midBlue
                        .frame(height: 280)
                    
                    VStack(spacing: 20) {
                        // nombre
                        Text(userName)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                        
                        // foto de perfil
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 150, height: 150)
                            
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                            
                            // boton de camara para cambiar foto
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showImagePicker = true
                                    }) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(midBlue)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .frame(width: 150, height: 150)
                        }
                    }
                    
                    // boton de editar
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showEditSheet = true
                            }) {
                                Image(systemName: "pencil")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
                
                // email del usuario
                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                
                // espacio blanco debajo
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .top)
            .onAppear {
                loadUserData()
                loadProfileImage()
            }
            .sheet(isPresented: $showEditSheet) {
                EditProfileSheet(userName: $userName)
            }
            .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        profileImage = image
                        saveProfileImage(image)
                    }
                }
            }
        }
    }
    
    // datos del usuario de Firebase
    func loadUserData() {
        if let user = Auth.auth().currentUser {
            // obtener nombre (si fue configurado) o email
            userName = user.displayName ?? user.email?.components(separatedBy: "@").first?.capitalized ?? "User"
            userEmail = user.email ?? ""
        }
    }
    
    // guardar imagen de perfil en userdefaults
    func saveProfileImage(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "profileImage")
        }
    }
    
    // cargar imagen de perfil desde userdefaults
    func loadProfileImage() {
        if let data = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: data) {
            profileImage = image
        }
    }
}

// sheet para editar el perfil
struct EditProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var userName: String
    @State private var tempName: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Name", text: $tempName)
                }
                
                if showError {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: saveProfile) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(midBlue)
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempName = userName
            }
        }
    }
    
    func saveProfile() {
        guard !tempName.isEmpty else {
            errorMessage = "Name cannot be empty"
            showError = true
            return
        }
        
        isLoading = true
        showError = false
        
        // actualizar el nombre en firebase
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = tempName
        changeRequest?.commitChanges { error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            // exito
            userName = tempName
            dismiss()
        }
    }
}

#Preview {
    ProfileView()
}
