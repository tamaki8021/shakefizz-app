import SwiftUI

struct ResultView: View {
  @ObservedObject var viewModel: GameViewModel
  @AppStorage("bestScore") private var bestScore: Double = 0.0
  @State private var showTier1 = false
  @State private var showTier2 = false
  @State private var showTier3 = false

  var body: some View {
    ZStack {
      BackgroundView()

      VStack(spacing: 0) {
        // Top Bar
        HStack {
          Button(action: { viewModel.resetGame() }) {
            Image(systemName: "xmark")
              .font(.title3)
              .foregroundColor(.white)
              .padding(10)
              .background(Circle().fill(Color.white.opacity(0.1)))
          }

          Spacer()

          VStack(spacing: 2) {
            Text("MISSION COMPLETE")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(.neonCyan)
            Text("SHAKEN!")
              .font(.system(size: 14, weight: .black))
              .foregroundColor(.white)
          }

          Spacer()
        }
        .padding()

        if let session = viewModel.currentSession {
          ScrollView {
            VStack(spacing: 30) {
              // Tier 1: Rank and Score Section (最初に表示)
              if showTier1 {
                VStack(spacing: 15) {
                  // Rank Badge (角丸の長方形、光るピンク/紫の枠)
                  RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: session.rank.colorHex).opacity(0.1))
                    .frame(width: 200, height: 120)
                    .overlay(
                      RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: session.rank.colorHex), lineWidth: 4)
                        .shadow(color: Color(hex: session.rank.colorHex), radius: 20)
                    )
                    .overlay(
                      Text(session.rank.rawValue)
                        .font(.system(size: 72, weight: .black))
                        .foregroundColor(.white)
                    )
                    .padding(.top, 20)

                  // Score
                  VStack(spacing: 8) {
                    if session.score <= 0.0 {
                      // 低スコア時の対応
                      VStack(spacing: 4) {
                        Text("—")
                          .font(.system(size: 80, weight: .black))
                          .foregroundColor(.gray)
                        Text("もっと振ってみよう！")
                          .font(.system(size: 16, weight: .bold))
                          .foregroundColor(.neonCyan)
                      }
                    } else {
                      HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", session.score))
                          .font(.system(size: 80, weight: .black))
                          .foregroundColor(.white)
                        Text("m")
                          .font(.system(size: 24, weight: .black))
                          .foregroundColor(.neonCyan)
                      }
                      .shadow(color: .neonCyan.opacity(0.3), radius: 10)
                    }
                  }
                }
                .transition(.scale.combined(with: .opacity))
              }

              // Tier 2: NEW RECORD Badge (条件付き表示)
              if showTier2 && session.isPersonalBest && session.score > 0.0 {
                VStack(spacing: 4) {
                  HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                      .foregroundColor(.green)
                    Text("NEW PERSONAL RECORD")
                      .font(.system(size: 12, weight: .bold))
                      .foregroundColor(.white)
                  }
                  .padding(.horizontal, 16)
                  .padding(.vertical, 8)
                  .background(
                    RoundedRectangle(cornerRadius: 12)
                      .stroke(Color.neonCyan, lineWidth: 2)
                      .background(Color.neonCyan.opacity(0.1))
                  )
                  .cornerRadius(12)
                  
                  if bestScore > 0 {
                    Text("Best: \(String(format: "%.1f", bestScore))m")
                      .font(.system(size: 10))
                      .foregroundColor(.gray)
                  }
                }
                .transition(.scale.combined(with: .opacity))
              }

              // Tier 3: Stats Cards (高スコア時 or 2回目以降に表示)
              if showTier3 && session.score > 0.0 {
                HStack(spacing: 15) {
                  ResultStatCard(
                    title: "TOP SPEED", value: "42", unit: "km/h", icon: "bolt.fill",
                    color: .neonCyan)
                  ResultStatCard(
                    title: "TOTAL SHAKES", value: "\(session.totalShakes)", unit: "times",
                    icon: "drop.fill", color: .neonCyan)
                }
                .padding(.horizontal)
                .transition(.opacity)
              }

              // Tier 3: Action Buttons
              if showTier3 {
                VStack(spacing: 15) {
                  NeonButton(title: "TRY AGAIN", color: .neonCyan, icon: "arrow.clockwise") {
                    viewModel.retryGame()
                  }

                  Button(action: { viewModel.resetGame() }) {
                    HStack {
                      Image(systemName: "bottle.fill")
                      Image(systemName: "wineglass.fill")
                      Text("CHANGE DRINK")
                        .font(.system(size: 16, weight: .black))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                  }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .transition(.opacity)
              }
            }
          }
        } else {
          Spacer()
          Text("NO MISSION DATA")
            .font(.headline)
            .foregroundColor(.gray)
          Spacer()
        }
      }
      .onAppear {
        // 段階的表示アニメーション
        withAnimation(.easeInOut(duration: 0.5)) {
          showTier1 = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          withAnimation(.easeInOut(duration: 0.5)) {
            showTier2 = true
          }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          withAnimation(.easeInOut(duration: 0.5)) {
            showTier3 = true
          }
        }
      }
    }
  }
}

struct ResultStatCard: View {
  let title: String
  let value: String
  let unit: String
  let icon: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: icon)
          .font(.system(size: 12))
          .foregroundColor(color)
        Text(title)
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(.gray)
      }

      HStack(alignment: .lastTextBaseline, spacing: 4) {
        Text(value)
          .font(.system(size: 28, weight: .black, design: .monospaced))
          .foregroundColor(.white)
        Text(unit)
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(.gray)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(Color.white.opacity(0.05))
    .cornerRadius(16)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(color.opacity(0.3), lineWidth: 1)
    )
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
