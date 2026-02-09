import SwiftUI

struct DrinkSelectionView: View {
  @ObservedObject var viewModel: GameViewModel
  @State private var showLockedModal: Bool = false
  @State private var showSettings: Bool = false
  @State private var lockedDrinkType: DrinkType?

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    ZStack {
      BackgroundView()

      VStack(spacing: 0) {
        // Top Navigation Bar
        HStack {
          Button(action: {
            showSettings = true
          }) {
            Image(systemName: "gearshape.fill")
              .font(.title2)
              .foregroundColor(.white)
              .padding(8)
              .background(Circle().fill(Color.white.opacity(0.1)))
          }

          Spacer()

          Text("SHAKE FIZZ")
            .font(.system(size: 18, weight: .black))
            .foregroundColor(.neonCyan)

          Spacer()

          // Spacer explicitly for balance
          Spacer()
            .frame(width: 44)
        }
        .padding(.horizontal)
        .padding(.top, 10)

        ScrollView {
          VStack(alignment: .leading, spacing: 10) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
              Text(LocalizedStringKey("select_title"))
                .font(.system(size: 36, weight: .black))
                .foregroundColor(.white)  // "ULTIMATE FIZZ" part color needs logic if we want to keep it Cyan.
              // Since "select_title" combines both, we might just color it all white or keep it simple.
              // Let's stick to simple localization first.

              Text(LocalizedStringKey("select_subtitle"))
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // Grid
            LazyVGrid(columns: columns, spacing: 16) {
              ForEach(DrinkType.allCases) { drinkType in
                DrinkCard(type: drinkType, isSelected: viewModel.selectedDrink == drinkType)
                  .onTapGesture {
                    // ハプティクスフィードバック
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()

                    // ロック缶の場合はモーダルを表示
                    if drinkType.isLocked {
                      lockedDrinkType = drinkType
                      showLockedModal = true
                    } else {
                      viewModel.selectDrink(drinkType)
                    }
                  }
              }
            }
            .padding()

            Spacer(minLength: 120)  // Increased padding for button overlap
          }
        }

        // Floating Start Button Area
        VStack {
          PulsingNeonButton(
            title: "shake_now",
            localized: true,
            color: viewModel.selectedDrink != nil ? .neonCyan : .gray,
            icon: "bolt.fill"
          ) {
            viewModel.proceedToWarning()
          }
          .disabled(viewModel.selectedDrink == nil)
          .padding(.horizontal)
          .padding(.bottom, 30)
          .background(
            LinearGradient(
              gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top,
              endPoint: .bottom)
          )
        }
      }
    }
    .sheet(isPresented: $showLockedModal) {
      LockedDrinkModal(drinkType: lockedDrinkType)
    }
    .sheet(isPresented: $showSettings) {
      SettingsView()
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

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      ZStack(alignment: .topTrailing) {
        // Can Image
        Image(type.imageName)
          .resizable()
          .scaledToFit()
          .frame(height: 140)
          .padding(.vertical, 10)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color.white.opacity(0.05))
          )

        if isSelected {
          Text(LocalizedStringKey("ready"))
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.neonCyan))
            .padding(8)
        }
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(type.displayName)
          .font(.system(size: 16, weight: .black))
          .foregroundColor(.white)

        // FIZZ Stat Bar with Icons and Description
        VStack(alignment: .leading, spacing: 4) {
          // FIZZ label with percentage and icons in one line
          HStack(spacing: 4) {
            Text(LocalizedStringKey("fizz_label"))
              .font(.system(size: 8, weight: .bold))
              .foregroundColor(.gray)

            Text("\(type.fizzPercent)%")
              .font(.system(size: 8, weight: .bold))
              .foregroundColor(.gray)

            // Icons for FIZZ meaning
            Image(systemName: "arrow.up")
              .font(.system(size: 8))
              .foregroundColor(.neonCyan)

            Text(LocalizedStringKey("height_label"))
              .font(.system(size: 9))
              .foregroundColor(.gray.opacity(0.9))

            Image(systemName: "exclamationmark.triangle.fill")
              .font(.system(size: 10))
              .foregroundColor(.neonYellow)

            Text(LocalizedStringKey("stability_label"))
              .font(.system(size: 9))
              .foregroundColor(.gray.opacity(0.9))

            Spacer()
          }
        }

        GeometryReader { geo in
          ZStack(alignment: .leading) {
            Capsule()
              .fill(Color.gray.opacity(0.2))
              .frame(height: 4)

            Capsule()
              .fill(fizzColor)
              .frame(width: geo.size.width * CGFloat(type.fizzPercent) / 100.0, height: 4)
          }
        }
        .frame(height: 4)
      }
    }
    .padding(12)
    .background(Color.black.opacity(0.3))
    .cornerRadius(20)
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(
          isSelected ? Color.neonCyan : Color.gray.opacity(0.2), lineWidth: isSelected ? 3 : 2
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    )
    .shadow(color: isSelected ? .neonCyan.opacity(0.3) : .clear, radius: 10)
    .opacity(type.isLocked ? 0.5 : 1.0)
    .overlay(
      Group {
        if type.isLocked {
          VStack {
            Image(systemName: "lock.fill")
              .font(.title2)
              .foregroundColor(.white)
            Text(LocalizedStringKey("rank_5"))
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(.white)
          }
        }
      }
    )
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
