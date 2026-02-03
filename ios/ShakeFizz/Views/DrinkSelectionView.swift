import SwiftUI

struct DrinkSelectionView: View {
  @ObservedObject var viewModel: GameViewModel
  @State private var showLockedModal: Bool = false
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
          Spacer()

          Text("SHAKE FIZZ")
            .font(.system(size: 18, weight: .black))
            .foregroundColor(.neonCyan)

          Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)

        ScrollView {
          VStack(alignment: .leading, spacing: 10) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
              Text("SELECT YOUR")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(.white)
              Text("ULTIMATE FIZZ")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(.neonCyan)

              Text("Choose your weapon. Higher carbonation means\nmore height, but less stability.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // Your Best Section
            YourBestView()
              .padding(.horizontal)
              .padding(.top, 20)
              .padding(.bottom, 10)

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

            Spacer(minLength: 100)
          }
        }

        // Floating Start Button Area
        VStack {
          PulsingNeonButton(
            title: "SHAKE NOW!",
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
      .sheet(isPresented: $showLockedModal) {
        LockedDrinkModal(drinkType: lockedDrinkType)
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
        Text("LOCKED")
          .font(.system(size: 32, weight: .black))
          .foregroundColor(.white)
        
        // メッセージ
        Text("Reach Rank S to unlock this drink")
          .font(.system(size: 16))
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)
        
        // OKボタン
        Button(action: {
          dismiss()
        }) {
          Text("OK")
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
  let color: Color
  let icon: String?
  let action: () -> Void
  
  @State private var isPulsing = false
  
  var body: some View {
    Button(action: action) {
      HStack {
        Text(title)
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(.black)
        
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

struct YourBestView: View {
  @AppStorage("bestScore") private var bestScore: Double = 0.0
  @AppStorage("bestRank") private var bestRank: String = ""
  @AppStorage("bestDrink") private var bestDrink: String = ""
  @AppStorage("bestDate") private var bestDate: String = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("YOUR BEST")
        .font(.system(size: 12, weight: .black))
        .foregroundColor(.neonCyan)

      if bestScore > 0 {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
          Text(String(format: "%.1f", bestScore))
            .font(.system(size: 48, weight: .black))
            .foregroundColor(.neonCyan)
          Text("m")
            .font(.system(size: 20, weight: .black))
            .foregroundColor(.neonCyan.opacity(0.7))
        }

        Text("\(bestRank) · \(bestDrink) · \(bestDate)")
          .font(.system(size: 12))
          .foregroundColor(.gray)
      } else {
        Text("START YOUR FIRST GAME!")
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(.gray)
          .padding(.vertical, 8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(Color.white.opacity(0.05))
    .cornerRadius(16)
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
          Text("READY!")
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.neonMagenta))
            .padding(8)
        }
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(type.displayName.uppercased())
          .font(.system(size: 16, weight: .black))
          .foregroundColor(.white)

        // FIZZ Stat Bar with Icons and Description
        VStack(alignment: .leading, spacing: 4) {
          // FIZZ label with percentage and icons in one line
          HStack(spacing: 4) {
            Text("FIZZ")
              .font(.system(size: 8, weight: .bold))
              .foregroundColor(.gray)
            
            Text("\(type.fizzPercent)%")
              .font(.system(size: 8, weight: .bold))
              .foregroundColor(.gray)
            
            // Icons for FIZZ meaning
            Image(systemName: "arrow.up")
              .font(.system(size: 8))
              .foregroundColor(.neonCyan)
            
            Text("高さ")
              .font(.system(size: 7))
              .foregroundColor(.gray.opacity(0.7))
            
            Image(systemName: "exclamationmark.triangle.fill")
              .font(.system(size: 8))
              .foregroundColor(.neonYellow)
            
            Text("不安定")
              .font(.system(size: 7))
              .foregroundColor(.gray.opacity(0.7))

            Spacer()
          }
        }

        GeometryReader { geo in
          ZStack(alignment: .leading) {
            Capsule()
              .fill(Color.gray.opacity(0.2))
              .frame(height: 4)

            Capsule()
              .fill(isSelected ? Color.neonCyan : Color.yellow)
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
        .stroke(isSelected ? Color.neonCyan : Color.gray.opacity(0.2), lineWidth: isSelected ? 3 : 2)
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
            Text("RANK 5")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(.white)
          }
        }
      }
    )
  }
}
