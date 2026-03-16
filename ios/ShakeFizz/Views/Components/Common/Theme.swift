import SwiftUI

extension Color {
  static let neonCyan = Color(red: 0.0, green: 1.0, blue: 1.0)
  static let neonMagenta = Color(red: 1.0, green: 0.0, blue: 1.0)
  static let neonYellow = Color(red: 1.0, green: 1.0, blue: 0.0)
  static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.05)
  static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.1)
}

struct Theme {
  static let gradientBackground = LinearGradient(
    gradient: Gradient(colors: [Color.darkBackground, Color.black]),
    startPoint: .top,
    endPoint: .bottom
  )
}

// MARK: - グラスモーフィズム（透き通ったガラス風）
struct GlassPanelModifier: ViewModifier {
  var cornerRadius: CGFloat = 12
  var opacity: Double = 0.25

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(.ultraThinMaterial)
          .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
              .fill(Color.white.opacity(opacity))
          )
      )
  }
}

extension View {
  func glassPanel(cornerRadius: CGFloat = 12, opacity: Double = 0.25) -> some View {
    modifier(GlassPanelModifier(cornerRadius: cornerRadius, opacity: opacity))
  }
}
