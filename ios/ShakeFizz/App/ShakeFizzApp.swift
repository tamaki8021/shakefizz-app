import SwiftUI

@main
struct ShakeFizzApp: App {
  @StateObject private var languageManager = LanguageManager()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .preferredColorScheme(.dark)  // Force dark mode as per design
        .environment(\.locale, languageManager.locale)
        .environmentObject(languageManager)
    }
  }
}
