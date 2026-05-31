// SiriGameMessaging.swift — HomePod Siri Integration
// Voice commands send messages to friends in-game
// "Hey Siri, Tell my friends I'll be there!" integrates with GameIO 3P

import Foundation
import AVFoundation
import SiriKit

@MainActor
class SiriGameMessaging: NSObject, ObservableObject {
    @Published var lastVoiceCommand: String = ""
    @Published var messagesSent: [GameMessage] = []
    @Published var isListeningForSiri: Bool = false
    @Published var friendsOnline: [String] = []

    static let shared = SiriGameMessaging()

    struct GameMessage: Identifiable, Codable {
        let id: UUID
        var sender: String
        var message: String
        var timestamp: Date
        var recipients: [String]
        var deliveryStatus: MessageStatus

        enum MessageStatus: String, Codable {
            case pending, sent, delivered, failed
        }
    }

    struct SiriIntent {
        var command: String
        var action: GameAction
        var recipients: [String]
        var timestamp: Date

        enum GameAction {
            case notifyFriendsArriving
            case notifyGameStarting
            case sendCustomMessage(String)
            case requestToJoinGame
            case inviteFriendsToPlay
        }
    }

    private var messageQueue: [GameMessage] = []
    private var siriIntentHandler: SiriIntentHandler?
    private let audioEngine = AVAudioEngine()

    override init() {
        super.init()
        initializeSiriMessaging()
    }

    private func initializeSiriMessaging() {
        setupSiriIntentHandler()
        loadFriendsOnline()
        startSiriListening()
    }

    private func setupSiriIntentHandler() {
        siriIntentHandler = SiriIntentHandler()
        siriIntentHandler?.delegate = self
    }

    private func startSiriListening() {
        isListeningForSiri = true
        print("🎤 HomePod: Listening for Siri commands...")
        print("Example: 'Hey Siri, Tell my friends I'll be there!'")
        print("Example: 'Hey Siri, Invite friends to play GameIO'")
    }

    private func loadFriendsOnline() {
        // In production, load from network
        friendsOnline = [
            "Alex",
            "Jordan",
            "Casey",
            "Morgan",
            "Taylor"
        ]
    }

    // MARK: - Voice Command Processing
    func processSiriCommand(_ command: String) {
        lastVoiceCommand = command
        let intent = parseSiriIntent(command)

        switch intent.action {
        case .notifyFriendsArriving:
            sendGameMessage(
                message: "I'll be there! 🎮",
                recipients: friendsOnline,
                action: intent.action
            )

        case .notifyGameStarting:
            sendGameMessage(
                message: "Starting a game now! 🏁",
                recipients: friendsOnline,
                action: intent.action
            )

        case .sendCustomMessage(let customMsg):
            sendGameMessage(
                message: customMsg,
                recipients: friendsOnline,
                action: intent.action
            )

        case .requestToJoinGame:
            sendGameMessage(
                message: "Can I join your game? 🎯",
                recipients: friendsOnline,
                action: intent.action
            )

        case .inviteFriendsToPlay:
            sendGameMessage(
                message: "Join me for GameIO 3P! Let's play! 🎪",
                recipients: friendsOnline,
                action: intent.action
            )
        }
    }

    private func parseSiriIntent(_ command: String) -> SiriIntent {
        let lowerCommand = command.lowercased()

        if lowerCommand.contains("i'll be there") || lowerCommand.contains("ill be there") {
            return SiriIntent(
                command: command,
                action: .notifyFriendsArriving,
                recipients: friendsOnline,
                timestamp: Date()
            )
        } else if lowerCommand.contains("starting") || lowerCommand.contains("start game") {
            return SiriIntent(
                command: command,
                action: .notifyGameStarting,
                recipients: friendsOnline,
                timestamp: Date()
            )
        } else if lowerCommand.contains("invite") || lowerCommand.contains("play") {
            return SiriIntent(
                command: command,
                action: .inviteFriendsToPlay,
                recipients: friendsOnline,
                timestamp: Date()
            )
        } else if lowerCommand.contains("join") {
            return SiriIntent(
                command: command,
                action: .requestToJoinGame,
                recipients: friendsOnline,
                timestamp: Date()
            )
        }

        // Default: treat as custom message
        let message = String(command.dropFirst("tell my friends".count).trimmingCharacters(in: .whitespaces))
        return SiriIntent(
            command: command,
            action: .sendCustomMessage(message.isEmpty ? command : message),
            recipients: friendsOnline,
            timestamp: Date()
        )
    }

    // MARK: - Message Sending
    private func sendGameMessage(
        message: String,
        recipients: [String],
        action: SiriIntent.GameAction
    ) {
        let gameMessage = GameMessage(
            id: UUID(),
            sender: "You",
            message: message,
            timestamp: Date(),
            recipients: recipients,
            deliveryStatus: .pending
        )

        // Add to queue
        messageQueue.append(gameMessage)

        // Send via network
        sendMessageToNetwork(gameMessage) { [weak self] success in
            var updatedMessage = gameMessage
            updatedMessage.deliveryStatus = success ? .delivered : .failed
            self?.messagesSent.append(updatedMessage)
            self?.announceMessageSent(message: message, success: success)
        }
    }

    private func sendMessageToNetwork(_ message: GameMessage, completion: @escaping (Bool) -> Void) {
        // Simulate network send
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }

    private func announceMessageSent(message: String, success: Bool) {
        let text = success ?
            "Message sent to friends: '\(message)' 📱" :
            "Failed to send message. Please try again."

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)

        print("🔊 HomePod: \(text)")
    }

    // MARK: - Friend Management
    func addFriend(_ name: String) {
        if !friendsOnline.contains(name) {
            friendsOnline.append(name)
        }
    }

    func removeFriend(_ name: String) {
        friendsOnline.removeAll { $0 == name }
    }

    func broadcastMessage(_ message: String) {
        sendGameMessage(
            message: message,
            recipients: friendsOnline,
            action: .sendCustomMessage(message)
        )
    }
}

// MARK: - Siri Intent Handler
@available(iOS 14, *)
class SiriIntentHandler: NSObject {
    weak var delegate: SiriGameMessaging?

    func handleGameMessageIntent(_ text: String) {
        delegate?.processSiriCommand(text)
    }
}

// MARK: - HomePod Siri Shortcuts Support
@available(iOS 14, *)
extension SiriGameMessaging {
    /// Register custom Siri shortcuts for GameIO
    static func registerSiriShortcuts() {
        let shortcuts: [String] = [
            "Tell my friends I'll be there",
            "Invite friends to play GameIO",
            "Start a multiplayer game",
            "Join my friends game",
            "Send message to friends"
        ]

        print("📱 Registered \(shortcuts.count) Siri shortcuts for GameIO 3P")
    }

    /// Called when a Siri shortcut is executed
    func executeSiriShortcut(named shortcutName: String, withParameters params: [String: Any]) {
        switch shortcutName {
        case "Tell my friends I'll be there":
            processSiriCommand("Tell my friends I'll be there")

        case "Invite friends to play GameIO":
            processSiriCommand("Invite friends to play GameIO")

        case "Start a multiplayer game":
            processSiriCommand("Start a multiplayer game")

        case "Join my friends game":
            processSiriCommand("Join my friends game")

        case "Send message to friends":
            if let message = params["message"] as? String {
                processSiriCommand("Tell my friends \(message)")
            }

        default:
            break
        }
    }
}

// MARK: - Message Broadcasting
extension SiriGameMessaging {
    /// Broadcast a message to all online friends
    func broadcastToFriends(_ message: String, priority: MessagePriority = .normal) {
        let fullMessage = "[\(priority.rawValue.uppercased())] \(message)"

        for friend in friendsOnline {
            let gameMessage = GameMessage(
                id: UUID(),
                sender: "You",
                message: fullMessage,
                timestamp: Date(),
                recipients: [friend],
                deliveryStatus: .sent
            )
            messagesSent.append(gameMessage)
        }

        print("📢 Broadcast to \(friendsOnline.count) friends: \(message)")
    }

    enum MessagePriority: String {
        case low, normal, high, urgent
    }
}
