import SwiftUI

struct LockedDrinkModal: View {
  let drinkType: DrinkType?
  @Environment(\.dismiss) var dismiss

  var body: some View {
    ZStack {
      Color.black.opacity(0.8)
        .ignoresSafeArea()

      VStack(spacing: 24) {
        Image(systemName: "lock.fill")
          .font(.system(size: 60))
          .foregroundColor(.neonYellow)

        Text(LocalizedStringKey("locked"))
          .font(.system(size: 32, weight: .black))
          .foregroundColor(.white)

        Text(LocalizedStringKey("locked_desc"))
          .font(.system(size: 16))
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)

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
