import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var languageManager: LanguageManager
  @EnvironmentObject var settingsManager: SettingsManager
  @Environment(\.dismiss) var dismiss
  @State private var showHelp = false

  var body: some View {
    ZStack {
      BackgroundView()

      VStack(spacing: 0) {
        // Header
        HStack {
          Button(action: {
            dismiss()
          }) {
            Image(systemName: "chevron.left")
              .font(.title2)
              .foregroundColor(.white)
              .padding(8)
              .background(Circle().fill(Color.white.opacity(0.1)))
          }

          Spacer()

          Text("SETTINGS")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.neonCyan)
            .tracking(1.5)

          Spacer()

          Button(action: {
            // TODO: Share functionality
          }) {
            Image(systemName: "square.and.arrow.up")
              .font(.title2)
              .foregroundColor(.white)
              .padding(8)
              .background(Circle().fill(Color.white.opacity(0.1)))
          }
        }
        .padding(.horizontal)
        .padding(.top, 10)

        ScrollView {
          VStack(spacing: 24) {
            // Profile Section
            NewProfileSection()

            // General Section
            GeneralSection(showHelp: $showHelp)
              .environmentObject(languageManager)

            // Immersion Section
            ImmersionSection()
              .environmentObject(settingsManager)

            // About Section
            AboutSection()

            // Footer
            FooterSection()

            Spacer(minLength: 80)
          }
          .padding(.horizontal, 16)
          .padding(.top, 16)
        }
      }
    }
    .sheet(isPresented: $showHelp) {
      HelpSheetView()
    }
  }
}

// MARK: - New Profile Section
struct NewProfileSection: View {
  var body: some View {
    Button(action: {
      // TODO: Edit profile action
    }) {
      HStack(spacing: 16) {
        // Profile Image with Rainbow Border
        ZStack(alignment: .bottomLeading) {
          Circle()
            .strokeBorder(
              AngularGradient(
                gradient: Gradient(colors: [
                  .red, .orange, .yellow, .green, .cyan, .blue, .purple, .red,
                ]),
                center: .center
              ),
              lineWidth: 3
            )
            .frame(width: 70, height: 70)
            .background(
              Circle()
                .fill(Color.black.opacity(0.5))
            )
            .overlay(
              Image("can_ultra_cola")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            )

          // PRO Badge
          Text("PRO")
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
              Capsule()
                .fill(Color.neonMagenta)
            )
            .offset(x: -4, y: 4)
        }

        // User Info
        VStack(alignment: .leading, spacing: 4) {
          Text(LocalizedStringKey("fizz_master"))
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
        }

        Spacer()

        // Visual Indicator
        Image(systemName: "chevron.right")
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(.white.opacity(0.3))
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.black.opacity(0.4))
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
          )
      )
    }
    .buttonStyle(TappableCardStyle())
  }
}

// MARK: - General Section
struct GeneralSection: View {
  @EnvironmentObject var languageManager: LanguageManager
  @Binding var showHelp: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Section Title
      Text(LocalizedStringKey("general"))
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.white)
        .tracking(1.5)

      VStack(spacing: 0) {
        // Language
        SettingLanguageRow(
          icon: "globe",
          iconColor: .gray,
          title: "language"
        )

        Divider()
          .background(Color.white.opacity(0.1))
          .padding(.leading, 52)

        // How to Play
        Button(action: { showHelp = true }) {
          HStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
              .font(.system(size: 20))
              .foregroundColor(.gray)
              .frame(width: 24)

            Text(LocalizedStringKey("how_to_play_title"))
              .font(.system(size: 15, weight: .semibold))
              .foregroundColor(.white)

            Spacer()

            Image(systemName: "chevron.right")
              .font(.system(size: 14, weight: .bold))
              .foregroundColor(.white.opacity(0.3))
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 14)
        }
      }
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.black.opacity(0.4))
      )
    }
  }
}

// MARK: - Setting Language Row
struct SettingLanguageRow: View {
  @EnvironmentObject var languageManager: LanguageManager
  let icon: String
  let iconColor: Color
  let title: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(iconColor)
        .frame(width: 24)

      Text(LocalizedStringKey(title))
        .font(.system(size: 15, weight: .semibold))
        .foregroundColor(.white)

      Spacer()

      Menu {
        Button(action: { languageManager.setLanguage("en") }) {
          HStack {
            Text(LocalizedStringKey("english"))
            if languageManager.locale.identifier.starts(with: "en") {
              Image(systemName: "checkmark")
            }
          }
        }
        Button(action: { languageManager.setLanguage("ja") }) {
          HStack {
            Text(LocalizedStringKey("japanese"))
            if languageManager.locale.identifier.starts(with: "ja") {
              Image(systemName: "checkmark")
            }
          }
        }
      } label: {
        HStack(spacing: 4) {
          Text(languageManager.locale.identifier.starts(with: "ja") ? LocalizedStringKey("japanese") : LocalizedStringKey("english"))
            .font(.system(size: 14))
            .foregroundColor(.gray)
          Image(systemName: "chevron.up.chevron.down")
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
  }
}

// MARK: - About Section
struct AboutSection: View {
  let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Section Title
      Text(LocalizedStringKey("about_title"))
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.white)
        .tracking(1.5)

      VStack(spacing: 0) {
        // Version
        HStack(spacing: 12) {
          Image(systemName: "info.circle")
            .font(.system(size: 20))
            .foregroundColor(.gray)
            .frame(width: 24)
          Text(LocalizedStringKey("version"))
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
          Spacer()
          Text(appVersion)
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)

        Divider()
          .background(Color.white.opacity(0.1))
          .padding(.leading, 52)

        // Credits
        HStack(spacing: 12) {
          Image(systemName: "person.2.fill")
            .font(.system(size: 18))
            .foregroundColor(.gray)
            .frame(width: 24)
          Text(LocalizedStringKey("credits"))
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
          Spacer()
          Text(LocalizedStringKey("developer_team"))
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)

        Divider()
          .background(Color.white.opacity(0.1))
          .padding(.leading, 52)

        // Rate App
        Button(action: {
          // TODO: Open App Store review page
          // if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") {
          //   UIApplication.shared.open(url)
          // }
        }) {
          HStack(spacing: 12) {
            Image(systemName: "star.fill")
              .font(.system(size: 20))
              .foregroundColor(.yellow)
              .frame(width: 24)
            Text(LocalizedStringKey("rate_app"))
              .font(.system(size: 15, weight: .semibold))
              .foregroundColor(.white)
            Spacer()
            Image(systemName: "arrow.up.right")
              .font(.system(size: 12))
              .foregroundColor(.gray)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 14)
        }
      }
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.black.opacity(0.4))
      )
    }
  }
}

// タップ時に不透明度を変えるシンプルなスタイル
struct TappableCardStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(configuration.isPressed ? 0.7 : 1.0)
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}

// MARK: - Immersion Section
struct ImmersionSection: View {
  @EnvironmentObject var settingsManager: SettingsManager

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Section Title
      Text(LocalizedStringKey("immersion"))
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.white)
        .tracking(1.5)

      VStack(spacing: 0) {
        // Sound Effects
        SettingToggleRow(
          icon: "speaker.wave.2.fill",
          iconColor: .neonCyan,
          title: "sound_effects",
          description: "sound_effects_desc",
          isOn: $settingsManager.soundEffectsEnabled
        )

        Divider()
          .background(Color.white.opacity(0.1))
          .padding(.leading, 52)

        // Music
        SettingToggleRow(
          icon: "music.note",
          iconColor: .neonMagenta,
          title: "music",
          description: "music_desc",
          isOn: $settingsManager.musicEnabled
        )

        Divider()
          .background(Color.white.opacity(0.1))
          .padding(.leading, 52)

        // Haptic Feedback
        SettingToggleRow(
          icon: "waveform",
          iconColor: .neonYellow,
          title: "haptic_feedback",
          description: "haptic_feedback_desc",
          isOn: $settingsManager.hapticFeedbackEnabled
        )
      }
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.black.opacity(0.4))
      )
    }
  }
}

// MARK: - Setting Toggle Row
struct SettingToggleRow: View {
  let icon: String
  let iconColor: Color
  let title: String
  let description: String?
  @Binding var isOn: Bool

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(iconColor)
        .frame(width: 24)

      VStack(alignment: .leading, spacing: 2) {
        Text(LocalizedStringKey(title))
          .font(.system(size: 15, weight: .semibold))
          .foregroundColor(.white)

        if let description = description {
          Text(LocalizedStringKey(description))
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
      }

      Spacer()

      Toggle("", isOn: $isOn)
        .labelsHidden()
        .tint(.neonCyan)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }
}

// MARK: - Footer Section
struct FooterSection: View {
  var body: some View {
    VStack(spacing: 12) {
      // Version
      Text(String(format: NSLocalizedString("app_version", comment: ""), "2.4.0"))
        .font(.system(size: 11))
        .foregroundColor(.gray)

      // Links
      HStack(spacing: 16) {
        Button(action: {
          // TODO: Privacy
        }) {
          Text(LocalizedStringKey("privacy"))
            .font(.system(size: 11))
            .foregroundColor(.gray)
        }

        Text("•")
          .foregroundColor(.gray)

        Button(action: {
          // TODO: Terms
        }) {
          Text(LocalizedStringKey("terms"))
            .font(.system(size: 11))
            .foregroundColor(.gray)
        }

        Text("•")
          .foregroundColor(.gray)

        Button(action: {
          // TODO: Support
        }) {
          Text(LocalizedStringKey("support"))
            .font(.system(size: 11))
            .foregroundColor(.gray)
        }
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 16)
  }
}
