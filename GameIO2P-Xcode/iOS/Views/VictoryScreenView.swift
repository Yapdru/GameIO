// VictoryScreenView.swift
// GameIO 2P — Victory / Race Result Screen
// Position, time, score earned, stars, continue button.

import SwiftUI

struct RaceResultData {
    var position: Int
    var totalPlayers: Int
    var raceTime: TimeInterval
    var bestLap: TimeInterval
    var scoreEarned: Int
    var xpEarned: Int
    var stars: Int          // 0-3
    var isNewRecord: Bool
    var gameName: String
}

struct VictoryScreenView: View {
    let result: RaceResultData
    @State private var animIn: Bool = false
    @State private var confettiParticles: [ConfettiParticle] = ConfettiParticle.generate(count: 60)
    @State private var confettiOffset: CGFloat = 0
    @State private var starsShown: Int = 0

    var onContinue: () -> Void = {}
    var onPlayAgain: () -> Void = {}

    var isVictory: Bool { result.position == 1 }

    var body: some View {
        ZStack {
            LinearGradient(colors: isVictory
                           ? [Color(hex: "#1A0A00"), Color(hex: "#2A1000")]
                           : [Color(hex: "#0A0A1A"), Color(hex: "#0D0D2A")],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            // Confetti (victory only)
            if isVictory {
                Canvas { ctx, size in
                    for p in confettiParticles {
                        let y = (p.yStart + confettiOffset).truncatingRemainder(dividingBy: size.height + 80)
                        let rect = CGRect(x: p.x * size.width, y: y, width: p.size, height: p.size * 1.6)
                        ctx.fill(Path(rect), with: .color(p.color.opacity(p.alpha)))
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }

            VStack(spacing: 28) {
                Spacer()

                // Trophy / position
                VStack(spacing: 8) {
                    Text(positionEmoji)
                        .font(.system(size: 72))
                        .scaleEffect(animIn ? 1 : 0.2)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.1), value: animIn)

                    Text(isVictory ? "WINNER!" : "RACE OVER")
                        .font(.system(size: 34, weight: .black, design: .monospaced))
                        .foregroundStyle(isVictory
                                         ? LinearGradient(colors: [Color(hex: "#F39C12"), Color(hex: "#FF6B35")],
                                                          startPoint: .leading, endPoint: .trailing)
                                         : LinearGradient(colors: [.white, .white.opacity(0.7)],
                                                          startPoint: .leading, endPoint: .trailing))
                        .shadow(color: isVictory ? Color(hex: "#F39C12").opacity(0.7) : .clear, radius: 16)
                        .opacity(animIn ? 1 : 0)
                        .animation(.easeIn(duration: 0.4).delay(0.25), value: animIn)

                    if result.isNewRecord {
                        Text("🏆 NEW RECORD!")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(Color(hex: "#F39C12"))
                            .padding(.horizontal, 16).padding(.vertical, 6)
                            .background(Color(hex: "#F39C12").opacity(0.15))
                            .cornerRadius(20)
                    }
                }

                // Stars row
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: i < starsShown ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundColor(i < starsShown ? Color(hex: "#F39C12") : .white.opacity(0.2))
                            .scaleEffect(i < starsShown ? 1.2 : 0.9)
                            .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.6 + Double(i) * 0.15), value: starsShown)
                    }
                }

                // Stats card
                VStack(spacing: 16) {
                    statRow(label: "POSITION", value: "\(ordinal(result.position)) / \(result.totalPlayers)", highlight: isVictory)
                    Divider().background(Color.white.opacity(0.1))
                    statRow(label: "RACE TIME", value: formatTime(result.raceTime), highlight: false)
                    Divider().background(Color.white.opacity(0.1))
                    statRow(label: "BEST LAP", value: formatTime(result.bestLap), highlight: false)
                    Divider().background(Color.white.opacity(0.1))
                    statRow(label: "SCORE", value: "+\(result.scoreEarned)", highlight: true)
                    statRow(label: "XP", value: "+\(result.xpEarned) XP", highlight: true)
                }
                .padding(20)
                .background(Color.white.opacity(0.07))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                .padding(.horizontal, 24)
                .opacity(animIn ? 1 : 0)
                .offset(y: animIn ? 0 : 30)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: animIn)

                // Buttons
                HStack(spacing: 14) {
                    Button(action: onPlayAgain) {
                        Label("REPLAY", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    Button(action: onContinue) {
                        Label("CONTINUE", systemImage: "chevron.right")
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(hex: "#00FF88"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 24)
                .opacity(animIn ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.55), value: animIn)

                Spacer()
            }
        }
        .onAppear {
            animIn = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { starsShown = result.stars }
            }
            if isVictory {
                Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
                    confettiOffset += 2
                }
            }
        }
    }

    @ViewBuilder
    private func statRow(label: String, value: String, highlight: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(highlight ? Color(hex: "#00FF88") : .white)
        }
    }

    private var positionEmoji: String {
        switch result.position {
        case 1: return "🏆"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏎️"
        }
    }

    private func ordinal(_ n: Int) -> String {
        switch n { case 1: return "1st"; case 2: return "2nd"; case 3: return "3rd"; default: return "\(n)th" }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60; let s = Int(t) % 60; let ms = Int((t - Double(Int(t))) * 100)
        return String(format: "%d:%02d.%02d", m, s, ms)
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat; var yStart: CGFloat; var size: CGFloat; var color: Color; var alpha: Double
    static func generate(count: Int) -> [ConfettiParticle] {
        let colors: [Color] = [Color(hex:"#FF6B35"),Color(hex:"#00E5FF"),Color(hex:"#F39C12"),Color(hex:"#00FF88"),Color(hex:"#FF2D95")]
        return (0..<count).map { _ in
            ConfettiParticle(x: CGFloat.random(in:0...1), yStart: CGFloat.random(in:-400...0),
                             size: CGFloat.random(in:5...12), color: colors.randomElement()!, alpha: Double.random(in:0.6...1))
        }
    }
}

#Preview {
    VictoryScreenView(result: RaceResultData(position: 1, totalPlayers: 2,
        raceTime: 143.27, bestLap: 46.88, scoreEarned: 2450, xpEarned: 120,
        stars: 3, isNewRecord: true, gameName: "NITRO RACER"))
}
