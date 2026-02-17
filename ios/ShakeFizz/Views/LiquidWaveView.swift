import SwiftUI

struct LiquidWaveView: View {
  var color: Color
  var roll: Double  // Device roll (tilt left/right)
  var pitch: Double  // Device pitch (tilt forward/back)
  var agitation: Double  // 0.0 to 1.0 (from shake intensity)

  var body: some View {
    TimelineView(.animation) { timeline in
      Canvas { context, size in
        let time = timeline.date.timeIntervalSinceReferenceDate

        // Normalize agitation (0.0 to 1.5) to useful visual parameters
        // Cap visual agitation to avoid breaking the view
        let safeAgitation = min(agitation, 2.0)

        let waveHeightBase = size.height * 0.05
        let waveHeightDynamic = size.height * 0.15 * safeAgitation
        let totalWaveHeight = waveHeightBase + waveHeightDynamic

        // Faster movement when agitated
        let phase = time * (2.0 + safeAgitation * 15.0)

        // Center point for rotation
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        // ---------------------------------------------------------
        // Rotated Context (Liquid stays horizontal)
        // ---------------------------------------------------------
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: .radians(roll))
        context.translateBy(x: -center.x, y: -center.y)

        // Helper to draw a wave layer
        func drawWave(
          offsetY: CGFloat, opacity: Double, phaseShift: Double, heightMult: Double, color: Color
        ) {
          let path = Path { path in
            path.move(to: CGPoint(x: -size.width, y: size.height))

            let startX = -size.width
            let endX = size.width * 2
            let step = 10.0

            for x in stride(from: startX, to: endX, by: step) {
              let relativeX = x / size.width

              // Complex wave function
              let term1 = sin(Double(relativeX) * 4.0 * .pi + phase + phaseShift)
              let term2 = cos(Double(relativeX) * 3.0 * .pi + phase * 1.5)

              let y = CGFloat(term1 + term2) * totalWaveHeight * heightMult

              // Base level varies slightly by layer
              let baseLevel = size.height * 0.15 + offsetY

              path.addLine(to: CGPoint(x: x, y: baseLevel + y))
            }

            path.addLine(to: CGPoint(x: endX, y: size.height * 2))
            path.addLine(to: CGPoint(x: -size.width, y: size.height * 2))
            path.closeSubpath()
          }
          context.fill(path, with: .color(color.opacity(opacity)))
        }

        // Layer 1: Back/Darker wave
        drawWave(
          offsetY: 10, opacity: 0.6, phaseShift: 0, heightMult: 0.8, color: color.opacity(0.8))

        // Layer 2: Main Body
        drawWave(offsetY: 0, opacity: 1.0, phaseShift: 2.0, heightMult: 1.0, color: color)

        // Layer 3: Gloss/Highlight (The "Sparkle")
        // Drawn with blending mode for neon effect
        var glossContext = context
        glossContext.blendMode = .screen

        let glossPath = Path { path in
          let startX = -size.width
          let endX = size.width * 2
          let step = 10.0

          // Only draw the top line of the wave for gloss
          path.move(to: CGPoint(x: startX, y: size.height * 0.15))

          for x in stride(from: startX, to: endX, by: step) {
            let relativeX = x / size.width
            let term1 = sin(Double(relativeX) * 4.0 * .pi + phase + 2.0)
            let term2 = cos(Double(relativeX) * 3.0 * .pi + phase * 1.5)
            let y = CGFloat(term1 + term2) * totalWaveHeight
            let baseLevel = size.height * 0.15

            path.addLine(to: CGPoint(x: x, y: baseLevel + y))
          }
          // Close locally to create a "cap" slightly below
          for x in stride(from: endX, to: startX, by: -step) {
            let relativeX = x / size.width
            let term1 = sin(Double(relativeX) * 4.0 * .pi + phase + 2.0)
            let term2 = cos(Double(relativeX) * 3.0 * .pi + phase * 1.5)
            let y = CGFloat(term1 + term2) * totalWaveHeight
            let baseLevel = size.height * 0.15 + 15  // Gloss thickness

            path.addLine(to: CGPoint(x: x, y: baseLevel + y))
          }
          path.closeSubpath()
        }

        glossContext.fill(glossPath, with: .color(.white.opacity(0.4 + (safeAgitation * 0.4))))

      }
    }
  }
}

// Preview to test logic without CoreMotion
struct LiquidWaveView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      LiquidWaveView(
        color: .neonCyan,
        roll: 0.2,  // Slight tilt
        pitch: 0.0,
        agitation: 0.5  // Modreate shake
      )
    }
  }
}
