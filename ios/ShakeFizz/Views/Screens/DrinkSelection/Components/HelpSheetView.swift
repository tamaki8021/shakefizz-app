import SwiftUI

enum HelpStep {
  case choose, shake, compete
}

struct RankingItem: Identifiable, Equatable {
  let id = UUID()
  var rank: Int
  let name: String
  let score: String
  let isMe: Bool
}

struct HelpSheetView: View {
  @Environment(\.dismiss) var dismiss
  @State private var selectedStep: HelpStep = .choose
  @State private var shakeOffset: CGFloat = 0
  @State private var lineOpacity: Double = 0.3
  @State private var chooseAnim: Bool = false
  @State private var showRankList: Bool = false
  @State private var scoreScan: CGFloat = -1.0
  @State private var animatedScore: Double = 0.0
  @State private var showCrown: Bool = false
  @State private var rankListOffset: CGFloat = -110
  @State private var shakeRotation: Double = 0
  @State private var chooseSlide: CGFloat = 400
  @State private var showCheckmark: Bool = false
  private let initialRankings: [RankingItem] = [
    RankingItem(rank: 1, name: "SHAKE_KING", score: "15.2m", isMe: false),
    RankingItem(rank: 2, name: "FIZZ_MASTER", score: "14.8m", isMe: false),
    RankingItem(rank: 4, name: "BUBBLE_PRO", score: "13.5m", isMe: false),
    RankingItem(rank: 5, name: "FOAM_FAN", score: "13.2m", isMe: false),
    RankingItem(rank: 10, name: "YOU", score: "12.4m", isMe: true)
  ]

  @State private var rankings: [RankingItem] = []

  init() {
    _rankings = State(initialValue: [
      RankingItem(rank: 1, name: "SHAKE_KING", score: "15.2m", isMe: false),
      RankingItem(rank: 2, name: "FIZZ_MASTER", score: "14.8m", isMe: false),
      RankingItem(rank: 4, name: "BUBBLE_PRO", score: "13.5m", isMe: false),
      RankingItem(rank: 5, name: "FOAM_FAN", score: "13.2m", isMe: false),
      RankingItem(rank: 10, name: "YOU", score: "12.4m", isMe: true)
    ])
  }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      // Background decorative glow
      RadialGradient(
        gradient: Gradient(colors: [Color.neonCyan.opacity(0.15), .clear]),
        center: .center,
        startRadius: 0,
        endRadius: 300
      )
      .ignoresSafeArea()

      GeometryReader { geometry in
        let h = geometry.size.height

        VStack(spacing: 0) {
          // 1. Header Area (15%)
          VStack(spacing: 4) {
            Text("HOW TO PLAY")
              .font(.system(size: 32, weight: .black))
              .foregroundColor(.neonCyan)
              .shadow(color: .neonCyan.opacity(0.8), radius: 10)
              .tracking(2)

            Text("Shake your phone like a soda can!")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(.white.opacity(0.5))
          }
          .frame(height: h * 0.15)
          .frame(maxWidth: .infinity)

          // 2. Main Area (55%)
          ZStack {
            switch selectedStep {
            case .choose:
              chooseIllustration
            case .shake:
              shakeIllustration
            case .compete:
              competeIllustration
            }
          }
          .frame(height: h * 0.55)
          .id(selectedStep) // 切り替え時にアニメーションをリセットするため

          // 3. Bottom Step Area (25%)
          HStack(spacing: 12) {
            HelpStepCard(
              // icon: "square.grid.2x2.fill",
              icon: "hand.tap.fill",
              title: "CHOOSE",
              color: .neonCyan,
              isSelected: selectedStep == .choose
            ) { selectedStep = .choose }

            HelpStepCard(
              icon: "bolt.fill",
              title: "SHAKE HARD",
              color: .neonCyan,
              isSelected: selectedStep == .shake
            ) { selectedStep = .shake }

            HelpStepCard(
              icon: "trophy.fill",
              title: "COMPETE",
              color: .neonCyan,
              isSelected: selectedStep == .compete
            ) { selectedStep = .compete }
          }
          .padding(.horizontal, 16)
          .frame(height: h * 0.25)

          Spacer()
        }
      }

      // Close Button
      VStack {
        HStack {
          Spacer()
          Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 28))
              .foregroundColor(.white.opacity(0.5))
              .padding(20)
          }
        }
        Spacer()
      }
    }
  }

  // --- Illustrations ---

  private var chooseIllustration: some View {
    ZStack {
      HStack(spacing: 30) {
        // Diversified cans
        SodaCanView(color: .purple, width: 40, height: 80).opacity(0.3).scaleEffect(0.8)
        SodaCanView(color: .neonCyan, width: 40, height: 80).opacity(0.4).scaleEffect(0.8)
        
        // Target Can (Red)
        ZStack {
          SodaCanView(color: .red, width: 80, height: 160, isSelected: true)
            .scaleEffect(chooseAnim ? 1.05 : 1.0)

          if showCheckmark {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 32))
              .foregroundColor(.neonCyan)
              .shadow(color: .neonCyan, radius: 10)
              .offset(y: 45)
              .transition(.scale.combined(with: .opacity))
          }
        }

        SodaCanView(color: .green, width: 40, height: 80).opacity(0.4).scaleEffect(0.8)
        SodaCanView(color: .neonYellow, width: 40, height: 80).opacity(0.3).scaleEffect(0.8)
      }
      .offset(x: chooseSlide)
    }
    .onAppear {
      // 1. Reset state
      chooseSlide = 500
      showCheckmark = false
      chooseAnim = false
      
      // 2. Multi-phase overshoot animation
      // Phase 1: Slide far left
      withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
        chooseSlide = -80
      }
      
      // Phase 2: Bounce back to the right
      withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.8)) {
        chooseSlide = 40
      }
      
      // Phase 3: Settle at center
      withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(1.3)) {
        chooseSlide = 0
      }
      
      // 3. Show highlight/checkmark after all movement stops
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
        withAnimation(.spring()) {
          showCheckmark = true
        }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
          chooseAnim = true
        }
      }
    }
  }

  private var shakeIllustration: some View {
    ZStack {
      // Speed Lines (Dynamic diagonal lines)
      ForEach(0..<8) { i in
        Capsule()
          .fill(Color.neonCyan.opacity(lineOpacity))
          .frame(width: 60, height: 4)
          .rotationEffect(.degrees(-35))
          .offset(
            x: CGFloat((i % 4) * 80 - 120),
            y: CGFloat((i / 4) * 160 - 80)
          )
      }

      // Simplified Phone Container (No external hand)
      ZStack {
        // Phone
        ZStack {
          RoundedRectangle(cornerRadius: 24)
            .stroke(Color.neonCyan, lineWidth: 3)
            .frame(width: 120, height: 220)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.black))
            .shadow(color: .neonCyan.opacity(0.6), radius: 20)

          VStack(spacing: 12) {
            Image(systemName: "hand.raised.fill")
              .font(.system(size: 60))
              .foregroundColor(.neonCyan)
              .blur(radius: lineOpacity > 0.5 ? 1 : 0)
            
            Text("SHAKE!")
              .font(.system(size: 20, weight: .black))
              .foregroundColor(.white)
              .italic()
          }
        }
        .rotationEffect(.degrees(-15)) // Tilted phone
      }
      .rotationEffect(.degrees(shakeRotation))
      .offset(x: shakeOffset * 0.8, y: -shakeOffset) // Complex arc motion
    }
    .onAppear {
      // 1. Reset state to initial values
      shakeRotation = 0
      shakeOffset = 0
      lineOpacity = 0.3
      
      // 2. Start animations
      // Fast shake animation
      withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
        shakeRotation = 15
        shakeOffset = 20
      }
      // Speed lines pulse
      withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
        lineOpacity = 0.8
      }
    }
  }

  private var competeIllustration: some View {
    VStack(spacing: 20) {
      // Top: Animated Score Visual
      VStack(spacing: 4) {
        if showCrown {
          Image(systemName: "crown.fill")
            .font(.system(size: 30))
            .foregroundColor(.neonYellow)
            .shadow(color: .neonYellow.opacity(0.8), radius: 10)
            .transition(.asymmetric(
              insertion: .scale(scale: 0.1).combined(with: .offset(y: -20)).combined(with: .opacity),
              removal: .opacity
            ))
            .padding(.bottom, 2)
        }

        Text("YOUR SCORE")
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(.neonCyan)
          .tracking(2)
          .opacity(showRankList ? 1 : 0)

        HStack(alignment: .lastTextBaseline, spacing: 4) {
          Text("")
            .modifier(ScoreCountingModifier(number: animatedScore))
            .font(.system(size: 64, weight: .black))
            .foregroundColor(.white)
            .italic()
            .shadow(color: .neonCyan.opacity(0.5 + (animatedScore / 25.0)), radius: 10 + (animatedScore / 2.0))
          Text("m")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.neonCyan)
        }
        .scaleEffect(showRankList ? (1.0 + sin(animatedScore * .pi / 6) * 0.05) : 0.8)
        .opacity(showRankList ? 1 : 0)
        .overlay(
          // Scanning light effect
          Rectangle()
            .fill(
              LinearGradient(
                gradient: Gradient(colors: [.clear, .white.opacity(0.4), .clear]),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(width: 60)
            .rotationEffect(.degrees(25))
            .offset(x: scoreScan * 200)
            .mask(
              Text("")
                .modifier(ScoreCountingModifier(number: animatedScore, suffix: " m"))
                .font(.system(size: 64, weight: .black))
                .italic()
            )
        )
      }
      .padding(.top, 20)

      // Bottom: Scrolling Ranking List
      VStack(spacing: 0) {
        VStack(spacing: 8) {
          ForEach(rankings) { item in
            rankingRow(item: item)
          }
        }
        .padding(16)
        .offset(y: rankListOffset)
      }
      .frame(height: 140)
      .clipped()
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(Color.white.opacity(0.05))
          .background(
            BlurView(style: .systemUltraThinMaterialDark)
              .cornerRadius(20)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .stroke(
                LinearGradient(
                  colors: [.white.opacity(0.2), .clear, .white.opacity(0.05)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: 1
              )
          )
      )
      .padding(.horizontal, 24)
      .offset(y: showRankList ? 0 : 300)
      .opacity(showRankList ? 1 : 0)
    }
    .onAppear {
      // 1. Reset all states for replay
      showRankList = false
      animatedScore = 0.0
      scoreScan = -1.0
      showCrown = false
      rankListOffset = -110
      rankings = initialRankings
      
      // 2. Start animations sequence
      withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
        showRankList = true
      }
      
      // Counter Animation: 0 to 12.48
      withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
        animatedScore = 12.48
      }
      
      withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
        scoreScan = 1.0
      }
      
      // Crown pop-in after count-up
      withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(1.9)) {
        showCrown = true
      }
      
      // Rank list scroll-up after crown
      withAnimation(.easeInOut(duration: 2.0).delay(2.2)) {
        rankListOffset = 0
      }
      
      // Rank-Up Action: #10 -> #3
      DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
        // Ensure we are still on the compete step before executing
        if selectedStep == .compete {
          withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            // Replace rank 10 with rank 3 and reorder
            if let meIndex = rankings.firstIndex(where: { $0.isMe }) {
              var newRankings = rankings
              var me = newRankings.remove(at: meIndex)
              me.rank = 3
              newRankings.insert(me, at: 2) // Insert at 3rd position
              rankings = newRankings
            }
          }
        }
      }
    }
  }

  private func rankingRow(item: RankingItem) -> some View {
    HStack {
      Text("#\(item.rank)")
        .font(.system(size: 14, weight: .black))
        .foregroundColor(item.isMe ? .neonCyan : .white.opacity(0.5))
        .frame(width: 45, alignment: .leading)

      Text(item.name)
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(item.isMe ? .white : .white.opacity(0.8))

      Spacer()

      Text(item.score)
        .font(.system(size: 14, weight: .black))
        .foregroundColor(item.isMe ? .neonCyan : .white)
    }
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .background(item.isMe ? Color.neonCyan.opacity(0.1) : Color.clear)
    .cornerRadius(8)
  }
}

// Helper for Glassmorphism
struct BlurView: UIViewRepresentable {
  var style: UIBlurEffect.Style
  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: UIBlurEffect(style: style))
  }
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Animated Score Counting Modifier
struct ScoreCountingModifier: AnimatableModifier {
  var number: Double
  var suffix: String = ""

  var animatableData: Double {
    get { number }
    set { number = newValue }
  }

  func body(content: Content) -> some View {
    Text(String(format: "%.2f", number) + suffix)
  }
}

struct SodaCanView: View {
  let color: Color
  let width: CGFloat
  let height: CGFloat
  var isSelected: Bool = false

  var body: some View {
    VStack(spacing: 0) {
      // Top Rim
      RoundedRectangle(cornerRadius: 2)
        .fill(LinearGradient(
          gradient: Gradient(colors: [.white.opacity(0.6), .white.opacity(0.3), .white.opacity(0.5)]),
          startPoint: .leading, endPoint: .trailing
        ))
        .frame(width: width * 0.8, height: height * 0.04)

      // Top Neck
      RoundedRectangle(cornerRadius: 4)
        .fill(color.opacity(0.8))
        .frame(width: width * 0.85, height: height * 0.05)

      // Body
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [
                color.opacity(0.7),
                color,
                color.opacity(0.8),
                color.opacity(0.5)
              ]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(isSelected ? color : .clear, lineWidth: 2)
          )

        // Gloss effect
        Rectangle()
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [.clear, .white.opacity(0.2), .clear]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .frame(width: width * 0.2)
          .offset(x: -width * 0.15)
      }
      .frame(width: width, height: height * 0.82)

      // Bottom Rim
      RoundedRectangle(cornerRadius: 2)
        .fill(LinearGradient(
          gradient: Gradient(colors: [.white.opacity(0.4), .white.opacity(0.1), .white.opacity(0.3)]),
          startPoint: .leading, endPoint: .trailing
        ))
        .frame(width: width * 0.85, height: height * 0.04)
    }
    .shadow(color: isSelected ? color.opacity(0.5) : .clear, radius: 15)
  }
}

struct HelpStepCard: View {
  let icon: String
  let title: String
  let color: Color
  var isSelected: Bool = false
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      ZStack {
        RoundedRectangle(cornerRadius: 15)
          .fill(isSelected ? color.opacity(0.15) : Color.white.opacity(0.05))
          .overlay(
            RoundedRectangle(cornerRadius: 15)
              .stroke(isSelected ? color : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
          )
          .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 10)

        VStack(spacing: 8) {
          Image(systemName: icon)
            .font(.system(size: isSelected ? 28 : 22))
            .foregroundColor(isSelected ? color : .white.opacity(0.4))

          Text(title)
            .font(.system(size: 10, weight: .black))
            .foregroundColor(isSelected ? color : .white.opacity(0.4))
            .multilineTextAlignment(.center)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: isSelected ? 100 : 80)
      .scaleEffect(isSelected ? 1.05 : 1.0)
      .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isSelected)
    }
  }
}

#Preview {
  HelpSheetView()
}
