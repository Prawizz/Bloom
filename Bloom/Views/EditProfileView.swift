import SwiftUI
import FirebaseAuth
import PhotosUI

struct EditProfileView: View {
    var onProfileSaved: () -> Void = {}
    
    @State private var displayName: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Photo selection and tracking states
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var hasLocalImage: Bool = FileManager.default.fileExists(atPath: ProfileImageManager.fileURL.path)
    @State private var shouldRemovePhoto: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    // Theme Colors
    private let textBrown = Color(red: 0.4, green: 0.3, blue: 0.2)
    private let softBeige = Color(red: 0.98, green: 0.96, blue: 0.92)

    var body: some View {
        ZStack {
            softBeige.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Edit Profile")
                    .font(.custom("DarumadropOne-Regular", size: 32))
                    .foregroundColor(textBrown)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // 1. PHOTOS PICKER
                        VStack(spacing: 16) {
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                VStack(spacing: 12) {
                                    Group {
                                        if shouldRemovePhoto {
                                            Image("user_logo")
                                                .resizable()
                                                .scaledToFill()
                                        } else if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                        } else if hasLocalImage, let localImage = ProfileImageManager.loadLocalImage() {
                                            localImage
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Image("user_logo")
                                                .resizable()
                                                .scaledToFill()
                                        }
                                    }
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(textBrown.opacity(0.2), lineWidth: 3))
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "photo.badge.plus")
                                        Text("Change Photo")
                                    }
                                    .font(.custom("DarumadropOne-Regular", size: 14))
                                    .foregroundColor(textBrown)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 14)
                                    .background(Capsule().fill(Color.white.opacity(0.8)))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onChange(of: selectedItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        await MainActor.run {
                                            selectedImageData = data
                                            shouldRemovePhoto = false
                                        }
                                    }
                                }
                            }
                            
                            // REMOVE PHOTO
                            if (!shouldRemovePhoto && (hasLocalImage || selectedImageData != nil)) {
                                Button(action: {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        selectedItem = nil
                                        selectedImageData = nil
                                        shouldRemovePhoto = true
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trash")
                                        Text("Remove Photo")
                                    }
                                    .font(.custom("DarumadropOne-Regular", size: 13))
                                    .foregroundColor(.red.opacity(0.8))
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(Capsule().fill(Color.red.opacity(0.05)))
                                }
                            }
                        }
                        .padding(.top, 20)

                        // 2. INPUT FIELD
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DISPLAY NAME")
                                .font(.custom("DarumadropOne-Regular", size: 14))
                                .foregroundColor(textBrown.opacity(0.7))
                                .padding(.leading, 5)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(textBrown.opacity(0.4))
                                
                                TextField("", text: $displayName, prompt: Text("Enter your name...").foregroundColor(textBrown.opacity(0.3)))
                                    .font(.custom("DarumadropOne-Regular", size: 18))
                                    .foregroundColor(textBrown)
                            }
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(textBrown.opacity(0.1), lineWidth: 1))
                        }
                        .padding(.horizontal, 24)
                        
                        // 3. ACTION BUTTONS
                        VStack(spacing: 12) {
                            Button(action: saveProfileChangesLocally) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Save Changes")
                                }
                                .font(.custom("DarumadropOne-Regular", size: 20))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(displayName.isEmpty ? textBrown.opacity(0.4) : textBrown)
                                .cornerRadius(100)
                            }
                            .disabled(displayName.isEmpty)
                            
                            Button(action: { dismiss() }) {
                                Text("Cancel")
                                    .font(.custom("DarumadropOne-Regular", size: 16))
                                    .foregroundColor(textBrown.opacity(0.6))
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let user = Auth.auth().currentUser {
                displayName = user.displayName ?? ""
            }
        }
    }
    
    private func saveProfileChangesLocally() {
        // 1. Process local image file updates
        if shouldRemovePhoto {
            ProfileImageManager.deleteImage()
        } else if let selectedImageData {
            ProfileImageManager.saveImage(data: selectedImageData)
        }
        
        // 2. Save text name to Firebase profile metadata context container as normal
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { _ in
                DispatchQueue.main.async {
                    onProfileSaved()
                    dismiss()
                }
            }
        } else {
            onProfileSaved()
            dismiss()
        }
    }
}
