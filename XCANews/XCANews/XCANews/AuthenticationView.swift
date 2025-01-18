import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthenticationView: View {
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var showError = false
    @State private var errorMessage = ""

    @Binding var isLoggedIn: Bool // Bind this from the parent view
    
    var body: some View {
        NavigationView {
            VStack {
                // Header Section
                VStack(spacing: 8) {
                    Image(systemName: isLoginMode ? "lock.fill" : "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)

                    Text(isLoginMode ? "Welcome Back" : "Create an Account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 10)
                }
                .padding(.top, 30)

                // Authentication Form Section
                VStack(spacing: 16) {
                    // Toggle Login/Sign Up
                    Picker(selection: $isLoginMode, label: Text("Authentication Mode")) {
                        Text("Login").tag(true)
                        Text("Sign Up").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top)

                    // Form Fields
                    if !isLoginMode {
                        // Username for Sign Up
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .textFieldStyle(ModernTextFieldStyle(icon: "person.fill"))
                    }

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(ModernTextFieldStyle(icon: "envelope.fill"))

                    SecureField("Password", text: $password)
                        .textFieldStyle(ModernTextFieldStyle(icon: "lock.fill"))

                    if !isLoginMode {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(ModernTextFieldStyle(icon: "lock.fill"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Submit Button
                Button(action: handleAuthentication) {
                    Text(isLoginMode ? "Login" : "Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Error Message
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 10)
                }

                Spacer()
            }
            .navigationTitle(isLoginMode ? "Login" : "Sign Up")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Handle Login/Sign Up Logic
    private func handleAuthentication() {
        if !isLoginMode {
            guard !username.isEmpty else {
                showError("Username is required")
                return
            }

            guard password == confirmPassword else {
                showError("Passwords do not match")
                return
            }
        }

        Task {
            do {
                if isLoginMode {
                    try await performLogin(email: email, password: password)
                } else {
                    try await performSignUp(email: email, password: password, username: username)
                }
            } catch {
                showError(error.localizedDescription)
            }
        }
    }

    private func performLogin(email: String, password: String) async throws {
        do {
            let _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isLoggedIn = true
        } catch {
            throw error
        }
    }

    private func performSignUp(email: String, password: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            // Save the username to Firestore
            let userId = result.user.uid
            let db = Firestore.firestore()
            try await db.collection("users").document(userId).setData([
                "username": username,
                "email": email
            ])

            isLoggedIn = true
        } catch {
            throw error
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - ModernTextFieldStyle
struct ModernTextFieldStyle: TextFieldStyle {
    var icon: String

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            configuration
                .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

