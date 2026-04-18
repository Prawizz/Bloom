import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var user: User? = Auth.auth().currentUser
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Profile Widget
                NavigationLink(destination: EditProfileView()) {
                    HStack {
                        // Profile Picture
                        if let photoURL = user?.photoURL,
                           let url = URL(string: photoURL.absoluteString) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 60)
                            }
                        } else {
                            Circle()
                                .fill(Color("SoftPink"))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(user?.email?.prefix(1).uppercased() ?? "?")
                                        .foregroundColor(.white)
                                        .font(.title)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text(user?.displayName ?? user?.email ?? "User")
                                .font(.headline)
                            Text("Tap to edit profile")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Sign Out Button
                Button(action: signOut) {
                    Text("Sign Out")
                        .foregroundColor(.brown)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                user = Auth.auth().currentUser
            }
        }
    }
    
    private func signOut() {
        AuthManager.shared.signOut()
        // Note: You might need to handle navigation back to LoginView in your app's root
    }
}

#Preview {
    ProfileView()
}
