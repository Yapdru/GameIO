// NetworkManager.swift — Multi-platform networking with Bonjour, WiFi, Bluetooth
// Supports local multiplayer, leaderboard sync, and P2P communication

import Foundation
import Network
import Combine
import NetworkExtension

// MARK: - Network Message Types
enum NetworkMessage: Codable {
    case playerJoined(PlayerProfile)
    case playerLeft(String)
    case gameStateUpdate(GameStateSync)
    case playerAction(String, GameAction)
    case raceStart(RaceConfiguration)
    case raceEnd(RaceResult)
    case scoreUpdate(Int, Int)
    case chatMessage(String, String)
    case leaderboardRequest
    case leaderboardResponse([LeaderboardEntry])
    case achievementUnlocked(Achievement)
    case connectionRequest(String)
    case connectionAccept(String)
    case connectionReject(String)
    case heartbeat
}

// MARK: - Game Action Enum
enum GameAction: Codable {
    case movePlayer(CGPoint)
    case setVelocity(CGFloat)
    case castAbility(String)
    case useItem(String)
    case attack(String)
    case collectPowerup(String)
}

// MARK: - Game State Sync
struct GameStateSync: Codable {
    var playerId: String
    var position: CGPoint
    var rotation: CGFloat
    var velocity: CGFloat
    var health: Int
    var fuel: CGFloat
    var nitro: CGFloat
    var timestamp: TimeInterval
}

// MARK: - Race Configuration
struct RaceConfiguration: Codable {
    var raceId: String
    var trackId: String
    var laps: Int
    var aiCount: Int
    var weatherId: String
    var timeOfDay: String
    var difficulty: String
    var startTime: TimeInterval
}

// MARK: - Race Result
struct RaceResult: Codable {
    var raceId: String
    var winner: String
    var positions: [String]
    var lapTimes: [String: [Double]]
    var totalTime: Double
    var timestamp: TimeInterval
}

// MARK: - Network Connection Manager
@MainActor
class NetworkManager: NSObject, ObservableObject {
    @Published var connectedPeers: [String] = []
    @Published var isHost: Bool = false
    @Published var connectionQuality: Double = 1.0
    @Published var latency: Double = 0
    @Published var bandwidthUsage: Double = 0
    @Published var messageQueue: [NetworkMessage] = []

    private var connection: NWConnection?
    private var listener: NWListener?
    private let sessionId = UUID().uuidString
    private var bonjourBrowser: NetServiceBrowser?
    private var bonjourService: NetService?
    private var sentBytes: Int = 0
    private var receivedBytes: Int = 0
    private var messageHandlers: [String: (NetworkMessage) -> Void] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    static let shared = NetworkManager()

    func startAsHost(playerName: String) {
        isHost = true
        startBonjourService(playerName: playerName)
        setupListener()
    }

    func joinGame(serviceName: String) {
        isHost = false
        discoverService(serviceName: serviceName)
    }

    private func setupListener() {
        do {
            listener = try NWListener(using: .tcp)
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }
            try listener?.start(queue: DispatchQueue(label: "com.gameio.network"))
        } catch {
            print("Failed to setup listener: \(error)")
        }
    }

    private func handleNewConnection(_ connection: NWConnection) {
        self.connection = connection
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionStateChange(state)
        }
        connection.viabilityUpdateHandler = { [weak self] isViable in
            DispatchQueue.main.async {
                self?.connectionQuality = isViable ? 1.0 : 0.5
            }
        }
        connection.start(queue: DispatchQueue(label: "com.gameio.connection"))
        receiveMessage()
    }

    func sendMessage(_ message: NetworkMessage, to peerId: String? = nil) {
        guard let data = try? encoder.encode(message) else { return }

        let messageSize = data.count
        sentBytes += messageSize

        connection?.send(content: data, completion: .contentProcessed { [weak self] error in
            if let error = error {
                print("Send error: \(error)")
            } else {
                self?.recordLatency()
            }
        })
    }

    private func receiveMessage() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self?.receivedBytes += data.count

                if let message = try? self?.decoder.decode(NetworkMessage.self, from: data) {
                    DispatchQueue.main.async {
                        self?.messageQueue.append(message)
                        self?.handleMessage(message)
                    }
                }
            }

            if !isComplete {
                self?.receiveMessage()
            }
        }
    }

    private func handleMessage(_ message: NetworkMessage) {
        switch message {
        case .playerJoined(let profile):
            handlePlayerJoined(profile)
        case .playerLeft(let peerId):
            handlePlayerLeft(peerId)
        case .gameStateUpdate(let sync):
            handleGameStateUpdate(sync)
        case .raceStart(let config):
            handleRaceStart(config)
        case .raceEnd(let result):
            handleRaceEnd(result)
        case .heartbeat:
            respondToHeartbeat()
        default:
            break
        }
    }

    private func handlePlayerJoined(_ profile: PlayerProfile) {
        if !connectedPeers.contains(profile.id) {
            connectedPeers.append(profile.id)
        }
    }

    private func handlePlayerLeft(_ peerId: String) {
        connectedPeers.removeAll { $0 == peerId }
    }

    private func handleGameStateUpdate(_ sync: GameStateSync) {
        // Update remote player state
    }

    private func handleRaceStart(_ config: RaceConfiguration) {
        // Notify race start listeners
    }

    private func handleRaceEnd(_ result: RaceResult) {
        // Process race results
    }

    private func respondToHeartbeat() {
        sendMessage(.heartbeat)
    }

    private var pingTime: TimeInterval = 0

    private func recordLatency() {
        if pingTime == 0 {
            pingTime = Date().timeIntervalSince1970
        } else {
            let elapsed = (Date().timeIntervalSince1970 - pingTime) * 1000
            latency = elapsed / 2
            pingTime = 0
        }
    }

    // MARK: - Bonjour Service Management
    private func startBonjourService(playerName: String) {
        let serviceName = "\(playerName)-\(sessionId.prefix(4))"
        bonjourService = NetService(
            domain: "local.",
            type: "_gameio2p._tcp.",
            name: serviceName,
            port: 12345
        )

        bonjourService?.publish()
    }

    private func discoverService(serviceName: String) {
        bonjourBrowser = NetServiceBrowser()
        bonjourBrowser?.delegate = self
        bonjourBrowser?.searchForServices(ofType: "_gameio2p._tcp.", inDomain: "local.")
    }

    func getBandwidth() -> (up: Double, down: Double) {
        let upMbps = Double(sentBytes) / 1_000_000
        let downMbps = Double(receivedBytes) / 1_000_000
        return (upMbps, downMbps)
    }

    func disconnect() {
        connection?.cancel()
        listener?.cancel()
        bonjourService?.stop()
        bonjourBrowser?.stop()
    }

    deinit {
        disconnect()
    }
}

// MARK: - NetServiceBrowser Delegate
extension NetworkManager: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        service.resolve(withTimeout: 5.0)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        // Handle service removal
    }
}

// MARK: - NetService Delegate
extension NetworkManager: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        if let addresses = sender.addresses, !addresses.isEmpty {
            connectToService(sender)
        }
    }

    private func connectToService(_ service: NetService) {
        // Establish connection to discovered service
    }
}

// MARK: - Network Quality Monitor
@MainActor
class NetworkQualityMonitor: ObservableObject {
    @Published var packetLoss: Double = 0
    @Published var jitter: Double = 0
    @Published var rtt: Double = 0
    @Published var quality: NetworkQuality = .excellent

    enum NetworkQuality: String {
        case excellent
        case good
        case fair
        case poor
        case disconnected
    }

    private var lastPingTime: TimeInterval = 0
    private var pingSamples: [Double] = []

    func recordPing(rtt: Double) {
        self.rtt = rtt
        pingSamples.append(rtt)

        if pingSamples.count > 100 {
            pingSamples.removeFirst()
        }

        updateQuality()
    }

    func recordPacketLoss(_ loss: Double) {
        packetLoss = loss
        updateQuality()
    }

    private func updateQuality() {
        let avgRtt = pingSamples.isEmpty ? 0 : pingSamples.reduce(0, +) / Double(pingSamples.count)
        let rttGood = avgRtt < 50
        let lossGood = packetLoss < 1.0

        if rttGood && lossGood {
            quality = .excellent
        } else if avgRtt < 100 && packetLoss < 2.0 {
            quality = .good
        } else if avgRtt < 200 && packetLoss < 5.0 {
            quality = .fair
        } else {
            quality = .poor
        }
    }
}

// MARK: - Multiplayer Session Manager
@MainActor
class MultiplayerSessionManager: ObservableObject {
    @Published var sessionId: String = UUID().uuidString
    @Published var maxPlayers: Int = 4
    @Published var currentPlayers: [PlayerProfile] = []
    @Published var isSessionActive: Bool = false

    var isFull: Bool { currentPlayers.count >= maxPlayers }
    var isEmpty: Bool { currentPlayers.isEmpty }
    var playerCount: Int { currentPlayers.count }

    func addPlayer(_ player: PlayerProfile) -> Bool {
        guard !isFull, !currentPlayers.contains(where: { $0.id == player.id }) else {
            return false
        }
        currentPlayers.append(player)
        return true
    }

    func removePlayer(withId playerId: String) {
        currentPlayers.removeAll { $0.id == playerId }
    }

    func getPlayer(withId playerId: String) -> PlayerProfile? {
        currentPlayers.first { $0.id == playerId }
    }

    func startSession() {
        guard !currentPlayers.isEmpty else { return }
        isSessionActive = true
    }

    func endSession() {
        isSessionActive = false
        currentPlayers.removeAll()
    }
}

// MARK: - P2P Connection Handler
class P2PConnectionHandler {
    var isConnected: Bool = false
    var remoteAddress: String = ""
    var remotePort: UInt16 = 0

    func initiateConnection(to address: String, port: UInt16) {
        remoteAddress = address
        remotePort = port

        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(address), port: NWEndpoint.Port(rawValue: port)!)
        let connection = NWConnection(to: endpoint, using: .tcp)

        connection.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.isConnected = (state == .ready)
            }
        }

        connection.start(queue: DispatchQueue(label: "com.gameio.p2p"))
    }
}
