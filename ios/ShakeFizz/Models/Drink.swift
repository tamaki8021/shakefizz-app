import Foundation

enum DrinkType: String, Codable, CaseIterable, Identifiable {
  case ultraCola = "ultra_cola"
  case limeBurst = "lime_burst"
  case beastFuel = "beast_fuel"
  case gingerShock = "ginger_shock"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .ultraCola: return "ULTRA COLA"
    case .limeBurst: return "LIME BURST"
    case .beastFuel: return "BEAST FUEL"
    case .gingerShock: return "GINGER SHOCK"
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
}

struct Drink: Identifiable {
  let type: DrinkType
  var id: String { type.id }
}
