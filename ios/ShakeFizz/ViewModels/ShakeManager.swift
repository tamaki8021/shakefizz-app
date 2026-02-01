import Combine
import CoreMotion
import Foundation

class ShakeManager: ObservableObject {
  private let motionManager = CMMotionManager()
  private var timer: Timer?

  // Published properties for UI
  @Published var currentPressure: Double = 0.0
  @Published var projectedHeight: Double = 0.0
  @Published var isShaking: Bool = false
  @Published var shakeIntensity: Double = 0.0

  // Game constants
  private let shakeThreshold: Double = 1.2  // G-force threshold to count as shake
  private let pressureDecay: Double = 0.5  // Pressure lost per second when not shaking
  private let maxPressure: Double = 100.0

  // Drink modifiers
  var fizzModifier: Double = 1.0

  func startShaking() {
    currentPressure = 0.0
    projectedHeight = 0.0

    guard motionManager.isDeviceMotionAvailable else {
      print("Device Motion not available")
      return
    }

    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0  // 60 Hz
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
      guard let self = self, let data = data else { return }
      self.processMotionData(data)
    }
  }

  func stopShaking() {
    motionManager.stopDeviceMotionUpdates()
    timer?.invalidate()
    timer = nil
  }

  private func processMotionData(_ data: CMDeviceMotion) {
    let userAccel = data.userAcceleration
    let gravity = data.gravity

    // Calculate magnitude of user acceleration (removing gravity is handled by userAcceleration)
    let magnitude = sqrt(pow(userAccel.x, 2) + pow(userAccel.y, 2) + pow(userAccel.z, 2))

    DispatchQueue.main.async {
      self.shakeIntensity = magnitude

      if magnitude > 0.5 {
        self.isShaking = true
        // Add to pressure based on intensity
        let gain = magnitude * 0.1 * self.fizzModifier
        self.currentPressure = min(self.currentPressure + gain, self.maxPressure)
      } else {
        self.isShaking = false
        // Decay pressure slightly if not shaking hard? Or maybe just keep it?
        // For this game, maybe we don't decay to keep the "charge" feeling,
        // or decay slowly to encourage continuous shaking.
      }

      // Calculate height directly from pressure
      // Simplistic formula: Height (m) = Pressure * Constant
      self.projectedHeight = self.currentPressure * 0.5
    }
  }

  func reset() {
    stopShaking()
    currentPressure = 0.0
    projectedHeight = 0.0
    shakeIntensity = 0.0
  }
}
