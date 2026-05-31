// MoreMiniGames.swift — 6 Additional Mini-Games
// Pit Stop, Fuel Rush, Parking Master, Drag Strip, Turbo Quiz, Endurance

import SwiftUI

// MARK: - Pit Stop Challenge (Enhanced)
struct EnhancedPitStopGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 30
    @State private var gameActive: Bool = true
    @State private var gameTimer: Timer?

    @State private var wheelsChanged: Bool = false
    @State private var fuelAdded: Bool = false
    @State private var wingStepped: Bool = false

    @State private var wheelTimer: Int = 5
    @State private var fuelTimer: Int = 3
    @State private var wingTimer: Int = 2

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("PIT STOP CHALLENGE").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("\(score)").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                Text("Complete all tasks before time runs out!")
                    .font(.caption).foregroundColor(.gray)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    TaskRow(
                        title: "Change Wheels",
                        timeLeft: wheelTimer,
                        completed: wheelsChanged,
                        action: { completeTask(&wheelsChanged, 50) }
                    )

                    TaskRow(
                        title: "Add Fuel",
                        timeLeft: fuelTimer,
                        completed: fuelAdded,
                        action: { completeTask(&fuelAdded, 30) }
                    )

                    TaskRow(
                        title: "Adjust Wing",
                        timeLeft: wingTimer,
                        completed: wingStepped,
                        action: { completeTask(&wingStepped, 20) }
                    )
                }
                .padding()

                Spacer()

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

    private func completeTask(_ completed: inout Bool, points: Int) {
        if !completed && gameActive {
            completed = true
            score += points
        }
    }

    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if wheelTimer > 0 { wheelTimer -= 1 }
                if fuelTimer > 0 { fuelTimer -= 1 }
                if wingTimer > 0 { wingTimer -= 1 }
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

struct TaskRow: View {
    let title: String
    let timeLeft: Int
    let completed: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).font(.headline).foregroundColor(.gray)
                Text("\(timeLeft)s").font(.caption).foregroundColor(.gray)
            }
            Spacer()
            if completed {
                Text("✓").font(.title2).foregroundColor(.green)
            } else {
                Button(action: action) {
                    Text("TAP").font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.5)))
    }
}

// MARK: - Fuel Rush (Enhanced)
struct EnhancedFuelRushGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var fuelLevel: Float = 100
    @State private var distance: Float = 0
    @State private var speed: Float = 0
    @State private var score: Int = 0
    @State private var gameTimer: Timer?
    @State private var gameActive: Bool = true

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("FUEL RUSH").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("\(Int(distance))m").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                VStack(spacing: 12) {
                    HStack {
                        Text("FUEL").font(.caption.bold()).foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(fuelLevel))%").font(.caption.bold()).foregroundColor(fuelLevel > 30 ? .green : .red)
                    }
                    LinearProgressView(progress: Double(fuelLevel / 100), height: 10)
                        .foregroundColor(fuelLevel > 50 ? .green : fuelLevel > 25 ? .yellow : .red)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.5)))

                Spacer()

                VStack(spacing: 16) {
                    Text("Speed: \(Int(speed)) MPH").font(.headline).foregroundColor(.gray)
                    Slider(value: $speed, in: 0...150)
                        .padding()

                    HStack {
                        Text("Distance: \(Int(distance))m").font(.headline).foregroundColor(.gray)
                        Spacer()
                        Text("Score: \(score)").font(.headline).foregroundColor(.gray)
                    }
                    .padding()
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
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            distance += speed * 0.05
            fuelLevel -= (speed * 0.03)
            score = Int(distance / 10)

            if fuelLevel <= 0 {
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

// MARK: - Parking Master (Enhanced)
struct EnhancedParkingMasterGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var carPosition: CGFloat = 50
    @State private var targetPosition: CGFloat = 75
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 45
    @State private var gameActive: Bool = true
    @State private var gameTimer: Timer?
    @State private var parkingSpaces: Int = 5

    var positionAccuracy: Double { max(0, 1.0 - Double(abs(carPosition - targetPosition)) / 50.0) }

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("PARKING MASTER").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("\(score)").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                VStack(spacing: 16) {
                    // Parking visualization
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 60)

                        // Target spot
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .offset(x: targetPosition)

                        // Player car
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.1, green: 0.4, blue: 0.8))
                            .frame(width: 50, height: 50)
                            .offset(x: carPosition)
                    }
                    .padding()

                    Slider(value: $carPosition, in: 0...250)
                        .padding()
                        .onChange(of: carPosition) { _ in
                            if abs(carPosition - targetPosition) < 5 && gameActive {
                                score += Int(positionAccuracy * 100)
                                targetPosition = CGFloat.random(in: 0...250)
                                carPosition = 125
                                parkingSpaces -= 1
                            }
                        }

                    VStack(spacing: 8) {
                        HStack {
                            Text("ACCURACY").font(.caption.bold()).foregroundColor(.gray)
                            Spacer()
                            Text("\(Int(positionAccuracy * 100))%").font(.caption.bold()).foregroundColor(.blue)
                        }
                        LinearProgressView(progress: positionAccuracy, height: 8)
                    }
                    .padding()
                }

                Spacer()

                HStack {
                    Text("Time: \(timeRemaining)s").font(.caption).foregroundColor(.gray)
                    Spacer()
                    Text("Spaces: \(parkingSpaces)").font(.caption).foregroundColor(.gray)
                }
                .padding(.horizontal)

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
            } else if parkingSpaces == 0 {
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

// MARK: - Drag Strip (Enhanced)
struct EnhancedDragStripGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var distance: Float = 0
    @State private var throttle: CGFloat = 0
    @State private var rpm: Float = 800
    @State private var time: Float = 0
    @State private var gameTimer: Timer?
    @State private var gameActive: Bool = true
    @State private var finalTime: Float?

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("DRAG STRIP").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("\(Int(distance))m").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                VStack(spacing: 12) {
                    HStack {
                        Text("RPM").font(.caption.bold()).foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(rpm))").font(.caption.bold()).foregroundColor(.gray)
                    }
                    LinearProgressView(progress: Double(rpm / 8000), height: 8)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.5)))

                Spacer()

                VStack(spacing: 16) {
                    Text("Time: \(String(format: "%.2f", time))s").font(.title2).foregroundColor(.gray)

                    VStack(spacing: 8) {
                        Text("Throttle").font(.caption.bold()).foregroundColor(.gray)
                        Slider(value: $throttle, in: 0...1)
                            .padding()
                            .onChange(of: throttle) { _ in
                                rpm = min(8000, rpm + Float(throttle) * 100)
                            }
                    }

                    if let finalTime = finalTime {
                        Text("Final Time: \(String(format: "%.2f", finalTime))s")
                            .font(.headline).foregroundColor(.green)
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
        .onAppear { startRaceTimer() }
    }

    private func startRaceTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            time += 0.016
            rpm = max(800, rpm - 5)

            let acceleration = Float(throttle) * 50
            distance += acceleration * 0.016

            if distance >= 500 {
                gameActive = false
                finalTime = time
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    gameState.transitionTo(.lobby)
                }
            }
        }
    }

    deinit { gameTimer?.invalidate() }
}

// MARK: - Turbo Quiz (Enhanced)
struct EnhancedTurboQuizGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var currentQuestion: Int = 0
    @State private var score: Int = 0
    @State private var gameTimer: Timer?
    @State private var timePerQuestion: Int = 20

    let questions: [(question: String, answers: [String], correct: Int)] = [
        ("What is the top speed of most F1 cars?", ["220 MPH", "240 MPH", "370 MPH"], 2),
        ("Which brand makes the Bugatti Chiron?", ["Ferrari", "Bugatti", "Lambo"], 1),
        ("What does downforce do in racing?", ["Slows car", "Increases traction", "Reduces speed"], 1),
        ("Which circuit is the most famous?", ["Monaco", "Daytona", "Le Mans"], 0),
        ("What year did F1 start?", ["1920", "1950", "1975"], 1),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("TURBO QUIZ").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Spacer()
                    Text("\(score)").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                }
                .padding()

                if currentQuestion < questions.count {
                    VStack(spacing: 20) {
                        Text("Question \(currentQuestion + 1)/\(questions.count)")
                            .font(.caption).foregroundColor(.gray)

                        Text(questions[currentQuestion].question)
                            .font(.headline).foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 12) {
                            ForEach(Array(questions[currentQuestion].answers.enumerated()), id: \.offset) { index, answer in
                                Button(action: { selectAnswer(index) }) {
                                    Text(answer)
                                        .font(.headline).foregroundColor(.white)
                                        .frame(maxWidth: .infinity).padding()
                                        .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("Quiz Complete!").font(.title2.bold()).foregroundColor(.gray)
                        Text("Final Score: \(score)").font(.title.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                    }
                }

                Spacer()

                Text("Time: \(timePerQuestion)s").font(.caption).foregroundColor(.gray)

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT").font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startQuizTimer() }
    }

    private func selectAnswer(_ index: Int) {
        if index == questions[currentQuestion].correct {
            score += 100
        }
        currentQuestion += 1
    }

    private func startQuizTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timePerQuestion > 0 {
                timePerQuestion -= 1
            } else {
                currentQuestion += 1
                timePerQuestion = 20
                if currentQuestion >= questions.count {
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        gameState.transitionTo(.lobby)
                    }
                }
            }
        }
    }

    deinit { gameTimer?.invalidate() }
}
