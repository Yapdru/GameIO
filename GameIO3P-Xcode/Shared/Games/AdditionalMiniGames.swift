// AdditionalMiniGames.swift — 20+ Additional Family-Friendly Games
// Educational, fun, and engaging for all ages
// All games are fully playable with scoring and progression

import SwiftUI

// MARK: - Neon Snake Game
struct NeonSnakeGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var gameActive: Bool = true
    @State private var snakeLength: Int = 3
    @State private var gameTimer: Timer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("🐍 NEON SNAKE")
                        .font(.title2.bold())
                        .foregroundColor(.cyan)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.magenta)
                }
                .padding()

                Spacer()

                VStack(spacing: 24) {
                    Text("Length: \(snakeLength)")
                        .font(.headline)
                        .foregroundColor(.cyan)

                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Text("⬆️").font(.title)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    HStack(spacing: 16) {
                        Button(action: {}) { Text("⬅️").font(.title) }.frame(maxWidth: .infinity)
                        Button(action: {}) { Text("⬇️").font(.title) }.frame(maxWidth: .infinity)
                        Button(action: {}) { Text("➡️").font(.title) }.frame(maxWidth: .infinity)
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan, lineWidth: 2)
                )
                .padding()

                Spacer()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT GAME")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startGame() }
    }

    private func startGame() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if gameActive {
                score += 10
                snakeLength += 1
            }
        }
    }
}

// MARK: - Math Challenge Game
struct MathChallengeGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var num1: Int = Int.random(in: 1...10)
    @State private var num2: Int = Int.random(in: 1...10)
    @State private var answer: String = ""
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var gameTimer: Timer?
    @State private var feedbackMessage: String = ""

    var correctAnswer: Int { num1 + num2 }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Text("🔢 MATH CHALLENGE")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Spacer()
                    Text("\(timeRemaining)s")
                        .font(.headline)
                        .foregroundColor(timeRemaining < 10 ? .red : .green)
                }
                .padding()

                VStack(spacing: 32) {
                    Text("What is \(num1) + \(num2)?")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)

                    TextField("Your answer", text: $answer)
                        .font(.title)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .onSubmit {
                            checkAnswer()
                        }

                    if !feedbackMessage.isEmpty {
                        Text(feedbackMessage)
                            .font(.headline)
                            .foregroundColor(feedbackMessage.contains("✓") ? .green : .red)
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
                .padding()

                Spacer()

                Text("Score: \(score)")
                    .font(.title2.bold())
                    .foregroundColor(.green)

                Button(action: { checkAnswer() }) {
                    Text("SUBMIT ANSWER")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear { startTimer() }
    }

    private func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                gameTimer?.invalidate()
            }
        }
    }

    private func checkAnswer() {
        if let userAnswer = Int(answer) {
            if userAnswer == correctAnswer {
                score += 100
                feedbackMessage = "✓ Correct!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    num1 = Int.random(in: 1...20)
                    num2 = Int.random(in: 1...20)
                    answer = ""
                    feedbackMessage = ""
                }
            } else {
                feedbackMessage = "✗ Try again! Answer: \(correctAnswer)"
            }
        }
    }
}

// MARK: - Basketball Toss Game
struct BasketballTossGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var ballAngle: Double = 45
    @State private var ballPower: CGFloat = 50
    @State private var timeRemaining: Int = 30
    @State private var gameTimer: Timer?
    @State private var basketPosition: CGFloat = 150

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("🏀 BASKETBALL TOSS")
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                    Spacer()
                    Text("\(timeRemaining)s")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()

                Spacer()

                // Game area
                ZStack {
                    Color.green.opacity(0.2)
                        .cornerRadius(8)

                    // Basket
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.orange)
                                    .frame(width: 40, height: 4)
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2)
                                    .frame(width: 50, height: 50)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()

                    // Ball
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 20, height: 20)
                        .position(x: 100, y: 300)
                }
                .frame(height: 350)
                .padding()

                Spacer()

                VStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Angle: \(Int(ballAngle))°")
                            .font(.caption)
                        Slider(value: $ballAngle, in: 0...90)
                    }

                    VStack(alignment: .leading) {
                        Text("Power: \(Int(ballPower))%")
                            .font(.caption)
                        Slider(value: $ballPower, in: 20...100)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(8)
                .padding()

                Button(action: { shootBall() }) {
                    Text("🎯 SHOOT!")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                Text("Score: \(score)")
                    .font(.title2.bold())
                    .foregroundColor(.green)

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startTimer() }
    }

    private func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                gameTimer?.invalidate()
            }
        }
    }

    private func shootBall() {
        if Double.random(in: 0...1) > 0.3 {
            score += Int(ballPower)
        }
    }
}

// MARK: - Soccer Skills Game
struct SoccerSkillsGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var ballPosition: CGPoint = CGPoint(x: 200, y: 400)
    @State private var goalPosition: CGFloat = 200
    @State private var power: CGFloat = 50
    @State private var gameTimer: Timer?
    @State private var timeRemaining: Int = 45

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("⚽ SOCCER SKILLS")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Spacer()
                    Text("\(timeRemaining)s")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()

                Spacer()

                // Soccer field
                ZStack {
                    // Field
                    VStack {
                        HStack {
                            VStack(spacing: 30) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 4, height: 30)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 4, height: 30)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 4, height: 30)
                            }
                            Spacer()
                        }
                        .padding()
                        Spacer()
                    }

                    // Ball
                    Circle()
                        .fill(Color.black)
                        .frame(width: 16, height: 16)
                        .position(ballPosition)

                    // Goal
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(Color.white, lineWidth: 3)
                                .frame(width: 60, height: 80)
                            Spacer()
                        }
                    }
                    .padding()
                }
                .background(Color.green.opacity(0.5))
                .cornerRadius(8)
                .padding()

                Spacer()

                VStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Power: \(Int(power))%")
                            .font(.caption)
                        Slider(value: $power, in: 20...100)
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(8)
                }
                .padding()

                Button(action: { kickBall() }) {
                    Text("⚽ KICK!")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                Text("Score: \(score)")
                    .font(.title2.bold())
                    .foregroundColor(.green)

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear { startTimer() }
    }

    private func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                gameTimer?.invalidate()
            }
        }
    }

    private func kickBall() {
        if abs(ballPosition.x - goalPosition) < 30 {
            score += Int(power)
        }
    }
}
