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
    case .beastFuel: return true
    default: return false
    }
  }

  var backgroundColor: Color {
    switch self {
    case .ultraCola:
      return Color(red: 0.071, green: 0.008, blue: 0.027)  // Near Black Cola #120207
    case .limeBurst:
      return Color(red: 0.20, green: 0.80, blue: 0.20)  // Lime green #32CD32
    case .beastFuel:
      return Color(red: 0.04, green: 0.09, blue: 0.16)  // Deep blue #0A1628
    case .gingerShock:
      return Color(red: 0.75, green: 0.45, blue: 0.10)  // Golden Amber #BF731A
    }
  }

  /// UIアクセント用の鮮やかなカラー（スコアグロー、炭酸カラム、バッジ等で使用）
  var accentColor: Color {
    switch self {
    case .ultraCola: return Color(red: 0.95, green: 0.10, blue: 0.15)  // コーラ・レッド �
    case .limeBurst: return Color(red: 0.28, green: 0.95, blue: 0.28)  // ライム・グリーン 🟢
    case .beastFuel: return Color(red: 0.08, green: 0.62, blue: 0.96)  // エレクトリック・ブルー 🔵
    case .gingerShock: return Color(red: 0.98, green: 0.85, blue: 0.15)  // ジンジャー・ゴールド �
    }
  }

}

struct Drink: Identifiable {
  let type: DrinkType
  var id: String { type.id }
}
