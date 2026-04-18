import SwiftUI
import FirebaseAuth

struct EditProfileView: View {
    @State private var displayName: String = ""
    @State private var isLoading = false
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
    }
    
    private func saveProfile() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        
        changeRequest.commitChanges { error in
            isLoading = false
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationView {
        EditProfileView()
    }
}