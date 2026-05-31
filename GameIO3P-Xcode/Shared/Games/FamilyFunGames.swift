// FamilyFunGames.swift — Family-Friendly Games (Kids + Adults)
// Safe, Fun, Educational, Colorful, Engaging for All Ages

import SwiftUI

// MARK: - 1. ANIMAL QUIZ ADVENTURE - Educational Family Game
struct AnimalQuizAdventureView: View {
    @EnvironmentObject var gameState: GameState
    @State private var currentQuestion: Int = 0
    @State private var score: Int = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showFeedback: Bool = false
    @State private var feedbackMessage: String = ""
    @State private var gameCompleted: Bool = false
    @State private var playerName: String = "Player"
    @State private var difficulty: String = "Easy"

    let questions: [(question: String, emoji: String, answers: [String], correct: Int, fun_fact: String)] = [
        ("What do lions say?", "🦁", ["Meow", "Roar", "Growl"], 1, "Lions roar to communicate over long distances!"),
        ("What do penguins eat?", "🐧", ["Grass", "Fish", "Leaves"], 1, "Penguins dive deep into the ocean to catch fish!"),
        ("What sound does a cow make?", "🐄", ["Moo", "Neigh", "Oink"], 0, "Cows have best friends and get sad when separated!"),
        ("Where do kangaroos live?", "🦘", ["Africa", "America", "Australia"], 2, "Baby kangaroos are called joeys!"),
        ("What is a group of dolphins called?", "🐬", ["A school", "A pod", "A pod"], 1, "Dolphins are super smart and playful!"),
        ("Which animal is the fastest?", "🐆", ["Cheetah", "Lion", "Gazelle"], 0, "Cheetahs can run 70 mph - faster than cars!"),
        ("What do pandas eat?", "🐼", ["Bamboo", "Meat", "Fruit"], 0, "Giant pandas spend 12-16 hours eating bamboo!"),
        ("Which animal is the tallest?", "🦒", ["Elephant", "Giraffe", "Ostrich"], 1, "Giraffes can be taller than 18 feet!"),
        ("What color are flamingos naturally?", "🦩", ["Pink", "White", "Orange"], 2, "Flamingos get their pink color from their food!"),
        ("How many humps does a camel have?", "🐪", ["One", "Two", "Three"], 1, "Camels can drink 40 gallons of water at once!"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if !gameCompleted {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("🌍 ANIMAL ADVENTURE").font(.title2.bold()).foregroundColor(.blue)
                        Spacer()
                        Text("Score: \(score)").font(.headline).foregroundColor(.green)
                    }
                    .padding()

                    // Progress
                    HStack {
                        Text("Question \(currentQuestion + 1)/\(questions.count)").font(.caption).foregroundColor(.gray)
                        Spacer()
                        ProgressView(value: Double(currentQuestion) / Double(questions.count))
                            .frame(width: 100)
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Question with Emoji
                    VStack(spacing: 16) {
                        Text(questions[currentQuestion].emoji).font(.system(size: 80))
                        Text(questions[currentQuestion].question)
                            .font(.title2.bold())
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(16)
                    .padding()

                    Spacer()

                    // Answer Buttons
                    VStack(spacing: 12) {
                        ForEach(0..<questions[currentQuestion].answers.count, id: \.self) { index in
                            Button(action: { selectAnswer(index) }) {
                                Text(questions[currentQuestion].answers[index])
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .background(
                                        selectedAnswer == index ?
                                        Color.yellow :
                                        Color.blue.opacity(0.7)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .scaleEffect(selectedAnswer == index ? 1.05 : 1.0)
                            }
                        }
                    }
                    .padding()

                    // Feedback
                    if showFeedback {
                        VStack {
                            Text(feedbackMessage)
                                .font(.headline)
                                .foregroundColor(selectedAnswer == questions[currentQuestion].correct ? .green : .red)
                            Text(questions[currentQuestion].fun_fact)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .italic()
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .padding()

                        Button(action: { nextQuestion() }) {
                            Text("NEXT").font(.headline).frame(maxWidth: .infinity)
                                .padding(12).background(Color.blue).foregroundColor(.white).cornerRadius(8)
                        }
                        .padding()
                    }

                    Spacer()

                    Button(action: { gameState.transitionTo(.lobby) }) {
                        Text("EXIT GAME").font(.caption).frame(maxWidth: .infinity)
                            .padding(12).background(Color.red.opacity(0.6)).foregroundColor(.white).cornerRadius(8)
                    }
                    .padding()
                }
                .padding()
            } else {
                // Game Completed View
                VStack(spacing: 20) {
                    Text("🎉 GAME COMPLETE!").font(.title.bold()).foregroundColor(.blue)

                    VStack(spacing: 12) {
                        Text("Great job, \(playerName)!").font(.headline)
                        Text("Final Score: \(score)").font(.system(size: 32, weight: .bold)).foregroundColor(.green)
                        Text("You answered \(score/10) questions correctly!").font(.caption).foregroundColor(.gray)
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(16)

                    VStack(spacing: 12) {
                        Text("🏆 ACHIEVEMENTS").font(.headline)

                        if score >= 80 {
                            Label("Animal Expert!", systemImage: "star.fill")
                                .font(.caption).foregroundColor(.orange)
                        }

                        if score >= 60 {
                            Label("Animal Learner!", systemImage: "book.fill")
                                .font(.caption).foregroundColor(.blue)
                        }

                        if score >= 40 {
                            Label("Animal Curious!", systemImage: "eye.fill")
                                .font(.caption).foregroundColor(.green)
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(16)

                    Spacer()

                    Button(action: { resetGame() }) {
                        Text("PLAY AGAIN").font(.headline).frame(maxWidth: .infinity)
                            .padding(12).background(Color.blue).foregroundColor(.white).cornerRadius(8)
                    }

                    Button(action: { gameState.transitionTo(.lobby) }) {
                        Text("BACK TO LOBBY").font(.headline).frame(maxWidth: .infinity)
                            .padding(12).background(Color.green).foregroundColor(.white).cornerRadius(8)
                    }
                }
                .padding(24)
            }
        }
    }

    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        let isCorrect = index == questions[currentQuestion].correct
        feedbackMessage = isCorrect ? "✓ Correct! Well done!" : "✗ Not quite! Try again."
        if isCorrect {
            score += 10
        }
        showFeedback = true
    }

    private func nextQuestion() {
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
            selectedAnswer = nil
            showFeedback = false
        } else {
            gameCompleted = true
        }
    }

    private func resetGame() {
        currentQuestion = 0
        score = 0
        selectedAnswer = nil
        showFeedback = false
        gameCompleted = false
    }
}

// MARK: - 2. SHAPE COLLECTOR - Geometry Game for Kids
struct ShapeCollectorGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var shapes: [ShapeItem] = []
    @State private var timeRemaining: Int = 30
    @State private var gameTimer: Timer?
    @State private var gameActive: Bool = true
    @State private var targetShape: String = "🟢"
    @State private var shapeEmojis: [String: String] = [
        "circle": "🟢", "square": "🟨", "triangle": "🔺", "star": "⭐"
    ]

    struct ShapeItem {
        var id: UUID = UUID()
        var emoji: String
        var position: CGPoint
        var size: CGFloat
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Text("SHAPE COLLECTOR").font(.title2.bold()).foregroundColor(.purple)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(score)").font(.title.bold()).foregroundColor(.pink)
                        Text("\(timeRemaining)s").font(.caption).foregroundColor(.gray)
                    }
                }
                .padding()

                VStack(spacing: 12) {
                    Text("Tap all the \(targetShape)!").font(.headline)
                    HStack(spacing: 20) {
                        ForEach(shapeEmojis.values.sorted(), id: \.self) { shape in
                            Button(action: { changeTarget(shape) }) {
                                Text(shape).font(.system(size: 32))
                                    .frame(width: 50, height: 50)
                                    .background(shape == targetShape ? Color.yellow : Color.white.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()

                ZStack {
                    Color.white.opacity(0.2)

                    ForEach(shapes, id: \.id) { shape in
                        Text(shape.emoji)
                            .font(.system(size: 32))
                            .position(shape.position)
                            .onTapGesture {
                                collectShape(shape)
                            }
                    }
                }
                .frame(height: 400)
                .cornerRadius(8)
                .padding()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT").font(.headline).frame(maxWidth: .infinity)
                        .padding().background(Color.red.opacity(0.6)).foregroundColor(.white).cornerRadius(8)
                }
                .padding()
            }
            .padding()
        }
        .onAppear { startShapeGame() }
    }

    private func startShapeGame() {
        spawnShapes()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                gameActive = false
                gameTimer?.invalidate()
            }
        }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if gameActive {
                spawnShapes()
            }
        }
    }

    private func spawnShapes() {
        for _ in 0..<2 {
            let emoji = Array(shapeEmojis.values).randomElement() ?? "🟢"
            shapes.append(ShapeItem(
                emoji: emoji,
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...350)
                ),
                size: 32
            ))
        }
    }

    private func collectShape(_ shape: ShapeItem) {
        if shape.emoji == targetShape {
            score += 10
            shapes.removeAll { $0.id == shape.id }
        }
    }

    private func changeTarget(_ shape: String) {
        targetShape = shape
    }
}

// MARK: - 3. RAINBOW RUNNER - Colorful Endless Runner for Families
struct RainbowRunnerGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var position: CGFloat = 0
    @State private var score: Int = 0
    @State private var platforms: [Platform] = []
    @State private var gameTimer: Timer?
    @State private var gravity: CGFloat = 5
    @State private var velocity: CGFloat = 0

    struct Platform {
        var id: UUID = UUID()
        var yPosition: CGFloat
        var xPosition: CGFloat
        var width: CGFloat
        var color: Color
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(0.2),
                    Color.orange.opacity(0.2),
                    Color.yellow.opacity(0.2),
                    Color.green.opacity(0.2),
                    Color.blue.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Text("🌈 RAINBOW RUNNER").font(.title2.bold()).foregroundColor(.blue)
                    Spacer()
                    Text("\(score)").font(.title.bold()).foregroundColor(.orange)
                }
                .padding()

                ZStack {
                    Color.white.opacity(0.1)

                    // Platforms
                    ForEach(platforms, id: \.id) { platform in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(platform.color)
                            .frame(width: platform.width, height: 20)
                            .position(x: 200 + platform.xPosition, y: platform.yPosition)
                    }

                    // Player
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                        .position(x: 200 + position, y: 450)
                }
                .frame(height: 500)
                .cornerRadius(8)

                HStack(spacing: 20) {
                    Button(action: { moveLeft() }) {
                        Text("← LEFT").font(.headline).frame(maxWidth: .infinity)
                            .padding().background(Color.blue.opacity(0.7)).foregroundColor(.white).cornerRadius(8)
                    }
                    Button(action: { moveRight() }) {
                        Text("RIGHT →").font(.headline).frame(maxWidth: .infinity)
                            .padding().background(Color.blue.opacity(0.7)).foregroundColor(.white).cornerRadius(8)
                    }
                }
                .padding()

                Button(action: { gameState.transitionTo(.lobby) }) {
                    Text("EXIT").font(.headline).frame(maxWidth: .infinity)
                        .padding().background(Color.red.opacity(0.6)).foregroundColor(.white).cornerRadius(8)
                }
                .padding()
            }
            .padding()
        }
        .onAppear { startRainbowRunner() }
    }

    private func startRainbowRunner() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        for i in 0..<20 {
            platforms.append(Platform(
                yPosition: CGFloat(i * 60),
                xPosition: CGFloat.random(in: -50...50),
                width: 100,
                color: colors.randomElement()!
            ))
        }
    }

    private func moveLeft() {
        position = max(-60, position - 30)
    }

    private func moveRight() {
        position = min(60, position + 30)
    }
}
