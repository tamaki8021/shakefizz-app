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
    fizzRemaining = min(
      maxFizz, UserDefaults.standard.object(forKey: fizzUserDefaultsKey) as? Int ?? maxFizz)
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

    // 自己ベスト更新時のみランキングを更新（それ以外は順位キープ）
    let simulatedRank: Int
    let simulatedDelta: Int?

    if isPersonalBest {
      // 新しいベストスコアでランクを計算
      simulatedRank = max(1, Int(10000.0 / pow(max(1.0, score * 0.1), 1.5)))

      if currentBest > 0 {
        // 過去のベストからの上がり幅を計算
        let oldRank = max(1, Int(10000.0 / pow(max(1.0, currentBest * 0.1), 1.5)))
        let improved = oldRank - simulatedRank
        simulatedDelta = improved > 0 ? improved : nil
      } else {
        // 初回プレイ時は順位変動を見せない
        simulatedDelta = nil
      }
    } else {
      // 自己ベストではない場合、過去のベスト基準の順位を表示し、変動はなし
      simulatedRank =
        currentBest > 0 ? max(1, Int(10000.0 / pow(max(1.0, currentBest * 0.1), 1.5))) : 10000
      simulatedDelta = nil
    }

    let session = Session(
      score: score,
      drinkType: drink,
      topSpeed: topSpeed,
      totalShakes: totalShakes,
      duration: 15.0 - gameTimeRemaining,
      timestamp: Date(),
      isPersonalBest: isPersonalBest,
      rankNumber: simulatedRank,
      rankDelta: simulatedDelta
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
      UserDefaults.standard.set(NSLocalizedString("just_now", comment: ""), forKey: "bestDate")
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

  func retryGame(fromZero: Bool = false) {
    gameTimer?.cancel()
    gameTimer = nil
    shakeManager.reset()
    currentSession = nil

    if fromZero {
      // 炭酸を未消費扱いにする（1つ回復）
      refillFizz(amount: 1)

      // 再度消費して、Warningをスキップし直接プレイ開始
      if consumeFizzIfAvailable() {
        gameState = .playing
        isTimeUp = false
        gameTimeRemaining = 15.0
        if let drink = selectedDrink {
          shakeManager.fizzModifier = Double(drink.fizzPercent) / 100.0
        }
        startCountdown()
        return
      }
    }

    // 残機がない場合は、強制的にドリンク選択画面（ホーム）に戻る
    guard fizzRemaining > 0 else {
      gameState = .selection
      return
    }

    // 通常のリトライ
    gameState = .safetyWarning
  }
}
