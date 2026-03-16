import SwiftUI

struct BannerCarouselView: View {
  @State private var currentPage = 0
  @State private var slideCounter = 0
  @State private var autoSlideTimer: Timer?

  private let pageCount = 3
  private let autoSlideInterval: TimeInterval = 4.0

  var body: some View {
    TabView(selection: $currentPage) {
      EventBannerView().tag(0)
      LinkAdBannerView().tag(1)
      HowToPlayEventBannerView().tag(2)
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    .frame(height: 100)
    .padding(.bottom, 4)
    .onChange(of: slideCounter) { _, newValue in
      withAnimation(.easeInOut(duration: 0.35)) {
        currentPage = newValue % pageCount
      }
    }
    .onAppear {
      startAutoSlide()
    }
    .onDisappear {
      autoSlideTimer?.invalidate()
      autoSlideTimer = nil
    }
  }

  private func startAutoSlide() {
    autoSlideTimer?.invalidate()
    let timer = Timer.scheduledTimer(withTimeInterval: autoSlideInterval, repeats: true) { _ in
      slideCounter += 1
    }
    autoSlideTimer = timer
    RunLoop.main.add(timer, forMode: .common)
  }
}

struct EventBannerView: View {
  private let eventTitle = LocalizedStringKey("lime_burst_fever")
  private let eventEndsIn = "14h"
  private let rewardsTag = LocalizedStringKey("reward_2x")

  var body: some View {
    eventBannerBackground
      .overlay(eventBannerContent)
  }

  private var eventBannerBackground: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.ultraThinMaterial)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .fill(
            LinearGradient(
              colors: [Color.neonMagenta.opacity(0.4), Color.neonCyan.opacity(0.2)],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(
            LinearGradient(
              colors: [.white.opacity(0.3), .white.opacity(0.1)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1
          )
      )
      .shadow(color: .neonMagenta.opacity(0.2), radius: 10, x: 0, y: 4)
  }

  private var eventBannerContent: some View {
    HStack {
      eventBannerLeft
      eventBannerRewardsTag
    }
  }

  private var eventBannerLeft: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 6) {
        Text(LocalizedStringKey("live_now"))
          .font(.system(size: 9, weight: .black))
          .foregroundColor(.neonMagenta)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Capsule().fill(Color.neonMagenta.opacity(0.3)))
        Image(systemName: "clock")
          .font(.system(size: 10))
          .foregroundColor(.white.opacity(0.8))
        Text("ends_in_time \(eventEndsIn)")
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(.white.opacity(0.9))
      }
      Text(LocalizedStringKey("weekly_event"))
        .font(.system(size: 11, weight: .bold))
        .foregroundColor(.white.opacity(0.9))
      Text(eventTitle)
        .font(.system(size: 18, weight: .black))
        .foregroundColor(.white)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.leading, 14)
    .padding(.vertical, 12)
  }

  private var eventBannerRewardsTag: some View {
    HStack(spacing: 4) {
      Image(systemName: "flame.fill")
        .font(.system(size: 10))
      Text(rewardsTag)
        .font(.system(size: 11, weight: .black))
    }
    .foregroundColor(.orange)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(Capsule().fill(Color.black.opacity(0.3)))
    .overlay(Capsule().stroke(Color.orange.opacity(0.5), lineWidth: 1))
    .padding(.trailing, 10)
  }
}

struct LinkAdBannerView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.ultraThinMaterial)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.black.opacity(0.4))
      )
      .overlay(
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey("advertisement"))
              .font(.system(size: 9, weight: .bold))
              .foregroundColor(.white.opacity(0.5))
            Text(LocalizedStringKey("support_shakefizz"))
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(.white)
            Text(LocalizedStringKey("tap_to_learn_more"))
              .font(.system(size: 12))
              .foregroundColor(.neonCyan)
          }
          Spacer()
          Image(systemName: "arrow.up.right.square.fill")
            .font(.system(size: 24))
            .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 20)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
      )
  }
}

struct HowToPlayEventBannerView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.ultraThinMaterial)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .fill(
            LinearGradient(
              colors: [Color.neonCyan.opacity(0.3), Color.blue.opacity(0.2)],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
      )
      .overlay(
        HStack(spacing: 16) {
          Image(systemName: "iphone.radiowaves.left.and.right")
            .font(.system(size: 32))
            .foregroundColor(.white)

          VStack(alignment: .leading, spacing: 2) {
            Text(LocalizedStringKey("how_to_play_upper"))
              .font(.system(size: 10, weight: .black))
              .foregroundColor(.neonCyan)
            Text(LocalizedStringKey("select_and_shake"))
              .font(.system(size: 16, weight: .heavy))
              .foregroundColor(.white)
            Text(LocalizedStringKey("fill_the_gauge"))
              .font(.system(size: 12))
              .foregroundColor(.white.opacity(0.8))
          }
          Spacer()
        }
        .padding(.horizontal, 20)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
      )
  }
}
