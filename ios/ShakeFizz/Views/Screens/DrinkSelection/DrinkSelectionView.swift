import SwiftUI

struct DrinkSelectionView: View {
  @ObservedObject var viewModel: GameViewModel
  @State private var showLockedModal: Bool = false
  @State private var showSettings: Bool = false
  @State private var showHelp: Bool = false
  @State private var showOutOfFizzModal: Bool = false
  @State private var showRankingSheet: Bool = false
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
      .sheet(isPresented: $showRankingSheet) {
        LeagueRankingView(currentRank: 42, currentScore: 85.5)  // Mock current rank/score for MVP
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
        // イベント告知バナー / Carousel
        BannerCarouselView()
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
        Text(LocalizedStringKey("fizz_meter"))
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
      // League Rank / Currency Button
      Button(action: { showRankingSheet = true }) {
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
      }

      Button(action: { showSettings = true }) {
        Image(systemName: "person.crop.circle.fill")
          .font(.system(size: 24))
          .foregroundColor(.white.opacity(0.8))
      }

      Button(action: { showHelp = true }) {
        Image(systemName: "questionmark.circle.fill")
          .font(.system(size: 20))
          .foregroundColor(.white.opacity(0.8))
          .padding(6)
      }
    }
    .padding(.horizontal, 4)
    .padding(.vertical, 4)
  }

  private var drinkGridScrollView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        LazyVGrid(columns: columns, spacing: 32) {  // 縦のスペースを広げてハミ出しに備える
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
      .frame(height: 20)  // 高さをさらに減らす (30 -> 20)
      bottomButtonStack
    }
  }

  @ViewBuilder
  private var bottomButtonStack: some View {
    VStack(spacing: 12) {
      if viewModel.fizzRemaining == 0 {
        Text(LocalizedStringKey("out_of_fizz_refill_prompt"))
          .font(.system(size: 13, weight: .medium))
          .foregroundColor(.neonMagenta)
          .shadow(color: .neonMagenta.opacity(0.5), radius: 4)
      }
      startShakingButton
    }
    .padding(.top, 0)  // 上部パディングをさらに減らす (4 -> 0)
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
    .padding(.bottom, 8)  // 下部パディングをさらに減らす (16 -> 8)
  }
}
