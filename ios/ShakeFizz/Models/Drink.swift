import Foundation
import SwiftUI

enum DrinkType: String, Codable, CaseIterable, Identifiable {
  case ultraCola = "ultra_cola"
  case limeBurst = "lime_burst"
  case beastFuel = "beast_fuel"
  case gingerShock = "ginger_shock"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .ultraCola: return NSLocalizedString("ultra_cola", comment: "Drink Name")
    case .limeBurst: return NSLocalizedString("lime_burst", comment: "Drink Name")
    case .beastFuel: return NSLocalizedString("beast_fuel", comment: "Drink Name")
    case .gingerShock: return NSLocalizedString("ginger_shock", comment: "Drink Name")
    }
  }

  var imageName: String {
    switch self {
    case .ultraCola: return "ultra_cola_can"
    case .limeBurst: return "lime_burst_can"
    case .beastFuel: return "beast_fuel_can"  // Not yet generated
    case .gingerShock: return "ginger_shock_can"  // Not yet generated
    }
  }

  var fizzPercent: Int {
    switch self {
    case .ultraCola: return 85
    case .limeBurst: return 70
    case .beastFuel: return 60
    case .gingerShock: return 95
    }
  }

  var speedPercent: Int {
    switch self {
    case .ultraCola: return 60
    case .limeBurst: return 92
    case .beastFuel: return 80
    case .gingerShock: return 50
    }
  }

  var powerPercent: Int {
    switch self {
    case .ultraCola: return 70
    case .limeBurst: return 60
    case .beastFuel: return 98
    case .gingerShock: return 90
    }
  }

  var isLocked: Bool {
    switch self {
    case .gingerShock: return true
    default: return false
    }
  }

  var backgroundColor: Color {
    switch self {
    case .ultraCola:
      return Color(red: 0.18, green: 0.09, blue: 0.06)  // Dark brown #2D1810
    case .limeBurst:
      return Color(red: 0.20, green: 0.80, blue: 0.20)  // Lime green #32CD32
    case .beastFuel:
      return Color(red: 0.04, green: 0.09, blue: 0.16)  // Deep blue #0A1628
    case .gingerShock:
      return Color(red: 0.55, green: 0.27, blue: 0.07)  // Saddle brown #8B4513
    }
  }
}

struct Drink: Identifiable {
  let type: DrinkType
  var id: String { type.id }
}
