import SwiftUI

struct HelpSheetView: View {
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text(LocalizedStringKey("help_description"))
            .font(.body)
            .foregroundColor(.primary)
        }
        .padding()
      }
      .navigationTitle(LocalizedStringKey("how_to_play_title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(LocalizedStringKey("done")) { dismiss() }
        }
      }
    }
  }
}
