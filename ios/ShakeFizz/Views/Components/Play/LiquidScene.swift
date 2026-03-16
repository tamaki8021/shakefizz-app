import SpriteKit
import UIKit

// MARK: - MetaballFilter
// CIFilter サブクラス：ガウシアンブラー → アルファ閾値処理でメタボール表現を実現
final class MetaballFilter: CIFilter {
  @objc var inputImage: CIImage?
  var liquidUIColor: UIColor = .cyan

  private let blurFilter: CIFilter = {
    let f = CIFilter(name: "CIGaussianBlur")!
    f.setValue(16.0, forKey: kCIInputRadiusKey)  // 12 → 16: より広い融合ゾーン
    return f
  }()

  private let thresholdFilter: CIFilter = {
    let f = CIFilter(name: "CIColorMatrix")!
    // アルファの閾値を設定しつつ、RGBの色自体は保持する（1, 1, 1）
    f.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
    f.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
    f.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
    // アルファを 20 倍 → 実効閾値 ≈ 0.05
    f.setValue(CIVector(x: 0, y: 0, z: 0, w: 20), forKey: "inputAVector")
    f.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
    return f
  }()

  override var outputImage: CIImage? {
    guard let input = inputImage else { return nil }
    blurFilter.setValue(input, forKey: kCIInputImageKey)
    guard let blurred = blurFilter.outputImage else { return nil }
    thresholdFilter.setValue(blurred, forKey: kCIInputImageKey)
    guard let silhouette = thresholdFilter.outputImage else { return nil }

    // シルエットの extent に合わせた単色画像を生成（CIConstantColorGenerator を使用）
    let colorFilter = CIFilter(name: "CIConstantColorGenerator")!
    colorFilter.setValue(CIColor(color: liquidUIColor), forKey: kCIInputColorKey)
    guard let infiniteColorImage = colorFilter.outputImage else { return nil }
    let solidColorImage = infiniteColorImage.cropped(to: silhouette.extent)

    // CILinearBurnBlendModeやCIMultiplyBlendModeでシルエットの色味を強制的に「liquidColorの暗さ」に合わせる
    // 或者いはCIColorBlendMode(色相と彩度だけ上書き)を使う
    let blendFilter = CIFilter(name: "CIColorBlendMode")!
    blendFilter.setValue(solidColorImage, forKey: kCIInputImageKey)
    blendFilter.setValue(silhouette, forKey: kCIInputBackgroundImageKey)

    // CISourceAtopCompositingで元のアルファ形状で切り抜く（ColorBlendはアルファを保たない可能性があるため）
    let maskFilter = CIFilter(name: "CISourceAtopCompositing")!
    maskFilter.setValue(blendFilter.outputImage, forKey: kCIInputImageKey)
    maskFilter.setValue(silhouette, forKey: kCIInputBackgroundImageKey)

    return maskFilter.outputImage
  }
}

// MARK: - LiquidScene
final class LiquidScene: SKScene {

  // MARK: Configuration
  private let particleCount: Int = 90
  private let particleRadius: CGFloat = 14.0
  /// 液体表面ゾーンの下端（画面高さ比率）。PlayScreenView の baseHeightRatio と合わせる
  static let surfaceFloorRatio: CGFloat = 0.80

  // MARK: Public properties（毎フレーム PlayScreen から更新される）
  var liquidColor: UIColor = .cyan {
    didSet { updateNodeColors() }
  }
  var roll: Double = 0.0  // デバイスの左右傾き（ラジアン）
  var agitation: Double = 0.0  // 振動強度 0.0〜1.0+
  /// カウントダウン中は false → 物理演算を停止してパーティクルを静止させる
  var isPlaying: Bool = false {
    didSet {
      physicsWorld.speed = isPlaying ? 1.2 : 0.0
    }
  }

  // MARK: Private
  private weak var effectNode: SKEffectNode?
  private weak var baseBodyNode: SKShapeNode?  // 波打つ液体土台
  private var particleNodes: [SKSpriteNode] = []
  private var cachedTexture: SKTexture?
  private var wavePhase: Double = 0.0  // サイン波の位相（毎フレーム進む）
  private var lastUpdateTime: TimeInterval = 0

  // MARK: Bubble
  /// 泡パーティクル専用の親ノード（effectNode の外に置いてメタボールフィルターから独立させる）
  private weak var bubbleLayer: SKNode?
  /// 現在画面上に存在する泡の配列
  private var activeBubbles: [SKShapeNode] = []
  /// 泡の生成タイマー（次に泡を出すまでの秒数）
  private var bubbleTimer: Double = 0.0

  // MARK: - Lifecycle
  override func didMove(to view: SKView) {
    backgroundColor = .clear
    physicsWorld.speed = 1.2
  }

  override func didChangeSize(_ oldSize: CGSize) {
    super.didChangeSize(oldSize)
    guard size.width > 10, size.height > 10 else { return }
    rebuildScene()
  }

  // MARK: - Scene Construction
  private func rebuildScene() {
    removeAllChildren()
    particleNodes.removeAll()
    activeBubbles.removeAll()

    setupWalls()
    setupEffectNode()
    setupBase()  // 土台を effectNode 内に配置
    setupParticles()
    setupBubbleLayer()  // 泡レイヤー（effectNode の外）
  }

  private func setupWalls() {
    let visualFloorY = size.height * LiquidScene.surfaceFloorRatio
    let floorY = visualFloorY - 40.0
    let m: CGFloat = 2

    addChild(makeEdge(from: CGPoint(x: m, y: 0), to: CGPoint(x: m, y: size.height)))
    addChild(
      makeEdge(
        from: CGPoint(x: size.width - m, y: 0), to: CGPoint(x: size.width - m, y: size.height)))
    addChild(makeEdge(from: CGPoint(x: 0, y: floorY), to: CGPoint(x: size.width, y: floorY)))
  }

  private func makeEdge(from start: CGPoint, to end: CGPoint) -> SKNode {
    let node = SKNode()
    let body = SKPhysicsBody(edgeFrom: start, to: end)
    body.isDynamic = false
    body.friction = 0.05
    body.restitution = 0.02
    body.categoryBitMask = 0x02
    body.collisionBitMask = 0x01
    node.physicsBody = body
    return node
  }

  private func setupEffectNode() {
    let node = SKEffectNode()
    node.shouldEnableEffects = true
    node.shouldRasterize = false  // 毎フレーム変化するので false

    let filter = MetaballFilter()
    filter.liquidUIColor = liquidColor
    node.filter = filter

    node.blendMode = .alpha
    node.position = .zero
    addChild(node)
    effectNode = node
  }

  // MARK: Step1: 液体土台ノード（effectNode 内に追加してメタボールと一体化）
  private func setupBase() {
    guard let eNode = effectNode else { return }
    let node = SKShapeNode()
    node.fillColor = liquidColor
    node.strokeColor = .clear
    node.zPosition = -1  // パーティクルより後ろに描画
    eNode.addChild(node)
    baseBodyNode = node
  }

  private func setupParticles() {
    guard let eNode = effectNode else { return }
    let texture = particleTexture()

    for _ in 0..<particleCount {
      let node = SKSpriteNode(texture: texture)
      node.size = CGSize(width: particleRadius * 2, height: particleRadius * 2)
      node.color = liquidColor
      node.colorBlendFactor = 1.0
      node.blendMode = .alpha

      let visualFloorY = size.height * LiquidScene.surfaceFloorRatio
      let floorY = visualFloorY - 40.0
      let x = CGFloat.random(in: particleRadius...(size.width - particleRadius))
      let y = CGFloat.random(in: floorY...(size.height * 0.95))
      node.position = CGPoint(x: x, y: y)

      let body = SKPhysicsBody(circleOfRadius: particleRadius * 0.58)
      body.restitution = 0.0
      // Step2: 粘度UP（ドロッとした液体感）
      body.friction = 0.06  // 0.02 → 0.06: 粒同士が絡みやすく
      body.linearDamping = 2.8  // 1.8 → 2.8: より粘っこい動き
      body.angularDamping = 1.0
      body.allowsRotation = false
      body.mass = 0.04
      body.categoryBitMask = 0x01
      body.collisionBitMask = 0x01 | 0x02
      node.physicsBody = body

      eNode.addChild(node)
      particleNodes.append(node)
    }
  }

  private func particleTexture() -> SKTexture {
    if let tex = cachedTexture { return tex }

    let imgSize = CGSize(width: particleRadius * 2, height: particleRadius * 2)
    let renderer = UIGraphicsImageRenderer(size: imgSize)
    let image = renderer.image { ctx in
      let cgCtx = ctx.cgContext
      let colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor] as CFArray
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      guard
        let gradient = CGGradient(
          colorsSpace: colorSpace,
          colors: colors,
          locations: [0.0, 1.0]
        )
      else { return }

      let center = CGPoint(x: particleRadius, y: particleRadius)
      cgCtx.drawRadialGradient(
        gradient,
        startCenter: center, startRadius: 0,
        endCenter: center, endRadius: particleRadius,
        options: []
      )
    }
    let texture = SKTexture(image: image)
    cachedTexture = texture
    return texture
  }

  // MARK: - Update
  override func update(_ currentTime: TimeInterval) {
    let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
    lastUpdateTime = currentTime

    let waveSpeed = 0.8 + agitation * 1.7
    wavePhase += dt * waveSpeed

    updateBasePath()
    updateBubbles(dt: dt)

    let base: Double = 9.8
    let boost: Double = agitation * 9.0
    let magnitude = base + boost
    let gx = sin(roll) * magnitude * 1.4
    let gy = -abs(cos(roll)) * magnitude
    physicsWorld.gravity = CGVector(dx: gx, dy: gy)
  }

  // MARK: 波打つ土台パス（サイン波 × 時間で毎フレーム再構築）
  private func updateBasePath() {
    guard let base = baseBodyNode else { return }
    base.fillColor = liquidColor

    // --- パラメータ ---
    let baseY = size.height * LiquidScene.surfaceFloorRatio  // 静止時の液面Y
    // 振動が強いほど振れ幅が広がる（8pt〜30pt）
    let amplitude = CGFloat(15.0 + agitation * 22.0)
    // 傾きで左右に液体が寄る分だけ液面全体をオフセット
    let tiltOffset = CGFloat(sin(roll) * Double(size.height) * 0.06)

    // --- 上辺をサンプリング（細かいほどなめらか） ---
    let steps = 40
    let stepW = size.width / CGFloat(steps)

    let path = CGMutablePath()
    // 左下から出発
    path.move(to: CGPoint(x: 0, y: 0))

    // 左端の Y
    let y0 = surfaceY(x: 0, baseY: baseY, amplitude: amplitude, tiltOffset: tiltOffset)
    path.addLine(to: CGPoint(x: 0, y: y0))

    // 上辺を三次ベジェ曲線でなめらかに結ぶ
    for i in 1...steps {
      let prevX = CGFloat(i - 1) * stepW
      let currX = CGFloat(i) * stepW
      let prevY = surfaceY(
        x: Double(prevX), baseY: baseY, amplitude: amplitude, tiltOffset: tiltOffset)
      let currY = surfaceY(
        x: Double(currX), baseY: baseY, amplitude: amplitude, tiltOffset: tiltOffset)
      let midX = (prevX + currX) * 0.5
      path.addCurve(
        to: CGPoint(x: currX, y: currY),
        control1: CGPoint(x: midX, y: prevY),
        control2: CGPoint(x: midX, y: currY)
      )
    }

    // 右下 → 閉じる
    path.addLine(to: CGPoint(x: size.width, y: 0))
    path.closeSubpath()
    base.path = path
  }

  /// x座標から液面Yを計算（サイン波2重で自然な揺れを演出）
  private func surfaceY(x: Double, baseY: CGFloat, amplitude: CGFloat, tiltOffset: CGFloat)
    -> CGFloat
  {
    let w = Double(size.width)
    // 主波：ゆっくり大きく揺れる
    let wave1 = sin(x / w * .pi * 2.0 + wavePhase) * Double(amplitude)
    // 副波：速めに小さく揺れる（表面の細かいリップル）
    let wave2 = sin(x / w * .pi * 5.0 - wavePhase * 1.6) * Double(amplitude * 0.3)
    return baseY + tiltOffset + CGFloat(wave1 + wave2)
  }

  // MARK: - Helpers
  private func updateNodeColors() {
    baseBodyNode?.fillColor = liquidColor
    for node in particleNodes {
      node.color = liquidColor
    }
    if let filter = effectNode?.filter as? MetaballFilter {
      filter.liquidUIColor = liquidColor
    }
  }

  // MARK: - Bubble Layer

  /// 泡を乗せる専用ノード（effectNode の後に addChild → 液体の前面に描画）
  private func setupBubbleLayer() {
    let layer = SKNode()
    layer.zPosition = 10  // effectNode より手前
    addChild(layer)
    bubbleLayer = layer
  }

  /// 毎フレーム呼ばれる泡の生成・移動・消滅
  private func updateBubbles(dt: Double) {
    guard let layer = bubbleLayer else { return }

    // ---生成タイマーを更新---
    // agitation=0 のとき 1.8秒に1個、agitation=1.0 のとき 0.1秒に1個
    let spawnInterval = max(0.1, 1.8 - agitation * 1.7)
    bubbleTimer -= dt

    if bubbleTimer <= 0 {
      bubbleTimer = spawnInterval

      // シェイク強度に応じて1フレームで1〜3個まとめて発生
      let spawnCount = max(1, Int(agitation * 3))
      for _ in 0..<spawnCount {
        spawnBubble(in: layer)
      }
    }

    // ---既存の泡を移動・消滅させる---
    let surfaceY = size.height * LiquidScene.surfaceFloorRatio

    for bubble in activeBubbles.reversed() {
      // ゆらゆら上昇（左右にわずかなdrift）
      let riseSpeed = CGFloat(Double.random(in: 40...80))
      let driftX = CGFloat(Double.random(in: -8...8))
      bubble.position.y += riseSpeed * CGFloat(dt)
      bubble.position.x += driftX * CGFloat(dt)

      // 液面を超えたらフェードアウトして除去
      if bubble.position.y >= surfaceY {
        bubble.run(
          SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.removeFromParent(),
          ])
        )
        if let idx = activeBubbles.firstIndex(of: bubble) {
          activeBubbles.remove(at: idx)
        }
      }
    }
  }

  /// 1個の泡を生成してlayerに追加
  private func spawnBubble(in layer: SKNode) {
    let floorY = size.height * LiquidScene.surfaceFloorRatio
    let startY = CGFloat.random(in: floorY * 0.05...floorY * 0.55)
    let startX = CGFloat.random(in: 8...(size.width - 8))
    let radius = CGFloat.random(in: 2...6)

    // 輝度で泡の色を切り替える
    var h: CGFloat = 0
    var s: CGFloat = 0
    var bri: CGFloat = 0
    var al: CGFloat = 0
    liquidColor.getHue(&h, saturation: &s, brightness: &bri, alpha: &al)

    // 輝度 > 0.5（明るい液体: ライムなど）→ 液体色ベースの半透明泡
    // 輝度 ≤ 0.5（暗い液体: コーラなど）→ 白系の半透明泡（従来通り）
    let bubbleFill: UIColor
    let bubbleStroke: UIColor
    if bri > 0.5 {
      bubbleFill = UIColor(
        hue: h, saturation: s * 0.5, brightness: min(bri + 0.3, 1.0), alpha: 0.35)
      bubbleStroke = UIColor(
        hue: h, saturation: s * 0.3, brightness: min(bri + 0.5, 1.0), alpha: 0.55)
    } else {
      bubbleFill = UIColor.white.withAlphaComponent(0.35)
      bubbleStroke = UIColor.white.withAlphaComponent(0.6)
    }

    let bubble = SKShapeNode(circleOfRadius: radius)
    bubble.position = CGPoint(x: startX, y: startY)
    bubble.fillColor = bubbleFill
    bubble.strokeColor = bubbleStroke
    bubble.lineWidth = 0.8
    bubble.zPosition = 10

    layer.addChild(bubble)
    activeBubbles.append(bubble)
  }
}
