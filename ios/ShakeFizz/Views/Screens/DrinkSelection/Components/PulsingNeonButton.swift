import SwiftUI

struct PulsingNeonButton: View {
  let title: String
  let localized: Bool
  let color: Color
  let icon: String?
  let action: () -> Void

  @State private var isPulsing = false

  init(
    title: String, localized: Bool = false, color: Color, icon: String? = nil,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.localized = localized
    self.color = color
    self.icon = icon
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack {
        if localized {
          Text(LocalizedStringKey(title))
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.black)
        } else {
          Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.black)
        }

        if let icon = icon {
          Image(systemName: icon)
            .foregroundColor(.black)
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(color)
      .cornerRadius(12)
      .shadow(color: color.opacity(isPulsing ? 0.9 : 0.6), radius: isPulsing ? 15 : 10, x: 0, y: 0)
      .scaleEffect(isPulsing ? 1.02 : 1.0)
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
        isPulsing = true
      }
    }
  }
}
