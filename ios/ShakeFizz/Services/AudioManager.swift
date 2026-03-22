import AVFoundation

final class AudioManager {
  static let shared = AudioManager()

  private var players: [String: AVAudioPlayer] = [:]

  private init() {
    // Audio Session setup for iOS to ensure sounds play correctly even on silent mode or mix properly
    do {
      try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to set audio session category.")
    }
  }

  func playSE(_ name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.play()
      players[name] = player
    } catch {
      print("SE error: \\(error)")
    }
  }

  func playBGM(_ name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = -1
      player.play()
      players["bgm"] = player
    } catch {
      print("BGM error: \\(error)")
    }
  }

  func stopBGM() {
    players["bgm"]?.stop()
  }
}
