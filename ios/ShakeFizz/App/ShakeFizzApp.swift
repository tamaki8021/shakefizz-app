import SwiftUI

@main
struct ShakeFizzApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Force dark mode as per design
        }
    }
}
