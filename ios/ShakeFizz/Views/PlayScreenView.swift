import SwiftUI

struct PlayScreenView: View {
  @ObservedObject var viewModel: GameViewModel
  @ObservedObject var shakeManager: ShakeManager

  init(viewModel: GameViewModel) {
    self.viewModel = viewModel
    self.shakeManager = viewModel.shakeManager
  }

  var body: some View {
    ZStack {
      BackgroundView()

      // "Inside the Can" visual effect (simplified)
      Circle()
        .fill(Color.neonCyan.opacity(0.1))
        .scaleEffect(shakeManager.isShaking ? 1.2 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: shakeManager.isShaking)

      VStack {
        // Top Bar
        HStack {
          Button(action: { viewModel.resetGame() }) {
            Image(systemName: "xmark.circle.fill")
              .font(.title)
              .foregroundColor(.gray)
          }
          Spacer()
          Text("FLAVOR: \(viewModel.selectedDrink?.displayName ?? "UNKNOWN")")
            .font(.caption)
            .padding(8)
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)
            .foregroundColor(.neonCyan)
          Spacer()
        }
        .padding()

        Spacer()

        // Main Stats
        VStack(spacing: 5) {
          Text("PROJECTED SPRAY")
            .font(.caption)
            .tracking(2)
            .foregroundColor(.gray)

          Text("\(String(format: "%.1f", shakeManager.projectedHeight))m")
            .font(.system(size: 60, weight: .black, design: .monospaced))
            .foregroundColor(.white)
            .shadow(color: .neonCyan, radius: 10)
        }

        Spacer()

        // Height Meter (Right Side)
        HStack {
          Spacer()
          VStack {
            ZStack(alignment: .bottom) {
              Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 20, height: 300)

              Capsule()
                .fill(
                  LinearGradient(
                    gradient: Gradient(colors: [.neonCyan, .neonMagenta]), startPoint: .bottom,
                    endPoint: .top)
                )
                .frame(width: 20, height: 300 * min(shakeManager.currentPressure / 100.0, 1.0))
                .animation(.spring(), value: shakeManager.currentPressure)
            }
            Text("MAX")
              .font(.caption2)
              .foregroundColor(.gray)
          }
          .padding(.trailing, 20)
        }

        Spacer()

        if shakeManager.isShaking {
          Text("KEEP SHAKING!")
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.neonYellow)
            .transition(.scale)
        }

        Spacer()

        // POP Button
        Button(action: {
          viewModel.finishTyringToPop()
        }) {
          Text("POP THE TOP")
            .font(.title)
            .fontWeight(.heavy)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.neonCyan)
            .cornerRadius(20)
            .shadow(color: .neonCyan, radius: 10)
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
      }
    }
  }
}
