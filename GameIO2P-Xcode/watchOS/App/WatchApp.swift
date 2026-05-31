// WatchApp.swift
// GameIO 2P — watchOS App Entry Point
// Simplified game UI for Apple Watch.

import SwiftUI
import WatchKit
import WatchConnectivity

// MARK: - Watch App Entry

@main
struct GameIO2PApp: App {
    @WKApplicationDelegateAdaptor(GameIOWatchAppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            WatchRootView()
        }
    }
}

// MARK: - App Delegate

class GameIOWatchAppDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {

    override init() {
        super.init()
        setupWatchConnectivity()
    }

    func applicationDidFinishLaunching() {
        WKExtension.shared().isAutorotating = false
    }

    // MARK: - Watch Connectivity

    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("[Watch] WCSession activated")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .watchDidReceiveMessage, object: message)
        }
    }
}

extension Notification.Name {
    static let watchDidReceiveMessage = Notification.Name("watchDidReceiveMessage")
}

// MARK: - Root View

struct WatchRootView: View {
    @State private var currentTab: WatchTab = .status

    enum WatchTab: Int, CaseIterable {
        case status, leaderboard, settings
    }

    var body: some View {
        TabView(selection: $currentTab) {
            WatchRaceStatusView()
                .tag(WatchTab.status)

            WatchLeaderboardView()
                .tag(WatchTab.leaderboard)

            WatchSettingsView()
                .tag(WatchTab.settings)
        }
        .tabViewStyle(.page)
    }
}

// MARK: - Watch Settings (simplified)

struct WatchSettingsView: View {
    @State private var hapticsOn = true
    @State private var notifications = true

    var body: some View {
        List {
            Toggle("Haptics", isOn: $hapticsOn)
            Toggle("Alerts", isOn: $notifications)
            Button("Open on iPhone") {
                WCSession.default.sendMessage(["action": "openApp"], replyHandler: nil)
            }
        }
        .navigationTitle("Settings")
    }
}
