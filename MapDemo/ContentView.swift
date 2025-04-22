import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            MainView()
                .toolbar(.hidden, for: .navigationBar)
        }
        
        
    }
}

#Preview {
    ContentView()
}
