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
  @Published var isCountingDown: Bool = false
  @Published var countdownValue: Int = 3
  @Published var gameTimeRemaining: Double = 15.0
  @Published var isTimeUp: Bool = false
  @Published var currentSession: Session? = nil

  // Dependencies
  let shakeManager = ShakeManager()
  private var cancellables = Set<AnyCancellable>()
  private var countdownTimer: AnyCancellable?
  private var gameTimer: AnyCancellable?

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
    isTimeUp = false
    gameTimeRemaining = 15.0
    // Apply drink modifiers
    if let drink = selectedDrink {
      shakeManager.fizzModifier = Double(drink.fizzPercent) / 100.0
    }

    startCountdown()
  }

  private func startCountdown() {
    isCountingDown = true
    countdownValue = 3

    countdownTimer = Timer.publish(every: 1.0, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self = self else { return }
        if self.countdownValue > 1 {
          self.countdownValue -= 1
        } else if self.countdownValue == 1 {
          // Show "GO!" for 0.5 seconds
          self.countdownValue = 0
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startGame()
          }
        }
      }
  }

  private func startGame() {
    countdownTimer?.cancel()
    countdownTimer = nil
    isCountingDown = false
    isTimeUp = false
    gameTimeRemaining = 15.0
    shakeManager.startShaking()

    gameTimer = Timer.publish(every: 0.1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self = self else { return }
        if self.gameTimeRemaining > 0 {
          self.gameTimeRemaining -= 0.1
        } else {
          self.endGame()
        }
      }
  }

  private func endGame() {
    gameTimer?.cancel()
    gameTimer = nil
    isTimeUp = true
    shakeManager.stopShaking()
  }

  func finishTyringToPop() {
    gameTimer?.cancel()
    gameTimer = nil
    shakeManager.stopShaking()

    guard let drink = selectedDrink else { return }

    let score = shakeManager.projectedHeight
    let rank = Rank.calculate(meters: score)
    let topSpeed = 0.0  // Placeholder for MVP
    let totalShakes = Int(shakeManager.currentPressure)  // Proxy for shakes

    // Check if this is a new personal best before updating
    let currentBest = UserDefaults.standard.double(forKey: "bestScore")
    let isPersonalBest = score > currentBest
    
    let session = Session(
      score: score,
      rank: rank,
      drinkType: drink,
      topSpeed: topSpeed,
      totalShakes: totalShakes,
      duration: 15.0 - gameTimeRemaining,
      timestamp: Date(),
      isPersonalBest: isPersonalBest
    )

    self.currentSession = session

    // Update best score if this is a new personal best
    if isPersonalBest {
      updateBestScore(score: score, rank: rank, drinkType: drink)
    }

    gameState = .result
  }

  private func updateBestScore(score: Double, rank: Rank, drinkType: DrinkType) {
    let currentBest = UserDefaults.standard.double(forKey: "bestScore")

    if score > currentBest {
      UserDefaults.standard.set(score, forKey: "bestScore")
      UserDefaults.standard.set(rank.rawValue, forKey: "bestRank")
      UserDefaults.standard.set(drinkType.displayName, forKey: "bestDrink")

      let formatter = RelativeDateTimeFormatter()
      formatter.unitsStyle = .abbreviated
      UserDefaults.standard.set("just now", forKey: "bestDate")
    }
  }

  func performTapAction() {
    // Only allow taps during active gameplay (not countdown or time up)
    guard !isCountingDown && !isTimeUp && gameState == .playing else { return }

    // Add pressure to shake manager (simulates a shake action)
    shakeManager.addPressure(amount: 1.5)
  }

  func resetGame() {
    gameTimer?.cancel()
    gameTimer = nil
    shakeManager.reset()
    currentSession = nil
    gameState = .selection
  }

  func retryGame() {
    // Keep same drink, go back to warning? Or straight to play?
    // Usually safety warning is "once per session" but readme says "Required step before play".
    // Let's go to warning to be safe.
    gameTimer?.cancel()
    gameTimer = nil
    shakeManager.reset()
    currentSession = nil
    gameState = .safetyWarning
  }
}
