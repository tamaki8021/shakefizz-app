import SwiftUI

struct PlayScreenView: View {
  @ObservedObject var viewModel: GameViewModel
  @ObservedObject var shakeManager: ShakeManager
  @StateObject private var particleSystem = ParticleSystem()
  @State private var showExitConfirmation = false

  init(viewModel: GameViewModel) {
    self.viewModel = viewModel
    self.shakeManager = viewModel.shakeManager
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Background color based on drink type
        if let drink = viewModel.selectedDrink {
          drink.backgroundColor
            .ignoresSafeArea()
        }

        // Bubble particles
        ForEach(particleSystem.particles) { particle in
          Circle()
            .fill(Color.white.opacity(particle.opacity))
            .frame(width: particle.size, height: particle.size)
            .position(particle.position)
        }

        // UI Elements
        VStack(spacing: 0) {
          // Top Bar
          HStack {
            Button(action: {
              showExitConfirmation = true
            }) {
              Image(systemName: "xmark")
                .font(.title3)
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(Color.black.opacity(0.3)))
            }

            Spacer()

            (Text(LocalizedStringKey("flavor_prefix"))
              + Text(viewModel.selectedDrink?.displayName ?? "UNKNOWN"))
              .font(.system(size: 14, weight: .black))
              .foregroundColor(.white)
              .textCase(.uppercase)

            Spacer()
          }
          .padding()

          Spacer()

          // Bottom Timer and Action Buttons
          VStack(spacing: 20) {
            // Timer Display with Enhanced Feedback
            if !viewModel.isTimeUp && !viewModel.isCountingDown {
              VStack(spacing: 8) {
                // Circular Progress Bar
                ZStack {
                  Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)

                  Circle()
                    .trim(from: 0, to: CGFloat(viewModel.gameTimeRemaining / 15.0))
                    .stroke(
                      timerColor(for: viewModel.gameTimeRemaining),
                      style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: viewModel.gameTimeRemaining)

                  Text(
                    String(
                      format: "%02d:%02d",
                      Int(viewModel.gameTimeRemaining) / 60,
                      Int(viewModel.gameTimeRemaining) % 60)
                  )
                  .font(.system(size: 12, weight: .black, design: .monospaced))
                  .foregroundColor(timerColor(for: viewModel.gameTimeRemaining))
                }
              }
            }

            // Action Buttons
            if !viewModel.isTimeUp && !viewModel.isCountingDown {
              // TAP TO BUILD PRESSURE Button
              Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                viewModel.performTapAction()
              }) {
                HStack {
                  Text(LocalizedStringKey("tap_to_build"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                  Image(systemName: "hand.tap.fill")
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(white: 0.15, opacity: 0.8))
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.neonCyan, lineWidth: 2)
                )
              }
              .disabled(viewModel.isCountingDown)
            }
          }
          .padding(.horizontal)
          .padding(.bottom, 30)
        }

        // TIME UP Overlay
        if viewModel.isTimeUp {
          ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            Text(LocalizedStringKey("time_up"))
              .font(.system(size: 72, weight: .black))
              .foregroundColor(.white)
              .italic()
              .shadow(color: .neonCyan, radius: 20)

            VStack {
              Spacer()
              NeonButton(
                title: NSLocalizedString("view_results", comment: ""), color: .neonCyan,
                icon: "arrow.right"
              ) {
                viewModel.finishTyringToPop()
              }
              .padding(.horizontal)
              .padding(.bottom, 60)
            }
          }
          .zIndex(90)
        }

        // Countdown Overlay
        if viewModel.isCountingDown {
          ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()

            if viewModel.countdownValue > 0 {
              Text("\(viewModel.countdownValue)")
                .font(.system(size: 144, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .neonCyan, radius: 20)
                .id(viewModel.countdownValue)
                .transition(.scale.combined(with: .opacity))
            } else {
              Text(LocalizedStringKey("go"))
                .font(.system(size: 144, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .neonCyan, radius: 20)
                .transition(.scale.combined(with: .opacity))
            }
          }
          .zIndex(100)
        }
      }
      .onAppear {
        particleSystem.start(screenSize: geometry.size) { [weak shakeManager] in
          shakeManager?.shakeIntensity ?? 0.0
        }
      }
      .onDisappear {
        particleSystem.stop()
      }
      .alert(NSLocalizedString("alert_title", comment: ""), isPresented: $showExitConfirmation) {
        Button(LocalizedStringKey("alert_continue"), role: .cancel) {
          showExitConfirmation = false
        }
        Button(LocalizedStringKey("alert_cancel"), role: .destructive) {
          viewModel.resetGame()
        }
      } message: {
        Text(LocalizedStringKey("alert_message"))
      }
      .onChange(of: viewModel.gameTimeRemaining) { newValue in
        // 残り3秒でハプティクスと視覚的フィードバック
        if newValue <= 3.0 && newValue > 2.9 {
          let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
          impactFeedback.impactOccurred()
        }
      }
    }
  }

  // タイマーの色を残り時間に応じて変更
  private func timerColor(for remaining: Double) -> Color {
    if remaining <= 3.0 {
      return .red
    } else if remaining <= 5.0 {
      return .yellow
    } else {
      return .white
    }
  }
}

struct BadgeView: View {
  let text: String
  let color: Color
  var icon: String? = "circle.fill"

  var body: some View {
    HStack(spacing: 6) {
      if let icon = icon {
        Image(systemName: icon)
          .font(.system(size: 8))
      }
      Text(text)
        .font(.system(size: 10, weight: .bold))
    }
    .foregroundColor(color)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(
      Capsule()
        .stroke(color, lineWidth: 1)
        .background(color.opacity(0.1))
    )
    .clipShape(Capsule())
  }
}
