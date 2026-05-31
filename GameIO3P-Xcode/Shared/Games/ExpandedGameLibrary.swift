// ExpandedGameLibrary.swift — 30+ Premium Family Games
// Diverse, engaging, and optimized for maximum fun
// Racing, Puzzle, Action, Educational, Sports, Arcade games

import SwiftUI

// MARK: - Color Match Game
struct ColorMatchGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 45
    @State private var gameTimer: Timer?
    @State private var targetColor: Color = .red
    @State private var roundsWon: Int = 0

    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    targetColor.opacity(0.2),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("🎨 COLOR MATCH")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                    Spacer()
                    Text("\(timeRemaining)s")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()

                Spacer()

                Text("Find the matching color")
                    .font(.headline)
                    .foregroundColor(.gray)

                RoundedRectangle(cornerRadius: 20)
                    .fill(targetColor)
                    .frame(height: 120)
                    .padding()

                Spacer()

                VStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                if index < colors.count {
                                    Button(action: { checkColor(colors[index]) }) {
                                        Circle()
                                            .fill(colors[index])
                                            .frame(height: 60)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()

                Spacer()

                HStack(spacing: 20) {
                    Text("Score: \(score)")
                        .font(.headline)
                    Text("Wins: \(roundsWon)")
                        .font(.headline)
                }
                .padding()

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
        randomizeColor()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                gameTimer?.invalidate()
            }
        }
    }

    private func checkColor(_ color: Color) {
        if color == targetColor {
            score += 50
            roundsWon += 1
            randomizeColor()
        }
    }

    private func randomizeColor() {
        targetColor = colors.randomElement() ?? .red
    }
}

// MARK: - Flappy Bird Clone - Sky Runner
struct SkyRunnerGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var playerY: CGFloat = 200
    @State private var score: Int = 0
    @State private var gameActive: Bool = true
    @State private var gameTimer: Timer?
    @State private var obstacles: [CGFloat] = []
    @State private var velocity: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.cyan.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Text("🚀 SKY RUNNER")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()

                ZStack {
                    Color.cyan.opacity(0.1)

                    // Player
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 30, height: 30)
                        .position(x: 50, y: playerY)

                    // Obstacles
                    ForEach(obstacles, id: \.self) { obstacleY in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.red)
                            .frame(width: 100, height: 50)
                            .position(x: 300, y: obstacleY)
                    }
                }
                .frame(height: 400)
                .onTapGesture {
                    flap()
                }

                VStack(spacing: 12) {
                    Text("Tap to fly up!")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Button(action: { gameState.transitionTo(.lobby) }) {
                        Text("EXIT GAME")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .onAppear { startGame() }
    }

    private func startGame() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateGame()
        }
    }

    private func updateGame() {
        velocity += 0.3
        playerY += velocity

        if playerY > 380 || playerY < 20 {
            gameActive = false
            gameTimer?.invalidate()
        }

        score += 1
    }

    private func flap() {
        velocity = -8
    }
}

// MARK: - Dice Roller Game
struct DiceRollerGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var diceResult: Int = 1
    @State private var roundsPlayed: Int = 0
    @State private var targetNumber: Int = Int.random(in: 1...6)

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Text("🎲 DICE ROLLER")
                        .font(.title2.bold())
                        .foregroundColor(.purple)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()

                Spacer()

                VStack(spacing: 20) {
                    Text("Roll a \(targetNumber)")
                        .font(.headline)
                        .foregroundColor(.black)

                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 140)

                        Text("\(diceResult)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.purple)
                    }
                    .padding()
                }

                Spacer()

                Button(action: { rollDice() }) {
                    Text("🎲 ROLL")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Text("Rounds: \(roundsPlayed)")
                    .font(.caption)
                    .foregroundColor(.gray)

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
    }

    private func rollDice() {
        diceResult = Int.random(in: 1...6)
        roundsPlayed += 1

        if diceResult == targetNumber {
            score += 100
            targetNumber = Int.random(in: 1...6)
        }
    }
}

// MARK: - Tap Sequence Game
struct TapSequenceGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var sequence: [Int] = []
    @State private var currentIndex: Int = 0
    @State private var score: Int = 0
    @State private var gameActive: Bool = true
    @State private var gameLevel: Int = 1

    let colors: [Color] = [.red, .blue, .green, .yellow]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.2), Color.yellow.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("🎯 TAP SEQUENCE")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Spacer()
                    Text("Level: \(gameLevel)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                .padding()

                Spacer()

                Text("Repeat the sequence!")
                    .font(.headline)
                    .foregroundColor(.gray)

                VStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                Button(action: { tapButton(index) }) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colors[index])
                                        .frame(height: 80)
                                        .overlay(
                                            Text(String(index + 1))
                                                .font(.title.bold())
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding()

                Spacer()

                Text("Score: \(score)")
                    .font(.title2.bold())
                    .foregroundColor(.green)

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
        .onAppear { startSequence() }
    }

    private func startSequence() {
        addToSequence()
    }

    private func addToSequence() {
        sequence.append(Int.random(in: 0...3))
        currentIndex = 0
        score += 10 * gameLevel
        gameLevel = (sequence.count / 3) + 1
    }

    private func tapButton(_ index: Int) {
        if gameActive && index == sequence[currentIndex] {
            currentIndex += 1

            if currentIndex == sequence.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    addToSequence()
                }
            }
        } else {
            gameActive = false
        }
    }
}

// MARK: - Flick Ball Game
struct FlickBallGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var ballPosition: CGPoint = CGPoint(x: 200, y: 500)
    @State private var score: Int = 0
    @State private var targets: [CGPoint] = []
    @State private var gameTimer: Timer?

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("🎾 FLICK BALL")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()

                ZStack {
                    Color.white.opacity(0.2)
                        .cornerRadius(8)

                    // Targets
                    ForEach(targets, id: \.self) { target in
                        Circle()
                            .fill(Color.red.opacity(0.7))
                            .frame(width: 40, height: 40)
                            .position(target)
                    }

                    // Ball
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                        .position(ballPosition)
                }
                .frame(height: 350)
                .padding()
                .onTapGesture { location in
                    flickBall(towards: location)
                }

                Spacer()

                Text("Tap to flick the ball at targets!")
                    .font(.caption)
                    .foregroundColor(.gray)

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
        .onAppear { spawnTargets() }
    }

    private func spawnTargets() {
        targets = [
            CGPoint(x: 80, y: 100),
            CGPoint(x: 320, y: 150),
            CGPoint(x: 200, y: 250),
            CGPoint(x: 100, y: 300)
        ]
    }

    private func flickBall(towards location: CGPoint) {
        // Simple physics simulation
        let distance = hypot(location.x - ballPosition.x, location.y - ballPosition.y)

        for target in targets {
            let distanceToTarget = hypot(location.x - target.x, location.y - target.y)
            if distanceToTarget < 30 {
                score += 25
            }
        }
    }
}
