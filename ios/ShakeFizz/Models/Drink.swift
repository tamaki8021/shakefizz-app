import Foundation
import SwiftUI

enum DrinkType: String, Codable, CaseIterable, Identifiable {
  case ultraCola = "ultra_cola"
  case limeBurst = "lime_burst"
  case beastFuel = "beast_fuel"
  case gingerShock = "ginger_shock"
  case midnightMocha = "midnight_mocha"
  case tropicalBlast = "tropical_blast"
  case electricBerry = "electric_berry"

  var id: String { rawValue }

  var displayName: LocalizedStringKey {
    switch self {
    case .ultraCola: return LocalizedStringKey("ultra_cola")
    case .limeBurst: return LocalizedStringKey("lime_burst")
    case .beastFuel: return LocalizedStringKey("beast_fuel")
    case .gingerShock: return LocalizedStringKey("ginger_shock")
    case .midnightMocha: return LocalizedStringKey("midnight_mocha")
    case .tropicalBlast: return LocalizedStringKey("tropical_blast")
    case .electricBerry: return LocalizedStringKey("electric_berry")
    }
  }

  var imageName: String {
    switch self {
    case .ultraCola: return "ultra_cola_can"
    case .limeBurst: return "lime_burst_can"
    case .beastFuel: return "beast_fuel_can"
    case .gingerShock: return "ginger_shock_can"
    case .midnightMocha: return "midnight_mocha_can"
    case .tropicalBlast: return "tropical_blast_can"
    case .electricBerry: return "electric_berry_can"
    }
  }

  var fizzPercent: Int {
    switch self {
    case .ultraCola: return 85
    case .limeBurst: return 70
    case .beastFuel: return 95
    case .gingerShock: return 95
    case .midnightMocha: return 80
    case .tropicalBlast: return 90
    case .electricBerry: return 92
    }
  }

  var isLocked: Bool {
    switch self {
    case .midnightMocha: return true
    case .tropicalBlast: return true
    case .electricBerry: return true
    default: return false
    }
  }

  var backgroundColor: Color {
    switch self {
    case .ultraCola:
      return Color(red: 0.071, green: 0.008, blue: 0.027)  // Near Black Cola #120207
    case .limeBurst:
      return Color(red: 0.008, green: 0.071, blue: 0.008)  // Deep Lime Black #021202
    case .beastFuel:
      return Color(red: 0.008, green: 0.016, blue: 0.071)  // Deep Blue Black #020412
    case .gingerShock:
      return Color(red: 0.098, green: 0.071, blue: 0.043)  // Brightened Mocha Black #19120B
    case .midnightMocha:
      return Color(red: 0.055, green: 0.040, blue: 0.025)  // Deep Dark Mocha #0E0A06
    case .tropicalBlast:
      return Color(red: 0.16, green: 0.18, blue: 0.02)  // Deep Yellow Black
    case .electricBerry:
      return Color(red: 0.051, green: 0.031, blue: 0.071)  // Deep Berry Black #0D0812
    }
  }

  /// UIアクセント用の鮮やかなカラー（スコアグロー、炭酸カラム、バッジ等で使用）
  var accentColor: Color {
    switch self {
    case .ultraCola: return Color(red: 0.95, green: 0.10, blue: 0.15)
    case .limeBurst: return Color(red: 0.28, green: 0.95, blue: 0.28)
    case .beastFuel: return Color(red: 0.08, green: 0.62, blue: 0.96)
    case .gingerShock: return Color(red: 1.00, green: 0.50, blue: 0.00)  // Neon Orange
    case .midnightMocha: return Color(red: 0.88, green: 0.75, blue: 0.60)  // Brighter Mocha Bronze
    case .tropicalBlast: return Color(red: 1.00, green: 0.85, blue: 0.00)  // Tropical Yellow/Gold
    case .electricBerry: return Color(red: 1.00, green: 0.00, blue: 0.56)
    }
  }

  /// リーグで使用するアイコン
  var leagueIcon: String {
    switch self {
    case .ultraCola: return "crown.fill"
    case .limeBurst: return "leaf.fill"
    case .beastFuel: return "bolt.fill"
    case .gingerShock: return "flame.fill"
    case .midnightMocha: return "moon.stars.fill"
    case .tropicalBlast: return "sun.max.fill"
    case .electricBerry: return "sparkles"
    }
  }

  /// リーグ表示名
  var leagueName: LocalizedStringKey {
    switch self {
    case .ultraCola: return LocalizedStringKey("league_ultra_cola")
    case .limeBurst: return LocalizedStringKey("league_lime_burst")
    case .beastFuel: return LocalizedStringKey("league_beast_fuel")
    case .gingerShock: return LocalizedStringKey("league_ginger_shock")
    case .midnightMocha: return LocalizedStringKey("league_midnight_mocha")
    case .tropicalBlast: return LocalizedStringKey("league_tropical_blast")
    case .electricBerry: return LocalizedStringKey("league_electric_berry")
    }
  }

}

struct Drink: Identifiable {
  let type: DrinkType
  var id: String { type.id }
}
