import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    var onSignOut: () -> Void = {}
    @State private var user: User? = Auth.auth().currentUser
    @State private var showSignOutAlert = false
    
    // 👇 Local tracking ID to instantly refresh the local image render state
    @State private var localImageID = UUID().uuidString
    
    // Theme Colors
    private let textBrown = Color(red: 0.4, green: 0.3, blue: 0.2)
    private let softBeige = Color(red: 0.98, green: 0.96, blue: 0.92)

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Theme
                softBeige.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // HEADER
                    Text("Profile")
                        .font(.custom("DarumadropOne-Regular", size: 36))
                        .foregroundColor(textBrown)
                        .padding(.top, 40)
                    
                    Spacer()

                    // CENTERED PROFILE CARD
                    VStack(spacing: 24) {
                        
                        // Profile Picture & Details Stack
                        VStack(spacing: 16) {
                            // Centered Profile Picture (Now pulling completely from Local Device Storage)
                            Group {
                                if let localImage = ProfileImageManager.loadLocalImage() {
                                    localImage
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    // Default asset fallback
                                    Image("user_logo")
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(textBrown.opacity(0.15), lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                            .id(localImageID) // 👈 Forces an instant layout redraw when user saves changes
                            
                            // User Information
                            VStack(spacing: 6) {
                                Text(user?.displayName ?? "Gardener")
                                    .font(.custom("DarumadropOne-Regular", size: 26))
                                    .foregroundColor(textBrown)
                                
                                Text(user?.email ?? "No Email Linked")
                                    .font(.custom("DarumadropOne-Regular", size: 16))
                                    .foregroundColor(textBrown.opacity(0.6))
                            }
                        }
                        
                        // --- EXPLICIT EDIT PROFILE BUTTON ---
                        NavigationLink(destination: EditProfileView(onProfileSaved: refreshUser)) {
                            HStack(spacing: 8) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Edit Profile")
                            }
                            .font(.custom("DarumadropOne-Regular", size: 16))
                            .foregroundColor(textBrown)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                Capsule()
                                    .fill(textBrown.opacity(0.08))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 35)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.85))
                            .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
                    )
                    .padding(.horizontal, 24)

                    Spacer()

                    // SIGN OUT BUTTON (Bottom)
                    Button(action: {
                        showSignOutAlert = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .font(.custom("DarumadropOne-Regular", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(textBrown.opacity(0.85))
                        .cornerRadius(100)
                        .padding(.horizontal, 40)
                        .shadow(color: textBrown.opacity(0.2), radius: 10, y: 5)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                refreshUser()
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to leave the garden for now?")
            }
        }
    }

    private func refreshUser() {
        user = Auth.auth().currentUser
        localImageID = UUID().uuidString // 👈 Updates identity tracker to wipe old view hierarchies instantly
    }

    private func signOut() {
        AuthManager.shared.signOut()
        onSignOut()
    }
}
