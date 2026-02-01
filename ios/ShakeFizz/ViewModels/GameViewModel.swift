import Combine
import SwiftUI

enum GameState {
  case selection
  case safetyWarning
  case playing
  case result
}

class GameViewModel: ObservableObject {
  @Published var gameState: GameState = .selection
  @Published var selectedDrink: DrinkType? = nil
  @Published var currentSession: Session? = nil

  // Dependencies
  let shakeManager = ShakeManager()
  private var cancellables = Set<AnyCancellable>()

  init() {
    // Forward shake updates if needed, or Views can observe ShakeManager directly
    // For MVP, we pass ShakeManager to views via EnvironmentObject or directly
  }

  func selectDrink(_ type: DrinkType) {
    if type.isLocked { return }  // Simple lock check
    self.selectedDrink = type
  }

  func proceedToWarning() {
    guard selectedDrink != nil else { return }
    gameState = .safetyWarning
  }

  func acknowledgeWarning() {
    gameState = .playing
    // Reset shake manager for new game
    shakeManager.reset()
    // Apply drink modifiers
    if let drink = selectedDrink {
      shakeManager.fizzModifier = Double(drink.fizzPercent) / 100.0
    }
    // Start sensing immediately or after countdown?
    // For MVP, start immediately on view appear
    shakeManager.startShaking()
  }

  func finishTyringToPop() {
    shakeManager.stopShaking()

    guard let drink = selectedDrink else { return }

    let score = shakeManager.projectedHeight
    let rank = Rank.calculate(meters: score)
    let topSpeed = 0.0  // Placeholder for MVP
    let totalShakes = Int(shakeManager.currentPressure)  // Proxy for shakes

    let session = Session(
      score: score,
      rank: rank,
      drinkType: drink,
      topSpeed: topSpeed,
      totalShakes: totalShakes,
      duration: 0,  // Placeholder
      timestamp: Date()
    )

    self.currentSession = session
    gameState = .result
  }

  func resetGame() {
    shakeManager.reset()
    currentSession = nil
    gameState = .selection
  }

  func retryGame() {
    // Keep same drink, go back to warning? Or straight to play?
    // Usually safety warning is "once per session" but readme says "Required step before play".
    // Let's go to warning to be safe.
    shakeManager.reset()
    currentSession = nil
    gameState = .safetyWarning
  }
}
