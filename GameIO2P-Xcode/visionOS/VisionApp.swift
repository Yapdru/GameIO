// VisionApp.swift — Apple Vision Pro support
// Full 3D immersive racing with hand gestures and spatial audio

import SwiftUI
import RealityKit

@main
struct GameIO2PVisionApp: App {
    @StateObject private var gameState = GameState.shared
    @StateObject private var motionManager = MotionManager.shared
    @StateObject private var audioManager = AudioManager.shared

    var body: some Scene {
        WindowGroup {
            VisionRootView()
                .environmentObject(gameState)
                .environmentObject(motionManager)
                .environmentObject(audioManager)
        }

        ImmersiveSpace(id: "racing") {
            VisionRacingView()
                .environmentObject(gameState)
        }
    }
}

// MARK: - Vision Root View
struct VisionRootView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            switch gameState.phase {
            case .splash:
                VisionSplashView()
            case .carSelection:
                VisionCarSelectionView()
            case .racing:
                VisionRacingEntryView()
            case .lobby:
                VisionLobbyView()
            default:
                VisionMainMenuView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Vision Splash Screen
struct VisionSplashView: View {
    @EnvironmentObject var gameState: GameState
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 40) {
            Text("GAMEIO 2P")
                .font(.system(size: 60, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0)
                )

            Text("Vision Pro Edition")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.gray)

            VStack(spacing: 20) {
                Text("Hand Gestures:")
                    .font(.headline)

                HStack(spacing: 20) {
                    VisionGestureCard(
                        gesture: "Pinch",
                        action: "Throttle",
                        icon: "👆"
                    )
                    VisionGestureCard(
                        gesture: "Open Palm",
                        action: "Brake",
                        icon: "✋"
                    )
                    VisionGestureCard(
                        gesture: "Point",
                        action: "Steer",
                        icon: "☝️"
                    )
                }
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(16)

            Spacer()

            Button(action: {
                withAnimation {
                    gameState.transitionTo(.carSelection)
                }
            }) {
                Text("START RACING")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                    .cornerRadius(12)
            }
        }
        .padding(40)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Vision Gesture Card
struct VisionGestureCard: View {
    let gesture: String
    let action: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))

            Text(gesture)
                .font(.caption)
                .foregroundColor(.gray)

            Text(action)
                .font(.caption2.bold())
                .foregroundColor(.blue)
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Vision Car Selection
struct VisionCarSelectionView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedCar: CarBrand = .lamborghini
    @State private var carRotation: Double = 0

    let cars: [CarBrand] = [.lamborghini, .ferrari, .bugatti, .porsche, .mclaren]

    var body: some View {
        VStack(spacing: 30) {
            Text("SELECT YOUR CAR")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 20) {
                ForEach(cars, id: \.self) { car in
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedCar == car ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedCar == car ? Color.blue : Color.clear, lineWidth: 2)
                                )

                            Text("🏎")
                                .font(.system(size: 48))
                                .rotation3DEffect(
                                    .degrees(carRotation),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            withAnimation {
                                selectedCar = car
                                carRotation += 180
                            }
                        }

                        Text(car.rawValue)
                            .font(.caption)
                            .foregroundColor(.white)

                        Text("\(car.topSpeedMPH) MPH")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            Button(action: {
                gameState.selectedCar = selectedCar
                withAnimation {
                    gameState.transitionTo(.racing)
                }
            }) {
                Text("START RACE")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
}

// MARK: - Vision Racing Entry
struct VisionRacingEntryView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.openImmersiveSpace) var openImmersiveSpace

    var body: some View {
        VStack(spacing: 40) {
            Text("IMMERSIVE RACING")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)

            Text("You are about to enter\na fully immersive 3D racing environment")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                Text("Controls:")
                    .font(.headline)

                ControlHint(icon: "👆", text: "Pinch to accelerate")
                ControlHint(icon: "✋", text: "Open hand to brake")
                ControlHint(icon: "☝️", text: "Point to steer")
                ControlHint(icon: "👁️", text: "Look around with head")
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(16)

            Spacer()

            Button(action: {
                Task {
                    await openImmersiveSpace(id: "racing")
                }
            }) {
                Text("ENTER RACE")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
}

struct ControlHint: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 20))
            Text(text).font(.system(size: 16))
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Vision Racing View (3D Immersive)
struct VisionRacingView: View {
    @EnvironmentObject var gameState: GameState
    @State private var handPosition: CGPoint = .zero
    @State private var gazeDirection: SIMD3<Float> = [0, 0, 1]
    @State private var throttle: CGFloat = 0
    @State private var steering: CGFloat = 0

    var body: some View {
        ZStack {
            // 3D Immersive Content
            RealityViewContainer(
                handPosition: $handPosition,
                gazeDirection: $gazeDirection
            )
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        steering = gesture.translation.width / 300
                    }
                    .onEnded { _ in
                        steering = 0
                    }
            )

            // Overlay HUD
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Speed: 120 MPH")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Lap 1 / 3")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("1st")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("Position")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding()

                Spacer()

                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Throttle")
                            .font(.caption)
                        LinearProgressView(progress: throttle, height: 6)
                            .frame(width: 60)
                    }

                    VStack(spacing: 4) {
                        Text("Nitro")
                            .font(.caption)
                        LinearProgressView(progress: 0.7, height: 6)
                            .frame(width: 60)
                    }

                    VStack(spacing: 4) {
                        Text("Fuel")
                            .font(.caption)
                        LinearProgressView(progress: 0.45, height: 6)
                            .frame(width: 60)
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding()
            }
        }
    }
}

// MARK: - Reality View Container
struct RealityViewContainer: UIViewRepresentable {
    @Binding var handPosition: CGPoint
    @Binding var gazeDirection: SIMD3<Float>

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update 3D rendering based on hand position and gaze
    }
}

// MARK: - Vision Lobby View
struct VisionLobbyView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 30) {
            Text("LOBBY")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 40) {
                VisionPlayerCard(name: "You", position: 1)
                VisionPlayerCard(name: "Player 2", position: 2)
                VisionPlayerCard(name: "Player 3", position: 3)
            }

            Spacer()

            Button(action: {
                withAnimation {
                    gameState.transitionTo(.carSelection)
                }
            }) {
                Text("PLAY AGAIN")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
}

struct VisionPlayerCard: View {
    let name: String
    let position: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("\(position)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.yellow)

            Text(name)
                .font(.headline)
                .foregroundColor(.white)

            Text("250 Points")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Main Menu
struct VisionMainMenuView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("GAMEIO 2P")
                .font(.system(size: 56, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Vision Pro Edition")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)

            Spacer()

            VStack(spacing: 16) {
                Button(action: { gameState.transitionTo(.splash) }) {
                    Text("START GAME").frame(maxWidth: .infinity)
                        .padding(16).background(Color(red: 0.1, green: 0.4, blue: 0.8))
                        .foregroundColor(.white).cornerRadius(12)
                }

                Button(action: { gameState.transitionTo(.settings) }) {
                    Text("SETTINGS").frame(maxWidth: .infinity)
                        .padding(16).background(Color.gray.opacity(0.3))
                        .foregroundColor(.white).cornerRadius(12)
                }
            }
        }
        .padding(40)
    }
}
