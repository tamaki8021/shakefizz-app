import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var languageManager: LanguageManager
  @EnvironmentObject var settingsManager: SettingsManager
  @Environment(\.dismiss) var dismiss

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

            // Immersion Section
            ImmersionSection()
              .environmentObject(settingsManager)

            // Accessibility Section
            AccessibilitySection()
              .environmentObject(settingsManager)

            // Footer
            FooterSection()

            Spacer(minLength: 80)
          }
          .padding(.horizontal, 16)
          .padding(.top, 16)
        }
      }
    }
  }
}

// MARK: - New Profile Section
struct NewProfileSection: View {
  var body: some View {
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

        Text("Level 42 • Rank #156")
          .font(.system(size: 13))
          .foregroundColor(.gray)
      }

      Spacer()

      // Edit Profile Button
      Button(action: {
        // TODO: Edit profile
      }) {
        HStack(spacing: 4) {
          Text(LocalizedStringKey("edit_profile"))
            .font(.system(size: 13, weight: .semibold))
          Image(systemName: "pencil")
            .font(.system(size: 11))
        }
        .foregroundColor(.neonCyan)
      }
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

// MARK: - Accessibility Section
struct AccessibilitySection: View {
  @EnvironmentObject var settingsManager: SettingsManager

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Section Title
      Text(LocalizedStringKey("accessibility"))
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.white)
        .tracking(1.5)

      VStack(spacing: 0) {
        // Reduce Motion
        SettingToggleRow(
          icon: "eye.fill",
          iconColor: .gray,
          title: "reduce_motion",
          description: nil,
          isOn: $settingsManager.reduceMotionEnabled
        )

        Divider()
          .background(Color.white.opacity(0.1))
          .padding(.leading, 52)

        // High Contrast
        SettingToggleRow(
          icon: "circle.lefthalf.filled",
          iconColor: .gray,
          title: "high_contrast",
          description: nil,
          isOn: $settingsManager.highContrastEnabled
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
