// MainViewController.swift
// GameIO 2P — Main UIHostingController
// Wraps SwiftUI view tree, handles audio session setup.

import UIKit
import SwiftUI
import AVFoundation

// MARK: - App State

enum AppScreen {
    case splash
    case avatarCreator
    case lobby
    case roomCode(code: String, isHost: Bool)
    case carSelection
    case game(gameID: Int)
    case leaderboard
    case settings
}

class AppRouter: ObservableObject {
    @Published var currentScreen: AppScreen = .splash
    @Published var navigationPath: [AppScreen] = []

    func navigate(to screen: AppScreen) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.35)) {
                self.currentScreen = screen
            }
        }
    }

    func back() {
        guard !navigationPath.isEmpty else { return }
        DispatchQueue.main.async {
            _ = self.navigationPath.popLast()
        }
    }
}

// MARK: - Root SwiftUI View

struct RootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var audioService = AudioService.shared

    var body: some View {
        Group {
            switch router.currentScreen {
            case .splash:
                SplashScreenView(onStart: { router.navigate(to: .avatarCreator) })
                    .transition(.opacity)

            case .avatarCreator:
                AvatarCreatorView(onSave: { _, _ in router.navigate(to: .lobby) })
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .lobby:
                LobbyView(onEnterGame: { id in router.navigate(to: .game(gameID: id)) })
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .roomCode(let code, let isHost):
                RoomCodeView(roomCode: code, isHost: isHost,
                             onStartGame: { router.navigate(to: .carSelection) })
                    .transition(.opacity)

            case .carSelection:
                CarSelectionView(onSelect: { _ in router.navigate(to: .game(gameID: 0)) })
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .game:
                // Placeholder: in real app, embed GameViewController via UIViewControllerRepresentable
                GamePlaceholderView(onBack: { router.navigate(to: .lobby) })
                    .transition(.opacity)

            case .leaderboard:
                LeaderboardView()
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))

            case .settings:
                SettingsView()
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: UUID())
        .environmentObject(router)
    }
}

struct GamePlaceholderView: View {
    var onBack: () -> Void = {}
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("GAME RUNNING").font(.system(size: 24, weight: .black, design: .monospaced)).foregroundColor(.white)
                Button("BACK TO LOBBY", action: onBack)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "#00FF88"))
            }
        }
    }
}

// MARK: - MainViewController

class MainViewController: UIHostingController<RootView> {

    private var audioSessionObserver: NSObjectProtocol?

    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: RootView())
    }

    override init(rootView: RootView = RootView()) {
        super.init(rootView: rootView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupAppearance()
        observeAudioInterruptions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeLeft }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("[MainVC] Audio session setup failed: \(error)")
        }
    }

    private func observeAudioInterruptions() {
        audioSessionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAudioInterruption(notification)
        }
    }

    private func handleAudioInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        switch type {
        case .began:
            AudioService.shared.pauseAll()
        case .ended:
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) { AudioService.shared.resumeAll() }
            }
        @unknown default: break
        }
    }

    private func setupAppearance() {
        view.backgroundColor = .black
        // Hide home indicator for full immersion
        setNeedsUpdateOfHomeIndicatorAutoHidingPolicy()
    }

    override var prefersHomeIndicatorAutoHidden: Bool { true }

    deinit {
        if let obs = audioSessionObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
}
