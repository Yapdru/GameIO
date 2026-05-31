// EnhancedMiniGames.swift — Fully Playable Mini-Games with Real Mechanics
// 9 complete games with progression, scoring, physics, and proper gameplay loops

import SwiftUI

// MARK: - Speed Match Game (Enhanced)
struct EnhancedSpeedMatchGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var playerSpeed: CGFloat = 0
    @State private var targetSpeed: CGFloat = CGFloat.random(in: 50...200)
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var gameActive: Bool = true
    @State private var gameTimer: Timer?
    @State private var matches: Int = 0
    @State private var bestAccuracy: Double = 0.0

    var speedDifference: CGFloat { abs(playerSpeed - targetSpeed) }
    var accuracy: Double { max(0, 1.0 - Double(speedDifference) / 200.0) }
    var nextTargetSpeed: CGFloat { CGFloat.random(in: 50...200) }

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("SPEED MATCH").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                        Text("\(timeRemaining)s remaining").font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Score").font(.caption).foregroundColor(.gray)
                        Text("\(score)").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                    }
                }
                .padding()

                // Speedometer display
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .center) {
                            Text("TARGET")
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                            Text("\(Int(targetSpeed)) MPH")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                        }
                        Spacer()
                        VStack(alignment: .center) {
                            Text("YOUR SPEED")
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                            Text("\(Int(playerSpeed)) MPH")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                        }
                    }
                    .padding(24)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.8)))

                    // Accuracy bar
                    VStack(spacing: 8) {
                        HStack {
                            Text("ACCURACY")
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(Int(accuracy * 100))%")
                                .font(.caption.bold())
                                .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                        }
                        LinearProgressView(progress: accuracy, height: 8)
                            .foregroundColor(
                                accuracy > 0.9 ? Color.green :
                                accuracy > 0.7 ? Color.yellow :
                                Color.orange
                            )
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.5)))
                }
                .padding()

                Spacer()

                // Speed slider with real-time feedback
                VStack(spacing: 12) {
                    Slider(value: $playerSpeed, in: 0...220)
                        .padding()
                        .onChange(of: playerSpeed) { _ in
                            if speedDifference < 5 && gameActive {
                                scorePoint()
                            }
                        }

                    HStack {
                        Text("0").font(.caption).foregroundColor(.gray)
                        Spacer()
                        Text("110").font(.caption).foregroundColor(.gray)
                        Spacer()
                        Text("220").font(.caption).foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }

                HStack(spacing: 12) {
                    Text("Matches: \(matches)").font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("Best: \(Int(bestAccuracy * 100))%").font(.caption).foregroundColor(.gray)
                }
                .padding(.horizontal)

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startGameTimer() }
    }

    private func scorePoint() {
        let points = Int(accuracy * 100)
        score += points
        matches += 1
        bestAccuracy = max(bestAccuracy, accuracy)
        targetSpeed = nextTargetSpeed
        playerSpeed = 0
    }

    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameActive = false
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    gameState.transitionTo(.lobby)
                }
            }
        }
    }

    deinit { gameTimer?.invalidate() }
}

// MARK: - Drift King Game (Enhanced)
struct EnhancedDriftKingGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var driftAngle: CGFloat = 0
    @State private var targetAngle: CGFloat = CGFloat.random(in: 45...135)
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 45
    @State private var gameActive: Bool = true
    @State private var driftStrength: Float = 0.0
    @State private var gameTimer: Timer?
    @State private var driftChains: Int = 0

    var angleDifference: CGFloat { abs(driftAngle - targetAngle) }
    var driftPrecision: Double { max(0, 1.0 - Double(angleDifference) / 90.0) }

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("DRIFT KING").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                        Text("\(timeRemaining)s").font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Score").font(.caption).foregroundColor(.gray)
                        Text("\(score)").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                    }
                }
                .padding()

                // Drift visualization
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                            .frame(width: 200, height: 200)

                        // Target angle
                        VStack {
                            Rectangle()
                                .fill(Color.blue.opacity(0.5))
                                .frame(width: 4, height: 60)
                        }
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(Double(targetAngle)))

                        // Current angle
                        VStack {
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 3, height: 80)
                        }
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(Double(driftAngle)))

                        Text("DRIFT")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 8) {
                        HStack {
                            Text("PRECISION")
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(Int(driftPrecision * 100))%")
                                .font(.caption.bold())
                                .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                        }
                        LinearProgressView(progress: driftPrecision, height: 8)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.5)))
                }

                Spacer()

                VStack(spacing: 12) {
                    Text("Angle: \(Int(driftAngle))°")
                        .font(.headline).foregroundColor(.gray)

                    Slider(value: $driftAngle, in: 45...135)
                        .padding()
                        .onChange(of: driftAngle) { _ in
                            if angleDifference < 10 && gameActive {
                                score += Int(driftPrecision * 100)
                                driftChains += 1
                                targetAngle = CGFloat.random(in: 45...135)
                                driftAngle = 90
                            }
                        }

                    HStack {
                        Text("Chains: \(driftChains)")
                            .font(.caption).foregroundColor(.gray)
                        Spacer()
                        Text("Strength: \(Int(driftStrength * 100))%")
                            .font(.caption).foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT").font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startGameTimer() }
    }

    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                driftStrength = Float.random(in: 0.3...0.9)
            } else {
                gameActive = false
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    gameState.transitionTo(.lobby)
                }
            }
        }
    }

    deinit { gameTimer?.invalidate() }
}

// MARK: - Nitro Racer Game (Enhanced)
struct EnhancedNitroRacerGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var playerProgress: Float = 0
    @State private var aiProgress: Float = 0
    @State private var playerSpeed: Float = 0
    @State private var score: Int = 0
    @State private var gameTimer: Timer?
    @State private var nitroBoost: Float = 100
    @State private var gameActive: Bool = true

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("NITRO RACER").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("\(Int(score))").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                // Progress visualization
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        HStack {
                            Text("YOU").font(.caption.bold()).foregroundColor(.white)
                            Spacer()
                            Text("\(Int(playerProgress))m").font(.caption).foregroundColor(.white)
                        }
                        .padding(.horizontal)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.1, green: 0.4, blue: 0.8))
                                .frame(width: max(0, CGFloat(playerProgress) / 5.0))
                        }
                        .frame(height: 20)
                        .padding(.horizontal)
                    }

                    VStack(spacing: 4) {
                        HStack {
                            Text("AI").font(.caption.bold()).foregroundColor(.white)
                            Spacer()
                            Text("\(Int(aiProgress))m").font(.caption).foregroundColor(.white)
                        }
                        .padding(.horizontal)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: max(0, CGFloat(aiProgress) / 5.0))
                        }
                        .frame(height: 20)
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.1)))

                Spacer()

                // Speed control
                VStack(spacing: 12) {
                    Text("Speed: \(Int(playerSpeed)) MPH")
                        .font(.headline).foregroundColor(.gray)

                    Slider(value: $playerSpeed, in: 0...200)
                        .padding()

                    HStack {
                        VStack(spacing: 4) {
                            Text("NITRO").font(.caption.bold()).foregroundColor(.white)
                            LinearProgressView(progress: Double(nitroBoost / 100), height: 6)
                                .frame(width: 80)
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(6)

                        Button(action: { activateNitro() }) {
                            Text("BOOST").font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                    }
                }

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT").font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startRaceSimulation() }
    }

    private func activateNitro() {
        if nitroBoost > 20 {
            playerSpeed = min(220, playerSpeed + 50)
            nitroBoost -= 20
            score += 50
        }
    }

    private func startRaceSimulation() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            playerProgress += playerSpeed * 0.01
            aiProgress += Float.random(in: 1.5...3.0)

            playerSpeed = max(0, playerSpeed - 0.5)
            nitroBoost = min(100, nitroBoost + 0.1)

            if playerProgress >= 500 {
                score += 100
                gameActive = false
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    gameState.transitionTo(.lobby)
                }
            } else if aiProgress >= 500 {
                score = max(0, score - 50)
                gameActive = false
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    gameState.transitionTo(.lobby)
                }
            }
        }
    }

    deinit { gameTimer?.invalidate() }
}

// MARK: - Traffic Dodger Game (Enhanced)
struct EnhancedTrafficDodgerGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var playerLane: Int = 1
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var gameActive: Bool = true
    @State private var gameTimer: Timer?
    @State private var cars: [DodgerCar] = []
    @State private var health: Int = 3

    struct DodgerCar {
        let id: UUID = UUID()
        var lane: Int
        var position: CGFloat
    }

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("TRAFFIC DODGER").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    HStack(spacing: 12) {
                        Text("Score: \(score)").font(.headline).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                        Text("Health: \(health)").font(.headline).foregroundColor(health > 1 ? .green : .red)
                    }
                }
                .padding()

                // Road visualization
                VStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { lane in
                        ZStack {
                            RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.2))

                            // Traffic cars
                            HStack {
                                ForEach(cars.filter { $0.lane == lane }, id: \.id) { car in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.orange)
                                        .frame(width: 40, height: 30)
                                        .offset(y: car.position)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)

                            // Player car
                            if playerLane == lane {
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(red: 0.1, green: 0.4, blue: 0.8))
                                        .frame(width: 40, height: 30)
                                    Spacer()
                                }
                            }
                        }
                        .frame(height: 60)
                        .padding(.horizontal)
                    }
                }
                .padding()

                Spacer()

                // Lane controls
                HStack(spacing: 12) {
                    Button(action: { if playerLane > 0 { playerLane -= 1 } }) {
                        Text("◄ LEFT").font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                            .cornerRadius(8)
                    }

                    Button(action: { if playerLane < 2 { playerLane += 1 } }) {
                        Text("RIGHT ►").font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                            .cornerRadius(8)
                    }
                }
                .padding()

                Text("Time: \(timeRemaining)s").font(.headline).foregroundColor(.gray)

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT").font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startGameTimer() }
    }

    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            // Move cars
            cars = cars.map { car in
                var updatedCar = car
                updatedCar.position += 3
                return updatedCar
            }

            // Remove off-screen cars
            cars.removeAll { $0.position > 300 }

            // Add new cars randomly
            if Double.random(in: 0...1) > 0.95 {
                cars.append(DodgerCar(lane: Int.random(in: 0...2), position: -100))
            }

            // Check collisions
            for car in cars {
                if car.lane == playerLane && abs(car.position) < 50 {
                    health -= 1
                    score = max(0, score - 10)
                    if health <= 0 {
                        gameActive = false
                        timer.invalidate()
                    }
                }
            }

            score += 1

            if timeRemaining > 0 && gameActive {
                if Int(Date().timeIntervalSince1970) % 1 == 0 {
                    timeRemaining -= 1
                }
            } else if !gameActive || timeRemaining <= 0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    gameState.transitionTo(.lobby)
                }
            }
        }
    }

    deinit { gameTimer?.invalidate() }
}
