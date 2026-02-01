import SwiftUI

struct ResultView: View {
  @ObservedObject var viewModel: GameViewModel

  var body: some View {
    ZStack {
      BackgroundView()

      VStack(spacing: 30) {
        Text("MISSION COMPLETE")
          .font(.headline)
          .foregroundColor(.neonCyan)
          .padding(.top, 40)

        if let session = viewModel.currentSession {
          Spacer()

          // Rank Badge
          VStack {
            Text("RANK")
              .font(.caption)
              .foregroundColor(.gray)

            Text(session.rank.rawValue)
              .font(.system(size: 80, weight: .black))
              .foregroundColor(.white)
              .frame(width: 120, height: 120)
              .background(
                RoundedRectangle(cornerRadius: 20)
                  .stroke(Color(hex: session.rank.colorHex), lineWidth: 4)
                  .background(Color.black.opacity(0.5))
              )
              .shadow(color: Color(hex: session.rank.colorHex), radius: 15)
          }

          Spacer()

          // Score
          VStack {
            Text(String(format: "%.1f", session.score))
              .font(.system(size: 70, weight: .bold))
              .foregroundColor(.white)
            Text("METERS")
              .font(.title2)
              .foregroundColor(.neonCyan)
          }

          Spacer()

          VStack(spacing: 15) {
            NeonButton(title: "TRY AGAIN", color: .neonCyan, icon: "arrow.clockwise") {
              viewModel.retryGame()
            }

            Button(action: {
              viewModel.resetGame()
            }) {
              Text("CHANGE DRINK")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
            }
          }
          .padding(.horizontal)
          .padding(.bottom, 40)

        } else {
          Text("No Result Data")
        }
      }
    }
  }
}

// Helper for Hex Color
extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:  // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:  // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}
