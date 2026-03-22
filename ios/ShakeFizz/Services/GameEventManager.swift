import Foundation
import UIKit

final class GameEventManager {
  static let shared = GameEventManager()

  private init() {}

  private var isSoundEnabled: Bool {
    if UserDefaults.standard.object(forKey: "soundEffectsEnabled") == nil { return true }
    return UserDefaults.standard.bool(forKey: "soundEffectsEnabled")
  }

  private var isMusicEnabled: Bool {
    if UserDefaults.standard.object(forKey: "musicEnabled") == nil { return true }
    return UserDefaults.standard.bool(forKey: "musicEnabled")
  }

  private var isHapticEnabled: Bool {
    if UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") == nil { return true }
    return UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled")
  }

  func handleEvent(_ event: GameEvent) {
    let soundEnabled = isSoundEnabled
    let hapticEnabled = isHapticEnabled
    let musicEnabled = isMusicEnabled

    switch event {
    case .shakeStart:
      if soundEnabled { AudioManager.shared.playSE("shake_start") }
      if hapticEnabled { HapticManager.shared.impact(.light) }

    case .shaking:
      // 今はシェイク中専用のループは無くし、ゲーム中全体で鳴らす仕様に変更
      break

    case .shakeEnd:
      break
      
    case .gameStart:
      if soundEnabled { AudioManager.shared.playBGM("fizz_loop") }
      
    case .gameEnd:
      AudioManager.shared.stopBGM()

    case .canOpen:
      if soundEnabled { AudioManager.shared.playSE("can_open") }
      if hapticEnabled { HapticManager.shared.impact(.medium) }

    case .explosion:
      if soundEnabled { AudioManager.shared.playSE("explosion") }
      if hapticEnabled { HapticManager.shared.impact(.heavy) }

    case .scoreAppear:
      if soundEnabled { AudioManager.shared.playSE("pop") }
      if hapticEnabled { HapticManager.shared.impact(.light) }

    case .rankUp:
      if soundEnabled { AudioManager.shared.playSE("success") }
      if hapticEnabled { HapticManager.shared.notification(.success) }

    case .buttonTap:
      if soundEnabled { AudioManager.shared.playSE("btn_click") }
      if hapticEnabled { HapticManager.shared.impact(.light) }

    case .resultAmbient:
      if soundEnabled { AudioManager.shared.playSE("fizz_ambient") }
      
    case .menuBGM:
      if musicEnabled { AudioManager.shared.playBGM("main_bgm") }
      
    case .helpShake:
      if soundEnabled { AudioManager.shared.playBGM("shake_start") }
      
    case .stopBGM:
      AudioManager.shared.stopBGM()
    }
  }
}
