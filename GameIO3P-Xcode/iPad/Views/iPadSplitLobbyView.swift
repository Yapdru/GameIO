// iPadSplitLobbyView.swift
// GameIO 2P — iPad Split View Lobby
// Sidebar with player list, main area with lobby content.

import SwiftUI

struct PlayerInfo: Identifiable {
    let id: UUID
    let name: String
    let skinTone: Int
    let status: PlayerStatus
    let score: Int

    enum PlayerStatus: String {
        case online = "Online"
        case inGame = "In Game"
        case idle = "Idle"

        var color: Color {
            switch self {
            case .online: return Color(hex: "#00FF88")
            case .inGame: return Color(hex: "#FF6B35")
            case .idle: return Color(hex: "#999999")
            }
        }
    }
}

extension PlayerInfo {
    static let mock: [PlayerInfo] = [
        PlayerInfo(id: UUID(), name: "VoltFox", skinTone: 0, status: .online, score: 42500),
        PlayerInfo(id: UUID(), name: "DriftMaster", skinTone: 2, status: .inGame, score: 38200),
        PlayerInfo(id: UUID(), name: "NitroKing", skinTone: 4, status: .online, score: 55100),
        PlayerInfo(id: UUID(), name: "ShadowRacer", skinTone: 1, status: .idle, score: 21300),
        PlayerInfo(id: UUID(), name: "BlazeDrift", skinTone: 3, status: .inGame, score: 67800),
        PlayerInfo(id: UUID(), name: "GeckoSpeed", skinTone: 5, status: .online, score: 29900),
    ]
}

struct iPadSplitLobbyView: View {
    @State private var selectedPlayer: PlayerInfo? = nil
    @State private var selectedGame: Int? = nil
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var players: [PlayerInfo] = PlayerInfo.mock

    var onEnterGame: (Int) -> Void = { _ in }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar: players
            playerSidebar
                .navigationTitle("PLAYERS")
                .navigationBarTitleDisplayMode(.inline)
                .frame(minWidth: 220)
        } content: {
            // Middle: game portals (same as lobby)
            iPadGameGrid(onEnterGame: onEnterGame)
                .navigationTitle("GAME LOBBY")
        } detail: {
            // Detail: selected player or game info
            if let player = selectedPlayer {
                PlayerDetailView(player: player)
            } else {
                emptyDetailView
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - Sidebar

    var playerSidebar: some View {
        List(players, selection: $selectedPlayer) { player in
            PlayerRowView(player: player)
                .tag(player)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "#0A0010"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(Color(hex: "#FF6B35"))
                }
            }
        }
    }

    var emptyDetailView: some View {
        VStack(spacing: 16) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.2))
            Text("Select a player or game")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#0A0010"))
    }
}

// MARK: - Player Row

struct PlayerRowView: View {
    let player: PlayerInfo
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AvatarConfig.skinTones[player.skinTone])
                .frame(width: 38, height: 38)
                .overlay(
                    Circle()
                        .fill(player.status.color)
                        .frame(width: 10, height: 10)
                        .offset(x: 13, y: 13)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text(player.status.rawValue)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(player.status.color)
            }
            Spacer()
            Text("\(player.score)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "#00FF88"))
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.white.opacity(0.04))
    }
}

// MARK: - Player Detail

struct PlayerDetailView: View {
    let player: PlayerInfo
    var body: some View {
        ZStack {
            Color(hex: "#0A0010").ignoresSafeArea()
            VStack(spacing: 24) {
                Circle()
                    .fill(AvatarConfig.skinTones[player.skinTone])
                    .frame(width: 100, height: 100)
                    .overlay(Circle().stroke(player.status.color, lineWidth: 3))

                Text(player.name)
                    .font(.system(size: 26, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Circle().fill(player.status.color).frame(width: 8, height: 8)
                    Text(player.status.rawValue)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(player.status.color)
                }

                VStack(spacing: 12) {
                    detailRow("TOTAL SCORE", "\(player.score)")
                    detailRow("RANK", "#23")
                    detailRow("RACES", "142")
                    detailRow("WIN RATE", "67%")
                }
                .padding(16)
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                .padding(.horizontal, 40)

                Button("CHALLENGE") {}
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 40).padding(.vertical, 14)
                    .background(Color(hex: "#FF6B35"))
                    .cornerRadius(10)

                Spacer()
            }
            .padding(.top, 40)
        }
    }

    @ViewBuilder func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 12, design: .monospaced)).foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value).font(.system(size: 15, weight: .bold, design: .monospaced)).foregroundColor(.white)
        }
    }
}

// MARK: - iPad Game Grid (reuse from lobby)

struct iPadGameGrid: View {
    var onEnterGame: (Int) -> Void = { _ in }
    let columns = [GridItem(.adaptive(minimum: 160, maximum: 200))]
    var body: some View {
        ZStack {
            Color(hex: "#0D0D1A").ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(GamePortal.all) { portal in
                        Button(action: { onEnterGame(portal.id) }) {
                            VStack(spacing: 10) {
                                Text(portal.icon).font(.system(size: 44))
                                    .frame(width: 100, height: 100)
                                    .background(RadialGradient(colors: [portal.accentColor.opacity(0.5), portal.color.opacity(0.1)],
                                                              center: .center, startRadius: 0, endRadius: 50))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(portal.color, lineWidth: 2))
                                Text(portal.name)
                                    .font(.system(size: 12, weight: .black, design: .monospaced))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
        }
    }
}

#Preview {
    iPadSplitLobbyView()
}
