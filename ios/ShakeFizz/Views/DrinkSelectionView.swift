import SwiftUI

struct DrinkSelectionView: View {
  @ObservedObject var viewModel: GameViewModel
  @State private var showLockedModal: Bool = false
  @State private var showSettings: Bool = false
  @State private var showHelp: Bool = false
  @State private var showOutOfFizzModal: Bool = false
  @State private var lockedDrinkType: DrinkType?

  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  private var canStart: Bool {
    viewModel.selectedDrink != nil && viewModel.fizzRemaining > 0
  }

  var body: some View {
    bodyWithSheets
      .overlay { outOfFizzOverlay }
  }

  @ViewBuilder
  private var bodyWithSheets: some View {
    mainZStack
      .sheet(isPresented: $showLockedModal) {
        LockedDrinkModal(drinkType: lockedDrinkType)
      }
      .sheet(isPresented: $showSettings) {
        SettingsView()
      }
      .sheet(isPresented: $showHelp) {
        HelpSheetView()
      }
  }

  @ViewBuilder
  private var outOfFizzOverlay: some View {
    if showOutOfFizzModal {
      OutOfFizzModalView(
        onDismiss: { showOutOfFizzModal = false },
        onWatchAd: {
          viewModel.refillFizz(amount: 5)
          showOutOfFizzModal = false
        }
      )
    }
  }

  private var mainZStack: some View {
    ZStack {
      BackgroundView()
      VStack(spacing: 0) {
        topBarView
        EventBannerView()
          .padding(.horizontal, 16)
          .padding(.top, 12)
        drinkGridScrollView
        bottomButtonArea
      }
    }
  }

  private var topBarView: some View {
    HStack(spacing: 12) {
      fizzMeterPanel
      Spacer()
      profileHUDPanel
    }
    .padding(.horizontal, 16)
    .padding(.top, 10)
  }

  private var fizzMeterPanel: some View {
    HStack(spacing: 8) {
      VStack(alignment: .leading, spacing: 4) {
        Text("FIZZ METER")
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(.neonCyan)
        // .foregroundColor(.white.opacity(0.9))
        HStack(spacing: 4) {
          ForEach(0..<5, id: \.self) { index in
            Image(systemName: index < viewModel.fizzRemaining ? "bolt.fill" : "bolt")
              .font(.system(size: 14))
              .foregroundColor(index < viewModel.fizzRemaining ? .neonCyan : .white.opacity(0.3))
          }
          refillButton
        }
      }
    }
    .padding(.horizontal, 4)  // パディングを少し減らす
    .padding(.vertical, 4)
  }

  private var refillButton: some View {
    Button(action: {
      let impactFeedback = UIImpactFeedbackGenerator(style: .light)
      impactFeedback.impactOccurred()
      if viewModel.fizzRemaining < 5 {
        showOutOfFizzModal = true
      }
    }) {
      Image(systemName: "plus.circle.fill")
        .font(.system(size: 22))
        .foregroundColor(Color.neonCyan.opacity(0.9))
        .overlay(Circle().stroke(Color.neonCyan, lineWidth: 1))
    }
  }

  private var profileHUDPanel: some View {
    HStack(spacing: 8) {
      Button(action: { showSettings = true }) {
        Image(systemName: "person.crop.circle.fill")
          .font(.system(size: 24))
          .foregroundColor(.white.opacity(0.8))
      }

      HStack(spacing: 4) {
        Image(systemName: "crown.fill")
          .font(.system(size: 12))
          .foregroundColor(.neonYellow)
        Text("\(viewModel.currency)")
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(.white)
          .monospacedDigit()
          .fixedSize()
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(Capsule().fill(Color.white.opacity(0.1)))

      Button(action: { showHelp = true }) {
        Image(systemName: "questionmark.circle.fill")
          .font(.system(size: 20))
          .foregroundColor(.white.opacity(0.8))
          .padding(6)
      }
    }
    .padding(.horizontal, 4)  // パディングを少し減らす
    .padding(.vertical, 4)
  }

  private var drinkGridScrollView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        LazyVGrid(columns: columns, spacing: 24) {
          ForEach(DrinkType.allCases) { drinkType in
            DrinkCard(
              type: drinkType,
              isSelected: viewModel.selectedDrink == drinkType,
              rankNumber: viewModel.rankNumber(for: drinkType),
              bestMeters: viewModel.bestMeters(for: drinkType)
            )
            .onTapGesture {
              let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
              impactFeedback.impactOccurred()
              if drinkType.isLocked {
                lockedDrinkType = drinkType
                showLockedModal = true
              } else {
                viewModel.selectDrink(drinkType)
              }
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        Spacer(minLength: 120)  // 少し減らす
      }
    }
  }

  @ViewBuilder
  private var bottomButtonArea: some View {
    VStack(spacing: 0) {
      LinearGradient(
        gradient: Gradient(colors: [.clear, .black.opacity(0.95)]),
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: 30)  // 高さを減らす
      bottomButtonStack
    }
  }

  @ViewBuilder
  private var bottomButtonStack: some View {
    VStack(spacing: 12) {
      if viewModel.fizzRemaining == 0 {
        Text("Out of Fizz — tap + to refill")
          .font(.system(size: 13, weight: .medium))
          .foregroundColor(.neonMagenta)
          .shadow(color: .neonMagenta.opacity(0.5), radius: 4)
      }
      startShakingButton
    }
    .padding(.top, 4)  // 上部パディングを減らす
    .background(Color.black.opacity(0.95))
  }

  private var startShakingButton: some View {
    Button(action: {
      if canStart {
        viewModel.proceedToWarning()
      } else if viewModel.fizzRemaining == 0 {
        showOutOfFizzModal = true
      }
    }) {
      HStack(spacing: 8) {
        Text(LocalizedStringKey("shake_now"))
          .font(.title3)
          .fontWeight(.black)
          .foregroundColor(.black)
        Image(systemName: "arrow.right")
          .font(.headline)
          .foregroundColor(.black)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 56)
      .background(Color.neonCyan)
      .cornerRadius(16)
      .shadow(color: Color.neonCyan.opacity(0.6), radius: 12, x: 0, y: 4)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.white.opacity(0.4), lineWidth: 1)
      )
    }
    .disabled(viewModel.selectedDrink == nil)
    .opacity(canStart ? 1.0 : 0.5)
    .padding(.horizontal, 24)
    .padding(.bottom, 16)  // 下部パディングを大幅に減らす (26 -> 34 -> 16くらいに調整)
  }
}

// MARK: - イベント告知バナー
struct EventBannerView: View {
  private let eventTitle = "LIME BURST FEVER!"
  private let eventEndsIn = "14h"
  private let rewardsTag = "2X REWARDS"

  var body: some View {
    eventBannerBackground
      .overlay(eventBannerContent)
      .frame(height: 84)
  }

  private var eventBannerBackground: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.ultraThinMaterial)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .fill(
            LinearGradient(
              colors: [Color.neonMagenta.opacity(0.4), Color.neonCyan.opacity(0.2)],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(
            LinearGradient(
              colors: [.white.opacity(0.3), .white.opacity(0.1)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1
          )
      )
      .shadow(color: .neonMagenta.opacity(0.2), radius: 10, x: 0, y: 4)
  }

  private var eventBannerContent: some View {
    HStack {
      eventBannerLeft
      eventBannerRewardsTag
    }
  }

  private var eventBannerLeft: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 6) {
        Text("LIVE NOW")
          .font(.system(size: 9, weight: .black))
          .foregroundColor(.neonMagenta)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Capsule().fill(Color.neonMagenta.opacity(0.3)))
        Image(systemName: "clock")
          .font(.system(size: 10))
          .foregroundColor(.white.opacity(0.8))
        Text("Ends in \(eventEndsIn)")
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(.white.opacity(0.9))
      }
      Text("WEEKLY EVENT:")
        .font(.system(size: 11, weight: .bold))
        .foregroundColor(.white.opacity(0.9))
      Text(eventTitle)
        .font(.system(size: 18, weight: .black))
        .foregroundColor(.white)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.leading, 14)
    .padding(.vertical, 12)
  }

  private var eventBannerRewardsTag: some View {
    HStack(spacing: 4) {
      Image(systemName: "flame.fill")
        .font(.system(size: 10))
      Text(rewardsTag)
        .font(.system(size: 11, weight: .black))
    }
    .foregroundColor(.orange)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(Capsule().fill(Color.orange.opacity(0.3)))
    .padding(.trailing, 14)
  }
}

// MARK: - ヘルプシート（? ボタン用）
struct HelpSheetView: View {
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text(
            "Shake your device during the countdown to build pressure. When time runs out, your spray height (m) is recorded. Compete on the leaderboard!"
          )
          .font(.body)
          .foregroundColor(.primary)
        }
        .padding()
      }
      .navigationTitle("How to Play")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
  }
}

// MARK: - 炭酸切れモーダル（広告視聴チャージ）
struct OutOfFizzModalView: View {
  let onDismiss: () -> Void
  let onWatchAd: () -> Void

  @State private var countdownSeconds: Int = 14 * 60 + 59  // 14:59 start as per design
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
      Color.black.opacity(0.6)  // Slightly darker for better contrast
        .ignoresSafeArea()
    }
  }

  private var outOfFizzModalCard: some View {
    VStack(spacing: 0) {
      // Close Button
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
        // 3D Can Icon (Placeholder for now, using Image or intricate shape)
        emptyCanIcon
          .padding(.bottom, 10)

        // Title
        outOfFizzTitle

        // Description
        Text("Your arms need a rest, or grab a\nquick refill to keep shaking!")
          .font(.system(size: 15))
          .foregroundColor(.white.opacity(0.7))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 16)
          .fixedSize(horizontal: false, vertical: true)

        // Watch Ad Button
        Button(action: onWatchAd) {
          ZStack {
            RoundedRectangle(cornerRadius: 30)
              .fill(Color.neonMagenta)
              .shadow(color: .neonMagenta.opacity(0.6), radius: 20, x: 0, y: 0)  // Glow effect

            HStack(spacing: 12) {
              Image(systemName: "play.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.9))

              VStack(alignment: .leading, spacing: 0) {
                Text("FREE REFILL")
                  .font(.system(size: 10, weight: .bold))
                  .foregroundColor(.white.opacity(0.8))
                Text("WATCH VIDEO")
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

        // Divider / Text
        Text("OR WAIT FOR RECHARGE")
          .font(.system(size: 11, weight: .bold))
          .foregroundColor(.white.opacity(0.3))
          .padding(.top, 10)

        // Timer Section
        HStack {
          Image(systemName: "hourglass")
            .font(.system(size: 16))
            .foregroundColor(.neonMagenta)

          Text(countdownFormatted)
            .font(.system(size: 20, weight: .medium, design: .monospaced))
            .foregroundColor(.white)

          Spacer()

          Text("SLOW")
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white)  // Text color on badge
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
              Capsule()
                .fill(Color.neonMagenta.opacity(0.3))  // Background for badge
                .overlay(Capsule().stroke(Color.neonMagenta.opacity(0.5), lineWidth: 1))
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

        // ID
        Text("ID: 884-SHK-FZ")
          .font(.system(size: 10, weight: .medium, design: .monospaced))
          .foregroundColor(.white.opacity(0.2))
          .padding(.top, 16)
          .padding(.bottom, 24)
      }
      .padding(.top, -20)  // Pull content up slightly
    }
    .background(
      ZStack {
        RoundedRectangle(cornerRadius: 32)
          .fill(.ultraThinMaterial)  // Glass effect
        RoundedRectangle(cornerRadius: 32)
          .fill(Color.black.opacity(0.4))
        RoundedRectangle(cornerRadius: 32)
          .strokeBorder(
            LinearGradient(
              colors: [
                Color.neonMagenta.opacity(0.5), .clear, .clear, Color.neonMagenta.opacity(0.2),
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
      Text("OUT OF ")
        .font(.system(size: 32, weight: .bold))  // Slightly larger
        .foregroundColor(.white)
      Text("FIZZ!")
        .font(.system(size: 32, weight: .black))  // Italic if possible, but system font italic weight black might be tricky. Using black for now.
        .italic()
        .foregroundColor(.neonMagenta)
        .shadow(color: .neonMagenta.opacity(0.5), radius: 8)
    }
  }

  private var emptyCanIcon: some View {
    // 3D-like Icon representation
    ZStack {
      // Background glow
      Circle()
        .fill(Color.red.opacity(0.2))
        .frame(width: 140, height: 140)
        .blur(radius: 20)

      // The "Can" - represented by a rotated, slightly distorted shape if we don't have an asset
      // For now, let's use a combination of shapes to mimic a crushed can or use a symbol
      // Since we don't have the exact asset, we'll try to make a stylized version

      Image(systemName: "trash.fill")  // Placeholder for "Crushed"? No, maybe just a can.
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 80, height: 100)
        .foregroundColor(.gray)
        .opacity(0.0)  // Hide this, building custom shape

      // Custom "Crushed Can" using raw shapes (Simplified)
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
              .rotationEffect(.degrees(-5))  // Dent
          )
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .rotationEffect(.degrees(-10))

        // Red glow inside
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
    // Note: In a real app, we would use the provided 3D image asset here.
    // Since I cannot upload images, I will stick to a symbolic representation
    // or keep the previous icon but styled better.
    // Let's use the previous logic but refined.
    .overlay(
      Image(systemName: "can")  // if available in SF Symbols, otherwise cylinder
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

// ロック缶モーダル
struct LockedDrinkModal: View {
  let drinkType: DrinkType?
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.black.opacity(0.8)
        .ignoresSafeArea()

      VStack(spacing: 24) {
        // 南京錠アイコン
        Image(systemName: "lock.fill")
          .font(.system(size: 60))
          .foregroundColor(.neonYellow)

        // タイトル
        Text(LocalizedStringKey("locked"))
          .font(.system(size: 32, weight: .black))
          .foregroundColor(.white)

        // メッセージ
        Text(LocalizedStringKey("locked_desc"))
          .font(.system(size: 16))
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)

        // OKボタン
        Button(action: {
          dismiss()
        }) {
          Text(LocalizedStringKey("ok"))
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .frame(width: 120)
            .padding()
            .background(Color.neonCyan)
            .cornerRadius(12)
        }
      }
      .padding(40)
      .background(Color.black.opacity(0.9))
      .cornerRadius(24)
      .padding(40)
    }
  }
}

// 脈動アニメーション付きのNeonButton
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

struct DrinkCard: View {
  let type: DrinkType
  let isSelected: Bool
  var rankNumber: Int?
  var bestMeters: Double?

  @State private var isPressed = false

  private var unlockRequirementText: String {
    switch type {
    case .beastFuel: return "Reach Top 50 in Cola League"
    case .gingerShock: return "Reach Top 10 in Beast Fuel"
    default: return ""
    }
  }

  private var unlockProgress: Double {
    switch type {
    case .beastFuel: return 0.64
    case .gingerShock: return 0.2
    default: return 0
    }
  }

  var body: some View {
    drinkCardContent
      .background(drinkCardOuterBackground)
      .overlay(drinkCardBorder)
      .shadow(
        color: isSelected ? Color.neonCyan.opacity(0.4) : Color.black.opacity(0.3),
        radius: isSelected ? 15 : 8,
        x: 0,
        y: isSelected ? 8 : 4
      )
      .scaleEffect(isPressed ? 0.97 : 1.0)
      .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
      .animation(.easeInOut(duration: 0.3), value: isSelected)
      .opacity(type.isLocked ? 0.6 : 1.0)
      .overlay(drinkCardLockedOverlay)
      .onLongPressGesture(
        minimumDuration: .infinity, maximumDistance: .infinity,
        pressing: { pressing in isPressed = pressing }, perform: {}
      )
  }

  private var drinkCardContent: some View {
    VStack(alignment: .leading, spacing: 0) {
      drinkCardImageSection
      drinkCardInfoSection
    }
  }

  private var drinkCardImageSection: some View {
    ZStack(alignment: .topTrailing) {
      RoundedRectangle(cornerRadius: 20)
        .fill(.ultraThinMaterial)
        .overlay(RoundedRectangle(cornerRadius: 20).fill(type.backgroundColor.opacity(0.1)))
        .frame(height: 190)

      Image(type.imageName)
        .resizable()
        .scaledToFit()
        .frame(height: 170)
        .shadow(
          color: isSelected ? type.backgroundColor.opacity(0.6) : .black.opacity(0.3),
          radius: isSelected ? 24 : 12,
          x: 0,
          y: isSelected ? 8 : 4
        )

      if isSelected {
        Text("ACTIVE")
          .font(.system(size: 10, weight: .heavy))
          .foregroundColor(.black)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(
            Capsule()
              .fill(Color.neonCyan)
              .shadow(color: .neonCyan.opacity(0.6), radius: 8)
          )
          .padding(14)
      }
    }
  }

  @ViewBuilder
  private var drinkCardInfoSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      if !type.isLocked {
        drinkCardRankBestRow
      } else {
        // ロック時も高さを確保するためのダミー
        Text(" ")
          .font(.system(size: 11, weight: .bold))
          .opacity(0)
      }

      Text(type.displayName)
        .font(.system(size: 18, weight: .black))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
        .minimumScaleFactor(0.8)

      if type.isLocked {
        drinkCardLockedInfo
      }
    }
    .padding(.horizontal, 16)
    .padding(.top, 14)
    .padding(.bottom, 20)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(Color.black.opacity(0.4))
    )
  }

  private var drinkCardRankBestRow: some View {
    HStack(spacing: 8) {
      Group {
        if let rank = rankNumber {
          Text("RANK #\(rank)")
            .foregroundColor(.neonCyan)
        } else {
          Text("RANK #—")
            .foregroundColor(.white.opacity(0.5))
        }

        if let best = bestMeters {
          Text("BEST \(String(format: "%.1f", best))m")
            .foregroundColor(.white.opacity(0.9))
        } else {
          Text("BEST —")
            .foregroundColor(.white.opacity(0.5))
        }
      }
      .font(.system(size: 10, weight: .bold))
    }
  }

  private var drinkCardLockedInfo: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 4) {
        Image(systemName: "lock.fill")
          .font(.system(size: 10))
          .foregroundColor(.neonYellow)
        Text("UNLOCK REQ.")
          .font(.system(size: 10, weight: .black))
          .foregroundColor(.neonYellow)
      }

      Text(unlockRequirementText)
        .font(.system(size: 10, weight: .semibold))
        .foregroundColor(.white.opacity(0.7))
        .lineLimit(1)
        .minimumScaleFactor(0.8)

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(Color.white.opacity(0.15))
            .frame(height: 4)
          Capsule()
            .fill(Color.neonYellow.opacity(0.9))
            .frame(width: geo.size.width * unlockProgress, height: 4)
            .shadow(color: .neonYellow.opacity(0.5), radius: 4)
        }
      }
      .frame(height: 4)
    }
  }

  private var drinkCardOuterBackground: some View {
    RoundedRectangle(cornerRadius: 24)
      .fill(Color.black.opacity(0.3))
  }

  private var drinkCardBorder: some View {
    RoundedRectangle(cornerRadius: 24)
      .strokeBorder(
        isSelected
          ? LinearGradient(
            colors: [Color.neonCyan, Color.neonCyan.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          : LinearGradient(
            colors: [Color.white.opacity(0.15), Color.white.opacity(0.02)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
        lineWidth: isSelected ? 2 : 1
      )
  }

  @ViewBuilder
  private var drinkCardLockedOverlay: some View {
    if type.isLocked {
      ZStack {
        RoundedRectangle(cornerRadius: 24)
          .fill(.ultraThinMaterial)
          .opacity(0.8)

        VStack(spacing: 8) {
          ZStack {
            Circle()
              .fill(Color.black.opacity(0.6))
              .frame(width: 50, height: 50)

            Image(systemName: "lock.fill")
              .font(.system(size: 24))
              .foregroundColor(.neonYellow)
              .shadow(color: .neonYellow.opacity(0.6), radius: 8)
          }

          Text("LOCKED")
            .font(.system(size: 12, weight: .heavy))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.black.opacity(0.7)))
            .overlay(
              Capsule()
                .stroke(Color.neonYellow.opacity(0.5), lineWidth: 1)
            )
        }
      }
    }
  }

  private var fizzColor: Color {
    switch type {
    case .ultraCola: return .neonCyan
    case .limeBurst: return .neonYellow
    case .beastFuel: return .neonMagenta
    case .gingerShock: return .gray
    }
  }
}
