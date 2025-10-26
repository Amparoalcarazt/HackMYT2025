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
    @State private var userName = "Name"
    @State private var userEmail = "name@mail.com"
    @State private var profileImage: UIImage?
    @State private var showEditSheet = false
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
            NavigationStack {
                ZStack {
                    VStack(){
                        LinearGradient(colors: [lightBlue, midBlue.opacity(0.8)],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                        .frame(width: 400, height: 250)
                        Spacer()
                    }
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // MARK: - Profile Picture + Name
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 150, height: 150)
                                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                                    
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
                                            .foregroundColor(lightBlue)
                                    }
                                    
                                    // camera button overlay
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
                                                    .background(.black)
                                                    .clipShape(Circle())
                                            }
                                        }
                                    }
                                    .frame(width: 150, height: 150)
                                }
                                
                                Text(userName)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                            
                            }
                            .padding(.top, 40)
                            
                            // MARK: - Info Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    
                                    Text("Account Details")
                                        .bold()
                                    Spacer()
                                    Button("Edit") {
                                        showEditSheet = true
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                }
                                
                                Divider().background(Color.gray.opacity(0.2))
                                Text("\(userName)")
                                Text("\(userEmail)")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
                            .padding(.horizontal)
                            
                            // MARK: - Logout Button
                            Button {
                                try? Auth.auth().signOut()
                                // Handle navigation after logout
                            } label: {
                                Text("Log Out")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    loadUserData()
                    loadProfileImage()
                }
                .sheet(isPresented: $showEditSheet) {
                    EditProfileSheet(userName: $userName)
                }
                .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .images)
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            profileImage = image
                            saveProfileImage(image)
                        }
                    }
                }

            }
        }    // datos del usuario de Firebase
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
