// RoomCodeView.swift
// GameIO 2P — Room Code Screen
// Firebase-style room code with animated data stream background.

import SwiftUI
import Combine

struct RoomCodeView: View {
    let roomCode: String
    let isHost: Bool
    @State private var streamLines: [DataStreamLine] = DataStreamLine.generate(count: 22)
    @State private var animOffset: CGFloat = 0
    @State private var codeCopied = false
    @State private var playerCount: Int = 1
    @State private var countdownActive = false
    @State private var countdown: Int = 5

    var onPlayerJoined: (Int) -> Void = { _ in }
    var onStartGame: () -> Void = {}

    private var fullURL: String { "GAME://io.gameio2p.lobby/\(roomCode)" }

    var body: some View {
        ZStack {
            Color(hex: "#050510").ignoresSafeArea()

            // Animated data stream background
            GeometryReader { geo in
                Canvas { ctx, size in
                    for line in streamLines {
                        let x = line.xFraction * size.width
                        let yStart = (line.yOffset + animOffset).truncatingRemainder(dividingBy: size.height + 200) - 100
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: yStart))
                        path.addLine(to: CGPoint(x: x, y: yStart + line.length))
                        ctx.stroke(path, with: .color(line.color.opacity(line.alpha)), lineWidth: line.width)
                    }
                }
                .ignoresSafeArea()
            }
            .animation(.linear(duration: 0).repeatForever(autoreverses: false), value: animOffset)

            VStack(spacing: 28) {
                Spacer()

                // Header
                VStack(spacing: 6) {
                    Text(isHost ? "YOUR ROOM" : "JOINED ROOM")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "#FF6B35"))
                        .kerning(4)

                    Text("Share this link to invite a friend")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }

                // URL card
                VStack(spacing: 16) {
                    // URL bar
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color(hex: "#00FF88"))
                            .font(.system(size: 13))
                        Text(fullURL)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: "#00FF88").opacity(0.4), lineWidth: 1)
                    )
                    .cornerRadius(6)

                    // Big room code display
                    Text(roomCode)
                        .font(.system(size: 52, weight: .black, design: .monospaced))
                        .kerning(12)
                        .foregroundStyle(
                            LinearGradient(colors: [Color(hex: "#00E5FF"), Color(hex: "#7B61FF")],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: Color(hex: "#00E5FF").opacity(0.6), radius: 16)

                    // Copy button
                    Button(action: copyCode) {
                        HStack(spacing: 8) {
                            Image(systemName: codeCopied ? "checkmark.circle.fill" : "doc.on.doc")
                            Text(codeCopied ? "COPIED!" : "COPY CODE")
                        }
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(codeCopied ? Color(hex: "#00FF88") : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                .padding(.horizontal, 24)

                // Player status
                HStack(spacing: 20) {
                    playerSlot(index: 0, filled: true, isYou: true)
                    Text("VS")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(Color(hex: "#FF6B35"))
                    playerSlot(index: 1, filled: playerCount >= 2, isYou: false)
                }

                // Waiting / Start
                if isHost {
                    if playerCount >= 2 {
                        Button(action: onStartGame) {
                            Text("START GAME ▶")
                                .font(.system(size: 20, weight: .black, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#00FF88"))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 24)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        HStack(spacing: 8) {
                            ProgressView().tint(Color(hex: "#FF6B35"))
                            Text("Waiting for player 2...")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        ProgressView().tint(Color(hex: "#00E5FF"))
                        Text("Waiting for host to start...")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()
            }
        }
        .onAppear(perform: startAnimation)
    }

    @ViewBuilder
    private func playerSlot(index: Int, filled: Bool, isYou: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(filled ? Color(hex: "#1A1A2E") : Color.clear)
                    .frame(width: 60, height: 60)
                    .overlay(Circle().stroke(filled ? Color(hex: "#FF6B35") : Color.white.opacity(0.2), lineWidth: 2))
                if filled {
                    Text(isYou ? "YOU" : "P2")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "questionmark")
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            Text("PLAYER \(index + 1)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
        }
    }

    private func copyCode() {
        UIPasteboard.general.string = fullURL
        withAnimation { codeCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { codeCopied = false }
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            animOffset += 1.5
            if animOffset > 2000 { animOffset = 0 }
        }
    }
}

struct DataStreamLine: Identifiable {
    let id = UUID()
    var xFraction: CGFloat
    var yOffset: CGFloat
    var length: CGFloat
    var color: Color
    var alpha: Double
    var width: CGFloat

    static func generate(count: Int) -> [DataStreamLine] {
        let colors: [Color] = [Color(hex: "#00E5FF"), Color(hex: "#7B61FF"), Color(hex: "#FF6B35"), Color(hex: "#00FF88")]
        return (0..<count).map { _ in
            DataStreamLine(xFraction: CGFloat.random(in: 0...1),
                           yOffset: CGFloat.random(in: -400...400),
                           length: CGFloat.random(in: 40...200),
                           color: colors.randomElement()!,
                           alpha: Double.random(in: 0.05...0.25),
                           width: CGFloat.random(in: 0.5...2))
        }
    }
}

#Preview {
    RoomCodeView(roomCode: "A7B3X9", isHost: true)
}
