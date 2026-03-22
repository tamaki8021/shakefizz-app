import Combine
import SwiftUI

class SettingsManager: ObservableObject {
  @AppStorage("soundEffectsEnabled") var soundEffectsEnabled: Bool = true
  @AppStorage("musicEnabled") var musicEnabled: Bool = true
  @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled: Bool = true
  @AppStorage("selectedGameMode") private var selectedGameModeRaw: String = GameMode.normal.rawValue

  var selectedGameMode: GameMode {
    get {
      GameMode(rawValue: selectedGameModeRaw) ?? .normal
    }
    set {
      selectedGameModeRaw = newValue.rawValue
    }
  }

  func selectGameMode(_ mode: GameMode) {
    guard !mode.isLocked else { return }
    selectedGameMode = mode
  }
}
