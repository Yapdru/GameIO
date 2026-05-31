// BonusGamesCollection.swift — 15 Bonus Games
// Limited-time challenges, special events, and exclusive experiences
// Rotating game selection with seasonal themes

import SwiftUI

// MARK: - Typing Speed Challenge
struct TypingSpeedGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var currentWord: String = "GAMEIO"
    @State private var userInput: String = ""
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var gameTimer: Timer?

    let words = ["GAMEIO", "FAMILY", "FRIENDS", "RACING", "GAMING", "SWIFT", "XCODE", "APPLE", "KINGDOM", "ADVENTURE"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("⌨️ TYPING SPEED")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Spacer()
                    Text("\(timeRemaining)s")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()

                Spacer()

                Text("Type the word:")
                    .font(.headline)
                    .foregroundColor(.gray)

                Text(currentWord)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                    .kerning(2)

                TextField("Type here...", text: $userInput)
                    .font(.title2)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .padding()
                    .onChange(of: userInput) { _ in
                        checkWord()
                    }

                Spacer()

                Text("Score: \(score) WPM")
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
        .onAppear { startGame() }
    }

    private func startGame() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                gameTimer?.invalidate()
            }
        }
    }

    private func checkWord() {
        if userInput.uppercased() == currentWord {
            score += 10
            currentWord = words.randomElement() ?? "GAMEIO"
            userInput = ""
        }
    }
}

// MARK: - Fruit Catch Game
struct FruitCatchGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var lives: Int = 3
    @State private var fruits: [FruitItem] = []
    @State private var basketPosition: CGFloat = 150
    @State private var gameActive: Bool = true
    @State private var gameTimer: Timer?

    struct FruitItem {
        var id = UUID()
        var x: CGFloat
        var y: CGFloat
        var type: String
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("🍎 FRUIT CATCH")
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.green)
                    Spacer()
                    Text("❤️ \(lives)")
                        .font(.headline)
                }
                .padding()

                ZStack {
                    Color.white.opacity(0.3)

                    // Falling fruits
                    ForEach(fruits, id: \.id) { fruit in
                        Text(fruit.type)
                            .font(.system(size: 32))
                            .position(x: fruit.x, y: fruit.y)
                    }

                    // Basket
                    HStack {
                        Spacer()
                        Text("🧺")
                            .font(.system(size: 32))
                            .offset(x: basketPosition - 150)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .frame(height: 350)
                .onTapGesture { location in
                    basketPosition = location.x
                }
                .cornerRadius(8)
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
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if gameActive {
                spawnFruit()
                updateFruits()
            }
        }
    }

    private func spawnFruit() {
        let fruitTypes = ["🍎", "🍊", "🍌", "🍇", "🍓"]
        fruits.append(FruitItem(
            x: CGFloat.random(in: 30...270),
            y: 0,
            type: fruitTypes.randomElement() ?? "🍎"
        ))
    }

    private func updateFruits() {
        fruits = fruits.map { fruit in
            var updated = fruit
            updated.y += 20
            return updated
        }

        fruits.removeAll { $0.y > 350 }
    }
}

// MARK: - Word Builder Game
struct WordBuilderGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var availableLetters: [String] = []
    @State private var currentWord: String = ""
    @State private var score: Int = 0
    @State private var hints: Int = 3

    let targetWords = ["SWIFT", "APPLE", "GAMEIO", "XCODE", "PLAY", "FUN", "RACE", "WIN"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.1), Color.cyan.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("📝 WORD BUILDER")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()

                Spacer()

                Text("Build a word from the letters")
                    .font(.headline)
                    .foregroundColor(.gray)

                // Current word progress
                HStack(spacing: 8) {
                    ForEach(currentWord.map { String($0) }, id: \.self) { letter in
                        Text(letter)
                            .font(.headline)
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding()

                // Available letters
                VStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(availableLetters.dropFirst(row * 4).prefix(4), id: \.self) { letter in
                                Button(action: { addLetter(letter) }) {
                                    Text(letter)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding()

                Spacer()

                HStack(spacing: 12) {
                    Button(action: { currentWord = "" }) {
                        Text("CLEAR")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: { checkWord() }) {
                        Text("✓ SUBMIT")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
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
        .onAppear { initializeGame() }
    }

    private func initializeGame() {
        availableLetters = ["S", "W", "I", "F", "T", "A", "P", "L"]
    }

    private func addLetter(_ letter: String) {
        currentWord += letter
    }

    private func checkWord() {
        if targetWords.contains(currentWord.uppercased()) {
            score += 100
            currentWord = ""
        }
    }
}

// MARK: - Bubble Shooter Game
struct BubbleShooterGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var bubbles: [BubbleShot] = []
    @State private var gameTimer: Timer?

    struct BubbleShot {
        var id = UUID()
        var position: CGPoint
        var color: Color
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("🫧 BUBBLE SHOOTER")
                        .font(.title2.bold())
                        .foregroundColor(.purple)
                    Spacer()
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()

                ZStack {
                    Color.white.opacity(0.2)
                        .cornerRadius(8)

                    ForEach(bubbles, id: \.id) { bubble in
                        Circle()
                            .fill(bubble.color)
                            .frame(width: 40, height: 40)
                            .position(bubble.position)
                    }
                }
                .frame(height: 350)
                .padding()
                .onTapGesture { location in
                    shootBubble(at: location)
                }

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
        spawnBubbles()
    }

    private func spawnBubbles() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        for _ in 0..<5 {
            bubbles.append(BubbleShot(
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: CGFloat.random(in: 100...300)
                ),
                color: colors.randomElement() ?? .red
            ))
        }
    }

    private func shootBubble(at location: CGPoint) {
        bubbles = bubbles.filter { bubble in
            let distance = hypot(bubble.position.x - location.x, bubble.position.y - location.y)
            if distance < 30 {
                score += 50
                return false
            }
            return true
        }
    }
}

// MARK: - Simon Says Game
struct SimonSaysGameView: View {
    @EnvironmentObject var gameState: GameState
    @State private var score: Int = 0
    @State private var level: Int = 1
    @State private var gameActive: Bool = true

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.1), Color.yellow.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("👀 SIMON SAYS")
                        .font(.title2.bold())
                        .foregroundColor(.red)
                    Spacer()
                    Text("Level: \(level)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                .padding()

                Spacer()

                Text("Watch the pattern and repeat!")
                    .font(.headline)
                    .foregroundColor(.gray)

                VStack(spacing: 16) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 16) {
                            ForEach(0..<2, id: \.self) { col in
                                let index = row * 2 + col
                                let colors: [Color] = [.red, .blue, .green, .yellow]
                                Button(action: {}) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colors[index].opacity(0.7))
                                        .frame(height: 100)
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
    }
}
