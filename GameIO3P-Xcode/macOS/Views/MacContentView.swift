// MacContentView.swift
// GameIO 2P — macOS Main Window
// Game toolbar, sidebar navigation, menu bar integration.

import SwiftUI
import AppKit

// MARK: - macOS App State

class MacAppState: ObservableObject {
    @Published var selectedTab: MacTab = .lobby
    @Published var showSettings: Bool = false
    @Published var isFullScreen: Bool = false
    @Published var windowSize: CGSize = CGSize(width: 1280, height: 800)

    enum MacTab: String, CaseIterable, Identifiable {
        case lobby = "Lobby"
        case leaderboard = "Leaderboard"
        case garage = "Garage"
        case replays = "Replays"
        case store = "Store"

        var id: String { rawValue }
        var icon: String {
            switch self {
            case .lobby: return "house.fill"
            case .leaderboard: return "trophy.fill"
            case .garage: return "car.fill"
            case .replays: return "play.tv.fill"
            case .store: return "cart.fill"
            }
        }
    }
}

struct MacContentView: View {
    @StateObject private var appState = MacAppState()
    @State private var sidebarVisible: Bool = true

    var body: some View {
        NavigationSplitView {
            macSidebar
        } detail: {
            macDetailContent
        }
        .frame(minWidth: 900, minHeight: 600)
        .background(Color(hex: "#0A0010"))
        .toolbar { macToolbarContent }
        .sheet(isPresented: $appState.showSettings) {
            MacSettingsView()
                .frame(width: 580, height: 500)
        }
        .environmentObject(appState)
    }

    // MARK: - Sidebar

    var macSidebar: some View {
        VStack(spacing: 0) {
            // Profile header
            HStack(spacing: 12) {
                Circle()
                    .fill(AvatarConfig.skinTones[0])
                    .frame(width: 44, height: 44)
                    .overlay(Circle().stroke(Color(hex: "#FF6B35"), lineWidth: 2))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Player 1")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Level 12 • 42,500 pts")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.04))

            Divider().background(Color.white.opacity(0.1))

            // Navigation items
            List(MacAppState.MacTab.allCases, selection: $appState.selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(appState.selectedTab == tab ? Color(hex: "#FF6B35") : .white.opacity(0.7))
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)

            Divider().background(Color.white.opacity(0.1))

            // Quick stats
            VStack(spacing: 8) {
                quickStat("Online Players", value: "1,284")
                quickStat("Active Rooms", value: "347")
            }
            .padding(12)
        }
        .background(Color(hex: "#0D0D1A"))
        .navigationSplitViewColumnWidth(min: 180, ideal: 220)
    }

    @ViewBuilder
    private func quickStat(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 11, design: .monospaced)).foregroundColor(.white.opacity(0.4))
            Spacer()
            Text(value).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(Color(hex: "#00FF88"))
        }
    }

    // MARK: - Detail Content

    @ViewBuilder
    var macDetailContent: some View {
        switch appState.selectedTab {
        case .lobby:
            LobbyView(onEnterGame: { _ in })
        case .leaderboard:
            LeaderboardView()
        case .garage:
            CarSelectionView()
        case .replays:
            MacReplaysView()
        case .store:
            MacStoreView()
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    var macToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button(action: { sidebarVisible.toggle() }) {
                Image(systemName: "sidebar.leading")
            }
        }
        ToolbarItem(placement: .principal) {
            Text("GAMEIO 2P")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(colors: [Color(hex: "#FF6B35"), Color(hex: "#FF2D95")],
                                   startPoint: .leading, endPoint: .trailing)
                )
        }
        ToolbarItemGroup(placement: .automatic) {
            Button(action: { }) {
                Label("Invite Friend", systemImage: "person.badge.plus")
            }
            Button(action: { }) {
                Label("New Room", systemImage: "plus.circle.fill")
            }
            Button(action: { appState.showSettings = true }) {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

// MARK: - Placeholder Sub-views

struct MacReplaysView: View {
    var body: some View {
        ZStack {
            Color(hex: "#0A0010").ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "play.tv.fill").font(.system(size: 48)).foregroundColor(.white.opacity(0.2))
                Text("YOUR REPLAYS").font(.system(size: 20, weight: .black, design: .monospaced)).foregroundColor(.white)
                Text("No replays yet. Finish a race to see recordings.")
                    .font(.system(size: 14, design: .monospaced)).foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct MacStoreView: View {
    let items = [("Neon Ghost Car", "9,900 pts", "🏎️"),
                 ("VIP Crown Badge", "2,500 pts", "👑"),
                 ("Rainbow Nitro Trail", "4,200 pts", "🌈"),
                 ("Double XP Boost (1hr)", "1,000 pts", "⚡"),
                 ("Lunar Car Skin", "7,500 pts", "🌙")]
    var body: some View {
        ZStack {
            Color(hex: "#0A0010").ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 20) {
                    ForEach(items, id: \.0) { item in
                        VStack(spacing: 10) {
                            Text(item.2).font(.system(size: 40))
                            Text(item.0).font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text(item.1).font(.system(size: 14, weight: .black, design: .monospaced)).foregroundColor(Color(hex: "#F39C12"))
                            Button("BUY") {}
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20).padding(.vertical, 6)
                                .background(Color(hex: "#F39C12")).cornerRadius(6)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                .padding(24)
            }
        }
    }
}

#Preview { MacContentView() }
