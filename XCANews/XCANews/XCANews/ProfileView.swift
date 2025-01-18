import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var username: String = "Loading..."
    @State private var email: String = "Loading..."
    @State private var showError = false
    @State private var errorMessage = ""
    @Binding var isLoggedIn: Bool 

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding()

                    Text(username)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Divider()
                    .padding(.horizontal)

                // Logout Button
                Button(action: handleLogout) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .onAppear(perform: loadUserDetails)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // Load user details from Firestore
    private func loadUserDetails() {
        guard let user = Auth.auth().currentUser else {
            showError = true
            errorMessage = "Unable to fetch user details"
            return
        }

        // Fetch user details from Firestore
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { document, error in
            if let error = error {
                showError = true
                errorMessage = "Failed to fetch user details: \(error.localizedDescription)"
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                showError = true
                errorMessage = "User details not found"
                return
            }

            // Extract username and email from Firestore document
            username = data["username"] as? String ?? "Unknown User"
            email = data["email"] as? String ?? "No Email"
        }
    }

    // Handle logout functionality
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false // Update the binding to switch to the login view
        } catch {
            showError = true
            errorMessage = "Failed to log out: \(error.localizedDescription)"
        }
    }
}
