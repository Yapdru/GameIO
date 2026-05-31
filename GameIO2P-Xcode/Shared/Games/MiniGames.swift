// MiniGames.swift — 9 fully playable mini-games
// Speed Match, Drift King, Nitro Racer, Pit Stop, Traffic Dodger, Fuel Rush, Turbo Quiz, Parking Master, Drag Strip

import SwiftUI

// MARK: - Speed Match Game
struct SpeedMatchGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var playerSpeed: CGFloat = 0
    @State private var targetSpeed: CGFloat = CGFloat.random(in: 50...200)
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var gameActive: Bool = true
    @State private var speedInput: CGFloat = 0

    var speedDifference: CGFloat {
        abs(playerSpeed - targetSpeed)
    }

    var speedAccuracy: Double {
        max(0, 1.0 - Double(speedDifference) / 200.0)
    }

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("SPEED MATCH").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                        Text("Time: \(timeRemaining)s").font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    Text("Score: \(score)").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                VStack(spacing: 16) {
                    Text("Target Speed")
                        .font(.headline).foregroundColor(.gray)
                    Text("\(Int(targetSpeed)) MPH")
                        .font(.system(size: 48, weight: .bold)).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))

                    Text("Your Speed")
                        .font(.headline).foregroundColor(.gray)
                    Text("\(Int(playerSpeed)) MPH")
                        .font(.system(size: 42, weight: .bold)).foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                }
                .padding(24)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.98, green: 0.98, blue: 0.99)))

                Slider(value: $playerSpeed, in: 0...220)
                    .padding()
                    .onChange(of: playerSpeed) { _ in
                        if speedDifference < 10 && gameActive {
                            score += Int(speedAccuracy * 100)
                            targetSpeed = CGFloat.random(in: 50...200)
                            playerSpeed = 0
                        }
                    }

                Spacer()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear {
            startGameTimer()
        }
    }

    private func startGameTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameActive = false
                timer.invalidate()
            }
        }
    }
}

// MARK: - Drift King Game
struct DriftKingGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var playerAngle: CGFloat = 0
    @State private var driftStrength: CGFloat = 0
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 45
    @State private var gameActive: Bool = true

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("DRIFT KING").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("Score: \(score)").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                ZStack {
                    Circle()
                        .fill(Color(red: 0.98, green: 0.98, blue: 0.99))
                        .frame(width: 200, height: 200)

                    VStack {
                        Text("ANGLE")
                            .font(.caption).foregroundColor(.gray)
                        Text("\(Int(playerAngle))°")
                            .font(.system(size: 32, weight: .bold)).foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                    }
                    .rotationEffect(.degrees(playerAngle))
                }

                VStack(spacing: 12) {
                    Text("Rotate to Drift").font(.headline).foregroundColor(.gray)
                    Slider(value: $playerAngle, in: 0...360)
                        .onChange(of: playerAngle) { angle in
                            if angle > 45 && angle < 135 && gameActive {
                                score += 50
                                driftStrength = abs(angle - 90) / 90
                            }
                        }
                }
                .padding()

                Text("Drift Strength: \(Int(driftStrength * 100))%")
                    .font(.headline).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))

                Spacer()

                Text("Time: \(timeRemaining)s").font(.headline).foregroundColor(.gray)

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startGameTimer() }
    }

    private func startGameTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameActive = false
                timer.invalidate()
            }
        }
    }
}

// MARK: - Nitro Racer Game
struct NitroRacerGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var nitroLevel: CGFloat = 0
    @State private var playerPosition: CGFloat = 0
    @State private var opponentPosition: CGFloat = 0
    @State private var score: Int = 0
    @State private var gameActive: Bool = true

    var playerWinning: Bool { playerPosition > opponentPosition }

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("NITRO RACER").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("Score: \(score)").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("YOU").font(.headline).foregroundColor(.gray)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                        RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.1, green: 0.4, blue: 0.8)).frame(width: playerPosition * 300)
                    }
                    .frame(height: 40)
                }
                .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("OPPONENT").font(.headline).foregroundColor(.gray)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                        RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.8, green: 0.2, blue: 0.2)).frame(width: opponentPosition * 300)
                    }
                    .frame(height: 40)
                }
                .padding()

                VStack(spacing: 12) {
                    Text("NITRO LEVEL").font(.headline).foregroundColor(.gray)
                    Slider(value: $nitroLevel, in: 0...1)
                        .onChange(of: nitroLevel) { _ in
                            if nitroLevel > 0.8 && gameActive {
                                playerPosition = min(1, playerPosition + 0.15)
                                opponentPosition = min(1, opponentPosition + CGFloat.random(in: 0.05...0.12))
                                score += 100

                                if playerPosition >= 1 {
                                    gameActive = false
                                }
                            }
                        }
                }
                .padding()

                Spacer()

                if !gameActive {
                    Text(playerWinning ? "YOU WON!" : "OPPONENT WON!").font(.title2.bold()).foregroundColor(playerWinning ? Color(red: 0.1, green: 0.4, blue: 0.8) : Color(red: 0.8, green: 0.2, blue: 0.2))
                }

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

// MARK: - Pit Stop Game
struct PitStopGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var tasksCompleted: Int = 0
    @State private var timeRemaining: Int = 30
    @State private var gameActive: Bool = true
    @State private var wheelChanged: Bool = false
    @State private var fuelAdded: Bool = false
    @State private var wingAdjusted: Bool = false

    var allTasksCompleted: Bool { wheelChanged && fuelAdded && wingAdjusted }

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("PIT STOP").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("Time: \(timeRemaining)s").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                VStack(spacing: 16) {
                    TaskButton(title: "Change Wheels", isCompleted: $wheelChanged, taskNumber: 1)
                    TaskButton(title: "Add Fuel", isCompleted: $fuelAdded, taskNumber: 2)
                    TaskButton(title: "Adjust Wing", isCompleted: $wingAdjusted, taskNumber: 3)
                }
                .padding()

                if allTasksCompleted {
                    Text("PIT STOP COMPLETE!").font(.title3.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                }

                Spacer()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startGameTimer() }
    }

    private func startGameTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameActive = false
                timer.invalidate()
            }
        }
    }
}

struct TaskButton: View {
    let title: String
    @Binding var isCompleted: Bool
    let taskNumber: Int

    var body: some View {
        Button(action: { isCompleted.toggle() }) {
            HStack {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? Color(red: 0.1, green: 0.4, blue: 0.8) : .gray)
                Text(title)
                    .foregroundColor(isCompleted ? Color(red: 0.1, green: 0.4, blue: 0.8) : Color(red: 0.2, green: 0.2, blue: 0.2))
                Spacer()
                Text(isCompleted ? "DONE" : "TAP").font(.caption).foregroundColor(.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.98, green: 0.98, blue: 0.99)))
        }
    }
}

// MARK: - Traffic Dodger Game
struct TrafficDodgerGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var playerLane: Int = 1
    @State private var score: Int = 0
    @State private var gameActive: Bool = true
    @State private var obstacles: [ObstacleModel] = []
    @State private var timeRemaining: Int = 60

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("TRAFFIC DODGER").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("Score: \(score)").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { lane in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8).fill(lane == playerLane ? Color(red: 0.1, green: 0.4, blue: 0.8) : Color(red: 0.9, green: 0.9, blue: 0.9))
                            Image(systemName: "car.fill").foregroundColor(lane == playerLane ? .white : .gray)
                        }
                        .frame(height: 60)
                        .onTapGesture { playerLane = lane }
                    }
                }
                .padding()

                VStack(spacing: 12) {
                    ForEach(obstacles, id: \.id) { obstacle in
                        HStack {
                            Spacer().frame(width: CGFloat(obstacle.lane) * 120)
                            RoundedRectangle(cornerRadius: 8).fill(Color.red).frame(width: 80, height: 40)
                            Spacer()
                        }
                    }
                }
                .padding()

                Text("Time: \(timeRemaining)s").font(.headline).foregroundColor(.gray)

                Spacer()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startGameLoop() }
    }

    private func startGameLoop() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if gameActive {
                if Int.random(in: 0..<3) == 0 {
                    obstacles.append(ObstacleModel(lane: Int.random(in: 0..<3)))
                }
                obstacles.removeAll { $0.position > 1 }
                obstacles = obstacles.map { var o = $0; o.position += 0.05; return o }
                score += 1

                if timeRemaining > 0 { timeRemaining -= 1 }
            }
        }
    }
}

struct ObstacleModel: Identifiable {
    let id = UUID()
    let lane: Int
    var position: CGFloat = 0
}

// MARK: - Fuel Rush Game
struct FuelRushGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var fuelLevel: CGFloat = 1.0
    @State private var distance: CGFloat = 0
    @State private var score: Int = 0
    @State private var gameActive: Bool = true

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("FUEL RUSH").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("Score: \(score)").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                VStack(spacing: 12) {
                    Text("FUEL LEVEL").font(.headline).foregroundColor(.gray)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                        RoundedRectangle(cornerRadius: 8).fill(fuelLevel > 0.5 ? Color(red: 0.1, green: 0.4, blue: 0.8) : Color(red: 0.8, green: 0.2, blue: 0.2)).frame(width: fuelLevel * 300)
                    }
                    .frame(height: 40)
                    Text("\(Int(fuelLevel * 100))%").font(.headline).foregroundColor(.gray)
                }
                .padding()

                VStack(spacing: 12) {
                    Text("DISTANCE").font(.headline).foregroundColor(.gray)
                    Text("\(Int(distance)) KM").font(.system(size: 36, weight: .bold)).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                }
                .padding()

                Spacer()

                if fuelLevel <= 0 {
                    Text("OUT OF FUEL!").font(.title2.bold()).foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                }

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startGameLoop() }
    }

    private func startGameLoop() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if gameActive {
                fuelLevel = max(0, fuelLevel - 0.01)
                if fuelLevel > 0 {
                    distance += 0.1
                    score = Int(distance)
                } else {
                    gameActive = false
                }
            }
        }
    }
}

// MARK: - Turbo Quiz Game
struct TurboQuizGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var currentQuestion: Int = 0
    @State private var score: Int = 0
    @State private var gameActive: Bool = true

    let questions = [
        ("What is the top speed of a Ferrari?", ["200 mph", "230 mph", "250 mph", "180 mph"], 2),
        ("How long is a Lamborghini?", ["4.5 m", "5.2 m", "4.8 m", "5.5 m"], 2),
        ("What year was the first Porsche made?", ["1948", "1955", "1960", "1945"], 0),
        ("Which car has the most horsepower?", ["Bugatti", "Ferrari", "McLaren", "Koenigsegg"], 3),
        ("What does MPH stand for?", ["Miles Per Hour", "Max Power Hour", "Motor Performance Hour", "Multiple Power Hours"], 0),
    ]

    var currentQuestionData: (String, [String], Int) {
        questions[min(currentQuestion, questions.count - 1)]
    }

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("TURBO QUIZ").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("Score: \(score)").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                if currentQuestion < questions.count {
                    VStack(spacing: 20) {
                        Text("Q\(currentQuestion + 1): \(currentQuestionData.0)")
                            .font(.headline).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                            .padding()

                        VStack(spacing: 12) {
                            ForEach(0..<currentQuestionData.1.count, id: \.self) { idx in
                                Button(action: {
                                    if idx == currentQuestionData.2 {
                                        score += 100
                                    }
                                    if currentQuestion < questions.count - 1 {
                                        currentQuestion += 1
                                    } else {
                                        gameActive = false
                                    }
                                }) {
                                    Text(currentQuestionData.1[idx])
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.1, green: 0.4, blue: 0.8)).cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("QUIZ COMPLETE!").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                }

                Spacer()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

// MARK: - Parking Master Game
struct ParkingMasterGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var carPosition: CGFloat = 0
    @State private var parkingAccuracy: CGFloat = 0
    @State private var score: Int = 0
    @State private var gameActive: Bool = true

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("PARKING MASTER").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("Score: \(score)").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.98, green: 0.98, blue: 0.99)).frame(height: 300)

                    VStack(spacing: 12) {
                        HStack {
                            RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.2, green: 0.2, blue: 0.2)).frame(width: 40, height: 80)
                            Spacer()
                            RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.2, green: 0.2, blue: 0.2)).frame(width: 40, height: 80)
                        }
                        .padding()

                        Spacer()

                        HStack {
                            Spacer().frame(width: carPosition)
                            RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.1, green: 0.4, blue: 0.8)).frame(width: 50, height: 70)
                            Spacer()
                        }

                        Spacer()

                        Text("PARKING SPOT").font(.caption).foregroundColor(.gray)
                    }
                    .padding()
                }
                .padding()

                VStack(spacing: 12) {
                    Text("Position Car").font(.headline).foregroundColor(.gray)
                    Slider(value: $carPosition, in: 0...250)
                        .onChange(of: carPosition) { _ in
                            parkingAccuracy = max(0, 1.0 - abs(carPosition - 100) / 150)
                            if parkingAccuracy > 0.8 && gameActive {
                                score += Int(parkingAccuracy * 1000)
                                carPosition = 0
                            }
                        }
                    Text("Accuracy: \(Int(parkingAccuracy * 100))%").font(.caption).foregroundColor(.gray)
                }
                .padding()

                Spacer()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

// MARK: - Drag Strip Game
struct DragStripGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var throttleLevel: CGFloat = 0
    @State private var rpmLevel: CGFloat = 0
    @State private var distance: CGFloat = 0
    @State private var score: Int = 0
    @State private var gameActive: Bool = true
    @State private var raceStarted: Bool = false

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("DRAG STRIP").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("Score: \(score)").font(.title3.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                if !raceStarted {
                    VStack(spacing: 20) {
                        Text("3").font(.system(size: 60, weight: .bold)).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                        Button(action: { raceStarted = true; startRace() }) {
                            Text("START RACE")
                                .font(.headline).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding().background(Color(red: 0.1, green: 0.4, blue: 0.8)).cornerRadius(8)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Text("DISTANCE: \(Int(distance)) M").font(.headline).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))

                        VStack(spacing: 12) {
                            Text("THROTTLE").font(.caption).foregroundColor(.gray)
                            Slider(value: $throttleLevel, in: 0...1)
                        }
                        .padding()

                        VStack(spacing: 12) {
                            Text("RPM").font(.caption).foregroundColor(.gray)
                            Slider(value: $rpmLevel, in: 0...1)
                        }
                        .padding()
                    }
                }

                Spacer()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.8, green: 0.2, blue: 0.2)).cornerRadius(8)
                }
                .padding()
            }
        }
    }

    private func startRace() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if gameActive && raceStarted {
                distance += throttleLevel * 5
                score = Int(distance * 2)

                if distance >= 500 {
                    gameActive = false
                }
            }
        }
    }
}
