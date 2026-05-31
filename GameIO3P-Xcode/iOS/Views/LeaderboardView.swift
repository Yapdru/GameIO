// LeaderboardView.swift
// GameIO 2P — Global Leaderboard
// Table of top 50 scores with rank, avatar placeholder, name, score, best time.

import SwiftUI

struct LeaderboardEntry: Identifiable {
    let id: Int
    let rank: Int
    let playerName: String
    let score: Int
    let bestTime: TimeInterval // seconds
    let game: String
    let skinTone: Int
    let isCurrentUser: Bool

    var formattedScore: String {
        if score >= 1_000_000 { return String(format: "%.1fM", Double(score) / 1_000_000) }
        if score >= 1_000 { return String(format: "%.1fK", Double(score) / 1_000) }
        return "\(score)"
    }

    var formattedTime: String {
        let m = Int(bestTime) / 60
        let s = Int(bestTime) % 60
        let ms = Int((bestTime - Double(Int(bestTime))) * 100)
        return String(format: "%d:%02d.%02d", m, s, ms)
    }
}

extension LeaderboardEntry {
    static func mockData() -> [LeaderboardEntry] {
        let names = ["VoltFox","DriftMaster","NitroKing","ShadowRacer","BlazeDrift",
                     "GeckoSpeed","IronWheels","AuroraX","MicroFury","NeonGhost",
                     "TurboAce","PitBoss","FuelHero","ParkingPro","DragQueen",
                     "QuizKing","TrafficPro","SpeedDemon","RaceGod","BurnoutKing",
                     "ApexPredator","CurveKing","GridIron","SlipStream","RedShift",
                     "NightRider","ChaosDriver","ZeroGravity","MaxOverdrive","FullSend",
                     "BoostMode","TireKing","FuelCrazy","ThrottleUp","LapLegend",
                     "CrashTest","SmokeBomb","TailSlide","RearWheel","DriveShaft",
                     "TurboCharged","QuickShift","SlickTires","PedalToMetal","FlatOut",
                     "RoadRager","GrandPrix","Chicane","Hairpin","FlyingLap"]
        let games = ["NITRO RACER","DRIFT KING","SPEED MATCH","PIT STOP","TRAFFIC DODGE"]
        return names.enumerated().map { i, name in
            LeaderboardEntry(id: i, rank: i + 1, playerName: name,
                             score: Int.random(in: 5_000...999_999),
                             bestTime: Double.random(in: 45...300),
                             game: games[i % games.count],
                             skinTone: i % 6,
                             isCurrentUser: i == 12)
        }.sorted { $0.score > $1.score }.enumerated().map { idx, e in
            LeaderboardEntry(id: e.id, rank: idx+1, playerName: e.playerName,
                             score: e.score, bestTime: e.bestTime, game: e.game,
                             skinTone: e.skinTone, isCurrentUser: e.isCurrentUser)
        }
    }
}

struct LeaderboardView: View {
    @State private var entries: [LeaderboardEntry] = LeaderboardEntry.mockData()
    @State private var selectedGame: String = "ALL"
    @State private var isLoading: Bool = false
    @State private var showUserRank: Bool = true

    let games = ["ALL","NITRO RACER","DRIFT KING","SPEED MATCH","PIT STOP","TRAFFIC DODGE"]

    var filtered: [LeaderboardEntry] {
        selectedGame == "ALL" ? entries : entries.filter { $0.game == selectedGame }
    }

    var currentUserEntry: LeaderboardEntry? { entries.first { $0.isCurrentUser } }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0A0010").ignoresSafeArea()
                VStack(spacing: 0) {
                    // Game filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(games, id: \.self) { game in
                                Button(action: { selectedGame = game }) {
                                    Text(game)
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(selectedGame == game ? .black : .white.opacity(0.6))
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                        .background(selectedGame == game ? Color(hex: "#FF6B35") : Color.white.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }

                    // Top 3 podium
                    if filtered.count >= 3 {
                        podiumView(entries: Array(filtered.prefix(3)))
                    }

                    // My rank sticky bar
                    if let me = currentUserEntry {
                        myRankBar(entry: me)
                    }

                    // Full list
                    List {
                        ForEach(filtered) { entry in
                            LeaderboardRow(entry: entry)
                                .listRowBackground(entry.isCurrentUser ? Color(hex: "#FF6B35").opacity(0.15) : Color.clear)
                                .listRowSeparatorTint(Color.white.opacity(0.08))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("LEADERBOARD")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func podiumView(entries: [LeaderboardEntry]) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            podiumSlot(entry: entries[1], height: 70, medal: "🥈")
            podiumSlot(entry: entries[0], height: 90, medal: "🥇")
            podiumSlot(entry: entries[2], height: 55, medal: "🥉")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04))
    }

    @ViewBuilder
    private func podiumSlot(entry: LeaderboardEntry, height: CGFloat, medal: String) -> some View {
        VStack(spacing: 4) {
            Text(medal).font(.title2)
            miniAvatar(skinTone: entry.skinTone)
            Text(entry.playerName)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
            Text(entry.formattedScore)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(Color(hex: "#FF6B35"))
            Rectangle()
                .fill(Color(hex: "#FF6B35").opacity(0.5))
                .frame(height: height)
                .cornerRadius(4)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func myRankBar(entry: LeaderboardEntry) -> some View {
        HStack(spacing: 12) {
            Text("#\(entry.rank)")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(Color(hex: "#FF6B35"))
            miniAvatar(skinTone: entry.skinTone)
            Text("YOU")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Spacer()
            Text(entry.formattedScore)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(Color(hex: "#00FF88"))
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Color(hex: "#FF6B35").opacity(0.15))
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color(hex: "#FF6B35").opacity(0.4)), alignment: .bottom)
    }

    @ViewBuilder
    private func miniAvatar(skinTone: Int) -> some View {
        Circle()
            .fill(AvatarConfig.skinTones[skinTone])
            .frame(width: 28, height: 28)
            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry

    var rankColor: Color {
        switch entry.rank {
        case 1: return Color(hex: "#F39C12")
        case 2: return Color(hex: "#BDC3C7")
        case 3: return Color(hex: "#CD7F32")
        default: return Color.white.opacity(0.4)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(entry.rank <= 3 ? ["🥇","🥈","🥉"][entry.rank-1] : "#\(entry.rank)")
                .font(.system(size: entry.rank <= 3 ? 20 : 13, weight: .black, design: .monospaced))
                .foregroundColor(rankColor)
                .frame(width: 38, alignment: .leading)

            Circle()
                .fill(AvatarConfig.skinTones[entry.skinTone])
                .frame(width: 34, height: 34)
                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.playerName)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text(entry.game)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.formattedScore)
                    .font(.system(size: 15, weight: .black, design: .monospaced))
                    .foregroundColor(Color(hex: "#00FF88"))
                Text(entry.formattedTime)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color(hex: "#00E5FF").opacity(0.7))
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview { LeaderboardView() }
