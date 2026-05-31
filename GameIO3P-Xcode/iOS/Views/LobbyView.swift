// LobbyView.swift
// GameIO 2P — Main Lobby
// SwiftUI lobby with sofas, plants, and 9 game portals as circular buttons.

import SwiftUI

struct GamePortal: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let color: Color
    let accentColor: Color
    let isUnlocked: Bool
}

extension GamePortal {
    static let all: [GamePortal] = [
        GamePortal(id: 0, name: "NITRO RACER",   icon: "🏎️", color: Color(hex: "#FF6B35"), accentColor: Color(hex: "#FF2D00"), isUnlocked: true),
        GamePortal(id: 1, name: "DRIFT KING",    icon: "💨", color: Color(hex: "#00E5FF"), accentColor: Color(hex: "#0066FF"), isUnlocked: true),
        GamePortal(id: 2, name: "SPEED MATCH",   icon: "🃏", color: Color(hex: "#00FF88"), accentColor: Color(hex: "#007744"), isUnlocked: true),
        GamePortal(id: 3, name: "PIT STOP",      icon: "🔧", color: Color(hex: "#F39C12"), accentColor: Color(hex: "#E67E22"), isUnlocked: true),
        GamePortal(id: 4, name: "TRAFFIC DODGE", icon: "🚦", color: Color(hex: "#E74C3C"), accentColor: Color(hex: "#C0392B"), isUnlocked: true),
        GamePortal(id: 5, name: "FUEL RUSH",     icon: "⛽", color: Color(hex: "#9B59B6"), accentColor: Color(hex: "#6C3483"), isUnlocked: true),
        GamePortal(id: 6, name: "TURBO QUIZ",    icon: "❓", color: Color(hex: "#7B61FF"), accentColor: Color(hex: "#4A2ADB"), isUnlocked: true),
        GamePortal(id: 7, name: "PARK MASTER",   icon: "🅿️", color: Color(hex: "#1ABC9C"), accentColor: Color(hex: "#17A589"), isUnlocked: true),
        GamePortal(id: 8, name: "DRAG STRIP",    icon: "🏁", color: Color(hex: "#ECF0F1"), accentColor: Color(hex: "#BDC3C7"), isUnlocked: true),
    ]
}

struct LobbyView: View {
    @State private var selectedPortal: GamePortal? = nil
    @State private var pulse: Bool = false
    @State private var cameraOffset: CGSize = .zero
    @State private var floatOffset: CGFloat = 0
    var onEnterGame: (Int) -> Void = { _ in }

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                // Lobby background: wooden floor
                lobbyBackground

                ScrollView {
                    VStack(spacing: 32) {
                        // Lobby header
                        lobbyHeader.padding(.top, 16)

                        // Furniture row
                        furnitureRow

                        // Game portals grid
                        VStack(spacing: 16) {
                            Text("GAME PORTALS")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .foregroundColor(Color(hex: "#FF6B35"))
                                .kerning(4)

                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(GamePortal.all) { portal in
                                    PortalButton(portal: portal, isPulsing: pulse) {
                                        withAnimation(.spring()) { selectedPortal = portal }
                                        onEnterGame(portal.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Social strip
                        socialStrip
                            .padding(.bottom, 30)
                    }
                }

                // Portal selected overlay
                if let portal = selectedPortal {
                    portalEnterOverlay(portal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(Color(hex: "#FF6B35"))
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse.toggle()
                floatOffset = -8
            }
        }
    }

    var lobbyBackground: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#1A0A2E"), Color(hex: "#0D0D1A")],
                           startPoint: .top, endPoint: .bottom)
            // Floor tiles
            GeometryReader { geo in
                Path { p in
                    let tileW: CGFloat = 60, tileH: CGFloat = 30
                    var row = 0
                    var y: CGFloat = geo.size.height * 0.6
                    while y < geo.size.height + tileH {
                        var x: CGFloat = row % 2 == 0 ? 0 : -tileW / 2
                        while x < geo.size.width + tileW {
                            p.addRect(CGRect(x: x, y: y, width: tileW - 1, height: tileH - 1))
                            x += tileW
                        }
                        y += tileH; row += 1
                    }
                }
                .fill(Color(hex: "#2A1A4A").opacity(0.5))
            }
        }
        .ignoresSafeArea()
    }

    var lobbyHeader: some View {
        VStack(spacing: 6) {
            Text("🏠 GAME LOBBY")
                .font(.system(size: 26, weight: .black, design: .monospaced))
                .foregroundColor(.white)
            Text("Choose your game. Challenge a friend.")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
        }
    }

    var furnitureRow: some View {
        HStack(spacing: 0) {
            // Left plant
            Text("🌿").font(.system(size: 40)).offset(y: floatOffset * 0.5)
            Spacer()
            // Sofa
            Canvas { ctx, size in
                let w = size.width, h = size.height
                let sofaPath = Path { p in
                    p.addRoundedRect(in: CGRect(x: 0, y: h * 0.3, width: w, height: h * 0.7),
                                     cornerSize: CGSize(width: 10, height: 10))
                }
                ctx.fill(sofaPath, with: .color(Color(hex: "#6B21A8").opacity(0.8)))
                // Cushions
                for i in 0..<3 {
                    let cx = w * 0.15 + CGFloat(i) * w * 0.3
                    ctx.fill(Path(roundedRect: CGRect(x: cx, y: h * 0.2, width: w * 0.25, height: h * 0.55),
                                  cornerSize: CGSize(width: 8, height: 8)),
                             with: .color(Color(hex: "#7C3AED")))
                }
            }
            .frame(width: 140, height: 60)
            Spacer()
            // Right plant
            Text("🌵").font(.system(size: 36)).offset(y: floatOffset * 0.3)
        }
        .padding(.horizontal, 24)
    }

    var socialStrip: some View {
        HStack(spacing: 20) {
            socialButton(icon: "person.2.fill", label: "FRIENDS", count: 3)
            socialButton(icon: "trophy.fill", label: "RANKS", count: nil)
            socialButton(icon: "bell.fill", label: "ALERTS", count: 5)
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func socialButton(icon: String, label: String, count: Int?) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                if let n = count {
                    Text("\(n)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Color(hex: "#FF6B35"))
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.07))
        .cornerRadius(10)
    }

    @ViewBuilder
    private func portalEnterOverlay(_ portal: GamePortal) -> some View {
        Color.black.opacity(0.6).ignoresSafeArea()
            .onTapGesture { withAnimation { selectedPortal = nil } }
        VStack(spacing: 20) {
            Text(portal.icon).font(.system(size: 60))
            Text(portal.name)
                .font(.system(size: 24, weight: .black, design: .monospaced))
                .foregroundColor(portal.color)
            Button("ENTER") { onEnterGame(portal.id); selectedPortal = nil }
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .padding(.horizontal, 40).padding(.vertical, 14)
                .background(portal.color).foregroundColor(.black)
                .cornerRadius(10)
        }
        .padding(30)
        .background(Color(hex: "#1A1A2E"))
        .cornerRadius(20)
        .transition(.scale.combined(with: .opacity))
    }
}

struct PortalButton: View {
    let portal: GamePortal
    let isPulsing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [portal.accentColor.opacity(0.6), portal.color.opacity(0.2)],
                                            center: .center, startRadius: 0, endRadius: 40))
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(portal.color, lineWidth: 2))
                        .shadow(color: portal.color.opacity(isPulsing ? 0.8 : 0.3), radius: isPulsing ? 14 : 8)
                    Text(portal.icon).font(.system(size: 30))
                }
                Text(portal.name)
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28)
            }
        }
    }
}

#Preview { LobbyView() }
