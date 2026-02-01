import SwiftUI

struct DrinkSelectionView: View {
  @ObservedObject var viewModel: GameViewModel

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    ZStack {
      BackgroundView()

      VStack(spacing: 20) {
        // Header
        Text("SELECT YOUR\nULTIMATE FIZZ")
          .font(.system(size: 32, weight: .heavy, design: .default))
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
          .shadow(color: .neonCyan, radius: 2)

        // Grid
        LazyVGrid(columns: columns, spacing: 20) {
          ForEach(DrinkType.allCases) { drinkType in
            DrinkCard(type: drinkType, isSelected: viewModel.selectedDrink == drinkType)
              .onTapGesture {
                viewModel.selectDrink(drinkType)
              }
          }
        }
        .padding()

        Spacer()

        // Stats (Simplified for MVP)
        if let selected = viewModel.selectedDrink {
          HStack {
            VStack {
              Text("FIZZ")
                .font(.caption)
                .foregroundColor(.gray)
              Text("\(selected.fizzPercent)%")
                .font(.title3)
                .foregroundColor(.neonCyan)
            }
            Spacer()
            VStack {
              Text("POWER")
                .font(.caption)
                .foregroundColor(.gray)
              Text("\(selected.powerPercent)%")
                .font(.title3)
                .foregroundColor(.neonMagenta)
            }
          }
          .padding(.horizontal, 40)
        }

        // Start Button
        NeonButton(
          title: "START SHAKING",
          color: viewModel.selectedDrink != nil ? .neonCyan : .gray,
          icon: "bolt.fill"
        ) {
          viewModel.proceedToWarning()
        }
        .disabled(viewModel.selectedDrink == nil)
        .padding(.horizontal)
        .padding(.bottom, 20)
      }
    }
  }
}

struct DrinkCard: View {
  let type: DrinkType
  let isSelected: Bool

  var body: some View {
    VStack {
      // Placeholder for Can Image
      Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(height: 100)
        .overlay(Text("CAN").foregroundColor(.gray))

      Text(type.displayName)
        .font(.headline)
        .foregroundColor(isSelected ? .neonCyan : .white)

      if type.isLocked {
        Image(systemName: "lock.fill")
          .foregroundColor(.gray)
      }
    }
    .padding()
    .background(Color.cardBackground)
    .cornerRadius(16)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(isSelected ? Color.neonCyan : Color.clear, lineWidth: 3)
    )
    .shadow(color: isSelected ? .neonCyan.opacity(0.5) : .clear, radius: 10)
  }
}
