


import SwiftUI
import Firebase

struct RootView: View {
    @State private var isLoggedIn: Bool = false
    
    @StateObject var articleBookmarkVM = ArticleBookmarkViewModel.shared

    var body: some View {
        Group {
            if isLoggedIn {
                ContentView(isLoggedIn:$isLoggedIn).environmentObject(articleBookmarkVM)
            } else {
                AuthenticationView(isLoggedIn:$isLoggedIn)
            }
        }
        .onAppear(perform: checkAuthState)
    }

    private func checkAuthState() {
        // Set the initial state based on the current user
        isLoggedIn = Auth.auth().currentUser != nil

        // Listen for changes in authentication state
        Auth.auth().addStateDidChangeListener { _, user in
            isLoggedIn = (user != nil)
        }
    }
}
