// GameIO 2P — GameState.swift
// Central game state model, shared across all platforms
// Supports iPhone, iPad, Mac, Apple Watch, tvOS, CarPlay

import Foundation
import Combine

// MARK: - Game Phase Enum
/// All possible phases the game can be in
public enum GamePhase: String, CaseIterable, Codable {
    case carPlaySafety    = "carplay_safety"
    case splash           = "splash"
    case avatarCreator    = "avatar_creator"
    case roomCode         = "room_code"
    case carSelection     = "car_selection"
    case garageCinematic  = "garage_cinematic"
    case racing           = "racing"
    case walking          = "walking"
    case elevator         = "elevator"
    case lobby            = "lobby"
    case gamePortal       = "game_portal"
    case gameActive       = "game_active"
    case leaderboard      = "leaderboard"
    case settings         = "settings"
    case paused           = "paused"
    case gameOver         = "game_over"
    case victory          = "victory"
}

// MARK: - Platform Enum
public enum GamePlatform: String, CaseIterable, Codable {
    case iPhone   = "iphone"
    case iPad     = "ipad"
    case mac      = "mac"
    case appleTV  = "apple_tv"
    case watch    = "apple_watch"
    case carPlay  = "carplay"
    case web      = "web"
}

// MARK: - Game Mode
public enum GameMode: String, CaseIterable, Codable {
    case singlePlayer    = "single"
    case twoPlayer       = "two_player"
    case multiPlayer     = "multiplayer"
    case spectator       = "spectator"
    case practice        = "practice"
}

// MARK: - Car Brand
public enum CarBrand: String, CaseIterable, Codable {
    case lamborghini = "Lamborghini Huracán"
    case ferrari     = "Ferrari 488"
    case bugatti     = "Bugatti Chiron"
    case mclaren     = "McLaren 720S"
    case porsche     = "Porsche 911 GT3"
    case nissan      = "Nissan GT-R"
    case toyota      = "Toyota Supra"
    case ford        = "Ford Shelby GT500"
    case audi        = "Audi R8"
    case mercedes    = "Mercedes AMG GT"

    var topSpeedMPH: Int {
        switch self {
        case .bugatti:     return 304
        case .lamborghini: return 202
        case .ferrari:     return 205
        case .mclaren:     return 212
        case .porsche:     return 197
        case .nissan:      return 196
        case .toyota:      return 155
        case .ford:        return 180
        case .audi:        return 205
        case .mercedes:    return 193
        }
    }

    var horsepower: Int {
        switch self {
        case .bugatti:     return 1479
        case .lamborghini: return 630
        case .ferrari:     return 660
        case .mclaren:     return 710
        case .porsche:     return 502
        case .nissan:      return 565
        case .toyota:      return 335
        case .ford:        return 760
        case .audi:        return 562
        case .mercedes:    return 523
        }
    }

    var zeroToSixty: Double {
        switch self {
        case .bugatti:     return 2.4
        case .lamborghini: return 2.9
        case .ferrari:     return 3.0
        case .mclaren:     return 2.8
        case .porsche:     return 3.2
        case .nissan:      return 2.9
        case .toyota:      return 4.1
        case .ford:        return 3.5
        case .audi:        return 3.2
        case .mercedes:    return 3.5
        }
    }

    var carClass: String {
        switch self {
        case .bugatti:     return "Hypercar"
        case .lamborghini, .ferrari, .mclaren: return "Supercar"
        case .porsche, .nissan, .audi, .mercedes: return "Sports"
        case .toyota, .ford: return "Muscle"
        }
    }
}

// MARK: - Selected Game
public enum MiniGame: String, CaseIterable, Codable {
    case speedMatch     = "Speed Match"
    case driftKing      = "Drift King"
    case nitroRacer     = "Nitro Racer"
    case pitStop        = "Pit Stop Challenge"
    case trafficDodger  = "Traffic Dodger"
    case fuelRush       = "Fuel Rush"
    case turboQuiz      = "Turbo Quiz"
    case parkingMaster  = "Parking Master"
    case dragStrip      = "Drag Strip"
}

// MARK: - GameState (Observable)
/// The main game state object — published to all views via Combine
@MainActor
public final class GameState: ObservableObject {

    // MARK: Published Properties
    @Published public var phase: GamePhase = .carPlaySafety
    @Published public var platform: GamePlatform = .iPhone
    @Published public var mode: GameMode = .singlePlayer
    @Published public var selectedCar: CarBrand = .lamborghini
    @Published public var selectedGame: MiniGame?
    @Published public var isDriving: Bool = false
    @Published public var playerName: String = "Player"
    @Published public var roomCode: String = ""
    @Published public var score: Int = 0
    @Published public var highScore: Int = 0
    @Published public var lap: Int = 1
    @Published public var totalLaps: Int = 3
    @Published public var position: Int = 1
    @Published public var speed: Double = 0.0
    @Published public var fuelLevel: Double = 1.0
    @Published public var nitroLevel: Double = 0.0
    @Published public var isAudioEnabled: Bool = true
    @Published public var musicVolume: Float = 0.8
    @Published public var sfxVolume: Float = 1.0
    @Published public var showSafetyOverlay: Bool = false
    @Published public var connectedPlayers: [PlayerProfile] = []
    @Published public var leaderboard: [LeaderboardEntry] = []
    @Published public var achievements: [Achievement] = []
    @Published public var avatar: AvatarConfiguration = AvatarConfiguration()
    @Published public var settings: GameSettings = GameSettings()
    @Published public var raceTimer: Double = 0.0
    @Published public var bestLapTime: Double = .infinity
    @Published public var totalRaces: Int = 0
    @Published public var totalWins: Int = 0
    @Published public var currency: Int = 0
    @Published public var unlockedCars: Set<CarBrand> = [.lamborghini, .nissan, .toyota]
    @Published public var unlockedGames: Set<MiniGame> = Set(MiniGame.allCases)

    // MARK: Singleton
    public static let shared = GameState()

    private init() {
        loadFromStorage()
        generateRoomCode()
        detectPlatform()
    }

    // MARK: Phase Transitions
    public func transitionTo(_ newPhase: GamePhase) {
        let old = phase
        phase = newPhase
        NotificationCenter.default.post(
            name: .gamePhaseChanged,
            object: nil,
            userInfo: ["from": old, "to": newPhase]
        )
    }

    // MARK: Room Code Generation
    public func generateRoomCode() {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        roomCode = String((0..<6).map { _ in chars.randomElement()! })
    }

    // MARK: Score Management
    public func addScore(_ points: Int) {
        score += points
        if score > highScore {
            highScore = score
            saveToStorage()
        }
    }

    // MARK: Car Unlocking
    public func unlock(car: CarBrand, cost: Int) -> Bool {
        guard currency >= cost, !unlockedCars.contains(car) else { return false }
        currency -= cost
        unlockedCars.insert(car)
        saveToStorage()
        return true
    }

    // MARK: Platform Detection
    private func detectPlatform() {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            platform = .iPad
        } else {
            platform = .iPhone
        }
        #elseif os(macOS)
        platform = .mac
        #elseif os(tvOS)
        platform = .appleTV
        #elseif os(watchOS)
        platform = .watch
        #endif
    }

    // MARK: Persistence
    public func saveToStorage() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(StoredGameData(from: self)) {
            UserDefaults.standard.set(data, forKey: "gameio2p.state")
        }
    }

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: "gameio2p.state"),
              let stored = try? JSONDecoder().decode(StoredGameData.self, from: data)
        else { return }
        highScore = stored.highScore
        totalRaces = stored.totalRaces
        totalWins = stored.totalWins
        currency = stored.currency
        unlockedCars = stored.unlockedCars
        playerName = stored.playerName
    }
}

// MARK: - Notification Names
extension Notification.Name {
    public static let gamePhaseChanged = Notification.Name("GameIO2P.gamePhaseChanged")
    public static let playerJoined     = Notification.Name("GameIO2P.playerJoined")
    public static let playerLeft       = Notification.Name("GameIO2P.playerLeft")
    public static let raceStarted      = Notification.Name("GameIO2P.raceStarted")
    public static let raceFinished     = Notification.Name("GameIO2P.raceFinished")
    public static let achievementUnlocked = Notification.Name("GameIO2P.achievementUnlocked")
}

// MARK: - StoredGameData (Codable subset)
private struct StoredGameData: Codable {
    var highScore: Int
    var totalRaces: Int
    var totalWins: Int
    var currency: Int
    var unlockedCars: Set<CarBrand>
    var playerName: String

    init(from state: GameState) {
        highScore    = state.highScore
        totalRaces   = state.totalRaces
        totalWins    = state.totalWins
        currency     = state.currency
        unlockedCars = state.unlockedCars
        playerName   = state.playerName
    }
}
