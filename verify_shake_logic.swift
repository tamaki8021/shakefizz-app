import Foundation

// Mock Data
struct UserAccel {
  let x: Double
  let y: Double
  let z: Double
}

class ShakeSimulator {
  var currentPressure: Double = 0.0
  var projectedHeight: Double = 0.0
  var fizzModifier: Double = 1.0
  let maxPressure: Double = 100.0

  func tick(accel: UserAccel) {
    let magnitude = sqrt(pow(accel.x, 2) + pow(accel.y, 2) + pow(accel.z, 2))

    if magnitude > 0.5 {
      let gain = magnitude * 0.1 * fizzModifier
      currentPressure = min(currentPressure + gain, maxPressure)
    }

    projectedHeight = currentPressure * 0.5
  }
}

// Scenario 1: Hard Shake (2.0g) for 5 seconds
let sim1 = ShakeSimulator()
print("Scenario 1: Hard Shake (2.0g) for 5 seconds")
for i in 1...300 {  // 60fps * 5s
  sim1.tick(accel: UserAccel(x: 2.0, y: 0, z: 0))
  if i % 60 == 0 {
    print(
      "T=\(i/60)s: Height \(String(format: "%.2f", sim1.projectedHeight))m (Pressure: \(String(format: "%.2f", sim1.currentPressure)))"
    )
  }
}

print("\n")

// Scenario 2: Weak Shake (0.6g) for 5 seconds
let sim2 = ShakeSimulator()
print("Scenario 2: Weak Shake (0.6g) for 5 seconds")
for i in 1...300 {
  sim2.tick(accel: UserAccel(x: 0.6, y: 0, z: 0))
  if i % 60 == 0 {
    print(
      "T=\(i/60)s: Height \(String(format: "%.2f", sim2.projectedHeight))m (Pressure: \(String(format: "%.2f", sim2.currentPressure)))"
    )
  }
}
