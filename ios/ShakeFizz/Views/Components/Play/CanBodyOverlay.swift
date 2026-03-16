import SwiftUI

struct CanBodyOverlay: View {
  var condensationAmount: Double = 0.3  // 0.0 to 1.0

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // First: Top and Bottom Rims (drawn underneath)
        VStack(spacing: 0) {
          // Top Rim with more depth
          ZStack {
            // Main rim body
            Rectangle()
              .fill(
                LinearGradient(
                  colors: [
                    Color(white: 0.7),
                    Color(white: 0.95),
                    Color(white: 0.5),
                    Color(white: 0.95),
                    Color(white: 0.7),
                  ],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )

            // Top edge highlight
            VStack(spacing: 0) {
              Rectangle()
                .fill(Color.white.opacity(0.6))
                .frame(height: 2)
              Spacer()
            }

            // Bottom edge shadow
            VStack(spacing: 0) {
              Spacer()
              Rectangle()
                .fill(Color.black.opacity(0.4))
                .frame(height: 1)
            }
          }
          .frame(height: 18)
          .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

          Spacer()

          // Bottom Rim with more depth
          ZStack {
            // Main rim body
            Rectangle()
              .fill(
                LinearGradient(
                  colors: [
                    Color(white: 0.6),
                    Color(white: 0.85),
                    Color(white: 0.45),
                    Color(white: 0.85),
                    Color(white: 0.6),
                  ],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )

            // Top edge highlight
            VStack(spacing: 0) {
              Rectangle()
                .fill(Color.white.opacity(0.5))
                .frame(height: 2)
              Spacer()
            }

            // Bottom edge shadow
            VStack(spacing: 0) {
              Spacer()
              Rectangle()
                .fill(Color.black.opacity(0.5))
                .frame(height: 2)
            }
          }
          .frame(height: 24)
          .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: -2)
        }

        // Second: Condensation Effect (before side walls)
        if condensationAmount > 0 {
          ZStack {
            // Overall frost
            Color.white
              .opacity(0.03 * condensationAmount)
              .blendMode(.overlay)

            // Gradient from top to bottom (more condensation at bottom)
            LinearGradient(
              colors: [
                .clear,
                .white.opacity(0.05 * condensationAmount),
                .white.opacity(0.12 * condensationAmount),
              ],
              startPoint: .top,
              endPoint: .bottom
            )
            .blendMode(.overlay)
          }
        }

        // 3. Metallic Frame with Rounded Corners (The Can Body)
        // Uses a reverse mask to cut out a rounded window from the metallic surface
        ZStack {
          // Full screen metallic surface
          Rectangle()
            .fill(
              LinearGradient(
                colors: [
                  Color(white: 0.6),
                  Color(white: 0.85),
                  Color(white: 0.5),  // Darker middle for cylinder effect
                  Color(white: 0.85),
                  Color(white: 0.6),
                ],
                startPoint: .leading,
                endPoint: .trailing
              )
            )

          // Inner shadow for depth
          Rectangle()
            .fill(Color.black.opacity(0.4))
            .mask(
              RoundedRectangle(cornerRadius: 24)
                .stroke(lineWidth: 4)
                .padding(12)  // Slightly smaller than cut out to show shadow
            )
        }
        .mask(
          // The "Cutout" logic: Full screen opaque minus the window
          ZStack {
            Rectangle().fill(Color.white)  // Opaque everywhere

            // The Window (Transparent part)
            RoundedRectangle(cornerRadius: 24)
              .fill(Color.black)  // This part becomes transparent in mask(using: .luminance) logic if inverted,
              // but standard mask uses opacity.
              // To cut a hole, we use .inverseMask or composite.
              // SwiftUI doesn't have direct "reverseMask", so we use blendMode.destinationOut
              .padding(12)  // Margin for the rim thickness
              .blendMode(.destinationOut)
          }
          .compositingGroup()  // Necessary for blendMode to work on just this layer
        )
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)

        // 4. Extra gloss on the metal frame
        ZStack {
          // Top highlight
          VStack {
            LinearGradient(
              colors: [.white.opacity(0.6), .clear],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: 1)
            Spacer()
          }
          .padding(12)

          // Bottom shadow
          VStack {
            Spacer()
            LinearGradient(
              colors: [.clear, .black.opacity(0.4)],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: 2)
          }
          .padding(12)
        }
        .mask(
          ZStack {
            Rectangle().fill(Color.clear)
            RoundedRectangle(cornerRadius: 24)
              .stroke(lineWidth: 12)  // Only show on the rim
              .padding(6)
          }
        )
      }
      .ignoresSafeArea()
      .allowsHitTesting(false)
    }
  }
}

struct CanBodyOverlay_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.blue
      CanBodyOverlay(condensationAmount: 1.0)
    }
  }
}
