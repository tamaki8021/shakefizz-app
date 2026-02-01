import SwiftUI

struct SafetyWarningView: View {
  @ObservedObject var viewModel: GameViewModel

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack {
        // Top Warning Stripe
        WarningStripe()

        Spacer()

        VStack(spacing: 30) {
          Image(systemName: "exclamationmark.triangle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundColor(.neonYellow)

          VStack(spacing: 10) {
            Text("HOLD TIGHT WITH")
              .font(.title2)
              .fontWeight(.bold)
              .foregroundColor(.white)

            Text("BOTH HANDS!")
              .font(.system(size: 40, weight: .heavy))
              .foregroundColor(.neonYellow)
              .multilineTextAlignment(.center)
          }

          Text("Extreme shaking ahead.\nDo not drop your phone!")
            .font(.body)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
        }

        Spacer()

        NeonButton(title: "GOT IT!", color: .neonCyan, icon: nil) {
          viewModel.acknowledgeWarning()
        }
        .padding()

        // Bottom Warning Stripe
        WarningStripe()
      }
    }
  }
}

struct WarningStripe: View {
  var body: some View {
    HStack(spacing: 0) {
      ForEach(0..<20) { _ in
        Rectangle()
          .fill(Color.neonYellow)
          .frame(width: 20, height: 20)
        Rectangle()
          .fill(Color.black)
          .frame(width: 20, height: 20)
      }
    }
    .frame(height: 20)
    .clipped()
  }
}
