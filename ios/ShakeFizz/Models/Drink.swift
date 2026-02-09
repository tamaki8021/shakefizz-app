import Foundation
import SwiftUI

enum DrinkType: String, Codable, CaseIterable, Identifiable {
  case ultraCola = "ultra_cola"
  case limeBurst = "lime_burst"
  case beastFuel = "beast_fuel"
  case gingerShock = "ginger_shock"

  var id: String { rawValue }

  var displayName: LocalizedStringKey {
    switch self {
    case .ultraCola: return LocalizedStringKey("ultra_cola")
    case .limeBurst: return LocalizedStringKey("lime_burst")
    case .beastFuel: return LocalizedStringKey("beast_fuel")
    case .gingerShock: return LocalizedStringKey("ginger_shock")
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
    case .beastFuel: return 95
    case .gingerShock: return 95
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
