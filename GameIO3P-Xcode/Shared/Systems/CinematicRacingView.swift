// CinematicRacingView.swift — 3D Racing with Cinematic Storytelling
// Full 3D track, elevation changes, weather effects, dynamic lighting, cinematic cameras

import SwiftUI
import SceneKit

struct CinematicRacingView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject private var environment = CinematicEnvironment.shared
    @State private var position: Int = 1
    @State private var speed: Float = 0
    @State private var rpmValue: Float = 0
    @State private var fuel: Float = 80
    @State private var nitro: Float = 100
    @State private var lap: Int = 1
    @State private var lapTime: String = "02:34"
    @State private var cameraMode: CameraMode = .cinematic

    enum CameraMode {
        case cinematic, cockpit, thirdPerson, freefly
    }

    var body: some View {
        ZStack {
            // 3D Scene
            CinematicSceneView(environment: environment, cameraMode: cameraMode)
                .ignoresSafeArea()

            // Cinematic HUD with depth
            VStack {
                // Top bar - Race info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("LAP \(lap) / 3")
                            .font(.headline.bold())
                            .foregroundColor(.yellow)
                        Text(lapTime)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("P\(position)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("POSITION")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(8)
                .padding()

                Spacer()

                // Bottom HUD - Vehicle data
                HStack(spacing: 16) {
                    // Speedometer
                    VStack(spacing: 4) {
                        GaugeView(
                            value: Double(speed / 200.0),
                            label: "SPEED",
                            unit: "MPH",
                            color: .yellow
                        )
                        .frame(width: 80, height: 80)
                    }

                    VStack(spacing: 8) {
                        // RPM gauge
                        VStack(spacing: 2) {
                            Text("RPM")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                            LinearProgressView(progress: Double(rpmValue / 8000), height: 4)
                                .frame(width: 80)
                            Text("\(Int(rpmValue))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        // Fuel gauge
                        VStack(spacing: 2) {
                            Text("FUEL")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                            LinearProgressView(progress: Double(fuel / 100), height: 4)
                                .frame(width: 80)
                            Text("\(Int(fuel))%")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }

                    VStack(spacing: 8) {
                        // Nitro boost
                        VStack(spacing: 2) {
                            Text("NITRO")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                            LinearProgressView(progress: Double(nitro / 100), height: 4)
                                .frame(width: 80)
                            Text("\(Int(nitro))%")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }

                        // Temperature
                        VStack(spacing: 2) {
                            Text("TEMP")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                            LinearProgressView(progress: 0.65, height: 4)
                                .frame(width: 80)
                            Text("65°C")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8)
                .padding()

                // Camera mode selector
                HStack(spacing: 8) {
                    ForEach([CameraMode.cinematic, .cockpit, .thirdPerson, .freefly], id: \.self) { mode in
                        Button(action: { cameraMode = mode }) {
                            Text(modeLabel(mode))
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(8)
                                .background(cameraMode == mode ? Color(red: 0.1, green: 0.4, blue: 0.8) : Color.gray.opacity(0.3))
                                .cornerRadius(6)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
        }
        .onAppear {
            environment.loadScene(.urbanStreet)
            startRaceSimulation()
        }
    }

    private func modeLabel(_ mode: CameraMode) -> String {
        switch mode {
        case .cinematic: return "Cinema"
        case .cockpit: return "Cockpit"
        case .thirdPerson: return "3P"
        case .freefly: return "Free"
        }
    }

    private func startRaceSimulation() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            speed = min(220, speed + Float.random(in: -2...5))
            rpmValue = speed * 36.36
            fuel = max(0, fuel - Float.random(in: 0.01...0.05))
            nitro = min(100, nitro + Float.random(in: -0.5...1.5))

            if fuel <= 0 {
                gameState.transitionTo(.lobby)
            }
        }
    }
}

// MARK: - 3D Scene View
struct CinematicSceneView: UIViewRepresentable {
    let environment: CinematicEnvironment
    let cameraMode: CinematicRacingView.CameraMode

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = UIColor(red: 0.1, green: 0.15, blue: 0.2, alpha: 1.0)
        sceneView.allowsCameraControl = true
        sceneView.antialiasingMode = .multisampling4X
        sceneView.preferredFramesPerSecond = 60

        let scene = SCNScene()

        // Road with elevation
        let roadSegments = 50
        for i in 0..<roadSegments {
            let roadSegment = SCNPlane(width: 120, height: 100)
            roadSegment.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
            let segmentNode = SCNNode(geometry: roadSegment)
            segmentNode.eulerAngles.x = -CGFloat.pi / 2
            segmentNode.position = SCNVector3(0, CGFloat(sin(Float(i) * 0.1)) * 20, CGFloat(i * 100 - 2500))

            // Road markings every segment
            if i % 3 == 0 {
                let marking = SCNPlane(width: 2, height: 80)
                marking.firstMaterial?.diffuse.contents = UIColor.white
                let markingNode = SCNNode(geometry: marking)
                markingNode.eulerAngles.x = -CGFloat.pi / 2
                markingNode.position = SCNVector3(0, 0.1, CGFloat(i * 100 - 2500))
                segmentNode.addChildNode(markingNode)
            }

            scene.rootNode.addChildNode(segmentNode)
        }

        // Sky dome
        let skyGeometry = SCNSphere(radius: 5000)
        skyGeometry.firstMaterial?.diffuse.contents = UIColor(red: 0.5, green: 0.7, blue: 0.95, alpha: 1.0)
        skyGeometry.firstMaterial?.isDoubleSided = true
        let skyNode = SCNNode(geometry: skyGeometry)
        scene.rootNode.addChildNode(skyNode)

        // Dynamic lighting
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)

        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 1000
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.eulerAngles = SCNVector3(-CGFloat.pi / 4, CGFloat.pi / 6, 0)
        scene.rootNode.addChildNode(directionalNode)

        // Camera setup
        let camera = SCNCamera()
        camera.zFar = 10000
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 50, -200)
        scene.rootNode.addChildNode(cameraNode)

        sceneView.scene = scene
        sceneView.pointOfView = cameraNode

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update camera based on mode
        guard let cameraNode = uiView.pointOfView else { return }

        switch cameraMode {
        case .cinematic:
            cameraNode.position = SCNVector3(0, 50, -150)
            cameraNode.eulerAngles = SCNVector3(-0.3, 0, 0)
        case .cockpit:
            cameraNode.position = SCNVector3(0, 15, 30)
            cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        case .thirdPerson:
            cameraNode.position = SCNVector3(40, 30, -80)
            cameraNode.eulerAngles = SCNVector3(-0.2, 0.5, 0)
        case .freefly:
            cameraNode.position = SCNVector3(100, 100, -300)
            cameraNode.eulerAngles = SCNVector3(-0.4, 1.2, 0)
        }
    }
}

// MARK: - Gauge View
struct GaugeView: View {
    let value: Double
    let label: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: value)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int(value * 200))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            Text(label)
                .font(.caption.bold())
                .foregroundColor(.white)
        }
    }
}
