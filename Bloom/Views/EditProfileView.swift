import SwiftUI
import FirebaseAuth

struct EditProfileView: View {
    var onProfileSaved: () -> Void = {}
    
    @State private var displayName: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Profile Information")) {
                TextField("Display Name", text: $displayName)
            }
            
            Section {
                Button(action: saveProfile) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                    }
                }
                .disabled(displayName.isEmpty)
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            if let user = Auth.auth().currentUser {
                displayName = user.displayName ?? ""
            }
        }
        .alert("Unable to save profile", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func saveProfile() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        
        changeRequest.commitChanges { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    onProfileSaved()
                    dismiss()
                }
            }
        }
    }
}


