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

  /// スタミナ（炭酸の残り回数）1プレイで1消費。0で「炭酸切れ」→ 広告視聴や時間経過で補充
  @Published var fizzRemaining: Int = 5
  /// 所持通貨（クラウン等）。マネタイズ・アンロック用
  @Published var currency: Int = 2450
  private let maxFizz = 5
  private let fizzUserDefaultsKey = "shakefizz_fizz_remaining"
  private let currencyUserDefaultsKey = "shakefizz_currency"

  init() {
    fizzRemaining = min(maxFizz, UserDefaults.standard.object(forKey: fizzUserDefaultsKey) as? Int ?? maxFizz)
    currency = UserDefaults.standard.object(forKey: currencyUserDefaultsKey) as? Int ?? 2450
  }

  // Dependencies
  let shakeManager = ShakeManager()
  private var cancellables = Set<AnyCancellable>()
  private var countdownTimer: AnyCancellable?
  private var gameTimer: AnyCancellable?

  func consumeFizzIfAvailable() -> Bool {
    guard fizzRemaining > 0 else { return false }
    fizzRemaining -= 1
    UserDefaults.standard.set(fizzRemaining, forKey: fizzUserDefaultsKey)
    return true
  }

  func refillFizz(amount: Int = 1) {
    fizzRemaining = min(maxFizz, fizzRemaining + amount)
    UserDefaults.standard.set(fizzRemaining, forKey: fizzUserDefaultsKey)
  }

  func addCurrency(_ value: Int) {
    currency += value
    UserDefaults.standard.set(currency, forKey: currencyUserDefaultsKey)
  }

  /// リーグ別ベストスコア（m）。未実装時はグローバルベストを返す
  func bestMeters(for drinkType: DrinkType) -> Double? {
    let global = UserDefaults.standard.double(forKey: "bestScore")
    return global > 0 ? global : nil
  }

  /// リーグ別ランク表示用。未実装時はプレースホルダー
  func rankNumber(for drinkType: DrinkType) -> Int? {
    nil  // オンラインランキング実装時に返す
  }

  func selectDrink(_ type: DrinkType) {
    if type.isLocked { return }  // Simple lock check
    self.selectedDrink = type
  }

  func proceedToWarning() {
    guard selectedDrink != nil, fizzRemaining > 0 else { return }
    gameState = .safetyWarning
  }

  func acknowledgeWarning() {
    guard consumeFizzIfAvailable() else {
      // 炭酸切れ時はここに来ない想定（スタートボタン無効化で防ぐ）
      return
    }
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
    let topSpeed = 0.0  // Placeholder for MVP
    let totalShakes = Int(shakeManager.currentPressure)  // Proxy for shakes

    // Check if this is a new personal best before updating
    let currentBest = UserDefaults.standard.double(forKey: "bestScore")
    let isPersonalBest = score > currentBest

    let session = Session(
      score: score,
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
      updateBestScore(score: score, drinkType: drink)
    }

    gameState = .result
  }

  private func updateBestScore(score: Double, drinkType: DrinkType) {
    let currentBest = UserDefaults.standard.double(forKey: "bestScore")

    if score > currentBest {
      UserDefaults.standard.set(score, forKey: "bestScore")
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
    // Balance adjustment: Tapping is less effective than shaking (50% efficiency)
    let baseTapAmount = 1.5
    let tapEfficiency = 0.5
    shakeManager.addPressure(amount: baseTapAmount * tapEfficiency)
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
