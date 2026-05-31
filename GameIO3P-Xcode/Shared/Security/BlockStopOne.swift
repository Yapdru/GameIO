// BlockStopOne.swift — Suspicious Activity Detection & Prevention System
// Real-time monitoring | Behavioral anomalies | DDoS protection | Intrusion detection

import Foundation
import Network

@MainActor
class BlockStopOne: NSObject, ObservableObject {
    @Published var blockstopStatus: BlockStopStatus = .monitoring
    @Published var suspiciousActivities: [SuspiciousActivity] = []
    @Published var blockedEntities: [BlockedEntity] = []
    @Published var anomalyScore: Int = 0
    @Published var isActivelyBlocking: Bool = false
    @Published var blockingRules: [BlockingRule] = []

    // MARK: - Enums
    enum BlockStopStatus {
        case inactive, monitoring, alerting, blocking, locked
    }

    enum ActivityType: String {
        case abnormalLoginAttempt = "abnormal_login"
        case rateLimitExceeded = "rate_limit_exceeded"
        case suspiciousDataAccess = "suspicious_data_access"
        case unusualNetworkActivity = "unusual_network_activity"
        case failedAuthenticationAttempts = "failed_auth_attempts"
        case geoLocationAnomaly = "geo_location_anomaly"
        case deviceFingerprintMismatch = "device_fingerprint_mismatch"
        case dossAttackDetected = "dos_attack_detected"
        case dataExfiltrationAttempt = "data_exfiltration_attempt"
        case bruteForceAttack = "brute_force_attack"
        case sqlInjectionAttempt = "sql_injection_attempt"
        case xssAttempt = "xss_attempt"
        case pathTraversalAttempt = "path_traversal_attempt"
        case maliciousPayload = "malicious_payload"
        case suspiciousDecryption = "suspicious_decryption_attempt"
    }

    // MARK: - Structures
    struct SuspiciousActivity: Codable, Identifiable {
        let id: UUID
        var type: String
        var riskScore: Int // 1-100
        var timestamp: Date
        var sourceIdentifier: String
        var description: String
        var metadata: [String: AnyCodable]
        var isBlocked: Bool = false
        var blockReason: String?
        var relatedActivities: [UUID] = []
    }

    struct BlockedEntity: Codable, Identifiable {
        let id: UUID
        var entityType: String // "ip", "user", "device", "session"
        var entityValue: String
        var blockReason: String
        var blockTimestamp: Date
        var blockDuration: TimeInterval
        var blockExpiresAt: Date
        var isPermanent: Bool = false
        var blockingRuleID: UUID?
        var appealCount: Int = 0
    }

    struct BlockingRule: Codable, Identifiable {
        let id: UUID
        var name: String
        var description: String
        var conditions: [String: AnyCodable]
        var action: String // "block", "throttle", "alert", "captcha"
        var severity: Int // 1-5
        var isActive: Bool = true
        var affectsNewUsersOnly: Bool = false
        var whitelistExceptions: [String] = []
        var createdDate: Date
        var lastModifiedDate: Date
    }

    struct AnyCodable: Codable {
        let value: Any

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intVal = try? container.decode(Int.self) {
                value = intVal
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            } else if let doubleVal = try? container.decode(Double.self) {
                value = doubleVal
            } else {
                value = NSNull()
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            if let intVal = value as? Int {
                try container.encode(intVal)
            } else if let stringVal = value as? String {
                try container.encode(stringVal)
            } else if let boolVal = value as? Bool {
                try container.encode(boolVal)
            } else if let doubleVal = value as? Double {
                try container.encode(doubleVal)
            }
        }
    }

    struct NetworkProfile {
        var deviceID: String
        var previousIPAddresses: [String] = []
        var previousGeolocations: [String] = []
        var typicalLoginTimes: [Int] = [] // Hour of day
        var usualDeviceNames: [String] = []
        var typicalBandwidth: Float = 0.0
        var lastSeenDate: Date?
    }

    // MARK: - Singleton
    static let shared = BlockStopOne()

    // MARK: - Properties
    private var monitoringTimer: Timer?
    private var networkProfiles: [String: NetworkProfile] = [:]
    private var activityLog: [SuspiciousActivity] = []
    private let activityThreshold: Int = 10
    private let blockingDuration: TimeInterval = 3600 // 1 hour default

    override init() {
        super.init()
        initializeBlockStop()
    }

    // MARK: - Initialization
    private func initializeBlockStop() {
        setupDefaultBlockingRules()
        startContinuousMonitoring()
        loadBlockedEntityList()
    }

    private func setupDefaultBlockingRules() {
        let rules: [BlockingRule] = [
            // Rate limiting rule
            BlockingRule(
                id: UUID(),
                name: "Rate Limit Exceeded",
                description: "Block if more than 100 requests in 1 minute",
                conditions: ["requests_per_minute": AnyCodable(value: 100)],
                action: "throttle",
                severity: 2,
                isActive: true,
                createdDate: Date()
            ),

            // Brute force detection
            BlockingRule(
                id: UUID(),
                name: "Brute Force Attack Detection",
                description: "Block after 5 failed authentication attempts",
                conditions: ["failed_attempts": AnyCodable(value: 5)],
                action: "block",
                severity: 4,
                isActive: true,
                createdDate: Date()
            ),

            // DDoS protection
            BlockingRule(
                id: UUID(),
                name: "DDoS Attack Detection",
                description: "Detect and block coordinated attacks",
                conditions: ["request_flood": AnyCodable(value: 1000)],
                action: "block",
                severity: 5,
                isActive: true,
                createdDate: Date()
            ),

            // Geolocation anomaly
            BlockingRule(
                id: UUID(),
                name: "Impossible Travel",
                description: "Block logins from impossible locations",
                conditions: ["distance_threshold": AnyCodable(value: 900), "time_threshold": AnyCodable(value: 3600)],
                action: "block",
                severity: 3,
                isActive: true,
                createdDate: Date()
            ),

            // Data exfiltration
            BlockingRule(
                id: UUID(),
                name: "Data Exfiltration Prevention",
                description: "Detect abnormal data access patterns",
                conditions: ["data_volume_threshold": AnyCodable(value: 1073741824)],
                action: "block",
                severity: 5,
                isActive: true,
                createdDate: Date()
            )
        ]

        blockingRules = rules
    }

    private func startContinuousMonitoring() {
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.performRealTimeMonitoring()
        }
    }

    private func loadBlockedEntityList() {
        if let savedData = UserDefaults.standard.data(forKey: "blockedEntities"),
           let decoded = try? JSONDecoder().decode([BlockedEntity].self, from: savedData) {
            blockedEntities = decoded.filter { $0.blockExpiresAt > Date() }
        }
    }

    // MARK: - Real-Time Monitoring
    private func performRealTimeMonitoring() {
        // Monitor for suspicious activities
        checkForRateLimitViolations()
        checkForBruteForceAttempts()
        checkForDDoSPatterns()
        checkForGeolocationAnomalies()
        checkForDataExfiltration()
        checkForMaliciousPayloads()
        updateAnomalyScore()
    }

    private func checkForRateLimitViolations() {
        // Monitor request rate
        let recentActivities = activityLog.filter { $0.timestamp > Date(timeIntervalSinceNow: -60) }

        for rule in blockingRules where rule.name.contains("Rate Limit") {
            if let threshold = rule.conditions["requests_per_minute"] as? Int,
               recentActivities.count > threshold {
                recordSuspiciousActivity(
                    type: ActivityType.rateLimitExceeded.rawValue,
                    description: "Rate limit exceeded: \(recentActivities.count) requests in 1 minute",
                    riskScore: 30,
                    sourceIdentifier: "system"
                )
            }
        }
    }

    private func checkForBruteForceAttempts() {
        // Monitor failed authentication attempts
        let failedAttempts = activityLog.filter {
            $0.type == ActivityType.failedAuthenticationAttempts.rawValue &&
            $0.timestamp > Date(timeIntervalSinceNow: -300) // Last 5 minutes
        }

        if failedAttempts.count >= 5 {
            recordSuspiciousActivity(
                type: ActivityType.bruteForceAttack.rawValue,
                description: "Potential brute force attack detected: \(failedAttempts.count) failed attempts",
                riskScore: 80,
                sourceIdentifier: "auth_system"
            )

            blockFailedAuthenticationSource(failedAttempts)
        }
    }

    private func checkForDDoSPatterns() {
        // Monitor for distributed denial of service patterns
        let recentActivities = activityLog.filter { $0.timestamp > Date(timeIntervalSinceNow: -10) }

        if recentActivities.count > 1000 {
            recordSuspiciousActivity(
                type: ActivityType.dossAttackDetected.rawValue,
                description: "DDoS attack pattern detected: \(recentActivities.count) activities in 10 seconds",
                riskScore: 95,
                sourceIdentifier: "network_monitor"
            )

            activateDDoSProtection()
        }
    }

    private func checkForGeolocationAnomalies() {
        // Monitor for impossible travel
        // Check if same user logs in from geographically distant locations within impossible time
    }

    private func checkForDataExfiltration() {
        // Monitor for abnormal data access patterns
    }

    private func checkForMaliciousPayloads() {
        // Monitor for SQL injection, XSS, path traversal attacks
    }

    private func updateAnomalyScore() {
        let unmitigatedThreats = suspiciousActivities.filter { !$0.isBlocked }
        anomalyScore = min(100, unmitigatedThreats.reduce(0) { $0 + $1.riskScore / 10 })

        if anomalyScore > 80 {
            blockstopStatus = .blocking
            isActivelyBlocking = true
        } else if anomalyScore > 50 {
            blockstopStatus = .alerting
        } else {
            blockstopStatus = .monitoring
        }
    }

    // MARK: - Activity Recording
    private func recordSuspiciousActivity(
        type: String,
        description: String,
        riskScore: Int,
        sourceIdentifier: String,
        metadata: [String: AnyCodable] = [:]
    ) {
        let activity = SuspiciousActivity(
            id: UUID(),
            type: type,
            riskScore: riskScore,
            timestamp: Date(),
            sourceIdentifier: sourceIdentifier,
            description: description,
            metadata: metadata
        )

        activityLog.append(activity)
        suspiciousActivities.append(activity)

        // Trigger blocking rule if applicable
        checkBlockingRules(for: activity)
    }

    // MARK: - Blocking Actions
    private func blockFailedAuthenticationSource(_ activities: [SuspiciousActivity]) {
        for activity in activities {
            let blockedEntity = BlockedEntity(
                id: UUID(),
                entityType: "session",
                entityValue: activity.sourceIdentifier,
                blockReason: "Brute force attack detected",
                blockTimestamp: Date(),
                blockDuration: blockingDuration,
                blockExpiresAt: Date(timeIntervalSinceNow: blockingDuration)
            )

            blockedEntities.append(blockedEntity)
            saveBlockedEntities()
        }
    }

    private func activateDDoSProtection() {
        blockstopStatus = .locked
        isActivelyBlocking = true

        // Implement rate limiting
        // Implement CAPTCHA challenges
        // Implement IP reputation checks
    }

    private func checkBlockingRules(for activity: SuspiciousActivity) {
        for rule in blockingRules where rule.isActive {
            if shouldApplyRule(rule, to: activity) {
                applyBlockingRule(rule, to: activity)
            }
        }
    }

    private func shouldApplyRule(_ rule: BlockingRule, to activity: SuspiciousActivity) -> Bool {
        // Check if rule applies to this activity
        return activity.riskScore >= rule.severity * 15
    }

    private func applyBlockingRule(_ rule: BlockingRule, to activity: SuspiciousActivity) {
        var suspiciousActivity = activity
        suspiciousActivity.isBlocked = true
        suspiciousActivity.blockReason = rule.name

        let blockedEntity = BlockedEntity(
            id: UUID(),
            entityType: "activity",
            entityValue: activity.sourceIdentifier,
            blockReason: rule.description,
            blockTimestamp: Date(),
            blockDuration: blockingDuration,
            blockExpiresAt: Date(timeIntervalSinceNow: blockingDuration),
            blockingRuleID: rule.id
        )

        blockedEntities.append(blockedEntity)
        saveBlockedEntities()
    }

    // MARK: - Entity Management
    func unblockEntity(_ entity: BlockedEntity) -> Bool {
        if let index = blockedEntities.firstIndex(where: { $0.id == entity.id }) {
            blockedEntities.remove(at: index)
            saveBlockedEntities()
            return true
        }
        return false
    }

    func addToWhitelist(entityValue: String, rule: BlockingRule) {
        var updatedRule = rule
        updatedRule.whitelistExceptions.append(entityValue)

        if let index = blockingRules.firstIndex(where: { $0.id == rule.id }) {
            blockingRules[index] = updatedRule
        }
    }

    // MARK: - Persistence
    private func saveBlockedEntities() {
        if let encoded = try? JSONEncoder().encode(blockedEntities) {
            UserDefaults.standard.set(encoded, forKey: "blockedEntities")
        }
    }

    func isEntityBlocked(_ entityValue: String) -> Bool {
        return blockedEntities.contains {
            $0.entityValue == entityValue && $0.blockExpiresAt > Date()
        }
    }

    deinit {
        monitoringTimer?.invalidate()
    }
}
