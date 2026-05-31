// AIRacingController.swift — Intelligent AI racing opponent with learning and difficulty levels
// Rubber-banding, racing line optimization, dynamic difficulty adjustment

import Foundation
import CoreGraphics

// MARK: - AI Difficulty Levels
enum AIDifficulty: String, CaseIterable, Codable {
    case veryEasy = "Very Easy"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case veryHard = "Very Hard"
    case expert = "Expert"

    var skillLevel: CGFloat {
        switch self {
        case .veryEasy: return 0.2
        case .easy: return 0.4
        case .medium: return 0.6
        case .hard: return 0.75
        case .veryHard: return 0.9
        case .expert: return 0.99
        }
    }

    var reactionTime: Double {
        switch self {
        case .veryEasy: return 0.5
        case .easy: return 0.4
        case .medium: return 0.3
        case .hard: return 0.2
        case .veryHard: return 0.1
        case .expert: return 0.05
        }
    }
}

// MARK: - AI Race State
struct AIRaceState {
    var position: CGFloat = 0
    var speed: CGFloat = 0
    var rpm: Int = 800
    var fuel: CGFloat = 1.0
    var tires: CGFloat = 1.0
    var damage: CGFloat = 0
    var gear: Int = 1
    var driftAngle: CGFloat = 0
    var confidence: CGFloat = 1.0
}

// MARK: - Racing Line Data
struct RacingLineSegment {
    var position: CGFloat
    var optimalSpeed: CGFloat
    var brakingPoint: CGFloat
    var accelerationPoint: CGFloat
    var apexPoint: CGFloat
    var gripLevel: CGFloat
}

// MARK: - AI Racer Class
@MainActor
class AIRacer: ObservableObject {
    let id: String = UUID().uuidString
    var name: String = ""
    var difficulty: AIDifficulty = .medium
    var car: CarBrand = .ferrari
    var raceState: AIRaceState = AIRaceState()

    @Published var targetSpeed: CGFloat = 0
    @Published var throttle: CGFloat = 0
    @Published var brake: CGFloat = 0
    @Published var steering: CGFloat = 0
    @Published var racingLineAccuracy: CGFloat = 0

    private var racingLine: [RacingLineSegment] = []
    private var memoryBuffer: [(CGPoint, CGFloat)] = []
    private var lastDecisionTime: TimeInterval = 0
    private let decisionInterval: Double = 0.1

    func update(deltaTime: CGFloat, playerPosition: CGFloat, track: TrackData, otherAI: [AIRacer] = []) {
        let currentTime = Date().timeIntervalSince1970

        if currentTime - lastDecisionTime >= decisionInterval {
            makeDecision(playerPosition: playerPosition, track: track, otherAI: otherAI)
            lastDecisionTime = currentTime
        }

        updatePhysics(deltaTime: deltaTime, track: track)
    }

    private func makeDecision(playerPosition: CGFloat, track: TrackData, otherAI: [AIRacer]) {
        let positionGap = playerPosition - raceState.position
        let aheadByLap = positionGap > 100

        if aheadByLap {
            behaveWhenAhead(gap: positionGap)
        } else if abs(positionGap) < 50 {
            behaveWhenClose(gap: positionGap)
        } else {
            behaveWhenBehind(gap: abs(positionGap))
        }

        checkRacingLineAdherence(track: track)
        adjustForTrackConditions(track: track)
    }

    private func behaveWhenAhead(gap: CGFloat) {
        throttle = 0.7
        brake = 0.0

        if gap > 200 {
            throttle = 0.5
        }

        raceState.confidence = min(1.0, raceState.confidence + 0.01)
    }

    private func behaveWhenClose(gap: CGFloat) {
        if gap > 0 {
            throttle = 0.9
            brake = 0.1
        } else {
            throttle = 0.8
            brake = 0.0
        }

        raceState.confidence = max(0.5, raceState.confidence - 0.02)
    }

    private func behaveWhenBehind(gap: CGFloat) {
        throttle = 0.95
        brake = 0.0

        if gap > 150 {
            brake = 0.15
        }

        raceState.confidence = max(0.3, raceState.confidence - 0.05)
    }

    private func checkRacingLineAdherence(track: TrackData) {
        let targetLineAccuracy = difficulty.skillLevel
        let randomError = CGFloat.random(in: -0.1...0.1) * (1 - difficulty.skillLevel)
        steering = (targetLineAccuracy + randomError) * 0.3

        racingLineAccuracy = targetLineAccuracy
    }

    private func adjustForTrackConditions(track: TrackData) {
        let surfaceFriction = track.surface.frictionCoefficient
        let gripMultiplier = surfaceFriction / 1.0

        throttle *= gripMultiplier
        brake *= gripMultiplier

        if raceState.fuel < 0.3 {
            throttle *= 0.7
        }

        if raceState.tires < 0.4 {
            throttle *= 0.8
            brake *= 1.2
        }
    }

    private func updatePhysics(deltaTime: CGFloat, track: TrackData) {
        raceState.speed += (targetSpeed - raceState.speed) * 0.1

        let acceleration = (throttle - brake) * 10
        raceState.speed = max(0, raceState.speed + acceleration * deltaTime)

        raceState.position += raceState.speed * deltaTime / 1000

        raceState.fuel = max(0, raceState.fuel - 0.001 * throttle * deltaTime)
        raceState.tires = max(0, raceState.tires - 0.0005 * (throttle + abs(steering)) * deltaTime)

        if raceState.speed > 100 {
            raceState.driftAngle = steering * raceState.speed / 100
        }
    }

    func learnFromRace(finalPosition: Int, finalTime: Double) {
        let performanceBonus = CGFloat(finalPosition) / 4.0
        let timeBonus = 1.0 / CGFloat(finalTime)

        var updatedDifficulty = difficulty
        if performanceBonus < 0.5 || timeBonus < 0.5 {
            if difficulty != .veryEasy {
                updatedDifficulty = adjustDifficulty(by: -1)
            }
        } else if performanceBonus > 0.8 && timeBonus > 0.8 {
            if difficulty != .expert {
                updatedDifficulty = adjustDifficulty(by: 1)
            }
        }

        difficulty = updatedDifficulty
    }

    private func adjustDifficulty(by delta: Int) -> AIDifficulty {
        let allDifficulties = AIDifficulty.allCases
        let currentIndex = allDifficulties.firstIndex(of: difficulty) ?? 2
        let newIndex = max(0, min(allDifficulties.count - 1, currentIndex + delta))
        return allDifficulties[newIndex]
    }

    func performOvertake() -> Bool {
        guard difficulty.skillLevel > 0.6 else { return false }

        let overtakeRoll = CGFloat.random(in: 0...1)
        return overtakeRoll < (difficulty.skillLevel - 0.5)
    }

    func recoverFromCrash() -> Bool {
        let recoveryChance = difficulty.skillLevel * 0.8
        return CGFloat.random(in: 0...1) < recoveryChance
    }
}

// MARK: - Track Data Structure
struct TrackData: Codable {
    var trackId: String
    var trackName: String
    var length: CGFloat
    var turns: Int
    var lapRecord: Double
    var surface: TrackSurface
    var weather: WeatherCondition
    var difficulty: String
    var drivingLine: [CGPoint]

    var estimatedLapTime: Double {
        Double(length / 100) * 60
    }
}

// MARK: - Weather Condition
enum WeatherCondition: String, Codable {
    case sunny
    case cloudy
    case rainy
    case stormy
    case foggy
    case snowy

    var gripModifier: CGFloat {
        switch self {
        case .sunny: return 1.0
        case .cloudy: return 0.95
        case .rainy: return 0.7
        case .stormy: return 0.6
        case .foggy: return 0.85
        case .snowy: return 0.4
        }
    }

    var visibilityModifier: CGFloat {
        switch self {
        case .sunny: return 1.0
        case .cloudy: return 0.95
        case .rainy: return 0.85
        case .stormy: return 0.7
        case .foggy: return 0.6
        case .snowy: return 0.75
        }
    }
}

// MARK: - Rubber Banding Manager
@MainActor
class RubberBandingManager: ObservableObject {
    @Published var rubberBandStrength: CGFloat = 0.5
    var difficulty: AIDifficulty = .medium

    private let minSpeedMultiplier: CGFloat = 0.8
    private let maxSpeedMultiplier: CGFloat = 1.3

    func adjustAISpeed(currentPosition: CGFloat, playerPosition: CGFloat) -> CGFloat {
        let positionDifference = playerPosition - currentPosition
        let maxLapLength: CGFloat = 1.0

        let normalizedDifference = positionDifference / maxLapLength
        let rubberbandFactor = rubberBandStrength * (difficulty.skillLevel + 0.2)

        if normalizedDifference > 0.1 {
            return 1.0 + (normalizedDifference * rubberbandFactor * 0.5)
        } else if normalizedDifference < -0.1 {
            return 1.0 - (abs(normalizedDifference) * rubberbandFactor * 0.3)
        } else {
            return 1.0
        }
    }

    func setRubberBandStrength(_ strength: CGFloat) {
        rubberBandStrength = min(max(strength, 0), 1.0)
    }
}

// MARK: - Multi-AI Manager
@MainActor
class MultiAIRaceManager: ObservableObject {
    @Published var aiRacers: [AIRacer] = []
    var rubberBanding: RubberBandingManager = RubberBandingManager()

    func setupAI(count: Int, difficulties: [AIDifficulty]) {
        aiRacers = (0..<count).map { i in
            let ai = AIRacer()
            ai.name = "AI Driver \(i + 1)"
            ai.difficulty = difficulties[safe: i] ?? .medium
            ai.car = [.ferrari, .lamborghini, .porsche, .nissan][i % 4]
            return ai
        }
    }

    func updateAll(deltaTime: CGFloat, playerPosition: CGFloat, track: TrackData) {
        for (index, ai) in aiRacers.enumerated() {
            let otherAI = aiRacers.enumerated().filter { $0.offset != index }.map { $0.element }
            ai.update(deltaTime: deltaTime, playerPosition: playerPosition, track: track, otherAI: otherAI)

            let speedMultiplier = rubberBanding.adjustAISpeed(currentPosition: ai.raceState.position, playerPosition: playerPosition)
            ai.targetSpeed = ai.targetSpeed * speedMultiplier
        }
    }

    func getLeaderboard() -> [(String, CGFloat, Double)] {
        aiRacers.map { ($0.name, $0.raceState.position, Double($0.raceState.speed)) }
            .sorted { $0.1 > $1.1 }
    }
}

// MARK: - Helper Extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
