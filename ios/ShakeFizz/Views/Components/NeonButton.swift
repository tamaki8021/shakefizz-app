import SwiftUI

struct NeonButton: View {
  let title: String
  let color: Color
  let icon: String?
  let action: () -> Void

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
      .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 0)
    }
  }
}
