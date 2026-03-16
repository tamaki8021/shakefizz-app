import SpriteKit
import SwiftUI

// MARK: - LiquidSpriteKitView
// UIViewRepresentable: SwiftUI と SpriteKit の橋渡し
struct LiquidSpriteKitView: UIViewRepresentable {
  var color: Color
  var roll: Double
  var agitation: Double
  var isPlaying: Bool  // false: 物理止め（カウントダウン中） / true: 通常運転

  func makeUIView(context: Context) -> SKView {
    let view = SKView()
    view.backgroundColor = .clear
    view.allowsTransparency = true
    view.preferredFramesPerSecond = 60
    view.ignoresSiblingOrder = true
    view.showsFPS = false
    view.showsPhysics = false

    let scene = LiquidScene()
    // ⚠️ SpriteKit のデフォルト anchorPoint は (0.5, 0.5)（画面中央が原点）
    // → (0, 0) に設定して「左下が x=0, y=0」の直感的な座標系にする
    scene.anchorPoint = CGPoint(x: 0, y: 0)
    scene.scaleMode = .resizeFill
    scene.backgroundColor = .clear
    view.presentScene(scene)

    context.coordinator.scene = scene
    return view
  }

  func updateUIView(_ uiView: SKView, context: Context) {
    guard let scene = context.coordinator.scene else { return }
    scene.liquidColor = UIColor(color)
    scene.roll = roll
    scene.agitation = agitation
    scene.isPlaying = isPlaying
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  final class Coordinator {
    var scene: LiquidScene?
  }
}
