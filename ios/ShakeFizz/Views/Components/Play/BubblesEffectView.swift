import SwiftUI

struct Bubble: Identifiable {
  let id = UUID()
  var x: Double
  var y: Double
  var scale: Double
  var opacity: Double
  var speed: Double
  var wobbleAmplitude: Double
  var wobbleFrequency: Double
  var phase: Double
}

struct BubblesEffectView: View {
  var density: Int = 30  // Number of bubbles roughly on screen
  var speedMultiplier: Double = 1.0
  var roll: Double = 0.0  // Tilt left/right affects x drift

  @State private var bubbles: [Bubble] = []

  // Use a fixed random generator for consistent initial state if needed,
  // but for bubbles, pure randomness is fine.

  var body: some View {
    TimelineView(.animation) { timeline in
      Canvas { context, size in
        let time = timeline.date.timeIntervalSinceReferenceDate

        // Update bubbles (logic inside drawing for simplicity in this context,
        // ideally logic should be separate but SwiftUI Canvas allows this for visual effects)

        // Drift based on roll (gravity effect)
        // If phone tilts right (positive roll), bubbles drift left (up relative to gravity)
        // Actually, if phone tilts right, "up" is towards the left side of the screen?
        // Let's assume standard portrait:
        // Roll > 0 (tilted right) -> Bubbles should drift left to stay "up"?
        // Wait, if I tilt right, the left side is higher. Bubbles go up. So they drift left.
        // Let's approximate: xDrift = -roll * speed
        let xDrift = -roll * 100.0 * speedMultiplier  // Drift strength

        for index in bubbles.indices {
          var bubble = bubbles[index]

          // Move up
          bubble.y -= bubble.speed * speedMultiplier

          // Horizontal wobble + drift
          let wobble = sin(time * bubble.wobbleFrequency + bubble.phase) * bubble.wobbleAmplitude
          let currentX = bubble.x + wobble + (xDrift * 0.05)  // Apply drift slowly

          // Wrap around or respawn
          if bubble.y < -50 {
            // Respawn at bottom
            bubble.y = size.height + Double.random(in: 0...50)
            bubble.x = Double.random(in: 0...size.width)
            bubble.opacity = 0.0  // Fade in
          } else {
            // Fade in logic
            if bubble.opacity < 0.7 {
              bubble.opacity += 0.02
            }
          }

          // Handle X wrapping (particles staying in can)
          // For a can, maybe they just dissolve if they hit the side?
          // Or we just clamp/wrap. Let's wrap roughly.
          var finalX = currentX
          if finalX < 0 { finalX += size.width }
          if finalX > size.width { finalX -= size.width }

          // Update local state (Hack: we can't update @State inside Canvas easily without external state manager)
          // In Canvas, we are drawing immediately.
          // To make this persistent, we need a separate update loop or use the 'time' to calculate position deterministically.

          // Deterministic approach:
          // Position = InitialY - (Speed * Time) % Height
          // This is better for Canvas performance and correctness.

          let adjustedTime = time + bubble.phase  // Use phase as offset
          let loopDuration = size.height / bubble.speed
          let progress = (adjustedTime.truncatingRemainder(dividingBy: loopDuration)) / loopDuration

          let yPos = size.height - (progress * (size.height + 100))
          let xBase = bubble.x
          let xWobble = sin(adjustedTime * bubble.wobbleFrequency) * bubble.wobbleAmplitude
          // Cumulative drift over time is hard with modulo.
          // Let's just apply instant drift offset based on current roll, visualizing "force" rather than accumulated displacement
          let xPos = xBase + xWobble + (xDrift * 0.2)

          // Draw
          let rect = CGRect(
            x: xPos - (bubble.scale * 10) / 2,
            y: yPos - (bubble.scale * 10) / 2,
            width: bubble.scale * 10,
            height: bubble.scale * 10
          )

          context.opacity = bubble.opacity
          // context.fill(Circle().path(in: rect), with: .color(.white.opacity(0.6)))

          // Draw a circle with a gradient to look like a bubble
          // Simple white circle with low opacity center and higher opacity rim?
          // Or just a white circle is fine for small bubbles.
          context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.4)))
          // Highlight
          let highlightRect = CGRect(
            x: rect.minX + rect.width * 0.2,
            y: rect.minY + rect.height * 0.2,
            width: rect.width * 0.25,
            height: rect.width * 0.25
          )
          context.fill(Path(ellipseIn: highlightRect), with: .color(.white.opacity(0.9)))
        }
      }
    }
    .onAppear {
      // Initialize bubbles
      // Since we switched to deterministic drawing, we just need constant properties
      bubbles = (0..<density).map { _ in
        Bubble(
          x: Double.random(in: 0...400),  // Assuming reasonable width, will wrap in logic if needed or just be offscreen
          y: 0,  // Not used in deterministic
          scale: Double.random(in: 0.5...1.5),
          opacity: Double.random(in: 0.3...0.8),
          speed: Double.random(in: 50...150),
          wobbleAmplitude: Double.random(in: 2...10),
          wobbleFrequency: Double.random(in: 1...3),
          phase: Double.random(in: 0...100)
        )
      }
    }
  }
}

struct BubblesEffectView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.blue
      BubblesEffectView()
    }
  }
}
