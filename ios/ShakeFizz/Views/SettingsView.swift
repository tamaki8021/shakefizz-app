import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var languageManager: LanguageManager
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Language")) {
          Picker("Language", selection: $languageManager.locale) {
            Text("English").tag(Locale(identifier: "en"))
            Text("日本語").tag(Locale(identifier: "ja"))
          }
          .pickerStyle(SegmentedPickerStyle())
          .onChange(of: languageManager.locale) { newValue in
            languageManager.setLanguage(newValue.identifier)
          }
        }

        Section(header: Text("About")) {
          HStack {
            Text("Version")
            Spacer()
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
          }
          HStack {
            Text("Build")
            Spacer()
            Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
          }
        }
      }
      .navigationTitle("Settings")
      .navigationBarItems(
        trailing: Button("Done") {
          dismiss()
        })
    }
  }
}
