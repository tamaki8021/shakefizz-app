import SwiftUI

struct OutOfFizzModalView: View {
  let onDismiss: () -> Void
  let onWatchAd: () -> Void

  @State private var countdownSeconds: Int = 14 * 60 + 59
  @State private var timer: Timer?

  var body: some View {
    outOfFizzBackground
      .overlay(outOfFizzModalCard)
      .onAppear { startCountdown() }
      .onDisappear { timer?.invalidate() }
  }

  private var outOfFizzBackground: some View {
    ZStack {
      Rectangle()
        .fill(.ultraThickMaterial)
        .ignoresSafeArea()
      Color.black.opacity(0.6)
        .ignoresSafeArea()
    }
  }

  private var outOfFizzModalCard: some View {
    VStack(spacing: 0) {
      HStack {
        Spacer()
        Button(action: onDismiss) {
          Image(systemName: "xmark")
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white.opacity(0.6))
            .frame(width: 32, height: 32)
            .background(Circle().fill(Color.white.opacity(0.1)))
        }
      }
      .padding(.top, 16)
      .padding(.trailing, 16)
      .zIndex(1)

      VStack(spacing: 20) {
        emptyCanIcon
          .padding(.bottom, 10)

        outOfFizzTitle

        Text(LocalizedStringKey("out_of_fizz_desc"))
          .font(.system(size: 15))
          .foregroundColor(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 16)
          .fixedSize(horizontal: false, vertical: true)

        Button(action: onWatchAd) {
          ZStack {
            RoundedRectangle(cornerRadius: 30)
              .fill(Color.neonCyan)
              .shadow(color: .neonCyan.opacity(0.6), radius: 20, x: 0, y: 0)

            HStack(spacing: 12) {
              Image(systemName: "play.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.9))

              VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedStringKey("free_refill"))
                  .font(.system(size: 10, weight: .bold))
                  .foregroundColor(.white.opacity(0.8))
                Text(LocalizedStringKey("watch_video"))
                  .font(.system(size: 18, weight: .black))
                  .foregroundColor(.white)
              }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
          }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)

        Text(LocalizedStringKey("or_wait_for_recharge"))
          .font(.system(size: 11, weight: .bold))
          .foregroundColor(.white.opacity(0.3))
          .padding(.top, 10)

        HStack {
          Image(systemName: "hourglass")
            .font(.system(size: 16))
            .foregroundColor(.neonCyan)

          Text(countdownFormatted)
            .font(.system(size: 20, weight: .medium, design: .monospaced))
            .foregroundColor(.white)

          Spacer()

          Text(LocalizedStringKey("slow"))
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
              Capsule()
                .fill(Color.neonCyan.opacity(0.3))
                .overlay(Capsule().stroke(Color.neonCyan.opacity(0.5), lineWidth: 1))
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
          RoundedRectangle(cornerRadius: 24)
            .fill(Color.white.opacity(0.05))
            .overlay(
              RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        )
        .padding(.horizontal, 24)

        Text("ID: 884-SHK-FZ")
          .font(.system(size: 10, weight: .medium, design: .monospaced))
          .foregroundColor(.white.opacity(0.2))
          .padding(.top, 16)
          .padding(.bottom, 24)
      }
      .padding(.top, -20)
    }
    .background(
      ZStack {
        RoundedRectangle(cornerRadius: 32)
          .fill(.ultraThinMaterial)
        RoundedRectangle(cornerRadius: 32)
          .fill(Color.black.opacity(0.4))
        RoundedRectangle(cornerRadius: 32)
          .strokeBorder(
            LinearGradient(
              colors: [
                Color.neonCyan.opacity(0.5), .clear, .clear, Color.neonCyan.opacity(0.2),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1.5
          )
      }
    )
    .clipShape(RoundedRectangle(cornerRadius: 32))
    .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 10)
    .frame(maxWidth: 340)
  }

  private var outOfFizzTitle: some View {
    HStack(spacing: 0) {
      Text(LocalizedStringKey("out_of_fizz"))
        .font(.system(size: 32, weight: .bold))
        .foregroundColor(.white)
      Text(LocalizedStringKey("fizz_exclamation"))
        .font(.system(size: 32, weight: .black))
        .italic()
        .foregroundColor(.neonCyan)
        .shadow(color: .neonCyan.opacity(0.5), radius: 8)
    }
  }

  private var emptyCanIcon: some View {
    ZStack {
      Circle()
        .fill(Color.red.opacity(0.2))
        .frame(width: 140, height: 140)
        .blur(radius: 20)

      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(
            LinearGradient(
              colors: [.gray, .white, .gray],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .frame(width: 70, height: 100)
          .overlay(
            Rectangle()
              .fill(Color.black.opacity(0.2))
              .frame(height: 10)
              .offset(y: 20)
              .rotationEffect(.degrees(-5))
          )
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .rotationEffect(.degrees(-10))

        Circle()
          .fill(Color.red.opacity(0.4))
          .frame(width: 40, height: 40)
          .blur(radius: 10)
          .blendMode(.overlay)
      }
      .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
      .overlay(
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 30))
          .foregroundColor(.red.opacity(0.8))
          .offset(x: 20, y: -30)
      )
    }
    .overlay(
      Image(systemName: "cylinder.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 80, height: 100)
        .foregroundColor(.gray.opacity(0.5))
        .rotationEffect(.degrees(-15))
        .overlay(
          Image(systemName: "bolt.slash.fill")
            .font(.largeTitle)
            .foregroundColor(.red)
            .shadow(color: .red, radius: 10)
        )
    )
  }

  private var countdownFormatted: String {
    let m = countdownSeconds / 60
    let s = countdownSeconds % 60
    return String(format: "%02d:%02d", m, s)
  }

  private func startCountdown() {
    timer?.invalidate()
    countdownSeconds = 14 * 60 + 59
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
      if countdownSeconds > 0 {
        countdownSeconds -= 1
      } else {
        t.invalidate()
      }
    }
  }
}
