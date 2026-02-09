import SwiftUI

class LanguageManager: ObservableObject {
  @Published var locale: Locale {
    didSet {
      UserDefaults.standard.set(locale.identifier, forKey: "selectedLanguage")
    }
  }

  init() {
    if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
      self.locale = Locale(identifier: savedLanguage)
    } else {
      // Default to device language or English if not supported
      let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
      self.locale = (deviceLanguage == "ja") ? Locale(identifier: "ja") : Locale(identifier: "en")
    }
  }

  func setLanguage(_ identifier: String) {
    locale = Locale(identifier: identifier)
  }
}
