// GameIO 2P — PlayerProfile.swift
// Player profile model for all platforms

import Foundation
import SwiftUI

// MARK: - AvatarConfiguration
public struct AvatarConfiguration: Codable, Equatable {
    public var faceShape: FaceShape = .circle
    public var skinTone: SkinTone = .medium
    public var hairStyle: HairStyle = .short
    public var eyeStyle: EyeStyle = .round
    public var mouthStyle: MouthStyle = .smile
    public var hasGlasses: Bool = false
    public var glassesStyle: GlassesStyle = .wayfarer
    public var hasHat: Bool = false
    public var hatStyle: HatStyle = .baseball
    public var hasEarrings: Bool = false

    public init() {}
}

// MARK: - Face Enums
public enum FaceShape: String, CaseIterable, Codable {
    case circle = "circle"
    case oval   = "oval"
    case square = "square"
    case heart  = "heart"

    public var displayName: String { rawValue.capitalized }
}

public enum SkinTone: String, CaseIterable, Codable {
    case veryLight  = "#FFDBB4"
    case light      = "#D4A77A"
    case medium     = "#C68642"
    case tan        = "#8D5524"
    case dark       = "#4A2912"
    case veryDark   = "#1A0A00"

    public var color: Color {
        Color(hex: rawValue) ?? .brown
    }

    public var displayName: String {
        switch self {
        case .veryLight: return "Very Light"
        case .light:     return "Light"
        case .medium:    return "Medium"
        case .tan:       return "Tan"
        case .dark:      return "Dark"
        case .veryDark:  return "Very Dark"
        }
    }
}

public enum HairStyle: String, CaseIterable, Codable {
    case short     = "short"
    case long      = "long"
    case curly     = "curly"
    case bun       = "bun"
    case mohawk    = "mohawk"
    case bald      = "bald"
    case ponytail  = "ponytail"
    case afro      = "afro"

    public var displayName: String { rawValue.capitalized }
}

public enum EyeStyle: String, CaseIterable, Codable {
    case round    = "round"
    case narrow   = "narrow"
    case wide     = "wide"
    case cat      = "cat"
    case star     = "star"

    public var displayName: String { rawValue.capitalized }
}

public enum MouthStyle: String, CaseIterable, Codable {
    case smile    = "smile"
    case grin     = "grin"
    case serious  = "serious"
    case laugh    = "laugh"

    public var displayName: String { rawValue.capitalized }
}

public enum GlassesStyle: String, CaseIterable, Codable {
    case wayfarer   = "wayfarer"
    case aviator    = "aviator"
    case round      = "round"

    public var displayName: String { rawValue.capitalized }
}

public enum HatStyle: String, CaseIterable, Codable {
    case baseball   = "baseball"
    case beanie     = "beanie"
    case crown      = "crown"

    public var displayName: String { rawValue.capitalized }
}

// MARK: - PlayerProfile
public struct PlayerProfile: Identifiable, Codable, Equatable {
    public var id: UUID = UUID()
    public var name: String
    public var avatar: AvatarConfiguration
    public var selectedCar: CarBrand
    public var score: Int
    public var wins: Int
    public var losses: Int
    public var totalRaces: Int
    public var bestLapTime: Double
    public var rank: PlayerRank
    public var joinedAt: Date
    public var isHost: Bool
    public var isReady: Bool
    public var connectionQuality: ConnectionQuality
    public var platform: GamePlatform

    public init(
        name: String = "Player",
        avatar: AvatarConfiguration = AvatarConfiguration(),
        selectedCar: CarBrand = .lamborghini
    ) {
        self.name = name
        self.avatar = avatar
        self.selectedCar = selectedCar
        self.score = 0
        self.wins = 0
        self.losses = 0
        self.totalRaces = 0
        self.bestLapTime = .infinity
        self.rank = .rookie
        self.joinedAt = Date()
        self.isHost = false
        self.isReady = false
        self.connectionQuality = .excellent
        self.platform = .iPhone
    }

    public var winRate: Double {
        guard totalRaces > 0 else { return 0.0 }
        return Double(wins) / Double(totalRaces)
    }

    public var displayScore: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }
}

// MARK: - Player Rank
public enum PlayerRank: String, CaseIterable, Codable {
    case rookie      = "Rookie"
    case amateur     = "Amateur"
    case semipro     = "Semi-Pro"
    case professional = "Professional"
    case expert      = "Expert"
    case master      = "Master"
    case grandmaster = "Grand Master"
    case legend      = "Legend"

    public var requiredWins: Int {
        switch self {
        case .rookie:        return 0
        case .amateur:       return 5
        case .semipro:       return 15
        case .professional:  return 30
        case .expert:        return 60
        case .master:        return 100
        case .grandmaster:   return 200
        case .legend:        return 500
        }
    }

    public var colorHex: String {
        switch self {
        case .rookie:        return "#888888"
        case .amateur:       return "#4CAF50"
        case .semipro:       return "#2196F3"
        case .professional:  return "#9C27B0"
        case .expert:        return "#FF9800"
        case .master:        return "#F44336"
        case .grandmaster:   return "#FF5722"
        case .legend:        return "#FFD700"
        }
    }
}

// MARK: - Connection Quality
public enum ConnectionQuality: String, CaseIterable, Codable {
    case excellent  = "Excellent"
    case good       = "Good"
    case fair       = "Fair"
    case poor       = "Poor"
    case offline    = "Offline"

    public var pingMs: Int {
        switch self {
        case .excellent: return 15
        case .good:      return 50
        case .fair:      return 100
        case .poor:      return 250
        case .offline:   return -1
        }
    }

    public var iconName: String {
        switch self {
        case .excellent: return "wifi"
        case .good:      return "wifi"
        case .fair:      return "wifi.exclamationmark"
        case .poor:      return "wifi.slash"
        case .offline:   return "wifi.slash"
        }
    }
}

// MARK: - LeaderboardEntry
public struct LeaderboardEntry: Identifiable, Codable {
    public var id: UUID = UUID()
    public var playerName: String
    public var avatar: AvatarConfiguration
    public var score: Int
    public var bestTime: Double
    public var wins: Int
    public var car: CarBrand
    public var rank: Int
    public var date: Date

    public init(
        playerName: String,
        avatar: AvatarConfiguration,
        score: Int,
        bestTime: Double,
        wins: Int,
        car: CarBrand,
        rank: Int
    ) {
        self.playerName = playerName
        self.avatar = avatar
        self.score = score
        self.bestTime = bestTime
        self.wins = wins
        self.car = car
        self.rank = rank
        self.date = Date()
    }

    public var formattedBestTime: String {
        guard bestTime != .infinity else { return "--:--.--" }
        let minutes = Int(bestTime / 60)
        let seconds = Int(bestTime.truncatingRemainder(dividingBy: 60))
        let ms = Int((bestTime * 100).truncatingRemainder(dividingBy: 100))
        return String(format: "%d:%02d.%02d", minutes, seconds, ms)
    }
}

// MARK: - Achievement
public struct Achievement: Identifiable, Codable {
    public var id: UUID = UUID()
    public var name: String
    public var description: String
    public var iconName: String
    public var isUnlocked: Bool
    public var unlockedDate: Date?
    public var rarity: AchievementRarity

    public init(
        name: String,
        description: String,
        iconName: String,
        rarity: AchievementRarity = .common
    ) {
        self.name = name
        self.description = description
        self.iconName = iconName
        self.isUnlocked = false
        self.rarity = rarity
    }
}

// MARK: - Achievement Rarity
public enum AchievementRarity: String, CaseIterable, Codable {
    case common    = "Common"
    case rare      = "Rare"
    case epic      = "Epic"
    case legendary = "Legendary"

    public var colorHex: String {
        switch self {
        case .common:    return "#888888"
        case .rare:      return "#4169E1"
        case .epic:      return "#9400D3"
        case .legendary: return "#FFD700"
        }
    }
}

// MARK: - GameSettings
public struct GameSettings: Codable {
    public var graphicsQuality: GraphicsQuality = .high
    public var audioEnabled: Bool = true
    public var musicVolume: Float = 0.8
    public var sfxVolume: Float = 1.0
    public var hapticFeedback: Bool = true
    public var showFPS: Bool = false
    public var language: String = "en"
    public var controlScheme: ControlScheme = .tilt
    public var showMinimap: Bool = true
    public var showSpeedometer: Bool = true
    public var autoAccelerate: Bool = false
    public var cameraMode: CameraMode = .chase

    public init() {}
}

// MARK: - Graphics Quality
public enum GraphicsQuality: String, CaseIterable, Codable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"
    case ultra  = "Ultra"

    public var particleCount: Int {
        switch self {
        case .low:    return 50
        case .medium: return 150
        case .high:   return 300
        case .ultra:  return 500
        }
    }

    public var shadowEnabled: Bool {
        switch self {
        case .low: return false
        default:   return true
        }
    }
}

// MARK: - Control Scheme
public enum ControlScheme: String, CaseIterable, Codable {
    case tilt    = "Tilt"
    case swipe   = "Swipe"
    case buttons = "Buttons"
    case gamepad = "Gamepad"
}

// MARK: - Camera Mode
public enum CameraMode: String, CaseIterable, Codable {
    case chase      = "Chase"
    case cockpit    = "Cockpit"
    case overhead   = "Overhead"
    case cinematic  = "Cinematic"
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
