// AnalyticsEngine.swift — Comprehensive game analytics with event tracking, performance monitoring
// Player behavior analysis, engagement metrics, funnel tracking, crash reporting

import Foundation
import Combine

// MARK: - Event Types
enum AnalyticsEventType: String, Codable {
    case gameStarted
    case gameFinished
    case achievementUnlocked
    case purchaseCompleted
    case levelCompleted
    case characterCreated
    case multiplayerJoined
    case raceStarted
    case raceCompleted
    case miniGameStarted
    case miniGameCompleted
    case settingsChanged
    case socialActionTriggered
    case errorEncountered
    case featureExplored
}

// MARK: - Analytics Event
struct AnalyticsEvent: Codable {
    let eventId: String
    let eventType: AnalyticsEventType
    let timestamp: TimeInterval
    let sessionId: String
    let userId: String
    let properties: [String: AnyCodable]
    let duration: Double?
    let error: String?

    init(
        eventType: AnalyticsEventType,
        sessionId: String,
        userId: String,
        properties: [String: AnyCodable] = [:],
        duration: Double? = nil,
        error: String? = nil
    ) {
        self.eventId = UUID().uuidString
        self.eventType = eventType
        self.timestamp = Date().timeIntervalSince1970
        self.sessionId = sessionId
        self.userId = userId
        self.properties = properties
        self.duration = duration
        self.error = error
    }
}

// MARK: - Any Codable Helper
enum AnyCodable: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnyCodable])
    case dictionary([String: AnyCodable])

    init(_ value: Any) {
        if let string = value as? String {
            self = .string(string)
        } else if let int = value as? Int {
            self = .int(int)
        } else if let double = value as? Double {
            self = .double(double)
        } else if let bool = value as? Bool {
            self = .bool(bool)
        } else if let array = value as? [Any] {
            self = .array(array.map { AnyCodable($0) })
        } else if let dict = value as? [String: Any] {
            self = .dictionary(dict.mapValues { AnyCodable($0) })
        } else {
            self = .string(String(describing: value))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([AnyCodable].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: AnyCodable].self) {
            self = .dictionary(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }
}

// MARK: - Session Metrics
struct SessionMetrics: Codable {
    var sessionId: String
    var userId: String
    var startTime: TimeInterval
    var endTime: TimeInterval?
    var gameStarted: Int = 0
    var gameCompleted: Int = 0
    var totalPlayTime: Double = 0
    var totalDistance: CGFloat = 0
    var totalScore: Int = 0
    var eventsTriggered: [AnalyticsEventType] = []

    var duration: Double {
        let end = endTime ?? Date().timeIntervalSince1970
        return end - startTime
    }

    var completionRate: Double {
        gameStarted == 0 ? 0 : Double(gameCompleted) / Double(gameStarted)
    }

    var sessionType: String {
        totalPlayTime > 3600 ? "long_session" :
        totalPlayTime > 600 ? "medium_session" :
        "short_session"
    }
}

// MARK: - Performance Metrics
struct PerformanceMetrics: Codable {
    var fps: Double = 60
    var cpuUsage: Double = 0
    var memoryUsage: Double = 0
    var batteryDrain: Double = 0
    var networkLatency: Double = 0
    var frameDrops: Int = 0
    var stutters: Int = 0

    var isPerformanceGood: Bool {
        fps > 50 && memoryUsage < 80 && networkLatency < 100
    }
}

// MARK: - Crash Report
struct CrashReport: Codable {
    var crashId: String
    var timestamp: TimeInterval
    var errorDescription: String
    var stackTrace: String
    var sessionId: String
    var userId: String
    var deviceInfo: DeviceInfo
    var appVersion: String
    var osVersion: String

    init(
        errorDescription: String,
        stackTrace: String,
        sessionId: String,
        userId: String,
        appVersion: String,
        osVersion: String
    ) {
        self.crashId = UUID().uuidString
        self.timestamp = Date().timeIntervalSince1970
        self.errorDescription = errorDescription
        self.stackTrace = stackTrace
        self.sessionId = sessionId
        self.userId = userId
        self.deviceInfo = DeviceInfo()
        self.appVersion = appVersion
        self.osVersion = osVersion
    }
}

// MARK: - Device Info
struct DeviceInfo: Codable {
    var deviceModel: String = "Unknown"
    var screenSize: CGSize = CGSize(width: 0, height: 0)
    var totalMemory: UInt64 = 0
    var orientation: String = "unknown"

    init() {
        #if os(iOS)
        let device = UIDevice.current
        deviceModel = device.model
        orientation = device.orientation.rawValue.description
        if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            screenSize = window.screen.bounds.size
        }
        #elseif os(macOS)
        deviceModel = "Mac"
        screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1024, height: 768)
        #endif
    }
}

// MARK: - Analytics Engine (Main)
@MainActor
class AnalyticsEngine: ObservableObject {
    @Published var currentSessionMetrics: SessionMetrics
    @Published var performanceMetrics: PerformanceMetrics = PerformanceMetrics()
    @Published var eventQueue: [AnalyticsEvent] = []

    private let sessionId = UUID().uuidString
    private let userId = UserDefaults.standard.string(forKey: "userId") ?? UUID().uuidString
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var eventBuffer: [AnalyticsEvent] = []
    private let eventBufferSize = 50

    static let shared = AnalyticsEngine()

    init() {
        let sessionId = UUID().uuidString
        let userId = UserDefaults.standard.string(forKey: "userId") ?? UUID().uuidString
        self.currentSessionMetrics = SessionMetrics(
            sessionId: sessionId,
            userId: userId,
            startTime: Date().timeIntervalSince1970
        )
    }

    func trackEvent(
        _ eventType: AnalyticsEventType,
        properties: [String: Any] = [:],
        duration: Double? = nil
    ) {
        let event = AnalyticsEvent(
            eventType: eventType,
            sessionId: sessionId,
            userId: userId,
            properties: properties.mapValues { AnyCodable($0) },
            duration: duration
        )

        eventBuffer.append(event)
        eventQueue.append(event)
        currentSessionMetrics.eventsTriggered.append(eventType)

        if eventBuffer.count >= eventBufferSize {
            flushEventBuffer()
        }
    }

    func trackError(_ error: Error, context: String = "") {
        let event = AnalyticsEvent(
            eventType: .errorEncountered,
            sessionId: sessionId,
            userId: userId,
            properties: ["context": AnyCodable(context)],
            error: error.localizedDescription
        )

        eventBuffer.append(event)

        let crashReport = CrashReport(
            errorDescription: error.localizedDescription,
            stackTrace: Thread.callStackSymbols.joined(separator: "\n"),
            sessionId: sessionId,
            userId: userId,
            appVersion: Bundle.main.appVersion,
            osVersion: UIDevice.current.systemVersion
        )

        saveCrashReport(crashReport)
    }

    func updatePerformanceMetrics(fps: Double, cpu: Double, memory: Double) {
        performanceMetrics.fps = fps
        performanceMetrics.cpuUsage = cpu
        performanceMetrics.memoryUsage = memory

        if fps < 30 {
            performanceMetrics.frameDrops += 1
        }
    }

    func recordSessionMetric(gamesStarted: Int = 0, gamesCompleted: Int = 0, distance: CGFloat = 0, score: Int = 0) {
        currentSessionMetrics.gameStarted += gamesStarted
        currentSessionMetrics.gameCompleted += gamesCompleted
        currentSessionMetrics.totalDistance += distance
        currentSessionMetrics.totalScore += score
    }

    private func flushEventBuffer() {
        saveEventsToStorage()
        eventBuffer.removeAll()
    }

    private func saveEventsToStorage() {
        guard let data = try? encoder.encode(eventBuffer) else { return }
        UserDefaults.standard.set(data, forKey: "analytics.events")
    }

    private func saveCrashReport(_ report: CrashReport) {
        guard let data = try? encoder.encode(report) else { return }
        let defaults = UserDefaults.standard
        var reports = defaults.data(forKey: "crash.reports").flatMap { try? decoder.decode([CrashReport].self, from: $0) } ?? []
        reports.append(report)
        if let encoded = try? encoder.encode(reports) {
            defaults.set(encoded, forKey: "crash.reports")
        }
    }

    func endSession() {
        currentSessionMetrics.endTime = Date().timeIntervalSince1970
        currentSessionMetrics.totalPlayTime = currentSessionMetrics.duration

        flushEventBuffer()

        if let data = try? encoder.encode(currentSessionMetrics) {
            UserDefaults.standard.set(data, forKey: "session.metrics")
        }
    }

    func generateAnalyticsReport() -> String {
        var report = "=== GameIO 2P Analytics Report ===\n\n"

        report += "Session: \(currentSessionMetrics.sessionId)\n"
        report += "User: \(currentSessionMetrics.userId)\n"
        report += "Duration: \(String(format: "%.2f", currentSessionMetrics.duration)) seconds\n"
        report += "Type: \(currentSessionMetrics.sessionType)\n\n"

        report += "Game Metrics:\n"
        report += "- Games Started: \(currentSessionMetrics.gameStarted)\n"
        report += "- Games Completed: \(currentSessionMetrics.gameCompleted)\n"
        report += "- Completion Rate: \(String(format: "%.1f", currentSessionMetrics.completionRate * 100))%\n"
        report += "- Total Score: \(currentSessionMetrics.totalScore)\n"
        report += "- Total Distance: \(String(format: "%.2f", currentSessionMetrics.totalDistance)) units\n\n"

        report += "Performance:\n"
        report += "- Avg FPS: \(String(format: "%.1f", performanceMetrics.fps))\n"
        report += "- CPU Usage: \(String(format: "%.1f", performanceMetrics.cpuUsage))%\n"
        report += "- Memory Usage: \(String(format: "%.1f", performanceMetrics.memoryUsage))%\n"
        report += "- Frame Drops: \(performanceMetrics.frameDrops)\n\n"

        report += "Events Triggered: \(currentSessionMetrics.eventsTriggered.count)\n"
        for eventType in Set(currentSessionMetrics.eventsTriggered) {
            let count = currentSessionMetrics.eventsTriggered.filter { $0 == eventType }.count
            report += "- \(eventType.rawValue): \(count)\n"
        }

        return report
    }
}

// MARK: - Bundle Extension
extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Engagement Tracker
@MainActor
class EngagementTracker: ObservableObject {
    @Published var dailyActiveUsers: Int = 0
    @Published var monthlyActiveUsers: Int = 0
    @Published var averageSessionLength: Double = 0
    @Published var churnRate: Double = 0
    @Published var retentionRate: Double = 0

    private let analytics = AnalyticsEngine.shared

    func updateEngagementMetrics() {
        let currentMetrics = analytics.currentSessionMetrics

        if currentMetrics.duration > 60 {
            dailyActiveUsers += 1
        }

        if currentMetrics.duration > 300 {
            monthlyActiveUsers += 1
        }

        averageSessionLength = currentMetrics.duration
        churnRate = 1.0 - currentMetrics.completionRate
        retentionRate = currentMetrics.completionRate
    }
}
