import SwiftUI

// Mock Data Structure
struct LeaguePlayer: Identifiable {
  let id = UUID()
  let rank: Int
  let name: String
  let score: Double
  let isCurrentUser: Bool
}

// League Types for Navigation
enum LeagueType: String, CaseIterable, Identifiable {
  case ultraCola = "ultra_cola"
  case limeBurst = "lime_burst"
  case beastFuel = "beast_fuel"
  case gingerShock = "ginger_shock"
  case global = "Global Rank"

  var id: String { self.rawValue }

  var displayName: String {
    switch self {
    case .ultraCola: return "Ultra Cola League"
    case .limeBurst: return "Lime Burst League"
    case .beastFuel: return "Beast Fuel League"
    case .gingerShock: return "Ginger Shock League"
    case .global: return "Global Rank"
    }
  }

  var icon: String {
    switch self {
    case .global: return "globe.americas.fill"
    default: return "sparkles"
    }
  }

  var color: Color {
    switch self {
    case .ultraCola: return Color(red: 0.95, green: 0.10, blue: 0.15)
    case .limeBurst: return Color(red: 0.28, green: 0.95, blue: 0.28)
    case .beastFuel: return Color(red: 0.08, green: 0.62, blue: 0.96)
    case .gingerShock: return Color(red: 0.98, green: 0.85, blue: 0.15)
    case .global: return .neonCyan
    }
  }
}

struct LeagueRankingView: View {
  @Environment(\.presentationMode) var presentationMode
  let currentRank: Int
  let currentScore: Double
  
  @State private var selectedLeague: LeagueType = .ultraCola

  // Mock Data generation (centered around current player and top 3)
  private func rankingData(for league: LeagueType) -> [LeaguePlayer] {
    var data: [LeaguePlayer] = []
    
    // Create base score modifier depending on league
    let scoreModifier: Double
    switch league {
    case .ultraCola: scoreModifier = 0.85
    case .limeBurst: scoreModifier = 0.70
    case .beastFuel: scoreModifier = 0.95
    case .gingerShock: scoreModifier = 0.95
    case .global: scoreModifier = 1.0
    }

    let isUserLeague = (league == .ultraCola) // MVP: User is always in Ultra Cola league by default
    let targetRank = isUserLeague ? currentRank : Int.random(in: 100...500)
    let targetScore = currentScore * scoreModifier

    // Always add Top 3
    data.append(
      LeaguePlayer(
        rank: 1, name: targetRank == 1 ? "YOU" : "Player 882",
        score: targetRank == 1 ? targetScore : 98.5 * scoreModifier, isCurrentUser: targetRank == 1))
    data.append(
      LeaguePlayer(
        rank: 2, name: targetRank == 2 ? "YOU" : "Player 104",
        score: targetRank == 2 ? targetScore : 95.2 * scoreModifier, isCurrentUser: targetRank == 2))
    data.append(
      LeaguePlayer(
        rank: 3, name: targetRank == 3 ? "YOU" : "Player 639",
        score: targetRank == 3 ? targetScore : 92.8 * scoreModifier, isCurrentUser: targetRank == 3))

    // Add Ranks 4 to 100
    for rank in 4...100 {
      if rank == targetRank {
        data.append(
          LeaguePlayer(rank: rank, name: "YOU", score: targetScore, isCurrentUser: true))
      } else {
        // Create realistic mock scores that decrease as rank goes down, but maintain currentScore relationship
        let mockScore: Double
        if rank < targetRank {
          // Players above the user have higher scores
          let scoreDiff = Double(targetRank - rank) * 1.5 * scoreModifier
          mockScore = targetScore + scoreDiff
        } else {
          // Players below the user have lower scores
          let scoreDiff = Double(rank - targetRank) * 1.5 * scoreModifier
          mockScore = max(0, targetScore - scoreDiff)
        }
        let mockName = "Player \(100 + (rank * 137) % 899)"
        data.append(
          LeaguePlayer(rank: rank, name: mockName, score: mockScore, isCurrentUser: false))
      }
    }

    return data.sorted { $0.rank < $1.rank }
  }

  private func top3Data(for league: LeagueType) -> [LeaguePlayer] {
    rankingData(for: league).filter { $0.rank <= 3 }
  }

  private func listData(for league: LeagueType) -> [LeaguePlayer] {
    rankingData(for: league).filter { $0.rank > 3 }
  }

  var body: some View {
    NavigationView {
      ZStack(alignment: .top) {
        // Background
        Color.black.edgesIgnoringSafeArea(.all)
        
        VStack(spacing: 0) {
          // Swipable League Views
          TabView(selection: $selectedLeague) {
            ForEach(LeagueType.allCases) { league in
              LeaguePage(
                league: league,
                top3Data: top3Data(for: league),
                listData: listData(for: league),
                currentRank: currentRank,
                currentScore: currentScore
              )
              .tag(league)
            }
          }
          .tabViewStyle(.page(indexDisplayMode: .never)) // Hide default dots to use custom ones
          
          // Custom Page Indicators
          HStack(spacing: 8) {
            ForEach(LeagueType.allCases) { league in
              Circle()
                .fill(selectedLeague == league ? league.color : Color.white.opacity(0.2))
                .frame(width: selectedLeague == league ? 8 : 6, height: selectedLeague == league ? 8 : 6)
                .animation(.spring(), value: selectedLeague)
            }
          }
          .padding(.bottom, 12)
          
          // Fixed Bottom My Rank Bar for the User's ACTUAL league
          MyRankBar(rank: currentRank, score: currentScore)
            .padding(.bottom, 20)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          VStack(spacing: 2) {
            HStack(spacing: 6) {
              Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
              
              Image(systemName: selectedLeague.icon)
                .foregroundColor(selectedLeague.color)
              Text(selectedLeague.displayName)
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.white)
                .id(selectedLeague)
                .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .trailing)), removal: .opacity.combined(with: .move(edge: .leading))))
                .animation(.easeInOut, value: selectedLeague)
                
              Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            }
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            presentationMode.wrappedValue.dismiss()
          }) {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 24))
              .foregroundColor(.white.opacity(0.7))
          }
        }
      }
    }
  }
}

// MARK: - Individual League Page
struct LeaguePage: View {
  let league: LeagueType
  let top3Data: [LeaguePlayer]
  let listData: [LeaguePlayer]
  let currentRank: Int
  let currentScore: Double
  
  var body: some View {
    ZStack(alignment: .bottom) {
        VStack(spacing: 0) {
          // Fixed Podium View for Top 3
          PodiumView(topPlayers: top3Data)
            .padding(.top, 20)
            .padding(.bottom, 10)

          // Ranking List
          ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {

              // Table Header
              HStack {
                Text(LocalizedStringKey("ranking_rank"))
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(.gray)
                  .frame(width: 50, alignment: .center)
                Text(LocalizedStringKey("ranking_player"))
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(.gray)
                  .frame(maxWidth: .infinity, alignment: .leading)
                Text(LocalizedStringKey("ranking_score"))
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(.gray)
                  .frame(width: 80, alignment: .trailing)
              }
              .padding(.horizontal, 20)

              VStack(spacing: 12) {
                ForEach(listData) { data in
                  HStack {
                    Text("\(data.rank)")
                      .font(.system(size: 16, weight: .bold, design: .monospaced))
                      .foregroundColor(.white)
                      .frame(width: 50, alignment: .center)

                    // Player Name
                    Text(data.name)
                      .font(.system(size: 18, weight: data.isCurrentUser ? .black : .medium))
                      .foregroundColor(data.isCurrentUser ? .neonCyan : .white)
                      .frame(maxWidth: .infinity, alignment: .leading)

                    // Score
                    Text(String(format: "%.1f", data.score))
                      .font(.system(size: 18, weight: .bold, design: .monospaced))
                      .foregroundColor(data.isCurrentUser ? .neonCyan : .white)
                      .frame(width: 80, alignment: .trailing)
                  }
                  .padding(.vertical, 16)
                  .padding(.horizontal, 16)
                  .background(
                    RoundedRectangle(cornerRadius: 16)
                      .fill(
                        data.isCurrentUser
                          ? Color.neonCyan.opacity(0.15) : Color.white.opacity(0.05))
                  )
                  .overlay(
                    RoundedRectangle(cornerRadius: 16)
                      .stroke(data.isCurrentUser ? Color.neonCyan : Color.clear, lineWidth: 2)
                  )
                  .padding(.horizontal, 16)
                }
              }
              .padding(.bottom, 10)
            }
          }
        }
    }
  }
}

// MARK: - Podium Components
struct PodiumView: View {
  let topPlayers: [LeaguePlayer]

  var body: some View {
    HStack(alignment: .bottom, spacing: 16) {
      // 2nd Place
      if topPlayers.count > 1 {
        let p2 = topPlayers[1]
        PodiumStep(player: p2, place: 2, height: 100, color: Color(white: 0.8))
      }

      // 1st Place
      if topPlayers.count > 0 {
        let p1 = topPlayers[0]
        PodiumStep(player: p1, place: 1, height: 140, color: .yellow, isFirst: true)
          .zIndex(1)
      }

      // 3rd Place
      if topPlayers.count > 2 {
        let p3 = topPlayers[2]
        PodiumStep(player: p3, place: 3, height: 80, color: .orange)
      }
    }
    .padding(.horizontal, 24)
  }
}

struct PodiumStep: View {
  let player: LeaguePlayer
  let place: Int
  let height: CGFloat
  let color: Color
  var isFirst: Bool = false

  var body: some View {
    VStack(spacing: 12) {
      // Profile Area
      VStack(spacing: -8) {
        if isFirst {
          Image(systemName: "crown.fill")
            .font(.system(size: 28))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.8), radius: 10)
            .zIndex(1)
        }

        Circle()
          .fill(Color.black)
          .frame(width: isFirst ? 64 : 52, height: isFirst ? 64 : 52)
          .overlay(
            Circle()
              .stroke(isFirst ? color : color.opacity(0.5), lineWidth: isFirst ? 4 : 2)
              .shadow(color: isFirst ? color.opacity(0.6) : .clear, radius: 10)
          )
          .overlay(
            Image(systemName: "person.fill")
              .foregroundColor(.white.opacity(0.5))
              .font(.system(size: isFirst ? 24 : 20))
          )
      }

      // Player Info
      VStack(spacing: 4) {
        Text(player.name)
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(player.isCurrentUser ? .neonCyan : .white)
          .lineLimit(1)
          .minimumScaleFactor(0.8)

        Text(String(format: "%.1f", player.score))
          .font(.system(size: 12, weight: .bold, design: .monospaced))
          .foregroundColor(player.isCurrentUser ? .neonCyan : color)
      }

      // Podium Pillar
      ZStack {
        // Pillar Glow & Base
        RoundedRectangle(cornerRadius: 12)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [color.opacity(isFirst ? 0.6 : 0.3), color.opacity(0.0)]),
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(color.opacity(isFirst ? 0.8 : 0.4), lineWidth: 1)
          )
          .shadow(color: isFirst ? color.opacity(0.5) : .clear, radius: 15)

        VStack {
          Text("\(place)")
            .font(.system(size: 48, weight: .black))
            .foregroundColor(color.opacity(0.8))
            .padding(.top, 12)
            // Add subtle shadow for the number itself
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
          Spacer()
        }
      }
      .frame(height: height)
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - My Rank Bar Component
struct MyRankBar: View {
  let rank: Int
  let score: Double

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(LocalizedStringKey("ranking_my_rank"))
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(.neonCyan)
          .shadow(color: .neonCyan.opacity(0.8), radius: 4)

        HStack(alignment: .lastTextBaseline, spacing: 4) {
          Text("#")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.7))
          Text("\(rank)")
            .font(.system(size: 28, weight: .black, design: .monospaced))
            .foregroundColor(.white)
        }
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 2) {
        Text(LocalizedStringKey("ranking_score"))
          .font(.system(size: 10, weight: .bold))
          .foregroundColor(.gray)

        HStack(alignment: .lastTextBaseline, spacing: 2) {
          Text(String(format: "%.1f", score))
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
          Text("m")
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.gray)
        }
      }
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 16)
    .background(
      ZStack {
        RoundedRectangle(cornerRadius: 24)
          .fill(Color(white: 0.1).opacity(0.95))

        RoundedRectangle(cornerRadius: 24)
          .stroke(Color.neonCyan.opacity(0.6), lineWidth: 2)
          .shadow(color: .neonCyan.opacity(0.8), radius: 15)
      }
    )
    .padding(.horizontal, 20)
  }
}

// Preview
struct LeagueRankingView_Previews: PreviewProvider {
  static var previews: some View {
    LeagueRankingView(currentRank: 42, currentScore: 85.5)
  }
}
