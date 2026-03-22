import SwiftUI

struct DrinkCard: View {
  let type: DrinkType
  let isSelected: Bool
  var rankNumber: Int?
  var bestMeters: Double?

  @State private var isPressed = false
  @State private var lockPulse = false

  var body: some View {
    ZStack(alignment: .bottom) {
      // 1. 背面のカード（ボックス部分）
      VStack(spacing: 0) {
        Spacer().frame(height: 40)
        drinkCardBase
      }

      // 2. 前面の缶（フレーム・ブレイク）
      drinkCardImageSection
        .offset(y: isPressed ? -40 : -50)
        .zIndex(1)
        .opacity(type.isLocked ? 0.8 : 1.0)
        .saturation(type.isLocked ? 0.2 : 1.0)  // ロック時は色を抜く
        .brightness(type.isLocked ? -0.2 : 0)  // 少し暗くする

      // 3. ロック・オーバーレイ（全体を覆う）
      if type.isLocked {
        drinkCardLockedOverlay
          .zIndex(2)
      }
    }
    .scaleEffect(isPressed ? 0.97 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    .animation(.easeInOut(duration: 0.3), value: isSelected)
    .onLongPressGesture(
      minimumDuration: .infinity, maximumDistance: .infinity,
      pressing: { pressing in isPressed = pressing }, perform: {}
    )
  }

  private var drinkCardBase: some View {
    drinkCardInfoSection
      .background(drinkCardOuterBackground)
      .overlay(drinkCardBorder)
      .clipShape(RoundedRectangle(cornerRadius: 24))
      .shadow(
        color: isSelected ? Color.neonCyan.opacity(0.3) : Color.black.opacity(0.2),
        radius: isSelected ? 12 : 6,
        x: 0,
        y: 4
      )
  }

  private var drinkCardImageSection: some View {
    ZStack(alignment: .center) {
      // 選択時の背面放射状光（グロー）
      if isSelected {
        Circle()
          .fill(type.accentColor.opacity(0.5))
          .frame(width: 150, height: 150)
          .blur(radius: 40)
          .scaleEffect(isPressed ? 0.9 : 1.1)
          .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPressed)
      }

      Image(type.imageName)
        .resizable()
        .scaledToFit()
        .frame(height: 180)
        .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 15)
        .shadow(color: type.accentColor.opacity(isSelected ? 0.5 : 0), radius: 20, x: 0, y: 0)

      if isSelected {
        Text(LocalizedStringKey("active_upper"))
          .font(.system(size: 10, weight: .heavy))
          .foregroundColor(.black)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background(
            Capsule()
              .fill(Color.neonCyan)
              .shadow(color: .neonCyan.opacity(0.6), radius: 8)
          )
          .offset(x: 45, y: -50)
      }
    }
  }

  @ViewBuilder
  private var drinkCardInfoSection: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(type.displayName)
        .font(.system(size: 18, weight: .black))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
        .minimumScaleFactor(0.8)

      // ランク行を下に配置
      drinkCardRankBestRow
        .opacity(type.isLocked ? 0 : 1)
    }
    .frame(minHeight: 60)
    .padding(.horizontal, 16)
    .padding(.top, 115)
    .padding(.bottom, 12)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.black.opacity(0.4))
        .overlay(
          // カード上部に奥行きを出すグラデーション
          LinearGradient(
            colors: [type.backgroundColor.opacity(0.2), .clear],
            startPoint: .top,
            endPoint: .center
          )
          .clipShape(RoundedRectangle(cornerRadius: 16))
        )
    )
  }

  private var drinkCardRankBestRow: some View {
    HStack(spacing: 8) {
      Group {
        if let rank = rankNumber {
          Text("rank_number \(rank)")
            .foregroundColor(.neonCyan)
        } else {
          Text(LocalizedStringKey("rank_number_none"))
            .foregroundColor(.white.opacity(0.5))
        }

        if let best = bestMeters {
          Text("best_meters_format \(String(format: "%.1f", best))")
            .foregroundColor(.white.opacity(0.9))
        } else {
          Text(LocalizedStringKey("best_meters_none"))
            .foregroundColor(.white.opacity(0.5))
        }
      }
      .font(.system(size: 10, weight: .bold))
    }
  }

  private var drinkCardOuterBackground: some View {
    RoundedRectangle(cornerRadius: 24)
      .fill(Color.black.opacity(0.3))
  }

  private var drinkCardBorder: some View {
    RoundedRectangle(cornerRadius: 24)
      .strokeBorder(
        isSelected
          ? LinearGradient(
            colors: [Color.neonCyan, Color.neonCyan.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          : LinearGradient(
            colors: [Color.white.opacity(0.15), Color.white.opacity(0.02)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
        lineWidth: isSelected ? 2 : 1
      )
  }

  @ViewBuilder
  private var drinkCardLockedOverlay: some View {
    ZStack {
      // 全体を薄く暗くする（ボックス部分のみ）
      VStack(spacing: 0) {
        Spacer().frame(height: 50)
        RoundedRectangle(cornerRadius: 24)
          .fill(Color.black.opacity(0.4))
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .allowsHitTesting(false)

      // 缶の上部付近に鍵アイコンを配置
      VStack(spacing: 12) {
        // パルスアニメーション付きの鍵アイコン
        ZStack {
          Circle()
            .fill(Color.neonYellow.opacity(lockPulse ? 0.2 : 0.1))
            .frame(width: 60, height: 60)
            .blur(radius: 8)

          Circle()
            .fill(Color.black.opacity(0.6))
            .frame(width: 48, height: 48)
            .overlay(Circle().stroke(Color.neonYellow.opacity(0.5), lineWidth: 1.5))

          Image(systemName: "lock.fill")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.neonYellow)
            .shadow(color: .neonYellow.opacity(lockPulse ? 0.8 : 0.4), radius: 8)
        }
        .padding(.top, 60)

        // LOCKEDバッジ
        Text("COMING SOON")
          .font(.system(size: 10, weight: .black))
          .tracking(2)
          .foregroundColor(.neonYellow)
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(
            Capsule()
              .fill(Color.black.opacity(0.7))
              .overlay(Capsule().stroke(Color.neonYellow.opacity(0.3), lineWidth: 1))
          )

        Spacer()
      }
    }
    .onAppear { lockPulse = true }
  }
}
