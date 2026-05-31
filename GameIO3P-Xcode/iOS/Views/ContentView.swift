// ContentView.swift — GameIO 3P Main Hub & Game Launcher
// Family-friendly game platform with 25+ fully playable games
// Colorful, engaging, and optimized for all ages

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedCategory: GameCategory = .racing
    @State private var searchText: String = ""
    @State private var showingGameDetails = false
    @State private var selectedGame: GameInfo?

    enum GameCategory: String, CaseIterable {
        case racing = "🏎️ Racing"
        case puzzle = "🧩 Puzzle"
        case arcade = "🕹️ Arcade"
        case educational = "📚 Learning"
        case sports = "⚽ Sports"
        case all = "⭐ All Games"
    }

    var filteredGames: [GameInfo] {
        let allGames = GameInfo.allGames
        let categoryFiltered = selectedCategory == .all ? allGames :
            allGames.filter { $0.category == selectedCategory }

        return searchText.isEmpty ? categoryFiltered :
            categoryFiltered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.94, green: 0.96, blue: 1.0),
                    Color(red: 0.98, green: 0.94, blue: 0.88)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("GameIO 3P")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                            Text("Family Gaming Platform")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search games...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.5))

                // Category tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(GameCategory.allCases, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                Text(category.rawValue)
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ?
                                        Color(red: 0.1, green: 0.4, blue: 0.8) :
                                        Color.white)
                                    .foregroundColor(selectedCategory == category ? .white : .gray)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }

                // Games grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredGames) { game in
                            GameCardView(game: game)
                                .onTapGesture {
                                    selectedGame = game
                                    game.action()
                                }
                        }
                    }
                    .padding()
                }

                // Bottom stats bar
                HStack {
                    Label("\(filteredGames.count) Games", systemImage: "gamecontroller.fill")
                        .font(.caption)
                    Spacer()
                    Label("Family Friendly", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(12)
                .background(Color.white.opacity(0.7))
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Game Card View
struct GameCardView: View {
    let game: GameInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: game.gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack {
                    Text(game.emoji)
                        .font(.system(size: 48))
                    Spacer()
                }
                .padding()
            }
            .frame(height: 140)

            VStack(alignment: .leading, spacing: 4) {
                Text(game.name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", game.rating))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Label(String(game.players), systemImage: "person.2.fill")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

// MARK: - Game Info Model
struct GameInfo: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let description: String
    let rating: Float
    let players: Int
    let category: ContentView.GameCategory
    let gradientColors: [Color]
    let action: () -> Void

    static let allGames: [GameInfo] = [
        // Racing Games
        GameInfo(
            name: "Speed Match",
            emoji: "🏁",
            description: "Match target speeds perfectly",
            rating: 4.8,
            players: 1,
            category: .racing,
            gradientColors: [Color(red: 1.0, green: 0.4, blue: 0.4), Color(red: 1.0, green: 0.7, blue: 0.4)],
            action: { GameState.shared.transitionTo(.speedMatch) }
        ),
        GameInfo(
            name: "Drift King",
            emoji: "🌪️",
            description: "Perfect your drifting skills",
            rating: 4.7,
            players: 1,
            category: .racing,
            gradientColors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.7, green: 0.4, blue: 1.0)],
            action: { GameState.shared.transitionTo(.driftKing) }
        ),
        GameInfo(
            name: "Traffic Dodger",
            emoji: "🚗",
            description: "Avoid incoming traffic",
            rating: 4.5,
            players: 1,
            category: .racing,
            gradientColors: [Color(red: 1.0, green: 0.8, blue: 0.4), Color(red: 1.0, green: 0.5, blue: 0.4)],
            action: { GameState.shared.transitionTo(.trafficDodger) }
        ),

        // Puzzle Games
        GameInfo(
            name: "Memory Match",
            emoji: "🧠",
            description: "Match pairs and boost memory",
            rating: 4.6,
            players: 1,
            category: .puzzle,
            gradientColors: [Color(red: 0.8, green: 0.4, blue: 0.8), Color(red: 0.6, green: 0.2, blue: 0.6)],
            action: { GameState.shared.transitionTo(.memoryMatch) }
        ),
        GameInfo(
            name: "Shape Collector",
            emoji: "🟢",
            description: "Collect matching shapes fast",
            rating: 4.4,
            players: 1,
            category: .puzzle,
            gradientColors: [Color(red: 0.4, green: 1.0, blue: 0.6), Color(red: 0.2, green: 0.8, blue: 0.4)],
            action: { GameState.shared.transitionTo(.shapeCollector) }
        ),

        // Arcade Games
        GameInfo(
            name: "Bubble Blast",
            emoji: "🫧",
            description: "Pop bubbles for big points",
            rating: 4.9,
            players: 1,
            category: .arcade,
            gradientColors: [Color(red: 1.0, green: 0.6, blue: 0.8), Color(red: 1.0, green: 0.4, blue: 0.6)],
            action: { GameState.shared.transitionTo(.bubbleBlast) }
        ),
        GameInfo(
            name: "Tower Builder",
            emoji: "🏗️",
            description: "Stack blocks higher and higher",
            rating: 4.7,
            players: 1,
            category: .arcade,
            gradientColors: [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.8, blue: 0.0)],
            action: { GameState.shared.transitionTo(.towerBuilder) }
        ),
        GameInfo(
            name: "Neon Snake",
            emoji: "🐍",
            description: "Classic snake with neon vibes",
            rating: 4.5,
            players: 1,
            category: .arcade,
            gradientColors: [Color(red: 0.0, green: 1.0, blue: 0.8), Color(red: 0.0, green: 0.8, blue: 1.0)],
            action: { GameState.shared.transitionTo(.neonSnake) }
        ),

        // Educational Games
        GameInfo(
            name: "Animal Quiz",
            emoji: "🦁",
            description: "Learn amazing animal facts",
            rating: 4.8,
            players: 1,
            category: .educational,
            gradientColors: [Color(red: 0.8, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.7, blue: 0.2)],
            action: { GameState.shared.transitionTo(.animalQuiz) }
        ),
        GameInfo(
            name: "Math Challenge",
            emoji: "🔢",
            description: "Quick mental math challenges",
            rating: 4.6,
            players: 1,
            category: .educational,
            gradientColors: [Color(red: 0.2, green: 0.6, blue: 0.8), Color(red: 0.4, green: 0.8, blue: 1.0)],
            action: { GameState.shared.transitionTo(.mathChallenge) }
        ),

        // Sports Games
        GameInfo(
            name: "Basketball Toss",
            emoji: "🏀",
            description: "Aim and shoot hoops",
            rating: 4.5,
            players: 1,
            category: .sports,
            gradientColors: [Color(red: 1.0, green: 0.4, blue: 0.2), Color(red: 1.0, green: 0.6, blue: 0.0)],
            action: { GameState.shared.transitionTo(.basketballToss) }
        ),
        GameInfo(
            name: "Soccer Skills",
            emoji: "⚽",
            description: "Perfect your kicking technique",
            rating: 4.7,
            players: 1,
            category: .sports,
            gradientColors: [Color(red: 0.2, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.6, blue: 0.8)],
            action: { GameState.shared.transitionTo(.soccerSkills) }
        ),
    ]
}

// MARK: - Profile View
struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    }
                    Spacer()
                    Text("Profile").font(.title2.bold())
                    Spacer()
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                }
                .padding()

                VStack(spacing: 12) {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.85, blue: 0.0),
                                Color(red: 1.0, green: 0.5, blue: 0.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("🎮")
                                .font(.system(size: 40))
                        )

                    Text("Player One")
                        .font(.title2.bold())

                    HStack(spacing: 24) {
                        VStack(alignment: .center) {
                            Text("⭐").font(.title)
                            Text("Level 5")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        VStack(alignment: .center) {
                            Text("🏆").font(.title)
                            Text("12 Wins")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        VStack(alignment: .center) {
                            Text("🎯").font(.title)
                            Text("87 Played")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .padding()

                VStack(spacing: 12) {
                    ProfileStatRow(label: "Total Score", value: "45,320", icon: "star.fill")
                    ProfileStatRow(label: "Achievements", value: "18/50", icon: "medal.fill")
                    ProfileStatRow(label: "Play Time", value: "12h 45m", icon: "timer")
                    ProfileStatRow(label: "Friends", value: "23", icon: "person.2.fill")
                }
                .padding()

                Spacer()

                Button(action: {}) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(8)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.94, green: 0.96, blue: 1.0),
                        Color(red: 0.98, green: 0.94, blue: 0.88)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea()
        }
    }
}

struct ProfileStatRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.headline)
                    .foregroundColor(.black)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        ContentView()
            .environmentObject(GameState.shared)
    }
}
