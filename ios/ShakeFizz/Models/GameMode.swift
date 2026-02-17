import Foundation

enum GameMode: String, CaseIterable, Identifiable {
  case normal
  case timeAtk
  case endless

  var id: String { rawValue }

  var localizedKey: String {
    switch self {
    case .normal: return "mode_normal"
    case .timeAtk: return "mode_time_atk"
    case .endless: return "mode_endless"
    }
  }

  var descriptionKey: String {
    switch self {
    case .normal: return "mode_normal_long_desc"
    case .timeAtk: return "mode_time_atk_desc"
    case .endless: return "mode_endless_desc"
    }
  }

  var icon: String {
    switch self {
    case .normal: return "gamecontroller.fill"
    case .timeAtk: return "bolt.fill"
    case .endless: return "infinity"
    }
  }

  var isLocked: Bool {
    switch self {
    case .normal: return false
    case .timeAtk, .endless: return false
    }
  }
}
