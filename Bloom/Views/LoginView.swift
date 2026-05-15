import SwiftUI

struct LoginView: View {
    var onAuthenticate: () -> Void = {}
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var rotateLogo = false
    
    // MARK: - Colors
    let backgroundColor = Color(red: 232/255, green: 224/255, blue: 213/255)
    let accentColor = Color(red: 227/255, green: 168/255, blue: 145/255)
    let textColor = Color(red: 173/255, green: 150/255, blue: 127/255)
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer()
                
                // Logo
                Image("bloom_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                
                // Title
                Text("BLOOM")
                    .font(.custom("DarumadropOne-Regular", size: 42))
                    .foregroundColor(textColor)
                
                Text("WELCOME BACK!")
                    .font(.custom("DarumadropOne-Regular", size: 28))
                    .foregroundColor(textColor)
                
                VStack(spacing: 14) {
                    
                    TextField("email (eg. user@gmail.com)", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(14)
                        .autocapitalization(.none)
                    
                    SecureField("password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(14)
                }
                .padding(.top, 10)
                
                // Login Button
                Button {
                    if isLogin {
                        login()
                    } else {
                        register()
                    }
                } label: {
                    Text(isLogin ? "Login" : "Sign Up")
                        .font(.custom("DarumadropOne-Regular", size: 20))
                        .foregroundColor(Color(red: 140/255, green: 80/255, blue: 60/255))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(accentColor)
                        .cornerRadius(14)
                }
                
                // Switch auth mode
                Button {
                    isLogin.toggle()
                    errorMessage = ""
                } label: {
                    Text(
                        isLogin
                        ? "Don't have an account? Sign up"
                        : "Already have an account? Login"
                    )
                    .font(.custom("DarumadropOne-Regular", size: 20))
                    .foregroundColor(.brown)
                }
                
                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
            if isLoading {
                
                ZStack {
                    
                    backgroundColor
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        
                        Image("bloom_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(rotateLogo ? 360 : 0))
                            .animation(
                                .linear(duration: 5)
                                .repeatForever(autoreverses: false),
                                value: rotateLogo
                            )
                        
                        Text("watering your garden...")
                            .font(.custom("PatrickHand-Regular", size: 28))
                            .foregroundColor(.brown.opacity(0.8))
                    }
                }
                .transition(.opacity)
                .onAppear {
                    rotateLogo = true
                }
            }
        }
    }
    // MARK: - Auth
    
    func login() {
        
        isLoading = true
        
        AuthManager.shared.signIn(email: email, password: password) { success, error in
            
            isLoading = false
            rotateLogo = false
            
            if success {
                onAuthenticate()
            } else {
                errorMessage = error ?? "Login failed"
            }
        }
    }
    
    func register() {
        
        isLoading = true
        
        AuthManager.shared.signUp(email: email, password: password) { success, error in
            
            isLoading = false
            rotateLogo = false
            
            if success {
                onAuthenticate()
            } else {
                errorMessage = error ?? "Signup failed"
            }
        }
    }
}
