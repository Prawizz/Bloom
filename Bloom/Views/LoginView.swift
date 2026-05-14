import SwiftUI

struct LoginView: View {
    var onAuthenticate: () -> Void = {}
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 25) {
            
            Spacer()
            
            Text("Bloom 🌸")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(isLogin ? "Welcome back" : "Create account")
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            Button {
                if isLogin {
                    login()
                } else {
                    register()
                }
            } label: {
                Text(isLogin ? "Login" : "Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("SoftPink"))
                    .cornerRadius(12)
            }
            
            Button {
                isLogin.toggle()
                errorMessage = ""
            } label: {
                Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func login() {
        AuthManager.shared.signIn(email: email, password: password) { success, error in
            if success {
                onAuthenticate()
            } else {
                errorMessage = error ?? "Login failed"
            }
        }
    }
    
    func register() {
        AuthManager.shared.signUp(email: email, password: password) { success, error in
            if success {
                onAuthenticate()
            } else {
                errorMessage = error ?? "Signup failed"
            }
        }
    }
}

#Preview{
    LoginView()
}
