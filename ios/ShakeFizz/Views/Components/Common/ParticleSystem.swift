import SwiftUI

struct BubbleParticle: Identifiable {
  let id = UUID()
  var position: CGPoint
  var size: CGFloat
  var opacity: Double
  var velocity: CGFloat
  var wobbleOffset: CGFloat = 0
}

class ParticleSystem: ObservableObject {
  @Published var particles: [BubbleParticle] = []
  private var timer: Timer?
  private let maxParticles = 150

  func start(screenSize: CGSize, shakeIntensity: @escaping () -> Double) {
    timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
      guard let self = self else { return }

      let intensity = shakeIntensity()
      let particleCount = self.particleCount(for: intensity)

      // Generate new particles
      for _ in 0..<particleCount {
        if self.particles.count < self.maxParticles {
          self.particles.append(self.createParticle(screenSize: screenSize))
        }
      }

      // Update existing particles
      self.updateParticles(screenSize: screenSize)
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
    particles.removeAll()
  }

  private func particleCount(for intensity: Double) -> Int {
    switch intensity {
    case 0..<0.3:
      return Int.random(in: 0...1)  // weak: 5-10/sec → 0-1 per 0.05s
    case 0.3..<0.6:
      return Int.random(in: 1...2)  // normal: 15-30/sec → 1-2 per 0.05s
    case 0.6..<0.8:
      return Int.random(in: 2...3)  // strong: 40-60/sec → 2-3 per 0.05s
    default:
      return Int.random(in: 4...6)  // super: 80-120/sec → 4-6 per 0.05s
    }
  }

  private func createParticle(screenSize: CGSize) -> BubbleParticle {
    BubbleParticle(
      position: CGPoint(
        x: CGFloat.random(in: 50...(screenSize.width - 50)),
        y: screenSize.height + 20
      ),
      size: CGFloat.random(in: 4...12),
      opacity: Double.random(in: 0.6...1.0),
      velocity: CGFloat.random(in: 50...300)
    )
  }

  private func updateParticles(screenSize: CGSize) {
    for i in particles.indices.reversed() {
      particles[i].position.y -= particles[i].velocity * 0.05

      // Wobble effect (sin wave)
      particles[i].wobbleOffset = sin(particles[i].position.y * 0.05) * 10
      particles[i].position.x += particles[i].wobbleOffset * 0.1

      // Remove particles that left the screen
      if particles[i].position.y < -20 {
        particles.remove(at: i)
      }
    }
  }
}
