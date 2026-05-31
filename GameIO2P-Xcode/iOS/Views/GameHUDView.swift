// GameHUDView.swift
// GameIO 2P — In-Game HUD
// Speed, position, lap, minimap, nitro bar, fuel bar.

import SwiftUI

struct HUDState: ObservableObject {
    @Published var speed: Double = 0          // km/h
    @Published var maxSpeed: Double = 240
    @Published var position: Int = 1          // 1-based race position
    @Published var totalPlayers: Int = 2
    @Published var currentLap: Int = 1
    @Published var totalLaps: Int = 3
    @Published var lapTime: TimeInterval = 0
    @Published var bestLapTime: TimeInterval? = nil
    @Published var raceTime: TimeInterval = 0
    @Published var nitroCharge: Double = 1.0  // 0..1
    @Published var fuelLevel: Double = 1.0   // 0..1
    @Published var isNitroActive: Bool = false
    @Published var miniMapPoints: [CGPoint] = []
    @Published var carPosition: CGPoint = CGPoint(x: 0.3, y: 0.5)
    @Published var opponentPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @Published var isPaused: Bool = false
}

struct GameHUDView: View {
    @ObservedObject var hud: HUDState
    var onPause: () -> Void = {}
    var onNitro: () -> Void = {}

    var speedPercentage: Double { hud.speed / hud.maxSpeed }

    var body: some View {
        ZStack {
            // Bottom HUD
            VStack {
                // Top row
                HStack(alignment: .top) {
                    positionBadge
                    Spacer()
                    lapInfo
                    Spacer()
                    pauseButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                // Bottom row
                HStack(alignment: .bottom, spacing: 12) {
                    // Minimap
                    minimap

                    Spacer()

                    // Center: Speedometer
                    speedometer

                    Spacer()

                    // Right: bars + nitro button
                    VStack(spacing: 8) {
                        fuelBar
                        nitroBar
                        nitroButton
                    }
                    .frame(width: 80)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Position Badge

    var positionBadge: some View {
        VStack(spacing: 0) {
            Text("\(positionOrdinal(hud.position))")
                .font(.system(size: 38, weight: .black, design: .monospaced))
                .foregroundColor(hud.position == 1 ? Color(hex: "#F39C12") : .white)
                .shadow(color: hud.position == 1 ? Color(hex: "#F39C12").opacity(0.7) : .clear, radius: 10)
            Text("PLACE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(width: 64)
        .padding(8)
        .background(Color.black.opacity(0.55))
        .cornerRadius(10)
    }

    // MARK: - Lap Info

    var lapInfo: some View {
        VStack(spacing: 4) {
            Text("LAP \(hud.currentLap)/\(hud.totalLaps)")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.white)

            Text(formatTime(hud.lapTime))
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(Color(hex: "#00E5FF"))

            if let best = hud.bestLapTime {
                Text("BEST: \(formatTime(best))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color(hex: "#00FF88"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.55))
        .cornerRadius(10)
    }

    // MARK: - Pause Button

    var pauseButton: some View {
        Button(action: onPause) {
            Image(systemName: "pause.fill")
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.55))
                .cornerRadius(10)
        }
    }

    // MARK: - Minimap

    var minimap: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.6))
                .frame(width: 90, height: 90)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2), lineWidth: 1))

            // Track path
            if !hud.miniMapPoints.isEmpty {
                Canvas { ctx, size in
                    var path = Path()
                    let scaled = hud.miniMapPoints.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
                    path.addLines(scaled)
                    ctx.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 2)
                }
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Car dot (player)
            Circle()
                .fill(Color(hex: "#00FF88"))
                .frame(width: 8, height: 8)
                .position(x: hud.carPosition.x * 90, y: hud.carPosition.y * 90)

            // Opponent dot
            Circle()
                .fill(Color(hex: "#FF6B35"))
                .frame(width: 8, height: 8)
                .position(x: hud.opponentPosition.x * 90, y: hud.opponentPosition.y * 90)
        }
        .frame(width: 90, height: 90)
    }

    // MARK: - Speedometer

    var speedometer: some View {
        ZStack {
            // Arc background
            Circle()
                .trim(from: 0.15, to: 0.85)
                .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(90))
                .frame(width: 120, height: 120)

            // Speed arc
            Circle()
                .trim(from: 0.15, to: 0.15 + 0.70 * speedPercentage)
                .stroke(
                    LinearGradient(colors: [Color(hex: "#00FF88"), Color(hex: "#FF6B35"), Color(hex: "#FF2D00")],
                                   startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
                .frame(width: 120, height: 120)
                .animation(.easeOut(duration: 0.1), value: hud.speed)

            VStack(spacing: 0) {
                Text("\(Int(hud.speed))")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                Text("KM/H")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Bars

    var nitroBar: some View {
        VStack(spacing: 2) {
            Text("NITRO")
                .font(.system(size: 8, weight: .black, design: .monospaced))
                .foregroundColor(Color(hex: "#00E5FF"))
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [Color(hex: "#0066FF"), Color(hex: "#00E5FF")],
                                            startPoint: .bottom, endPoint: .top))
                        .frame(height: geo.size.height * hud.nitroCharge)
                        .animation(.easeOut(duration: 0.15), value: hud.nitroCharge)
                }
            }
            .frame(width: 18, height: 50)
        }
    }

    var fuelBar: some View {
        VStack(spacing: 2) {
            Text("FUEL")
                .font(.system(size: 8, weight: .black, design: .monospaced))
                .foregroundColor(hud.fuelLevel < 0.25 ? Color(hex: "#FF2D00") : Color(hex: "#00FF88"))
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(hud.fuelLevel < 0.25 ? Color(hex: "#FF2D00") : Color(hex: "#00FF88"))
                        .frame(height: geo.size.height * hud.fuelLevel)
                        .animation(.easeOut(duration: 0.15), value: hud.fuelLevel)
                }
            }
            .frame(width: 18, height: 50)
        }
    }

    // MARK: - Nitro Button

    var nitroButton: some View {
        Button(action: onNitro) {
            Text("N2O")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(hud.isNitroActive ? .black : Color(hex: "#00E5FF"))
                .frame(width: 50, height: 34)
                .background(hud.isNitroActive ? Color(hex: "#00E5FF") : Color(hex: "#00E5FF").opacity(0.2))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#00E5FF"), lineWidth: 1.5))
        }
        .disabled(hud.nitroCharge < 0.2)
        .opacity(hud.nitroCharge < 0.2 ? 0.4 : 1)
    }

    // MARK: - Helpers

    private func positionOrdinal(_ n: Int) -> String {
        switch n {
        case 1: return "1ST"
        case 2: return "2ND"
        case 3: return "3RD"
        default: return "\(n)TH"
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        let ms = Int((t - Double(Int(t))) * 100)
        return String(format: "%d:%02d.%02d", m, s, ms)
    }
}

#Preview {
    let hud = HUDState()
    hud.speed = 187
    hud.position = 1
    hud.currentLap = 2
    hud.nitroCharge = 0.65
    hud.fuelLevel = 0.42
    hud.miniMapPoints = [CGPoint(x:0.1,y:0.1),CGPoint(x:0.9,y:0.1),CGPoint(x:0.9,y:0.9),CGPoint(x:0.1,y:0.9)]
    return ZStack {
        Color.gray.ignoresSafeArea()
        GameHUDView(hud: hud)
    }
}
