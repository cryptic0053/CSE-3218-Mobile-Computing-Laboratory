import SwiftUI

struct ContentView: View {
    
    @Binding var isLoggedIn: Bool // Bind this from the parent view
    
    var body: some View {
        TabView {
            NewsTabView()
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
            
            SearchTabView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            BookmarkTabView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem{
                    Label("Profile",systemImage: "person")
                }
        }
        
    }
}

