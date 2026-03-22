import SpriteKit
import SwiftUI

struct PlayScreenView: View {
  @ObservedObject var viewModel: GameViewModel
  @ObservedObject var shakeManager: ShakeManager

  @State private var showExitConfirmation = false
  @State private var isPopping = false

  init(viewModel: GameViewModel) {
    self.viewModel = viewModel
    self.shakeManager = viewModel.shakeManager
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // 1. Background (Deep liquid color at the back)
        if let drink = viewModel.selectedDrink {
          drink.backgroundColor
            .brightness(-0.3)  // Darker background for depth
            .ignoresSafeArea()
        } else {
          Color.black.ignoresSafeArea()
        }

        // 2. Liquid（SpriteKit が土台＋表面を一体で描画）
        if let drink = viewModel.selectedDrink {
          LiquidSpriteKitView(
            color: drink.backgroundColor,
            roll: shakeManager.roll,
            agitation: shakeManager.liquidAgitation,
            isPlaying: !viewModel.isCountingDown
          )
          .ignoresSafeArea()
        }

        // 3. Bubbles (Carbonation)
        if viewModel.selectedDrink != nil {
          BubblesEffectView(
            density: 40,
            speedMultiplier: 1.0 + (shakeManager.liquidAgitation * 2.0),  // Faster when shaken
            roll: shakeManager.roll
          )
          .ignoresSafeArea()
        }

        // 4. Can Body Overlay (Glass/Metal/Condensation)
        CanBodyOverlay(condensationAmount: 0.4 + (shakeManager.liquidAgitation * 0.3))
          .ignoresSafeArea()
          .allowsHitTesting(false)

        // UI Elements
        VStack(spacing: 0) {
          // Top Bar
          ZStack {
            HStack {
              Button(action: {
                showExitConfirmation = true
              }) {
                Image(systemName: "xmark")
                  .font(.title3)
                  .foregroundColor(.white)
                  .padding(10)
                  .background(Circle().fill(Color.black.opacity(0.3)))
              }
              Spacer()
            }
            .padding()

            HStack(spacing: 6) {
              Image(systemName: "bubbles.and.sparkles.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
              Text(viewModel.selectedDrink?.displayName ?? "UNKNOWN")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .textCase(.uppercase)
                .kerning(1.2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
              Capsule()
                .fill(Color.white.opacity(0.15))
                .overlay(
                  Capsule()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
            )
          }

          Spacer()

          if !viewModel.isTimeUp && !viewModel.isCountingDown {
            // タイマー表示（下部）
            VStack(spacing: 4) {
              ZStack {
                Circle()
                  .fill(Color.black.opacity(0.45))
                  .frame(width: 76, height: 76)
                  .blur(radius: 2)
                Circle()
                  .stroke(Color.white.opacity(0.2), lineWidth: 4)
                  .frame(width: 68, height: 68)
                Circle()
                  .trim(from: 0, to: CGFloat(viewModel.gameTimeRemaining / 15.0))
                  .stroke(
                    timerColor(for: viewModel.gameTimeRemaining),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                  )
                  .frame(width: 68, height: 68)
                  .rotationEffect(.degrees(-90))
                  .animation(.linear(duration: 0.1), value: viewModel.gameTimeRemaining)
                  .shadow(
                    color: timerColor(for: viewModel.gameTimeRemaining).opacity(0.8), radius: 4)
                Text(
                  String(
                    format: "%02d:%02d",
                    Int(viewModel.gameTimeRemaining) / 60,
                    Int(viewModel.gameTimeRemaining) % 60)
                )
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(timerColor(for: viewModel.gameTimeRemaining))
                .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
              }
            }
            .padding(.bottom, 28)  // タイマーとテキストの間隔をさらに開ける

            // 操作指示テキスト（ボタンなし・画面全体がタップ領域）
            VStack(spacing: 8) {
              HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                Text(LocalizedStringKey("tap_anywhere"))
              }
              .font(.system(size: 13, weight: .semibold))
              .foregroundColor(.white.opacity(0.85))  // 少しだけ白を強く

              HStack(spacing: 8) {
                Rectangle()
                  .fill(Color.white.opacity(0.5))  // 少しだけ白を強く
                  .frame(width: 16, height: 1)
                Text("OR")
                  .font(.system(size: 10, weight: .bold))
                  .foregroundColor(.white.opacity(0.6))  // 少しだけ白を強く
                Rectangle()
                  .fill(Color.white.opacity(0.5))
                  .frame(width: 16, height: 1)
              }

              HStack(spacing: 6) {
                Image(systemName: "iphone.radiowaves.left.and.right")
                Text(LocalizedStringKey("shake_device"))
              }
              .font(.system(size: 13, weight: .semibold))
              .foregroundColor(.white.opacity(0.85))  // 少しだけ白を強く
            }
            .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)  // 強いドロップシャドウで縁取り
            .padding(.bottom, 48)
          }
        }
        // 画面全体をタップ領域にする（カウントダウン中・タイムアップ時は無効）
        .contentShape(Rectangle())
        .onTapGesture {
          guard !viewModel.isCountingDown && !viewModel.isTimeUp else { return }
          GameEventManager.shared.handleEvent(.buttonTap)
          viewModel.performTapAction()
        }

        // TIME UP Overlay
        if viewModel.isTimeUp && !isPopping {
          ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            Text(LocalizedStringKey("time_up"))
              .font(.system(size: 72, weight: .black))
              .foregroundColor(.white)
              .italic()
              .shadow(color: .neonCyan, radius: 20)

            VStack {
              Spacer()
              NeonButton(
                title: "view_results", color: .neonCyan,
                icon: "arrow.right"
              ) {
                // 爆発演出を開始（1.5秒後に本当の遷移処理を呼ぶ）
                withAnimation {
                  isPopping = true
                }
                GameEventManager.shared.handleEvent(.buttonTap)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                  viewModel.finishTyringToPop()
                }
              }
              .padding(.horizontal)
              .padding(.bottom, 60)
            }
          }
          .zIndex(90)
        }

        // 開栓・爆発アニメーション（ZStackの最前面）
        if isPopping {
          PopAnimationOverlay(fizzAmount: shakeManager.liquidAgitation)
            .zIndex(200)
        }

        // Countdown Overlay
        if viewModel.isCountingDown {
          ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()

            if viewModel.countdownValue > 0 {
              CountdownNumberView(value: viewModel.countdownValue)
                .id(viewModel.countdownValue)
            } else {
              CountdownGoView()
            }
          }
          .zIndex(100)
        }
      }

      .alert(NSLocalizedString("alert_title", comment: ""), isPresented: $showExitConfirmation) {
        Button(LocalizedStringKey("alert_continue"), role: .cancel) {
          showExitConfirmation = false
        }
        Button(LocalizedStringKey("alert_cancel"), role: .destructive) {
          viewModel.resetGame()
        }
      } message: {
        Text(LocalizedStringKey("alert_message"))
      }
      .onChange(of: viewModel.gameTimeRemaining) { newValue in
        // 残り3秒でハプティクスと視覚的フィードバック
        if newValue <= 3.0 && newValue > 2.9 {
          let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
          impactFeedback.impactOccurred()
        }
      }
    }
  }

  // タイマーの色を残り時間に応じて変更
  private func timerColor(for remaining: Double) -> Color {
    if remaining <= 3.0 {
      return .red
    } else if remaining <= 5.0 {
      return .yellow
    } else {
      return .white
    }
  }
}

// MARK: - カウントダウン数字（浮かび上がりアニメーション）
private struct CountdownNumberView: View {
  let value: Int
  @State private var isVisible = false

  var body: some View {
    Text("\(value)")
      .font(.system(size: 144, weight: .black, design: .monospaced))
      .foregroundColor(.white)
      .shadow(color: .neonCyan, radius: 20)
      .offset(y: isVisible ? 0 : 60)
      .opacity(isVisible ? 1 : 0)
      .scaleEffect(isVisible ? 1.0 : 0.6)
      .onAppear {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
          isVisible = true
        }
      }
  }
}

// MARK: - カウントダウン「GO!」（浮かび上がりアニメーション）
private struct CountdownGoView: View {
  @State private var isVisible = false

  var body: some View {
    Text(LocalizedStringKey("go"))
      .font(.system(size: 144, weight: .black, design: .monospaced))
      .foregroundColor(.white)
      .shadow(color: .neonCyan, radius: 20)
      .offset(y: isVisible ? 0 : 60)
      .opacity(isVisible ? 1 : 0)
      .scaleEffect(isVisible ? 1.0 : 0.6)
      .onAppear {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
          isVisible = true
        }
      }
  }
}

struct BadgeView: View {
  let text: String
  let color: Color
  var icon: String? = "circle.fill"

  var body: some View {
    HStack(spacing: 6) {
      if let icon = icon {
        Image(systemName: icon)
          .font(.system(size: 8))
      }
      Text(text)
        .font(.system(size: 10, weight: .bold))
    }
    .foregroundColor(color)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(
      Capsule()
        .stroke(color, lineWidth: 1)
        .background(color.opacity(0.1))
    )
    .clipShape(Capsule())
  }
}

// MARK: - 缶を開けて泡が噴き出すアニメーション
struct PopAnimationOverlay: View {
  let fizzAmount: Double  // 0.0 ~ 1.0+

  // フェーズ管理
  @State private var phase: Int = 0  // 0:待機 1:缶表示 2:タブ引き上げ 3:口が開く 4:爆発 5:暗転
  @State private var isExploding = false
  @State private var flashOpacity = 0.0
  @State private var bgOpacity = 0.6  // TIME UPと同じ暗さでスタートしてチラつきを防止
  @State private var blurOpacity = 0.0  // 背景ボカシ

  // 缶の蓋アニメーション
  @State private var canScale: CGFloat = 0.3
  @State private var canOpacity: Double = 0.0
  @State private var tabLiftAngle: Double = 0.0  // プルタブの持ち上がり角度 (deg)
  @State private var tabLiftOffset: CGFloat = 0.0  // タブの縦移動
  @State private var holeScale: CGFloat = 0.0  // 缶の口の広がり具合

  private let particleCount: Int
  init(fizzAmount: Double) {
    self.fizzAmount = fizzAmount
    self.particleCount = Int(20.0 + min(fizzAmount * 40.0, 40.0))
  }

  var body: some View {
    GeometryReader { geo in
      ZStack {
        // 背景のプレイ画面をボカしてアニメーションを目立たせる（色は透けて見える）
        Rectangle()
          .fill(.ultraThinMaterial)
          .opacity(blurOpacity)
          .ignoresSafeArea()

        // 暗転用オーバーレイ（初期0.6 -> 最後は1.0）
        Color.black.opacity(bgOpacity).ignoresSafeArea()

        // --- Phase1〜3: 缶の天面 ---
        if phase >= 1 && phase < 5 {
          CanTopView(
            tabAngle: tabLiftAngle,
            tabOffset: tabLiftOffset,
            holeScale: holeScale
          )
          .frame(width: 180, height: 180)
          .scaleEffect(canScale)
          .opacity(canOpacity)
          .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }

        // --- Phase4: 泡パーティクル ---
        if phase >= 4 {
          ForEach(0..<particleCount, id: \.self) { i in
            PopBubbleParticle(
              isExploding: isExploding,
              fizzAmount: fizzAmount,
              index: i,
              total: particleCount,
              screenSize: geo.size
            )
          }
        }

        // 開栓フラッシュ
        Color.white.opacity(flashOpacity).ignoresSafeArea().blendMode(.overlay)
      }
    }
    .onAppear { startAnimation() }
  }

  private func startAnimation() {
    // 0: はじめに背景ボカシをスッと入れる
    withAnimation(.easeOut(duration: 0.2)) {
      blurOpacity = 1.0
    }

    // Phase 1: 缶の蓋がスッと素早く現れる
    phase = 1
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      canScale = 1.0
      canOpacity = 1.0
    }

    // Phase 2: プルタブを「ジリリ...」と引き上げる（開く直前の緊張感）
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      phase = 2
      withAnimation(.easeOut(duration: 0.4)) {
        tabLiftAngle = -35  // タブが少しためを作るように上がる
        tabLiftOffset = -5
      }
      // カチカチッという小さな振動でテンションを上げる
      let impact = UIImpactFeedbackGenerator(style: .rigid)
      impact.impactOccurred()
    }

    // Phase 3 & Phase 4: 「パシュッ！」と開栓し、直後に爆発
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
      phase = 3
      // 缶の口が開く ＋ タブが弾き飛ばされるように奥へ
      withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
        holeScale = 1.0
        tabLiftAngle = -120  // 手前を通り越して奥へバコンと倒れる
        tabLiftOffset = -25
        canScale = 1.15  // 圧力の反動で少し大きくなる
      }

      GameEventManager.shared.handleEvent(.canOpen)

      // 開栓時の圧力開放フラッシュ
      withAnimation(.easeOut(duration: 0.05)) { flashOpacity = 0.9 }
      withAnimation(.easeIn(duration: 0.25).delay(0.05)) { flashOpacity = 0.0 }

      // 泡が一瞬で爆発！（遅延ゼロで飛び出す）
      phase = 4
      withAnimation(.easeOut(duration: 0.6)) {
        isExploding = true
      }

      // 爆発の勢いで缶自体は少し遅れてフェードアウト
      withAnimation(.easeIn(duration: 0.2).delay(0.2)) {
        canOpacity = 0.0
      }
    }

    // Phase 5: 画面遷移に合わせて暗転
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      phase = 5
      withAnimation(.easeIn(duration: 0.5)) { bgOpacity = 1.0 }
    }
  }
}

// MARK: - 缶の天面（プルタブ付き）ビュー
private struct CanTopView: View {
  let tabAngle: Double  // プルタブの角度（0: 寝ている, -90: 完全に立つ）
  let tabOffset: CGFloat  // タブの縦オフセット
  let holeScale: CGFloat  // 開口部の大きさ（0→1）

  var body: some View {
    ZStack {
      // 缶天面（シルバーの楕円）
      Circle()
        .fill(
          RadialGradient(
            colors: [Color(white: 0.92), Color(white: 0.62)],
            center: .topLeading,
            startRadius: 10,
            endRadius: 90
          )
        )
        .overlay(Circle().stroke(Color(white: 0.45), lineWidth: 2))

      // 開口部（ダークな楕円が広がる）
      Ellipse()
        .fill(Color(white: 0.08))
        .frame(width: 52 * holeScale, height: 28 * holeScale)
        .offset(y: 6)
        .opacity(holeScale > 0.01 ? 1 : 0)

      // リベット（留め具）の小さな円
      Circle()
        .fill(Color(white: 0.55))
        .frame(width: 10, height: 10)
        .offset(y: 20)

      // プルタブ本体
      PullTabShape()
        .fill(
          LinearGradient(
            colors: [Color(white: 0.88), Color(white: 0.55)],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .frame(width: 26, height: 44)
        .overlay(PullTabShape().stroke(Color(white: 0.4), lineWidth: 1))
        .rotation3DEffect(
          .degrees(tabAngle),
          axis: (x: 1, y: 0, z: 0),
          anchor: .bottom, perspective: 0.4
        )
        .offset(y: -14 + tabOffset)
    }
  }
}

// プルタブの形状（丸みを帯びた長方形 + 上端のリング）
private struct PullTabShape: Shape {
  func path(in rect: CGRect) -> Path {
    var p = Path()
    let w = rect.width
    let h = rect.height
    let ringR: CGFloat = w * 0.38
    // 上部リング
    p.addEllipse(in: CGRect(x: w / 2 - ringR, y: 0, width: ringR * 2, height: ringR * 2))
    p.addEllipse(
      in: CGRect(
        x: w / 2 - ringR * 0.55, y: ringR * 0.45,
        width: ringR * 1.1, height: ringR * 1.1))
    // 本体（下半分）
    let bodyY = ringR * 1.6
    let bodyH = h - bodyY
    let cr: CGFloat = w * 0.25
    p.move(to: CGPoint(x: cr, y: bodyY))
    p.addLine(to: CGPoint(x: w - cr, y: bodyY))
    p.addQuadCurve(
      to: CGPoint(x: w, y: bodyY + cr),
      control: CGPoint(x: w, y: bodyY))
    p.addLine(to: CGPoint(x: w, y: bodyY + bodyH - cr))
    p.addQuadCurve(
      to: CGPoint(x: w - cr, y: bodyY + bodyH),
      control: CGPoint(x: w, y: bodyY + bodyH))
    p.addLine(to: CGPoint(x: cr, y: bodyY + bodyH))
    p.addQuadCurve(
      to: CGPoint(x: 0, y: bodyY + bodyH - cr),
      control: CGPoint(x: 0, y: bodyY + bodyH))
    p.addLine(to: CGPoint(x: 0, y: bodyY + cr))
    p.addQuadCurve(
      to: CGPoint(x: cr, y: bodyY),
      control: CGPoint(x: 0, y: bodyY))
    p.closeSubpath()
    return p
  }
}

// 爆発する個別の泡パーティクル
private struct PopBubbleParticle: View {
  let isExploding: Bool
  let fizzAmount: Double
  let index: Int
  let total: Int
  let screenSize: CGSize

  @State private var randomX: CGFloat = 0
  @State private var randomY: CGFloat = 0
  @State private var randomScale: CGFloat = 1.0

  var body: some View {
    let baseSize = 16 * randomScale
    Circle()
      .fill(Color.white.opacity(Double.random(in: 0.5...1.0)))
      .frame(width: baseSize, height: baseSize)
      // 初期状態は画面中央下寄り、爆発後はランダムな方向へ
      .offset(
        x: isExploding ? randomX : 0,
        y: isExploding ? randomY : screenSize.height * 0.2
      )
      .scaleEffect(isExploding ? randomScale * 1.5 : randomScale)
      .opacity(isExploding ? 0.0 : 1.0)
      // 弾け飛ぶ勢いを表現するため遅延をなくし、一斉に飛び出す
      .animation(.easeOut(duration: Double.random(in: 0.4...0.7)), value: isExploding)
      .onAppear {
        let spreadMultiplier = 1.0 + fizzAmount * 1.5
        let angle = Double.random(in: -Double.pi...Double.pi)
        let distance = Double.random(in: 100...(Double(screenSize.height) * 0.6 * spreadMultiplier))

        // 上方向に吹き出しやすくする
        let upwardBias = -abs(distance) * 0.6

        self.randomX = CGFloat(cos(angle) * distance)
        self.randomY = CGFloat(sin(angle) * distance + upwardBias)
        self.randomScale = CGFloat.random(in: 0.3...1.5)
      }
  }
}
