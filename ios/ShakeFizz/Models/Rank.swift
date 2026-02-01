import Foundation

enum Rank: String, Codable, CaseIterable {
  case s = "S"
  case a = "A"
  case b = "B"
  case c = "C"

  var colorHex: String {
    switch self {
    case .s: return "#FF00FF"  // Magenta/Pink
    case .a: return "#00FFFF"  // Cyan
    case .b: return "#FFFF00"  // Yellow
    case .c: return "#808080"  // Gray
    }
  }

  static func calculate(meters: Double) -> Rank {
    switch meters {
    case 20.0...:
      return .s
    case 15.0..<20.0:
      return .a
    case 10.0..<15.0:
      return .b
    default:
      return .c
    }
  }
}
