import Foundation

struct Session: Identifiable, Codable {
    var id: UUID = UUID()
    let score: Double
    let drinkType: DrinkType
    let topSpeed: Double
    let totalShakes: Int
    let duration: TimeInterval
    let timestamp: Date
    
    var isPersonalBest: Bool = false
}
