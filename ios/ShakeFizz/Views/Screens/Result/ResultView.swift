import SwiftUI

struct ResultView: View {
  @ObservedObject var viewModel: GameViewModel
  @AppStorage("bestScore") private var bestScore: Double = 0.0

  // フェーズ制御
  @State private var showTier1 = false
  @State private var showTier2 = false
  @State private var showTier3 = false
  @State private var showTier4 = false

  // スコアカウントアップ
  @State private var displayedScore: Double = 0.0
  @State private var showScoreGlow = false

  // ランキングカウントアップ
  @State private var displayedRank: Int = 10000

  // 画面フラッシュ
  @State private var flashOpacity: Double = 0.0

  // アニメーション制御

  // ボタン脈動
  @State private var tryAgainPulse = false

  // シート
  @State private var showRankingSheet = false

  // 炭酸爆発演出
  @State private var showFizzColumn = false
  @State private var screenShakeX: CGFloat = 0

  // MARK: - Helpers

  /// スコアに応じた泡パーティクル量を返す
  private func fizzParticleCount(score: Double) -> Int {
    switch score {
    case 15.0...: return 38
    case 5.0..<15.0: return 18
    case 1.0..<5.0: return 8
    default: return 3
    }
  }

  private func realWorldComparison(meters: Double) -> String {
    switch meters {
    // 伝説・規格外ゾーン (2000m ~ 100,000m+)
    case 100000.0...: return "comp_100000"
    case 30000.0..<100000.0: return "comp_30000"
    case 10000.0..<30000.0: return "comp_10000"
    case 3776.0..<10000.0: return "comp_3776"
    case 2000.0..<3776.0: return "comp_2000"

    // 上級・ランドマークゾーン (50m ~ 1000m)
    case 1000.0..<2000.0: return "comp_1000"
    case 630.0..<1000.0: return "comp_630"
    case 500.0..<630.0: return "comp_500"
    case 333.0..<500.0: return "comp_333"
    case 300.0..<333.0: return "comp_300"
    case 200.0..<300.0: return "comp_200"
    case 150.0..<200.0: return "comp_150"
    case 100.0..<150.0: return "comp_100"
    case 80.0..<100.0: return "comp_80"
    case 50.0..<80.0: return "comp_50"

    // 中級・街中ゾーン (5m ~ 30m)
    case 30.0..<50.0: return "comp_30"
    case 20.0..<30.0: return "comp_20"
    case 15.0..<20.0: return "comp_15"
    case 10.0..<15.0: return "comp_10"
    case 7.0..<10.0: return "comp_7"
    case 5.0..<7.0: return "comp_5"

    // 初心者・日常ゾーン (0m ~ 3m)
    case 3.0..<5.0: return "comp_3"
    case 2.0..<3.0: return "comp_2"
    case 1.5..<2.0: return "comp_1_5"
    case 1.0..<1.5: return "comp_1"
    case 0.8..<1.0: return "comp_0_8"
    case 0.5..<0.8: return "comp_0_5"
    case 0.3..<0.5: return "comp_0_3"
    case 0.1..<0.3: return "comp_0_1"
    default: return "comp_0"
    }
  }

  private func shareText(session: Session) -> String {
    let baseText = String(format: NSLocalizedString("share_result_text", comment: ""), session.score)
    let comparisonKey = realWorldComparison(meters: session.score)
    let localizedComparison = NSLocalizedString(comparisonKey, comment: "")
    return "\(baseText)\n\(localizedComparison)\n#ShakeFizz"
  }

  private func animateScore(to target: Double) {
    let steps = 25
    let duration = 0.55
    let interval = duration / Double(steps)
    for i in 1...steps {
      DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
        displayedScore = target * (Double(i) / Double(steps))
        if i == steps { showScoreGlow = true }
      }
    }
  }

  private func animateRank(to target: Int) {
    // 順位は「下がる（数が減る）ほど良い」ため、10000位等からダウントレンドでカウントする
    displayedRank = 10000
    let steps = 20
    let duration = 0.4
    let interval = duration / Double(steps)

    // 現在のスコアの順位（目標値）まで一気に数字を減らすアニメーション
    let startRank = 10000
    let diff = startRank - target

    for i in 1...steps {
      DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
        let progress = Double(i) / Double(steps)
        // イーズアウト（徐々に遅くなる）カーブで数字を減らす
        let easedProgress = 1.0 - pow(1.0 - progress, 3)
        displayedRank = startRank - Int(Double(diff) * easedProgress)
        // 最終ステップで確実な値にする
        if i == steps { displayedRank = target }
      }
    }
  }

  // MARK: - Body

  var body: some View {
    ZStack {
      BackgroundView()

      // 画面フラッシュオーバーレイ
      Color.white
        .opacity(flashOpacity)
        .ignoresSafeArea()
        .allowsHitTesting(false)

      // ═══ 炭酸爆発カラム ═══
      if showFizzColumn, let session = viewModel.currentSession, session.score > 0 {
        FizzColumnView(
          score: session.score,
          color: session.drinkType.accentColor,
          particleCount: fizzParticleCount(score: session.score)
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
      }

      VStack(spacing: 0) {
        // ヘッダー
        HStack {
          Spacer()
          Text(LocalizedStringKey("shaken"))
            .font(.system(size: 20, weight: .black))
            .foregroundColor(.white)
            .shadow(color: .white.opacity(0.5), radius: 10)
          Spacer()
        }
        .padding(.vertical, 12)

        if let session = viewModel.currentSession {

          VStack(spacing: 0) {

            Spacer()

            // ─── コンテンツエリア ───
            VStack(spacing: 22) {

              // ════ Phase 1: スコア爆発 (0s) ════
              if showTier1 {
                VStack(spacing: 8) {
                  if session.score <= 0.0 {
                    VStack(spacing: 6) {
                      Text(LocalizedStringKey("dash_symbol"))
                        .font(.system(size: 96, weight: .black))
                        .foregroundColor(.gray)
                      Text(LocalizedStringKey("try_harder"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.neonCyan)
                    }
                  } else {
                    // スコア（カウントアップ）
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                      Text(String(format: "%.1f", displayedScore))
                        .font(.system(size: 96, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(
                          color: showScoreGlow
                            ? session.drinkType.accentColor.opacity(0.9) : .clear,
                          radius: 24
                        )
                        .animation(.easeOut(duration: 0.4), value: showScoreGlow)

                      Text(LocalizedStringKey("meters_label"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(session.drinkType.accentColor)
                    }

                    // リアル比較コピー
                    Text(LocalizedStringKey(realWorldComparison(meters: session.score)))
                      .font(.system(size: 16, weight: .heavy, design: .rounded))
                      .foregroundColor(.white.opacity(0.75))
                      .padding(.top, 2)

                  }
                }
                .transition(.scale.combined(with: .opacity))
              }

              // ════ Phase 2: ランクバッジ + NEW RECORD (0.4s) ════
              if showTier2 {
                VStack(spacing: 12) {

                  // NEW RECORD
                  if session.isPersonalBest && session.score > 0 {
                    HStack(spacing: 6) {
                      Image(systemName: "star.fill")
                        .foregroundColor(session.drinkType.accentColor)
                      Text(LocalizedStringKey("new_record"))
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                      if bestScore > 0 {
                        Text(String(format: "(%.1f)", bestScore))
                          .font(.system(size: 11, weight: .bold, design: .rounded))
                          .foregroundColor(.white.opacity(0.8))
                      }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                  }

                  // リーグバッジ（リッチ化・枠線排除）
                  if session.rankNumber != nil {
                    let baseColor = session.drinkType.accentColor

                    Button(action: { showRankingSheet = true }) {
                      HStack(spacing: 10) {
                        Image(systemName: session.drinkType.leagueIcon)
                          .font(.system(size: 16, weight: .bold))
                          .foregroundColor(baseColor)
                          .shadow(color: baseColor.opacity(0.6), radius: 4)

                        VStack(alignment: .leading, spacing: 2) {
                          Text(session.drinkType.leagueName)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(baseColor)

                          HStack(spacing: 2) {
                            Text(LocalizedStringKey("league_rank_label"))
                              .font(.system(size: 14, weight: .heavy, design: .rounded))
                              .foregroundColor(.white.opacity(0.6))
                            Text("\(displayedRank)")
                              .font(.system(size: 20, weight: .black, design: .rounded))
                              .foregroundColor(.white)
                              // 値が変わった時にモヤッとスケールアップするアニメーション
                              .animation(
                                .spring(response: 0.2, dampingFraction: 0.5), value: displayedRank)
                          }
                        }

                        Image(systemName: "chevron.right")
                          .font(.system(size: 14, weight: .bold))
                          .foregroundColor(.white.opacity(0.3))
                          .padding(.leading, 4)
                      }
                      .padding(.horizontal, 18)
                      .padding(.vertical, 10)
                      .background(Color.white.opacity(0.08))
                      .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    // バッジ出現時に軽くバウンスさせる
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                  }
                }
                .transition(.scale.combined(with: .opacity))
              }

              // ════ 次の目標用スペース（空き） ════
              // Phase 3の要素は削除されました

              // ════ スタッツカード ════
              if showTier3 && session.score > 0 {
                HStack(spacing: 12) {
                  let topSpeedDisplay =
                    session.topSpeed > 0
                    ? String(format: "%.0f", session.topSpeed * 3.6)
                    : String(localized: "dash_symbol")

                  let baseColor = session.drinkType.accentColor  // 視認性の高いアクセントカラーを使用

                  ResultStatCard(
                    title: "top_speed",
                    value: topSpeedDisplay,
                    unit: "km_h",
                    icon: "bolt.fill",
                    color: baseColor)
                  ResultStatCard(
                    title: "total_shakes",
                    value: "\(session.totalShakes)",
                    unit: "times",
                    icon: "drop.fill",
                    color: baseColor)
                }
                .padding(.horizontal)
                .transition(.opacity)
              }
            }
            // ─── コンテンツエリア終了 ───

            Spacer()

            // ════ Phase 4: アクションボタン (1.2s) ════
            if showTier4 {
              VStack(spacing: 14) {

                // TRY AGAIN（固定カラー .neonCyan）
                if viewModel.fizzRemaining > 0 {
                  NeonButton(
                    title: LocalizedStringKey("try_again"),
                    color: .neonCyan,
                    icon: "arrow.clockwise"
                  ) {
                    let fromZero = session.score <= 0.0
                    viewModel.retryGame(fromZero: fromZero)
                  }
                  .scaleEffect(tryAgainPulse ? 1.04 : 1.0)
                  .shadow(
                    color: .neonCyan.opacity(tryAgainPulse ? 0.7 : 0.3),
                    radius: tryAgainPulse ? 18 : 8
                  )
                  .animation(
                    .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                    value: tryAgainPulse
                  )
                  .onAppear { tryAgainPulse = true }
                }

                // SHARE（グラスモーフィズム風ワイドボタン）
                if session.score > 0 {
                  ShareLink(item: shareText(session: session)) {
                    HStack(spacing: 8) {
                      Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                      Text("share")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.12))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                  }
                  .padding(.horizontal, 4)
                }

                // HOME（ゴーストボタン）
                Button(action: { viewModel.resetGame() }) {
                  Text(LocalizedStringKey("home"))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .underline()
                }
              }
              .padding(.horizontal)
              .padding(.bottom, 40)
              .transition(.opacity)
            }
          }

        } else {
          Spacer()
          Text(LocalizedStringKey("no_data"))
            .font(.headline)
            .foregroundColor(.gray)
          Spacer()
        }
      }
      .offset(x: screenShakeX)
      .onAppear {
        guard let session = viewModel.currentSession else { return }

        // ── 0.0s〜0.32s: 缶ブルブル振動（爆発前の"緊張感"）
        // 8ステップで振幅を徐々に大きくしていく
        let preShakeCount = 8
        for i in 0..<preShakeCount {
          let t = Double(i) * 0.04
          let amp = CGFloat(i + 1) * 1.8
          DispatchQueue.main.asyncAfter(deadline: .now() + t) {
            withAnimation(.easeInOut(duration: 0.032)) {
              screenShakeX = i.isMultiple(of: 2) ? amp : -amp
            }
          }
        }

        // ── 0.32s: 静寂（缶オープン直前の"間"）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
          withAnimation(.easeOut(duration: 0.06)) { screenShakeX = 0 }
        }

        // ── 0.38s: 爆発！ フラッシュ + 炭酸カラム噴射
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
          if session.score > 0 {
            withAnimation(.none) { flashOpacity = 0.85 }
            withAnimation(.easeOut(duration: 0.22)) { flashOpacity = 0.0 }
            showFizzColumn = true
          }

          // 高スコア（15m以上）は爆発後の画面揺れも発動
          if session.score >= 15.0 {
            let shakeTimes: [Double] = [0.08, 0.16, 0.24, 0.32]
            for (i, t) in shakeTimes.enumerated() {
              DispatchQueue.main.asyncAfter(deadline: .now() + t) {
                withAnimation(.easeInOut(duration: 0.06)) {
                  screenShakeX = i.isMultiple(of: 2) ? 9 : -9
                }
              }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { screenShakeX = 0 }
            }
          }
        }

        // ── 0.72s: スコアポップ（炭酸の柱の中から飛び出す）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
          if session.score > 0 { animateScore(to: session.score) }
          withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) { showTier1 = true }
        }

        // ── 1.1s: ランクバッジ・スタッツ
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
          withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showTier2 = true
            showTier3 = true
          }
          if let rank = session.rankNumber { animateRank(to: rank) }
        }

        // ── 1.5s: アクションボタン
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          withAnimation(.easeOut(duration: 0.3)) { showTier4 = true }
        }
      }
      .sheet(isPresented: $showRankingSheet) {
        if let session = viewModel.currentSession {
          LeagueRankingView(currentRank: session.rankNumber ?? 0, currentScore: session.score)
        }
      }
    }
  }
}

// MARK: - ResultStatCard

struct ResultStatCard: View {
  let title: LocalizedStringKey
  let value: String
  let unit: LocalizedStringKey
  let icon: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: icon)
          .font(.system(size: 12))
          .foregroundColor(color)
        Text(title)
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(.white.opacity(0.6))
      }

      HStack(alignment: .lastTextBaseline, spacing: 4) {
        Text(value)
          .font(.system(size: 24, weight: .black, design: .rounded))
          .foregroundColor(.white.opacity(0.9))
        Text(unit)
          .font(.system(size: 11, weight: .bold, design: .rounded))
          .foregroundColor(.white.opacity(0.5))
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(14)
    .background(Color.white.opacity(0.04))
    .overlay(
      RoundedRectangle(cornerRadius: 14)
        .stroke(color.opacity(0.5), lineWidth: 1.5)
    )
    .cornerRadius(14)
  }
}

// MARK: - FizzColumnView

struct FizzColumnView: View {
  let score: Double
  let color: Color
  let particleCount: Int

  struct BubbleConfig: Identifiable {
    let id = UUID()
    let x: CGFloat
    let size: CGFloat
    let delay: Double
    let riseH: CGFloat
  }

  @State private var columnHeight: CGFloat = 0
  @State private var glowOpacity: Double = 0
  @State private var bubbles: [BubbleConfig] = []

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .bottom) {

        // ── 底面グロー（液体の溜まり感）
        Ellipse()
          .fill(color.opacity(0.28))
          .frame(width: 220, height: 55)
          .blur(radius: 30)
          .opacity(glowOpacity)
          .offset(y: 28)

        // ── 液体柱グラデーション
        LinearGradient(
          colors: [color.opacity(0.65), color.opacity(0.3), .clear],
          startPoint: .bottom,
          endPoint: .top
        )
        .frame(width: 70, height: columnHeight)
        .blur(radius: 22)
        .animation(.easeOut(duration: 0.52), value: columnHeight)

        // ── 泡パーティクル
        ForEach(bubbles) { b in
          RisingBubble(color: color, size: b.size, x: b.x, riseH: b.riseH, delay: b.delay)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      .onAppear {
        let target = min(CGFloat(score) * 18.0, geo.size.height * 0.90)
        bubbles = (0..<particleCount).map { i in
          BubbleConfig(
            x: CGFloat.random(in: -62...62),
            size: CGFloat.random(in: 5...16),
            delay: Double(i) * 0.032,
            riseH: target * CGFloat.random(in: 0.3...1.0)
          )
        }
        withAnimation(.easeOut(duration: 0.52)) {
          columnHeight = target
          glowOpacity = 1.0
        }
        // 1.3秒後にフェードアウト
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
          withAnimation(.easeIn(duration: 0.5)) {
            columnHeight = 0
            glowOpacity = 0
          }
        }
      }
    }
  }
}

// MARK: - RisingBubble

struct RisingBubble: View {
  let color: Color
  let size: CGFloat
  let x: CGFloat
  let riseH: CGFloat
  let delay: Double

  @State private var offsetY: CGFloat = 0
  @State private var opacity: Double = 0

  var body: some View {
    Circle()
      .fill(color.opacity(opacity))
      .frame(width: size, height: size)
      .blur(radius: size * 0.18)
      .offset(x: x, y: -offsetY)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          withAnimation(.easeIn(duration: 0.12)) { opacity = 0.85 }
          withAnimation(.easeOut(duration: Double.random(in: 0.55...1.05))) {
            offsetY = riseH
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.4)) { opacity = 0 }
          }
        }
      }
  }
}

// MARK: - Hex Color Helper

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }
    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}
