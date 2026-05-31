// GameIO 3P — Complete Universal Racing Platform
// Main app entry point — universal across iPhone, iPad, Mac Catalyst
// Initializes CoreMotion, Audio, and game state at launch

import SwiftUI
import AVFoundation
import CoreMotion
import Combine

@main
struct GameIO3PApp: App {

    // MARK: - State Objects
    @StateObject private var gameState   = GameState.shared
    @StateObject private var motionManager = MotionManager.shared
    @StateObject private var audioManager  = AudioManager.shared

    // MARK: - Scene Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(gameState)
                .environmentObject(motionManager)
                .environmentObject(audioManager)
                .preferredColorScheme(.light)
                .onAppear {
                    setupApp()
                }
        }
    }

    // MARK: - App Setup
    private func setupApp() {
        // Start motion monitoring
        motionManager.startMonitoring()

        // Start menu music
        audioManager.playMusic(.menu)

        // Configure audio session for background play
        configureAudioSession()

        // Lock screen orientation handling
        setupOrientationSupport()

        print("GameIO 3P started successfully - Ultra Detail Graphics Enabled")
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("GameIO 3P: Audio session error: \(error)")
        }
    }

    private func setupOrientationSupport() {
        // Allow all orientations for iPad, landscape for iPhone in race mode
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Will be restricted to landscape when racing starts
        }
        #endif
    }
}

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure appearance
        configureAppearance()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause audio when app goes to background
        AudioManager.shared.stopMusic()
        MotionManager.shared.stopMonitoring()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Resume audio
        AudioManager.shared.playMusic(.menu)
        MotionManager.shared.startMonitoring()
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        let phase = GameState.shared.phase
        // Landscape only during racing for immersive experience
        if phase == .racing || phase == .garageCinematic {
            return [.landscapeLeft, .landscapeRight]
        }
        // All orientations in lobby and menus
        return .all
    }

    private func configureAppearance() {
        // Navigation bar - light blue
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.99, alpha: 0.95)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 18, weight: .black)
        ]
        UINavigationBar.appearance().standardAppearance   = navAppearance
        UINavigationBar.appearance().compactAppearance    = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // Tab bar - light
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.99, alpha: 0.95)
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Status bar = dark content on light background
        UIApplication.shared.statusBarStyle = .darkContent
    }
}

// MARK: - Root View (phase-based navigation)
struct RootView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var motionManager: MotionManager

    var body: some View {
        ZStack {
            // Base background - light blue/white
            Color(red: 0.94, green: 0.96, blue: 1.0)
                .ignoresSafeArea()

            // Phase-based content
            Group {
                switch gameState.phase {
                case .carPlaySafety:
                    CarPlaySafetyView()
                        .transition(.opacity)

                case .splash:
                    SplashView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))

                case .avatarCreator:
                    AvatarCreatorPlaceholderView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .roomCode:
                    RoomCodePlaceholderView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .carSelection:
                    CarSelectionPlaceholderView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .garageCinematic:
                    GarageCinematicView()
                        .transition(.opacity)

                case .racing:
                    RacingView()
                        .transition(.opacity)
                        .ignoresSafeArea()

                case .lobby, .walking, .elevator:
                    LobbyPlaceholderView()
                        .transition(.opacity)

                case .gameActive:
                    GameActiveView()
                        .transition(.asymmetric(insertion: .scale(scale: 1.1), removal: .opacity))

                case .leaderboard:
                    LeaderboardPlaceholderView()
                        .transition(.move(edge: .bottom))

                case .settings:
                    SettingsPlaceholderView()
                        .transition(.move(edge: .bottom))

                default:
                    SplashView()
                }
            }
            .animation(.easeInOut(duration: 0.6), value: gameState.phase)

            // Safety overlay always on top
            DrivingSafetyOverlay()
        }
    }
}

// MARK: - CarPlay Safety View
struct CarPlaySafetyView: View {
    @EnvironmentObject var motionManager: MotionManager
    @EnvironmentObject var gameState: GameState
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var particleOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Animated grid background
            GridBackgroundView()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Text("GAMEIO 2P")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#f5a623") ?? .orange, Color(hex: "#ffd700") ?? .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: (Color(hex: "#f5a623") ?? .orange).opacity(0.8), radius: 20)
                    Text("UNIVERSAL RACING PLATFORM")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.6))
                        .kerning(6)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        logoScale = 1.0
                        logoOpacity = 1.0
                    }
                }

                // Status indicator
                MotionStatusView()

                Spacer()

                // Start button (when safe)
                if motionManager.showStartButton && !motionManager.isDriving {
                    StartButtonView {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            gameState.transitionTo(.splash)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer().frame(height: 60)
            }
        }
    }
}

// MARK: - Motion Status View
struct MotionStatusView: View {
    @EnvironmentObject var motionManager: MotionManager
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(motionManager.isDriving ? Color.red : Color(red: 1.0, green: 0.85, blue: 0.0))
                .frame(width: 12, height: 12)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseScale)

            if motionManager.isDriving {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Driving detected — please stop")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                    Text("It's Unsafe to play while driving.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.7))
                }
            } else if !motionManager.showStartButton {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vehicle stopped")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    let remaining = Int(ceil(max(0, motionManager.stationaryThreshold - motionManager.stationaryDuration)))
                    if remaining > 0 {
                        Text("Game available in \(remaining)s...")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
            } else {
                Text("Safe to play!")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.98, green: 0.98, blue: 0.99))
                .stroke(Color(red: 0.8, green: 0.9, blue: 1.0), lineWidth: 1.5)
        )
        .onAppear { pulseScale = 1.3 }
    }
}

// MARK: - Start Button View
struct StartButtonView: View {
    let action: () -> Void
    @State private var glowRadius: CGFloat = 15
    @State private var isPressed: Bool = false
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        Button(action: {
            isPressed = true
            audioManager.playSFX(.countdownGo)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Text("START")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 220, height: 66)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#f5a623") ?? .orange, Color(hex: "#ff8c00") ?? .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: (Color(hex: "#f5a623") ?? .orange).opacity(0.8), radius: glowRadius)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glowRadius)
        .onAppear { glowRadius = 30 }
    }
}

// MARK: - Grid Background
struct GridBackgroundView: View {
    @State private var animOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.94, green: 0.96, blue: 1.0)
                    .ignoresSafeArea()

                // Perspective grid lines
                Canvas { context, size in
                    let horizon = size.height * 0.5
                    context.withCGContext { cgContext in
                        cgContext.setStrokeColor(UIColor(red: 0.7, green: 0.8, blue: 0.95, alpha: 0.15).cgColor)
                        cgContext.setLineWidth(1.5)
                        // Vertical lines
                        for i in stride(from: -10, through: 10, by: 1) {
                            let xBot = size.width/2 + CGFloat(i) * 50 + animOffset
                            let xTop = size.width/2 + CGFloat(i) * 5
                            cgContext.move(to: CGPoint(x: xBot, y: size.height))
                            cgContext.addLine(to: CGPoint(x: xTop, y: horizon))
                            cgContext.strokePath()
                        }
                        // Horizontal lines
                        for i in stride(from: 0, through: 10, by: 1) {
                            let t = CGFloat(i) / 10.0
                            let y = horizon + (size.height - horizon) * t
                            cgContext.move(to: CGPoint(x: 0, y: y))
                            cgContext.addLine(to: CGPoint(x: size.width, y: y))
                            cgContext.strokePath()
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                animOffset = 50
            }
        }
    }
}

// MARK: - Splash View (placeholder calls game screens)
struct SplashView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var audioManager: AudioManager
    @State private var titleScale: CGFloat = 0.6
    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var buttonPulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            GridBackgroundView()

            VStack(spacing: 32) {
                Spacer()

                // Logo
                VStack(spacing: 6) {
                    Text("GAMEIO 2P")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#f5a623") ?? .orange, Color(hex: "#ffd700") ?? .yellow, Color(hex: "#f5a623") ?? .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: (Color(hex: "#f5a623") ?? .orange).opacity(1.0), radius: 30)

                    Text("UNIVERSAL RACING PLATFORM")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.7))
                        .kerning(5)
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                // Car silhouette
                LamborghiniSilhouetteView()
                    .opacity(subtitleOpacity)

                // Press START
                Button(action: {
                    audioManager.playSFX(.buttonTap)
                    withAnimation(.easeInOut(duration: 0.6)) {
                        gameState.transitionTo(.avatarCreator)
                    }
                }) {
                    Text("PRESS START")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "#f5a623") ?? .orange)
                        .kerning(4)
                        .scaleEffect(buttonPulse)
                }
                .opacity(buttonOpacity)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.8)) {
                subtitleOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(1.2)) {
                buttonOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(1.5)) {
                buttonPulse = 1.06
            }
        }
    }
}

// MARK: - Lamborghini Silhouette (Canvas)
struct LamborghiniSilhouetteView: View {
    var body: some View {
        Canvas { context, size in
            context.withCGContext { ctx in
                ctx.setFillColor(UIColor(red: 0.96, green: 0.65, blue: 0.14, alpha: 0.9).cgColor)
                let scaleX = size.width / 400.0
                let scaleY = size.height / 120.0
                ctx.scaleBy(x: scaleX, y: scaleY)
                // Lamborghini body
                let body = UIBezierPath()
                body.move(to: CGPoint(x: 40, y: 80))
                body.addLine(to: CGPoint(x: 60, y: 80))
                body.addLine(to: CGPoint(x: 80, y: 60))
                body.addLine(to: CGPoint(x: 130, y: 45))
                body.addLine(to: CGPoint(x: 200, y: 38))
                body.addLine(to: CGPoint(x: 270, y: 42))
                body.addLine(to: CGPoint(x: 320, y: 55))
                body.addLine(to: CGPoint(x: 350, y: 75))
                body.addLine(to: CGPoint(x: 360, y: 80))
                body.addLine(to: CGPoint(x: 40, y: 80))
                body.close()
                ctx.addPath(body.cgPath)
                ctx.fillPath()
                // Roof
                let roof = UIBezierPath()
                roof.move(to: CGPoint(x: 130, y: 45))
                roof.addLine(to: CGPoint(x: 145, y: 28))
                roof.addLine(to: CGPoint(x: 220, y: 22))
                roof.addLine(to: CGPoint(x: 280, y: 28))
                roof.addLine(to: CGPoint(x: 270, y: 42))
                roof.close()
                ctx.setFillColor(UIColor(red: 0.8, green: 0.5, blue: 0.1, alpha: 0.9).cgColor)
                ctx.addPath(roof.cgPath)
                ctx.fillPath()
                // Wheels
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fillEllipse(in: CGRect(x: 75, y: 68, width: 48, height: 32))
                ctx.fillEllipse(in: CGRect(x: 280, y: 68, width: 48, height: 32))
                // Wheel shine
                ctx.setFillColor(UIColor(white: 0.4, alpha: 1).cgColor)
                ctx.fillEllipse(in: CGRect(x: 85, y: 73, width: 28, height: 22))
                ctx.fillEllipse(in: CGRect(x: 290, y: 73, width: 28, height: 22))
            }
        }
        .frame(width: 360, height: 120)
    }
}

// MARK: - Placeholder Views (will be replaced by full implementations from Shared/Games)
struct AvatarCreatorPlaceholderView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        VStack { Text("Avatar Creator").font(.title).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
            Button("Continue") { gameState.transitionTo(.roomCode) }.buttonStyle(.borderedProminent) }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red:0.94,green:0.96,blue:1.0))
    }
}

struct RoomCodePlaceholderView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        VStack { Text("Room: GAME://io.gameio2p.lobby/\(gameState.roomCode)").font(.headline).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8)).padding()
            Button("Enter Lobby") { gameState.transitionTo(.carSelection) }.buttonStyle(.borderedProminent) }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red:0.94,green:0.96,blue:1.0))
    }
}

struct CarSelectionPlaceholderView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        VStack { Text("Select Car").font(.title).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
            Button("Lamborghini → Race") { gameState.transitionTo(.garageCinematic) }.buttonStyle(.borderedProminent) }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red:0.94,green:0.96,blue:1.0))
    }
}

struct GarageCinematicView: View {
    @EnvironmentObject var gameState: GameState
    @State private var doorProgress: CGFloat = 0
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.15).ignoresSafeArea()
            VStack {
                Text("GARAGE").font(.largeTitle.bold()).foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                    .padding()
                Rectangle().fill(Color(red: 0.3, green: 0.3, blue: 0.4)).frame(height: 200 * (1 - doorProgress))
                    .animation(.easeInOut(duration: 2.0), value: doorProgress)
            }
        }
        .onAppear {
            doorProgress = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                gameState.transitionTo(.racing)
            }
        }
    }
}

struct RacingView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()
            VStack {
                Text("RACING").font(.largeTitle.bold()).foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                Button("Get Out") { gameState.transitionTo(.walking) }.buttonStyle(.borderedProminent)
            }
        }
    }
}

struct LobbyPlaceholderView: View {
    @EnvironmentObject var gameState: GameState

    let games: [(String, MiniGame)] = [
        ("Speed Match", .speedMatch),
        ("Drift King", .driftKing),
        ("Nitro Racer", .nitroRacer),
        ("Pit Stop", .pitStop),
        ("Traffic Dodger", .trafficDodger),
        ("Fuel Rush", .fuelRush),
        ("Turbo Quiz", .turboQuiz),
        ("Parking Master", .parkingMaster),
        ("Drag Strip", .dragStrip),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("SELECT GAME").font(.title2.bold()).foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    .padding()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(games, id: \.1) { gameName, gameType in
                            Button(action: {
                                gameState.selectedGame = gameType
                                gameState.transitionTo(.gameActive)
                            }) {
                                HStack {
                                    Text(gameName).font(.headline).foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "play.circle.fill").foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity).padding(12)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.1, green: 0.4, blue: 0.8)))
                            }
                        }
                    }
                    .padding()
                }

                Button(action: { gameState.transitionTo(.racing) }) {
                    Text("RACE MODE")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 1.0, green: 0.5, blue: 0.0)).cornerRadius(8)
                }
                .padding()

                Button(action: { gameState.transitionTo(.settings) }) {
                    Text("SETTINGS")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color(red: 0.5, green: 0.5, blue: 0.5)).cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

struct GameActiveView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        Group {
            switch gameState.selectedGame {
            case .speedMatch:
                SpeedMatchGameView()
            case .driftKing:
                DriftKingGameView()
            case .nitroRacer:
                NitroRacerGameView()
            case .pitStop:
                PitStopGameView()
            case .trafficDodger:
                TrafficDodgerGameView()
            case .fuelRush:
                FuelRushGameView()
            case .turboQuiz:
                TurboQuizGameView()
            case .parkingMaster:
                ParkingMasterGameView()
            case .dragStrip:
                DragStripGameView()
            case .none:
                VStack {
                    Text("No Game Selected").foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.8))
                    Button("Back") { gameState.transitionTo(.lobby) }.buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.94, green: 0.96, blue: 1.0))
            }
        }
    }
}

struct LeaderboardPlaceholderView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        NavigationView { List(gameState.leaderboard) { entry in
            HStack { Text("#\(entry.rank)").foregroundColor(.orange); Text(entry.playerName).foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)); Spacer(); Text("\(entry.score)").foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0)) }
        }.navigationTitle("Leaderboard").navigationBarTitleDisplayMode(.inline) }
    }
}

struct SettingsPlaceholderView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        NavigationView { Form { Section("Audio") {
            Toggle("Music", isOn: $gameState.isAudioEnabled)
        } }.navigationTitle("Settings") }
    }
}
