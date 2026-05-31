// AirPodsManager.swift — AirPods Pro & 4 spatial audio and gesture support
// Adaptive audio, 3D spatial rendering, head tracking, double tap controls

import Foundation
import AVFoundation
import CoreMotion
import MediaPlayer

@MainActor
class AirPodsManager: NSObject, ObservableObject {
    @Published var isAirPodsConnected: Bool = false
    @Published var airPodsModel: String = "Unknown"
    @Published var batteryLevel: Int = 0
    @Published var spatialAudioEnabled: Bool = false
    @Published var adaptiveAudioEnabled: Bool = false
    @Published var noiseControlMode: NoiseControlMode = .off
    @Published var headPosition: HeadPosition = .center
    @Published var lastGestureDetected: AirPodsGesture?

    enum AirPodsGesture: String, Equatable {
        case doubleTapLeft
        case doubleTapRight
        case tripleTapLeft
        case tripleTapRight
        case longPressLeft
        case longPressRight
    }

    enum NoiseControlMode: String {
        case off
        case noiseCancellation
        case transparency
        case adaptiveAudio
    }

    struct HeadPosition {
        var yaw: Double = 0
        var pitch: Double = 0
        var roll: Double = 0

        static let center = HeadPosition(yaw: 0, pitch: 0, roll: 0)
    }

    private let motionManager = CMMotionManager()
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioEngine: AVAudioEngine?
    private var spatialMixer: AVAudioMixing?

    static let shared = AirPodsManager()

    override init() {
        super.init()
        setupAudioSession()
        setupHeadTracking()
        detectAirPods()
    }

    private func setupAudioSession() {
        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [.duckOthers, .defaultToSpeaker]
            )
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func setupHeadTracking() {
        guard CMHeadphoneMotionManager.isDeviceMotionAvailable() else {
            print("Head tracking not available on this device")
            return
        }

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion, error == nil else { return }

            let attitude = motion.attitude
            self?.updateHeadPosition(
                yaw: attitude.yaw,
                pitch: attitude.pitch,
                roll: attitude.roll
            )
        }
    }

    private func detectAirPods() {
        checkAirPodsConnection()

        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkAirPodsConnection()
        }
    }

    private func checkAirPodsConnection() {
        let route = audioSession.currentRoute
        for output in route.outputs {
            if output.portType == .airPods || output.portType == .airPodsMax {
                isAirPodsConnected = true
                determineAirPodsModel(output.name)
                getBatteryLevel(output.name)
                enableSpatialAudio()
                return
            }
        }
        isAirPodsConnected = false
    }

    private func determineAirPodsModel(_ outputName: String) {
        if outputName.contains("Max") {
            airPodsModel = "AirPods Max"
        } else if outputName.contains("Pro") {
            airPodsModel = "AirPods Pro 4"
        } else if outputName.contains("4") {
            airPodsModel = "AirPods 4"
        } else {
            airPodsModel = "AirPods"
        }
    }

    private func getBatteryLevel(_ outputName: String) {
        let batteryMonitor = UIDevice.current
        if batteryMonitor.isBatteryMonitoringEnabled {
            batteryLevel = Int(batteryMonitor.batteryLevel * 100)
        }
    }

    private func enableSpatialAudio() {
        guard isAirPodsConnected else { return }

        if #available(iOS 15.0, *) {
            spatialAudioEnabled = true

            let audioEngine = AVAudioEngine()
            let mixer = audioEngine.mainMixerNode

            if #available(iOS 17.0, *) {
                if let renderer = mixer as? AVAudioEnvironmentNode {
                    renderer.reverbPreset = .mediumRoom
                }
            }

            self.audioEngine = audioEngine

            do {
                try audioEngine.start()
            } catch {
                print("Failed to start audio engine: \(error)")
            }
        }
    }

    private func updateHeadPosition(yaw: Double, pitch: Double, roll: Double) {
        headPosition = HeadPosition(yaw: yaw, pitch: pitch, roll: roll)
        updateSpatialAudioRendering()
    }

    private func updateSpatialAudioRendering() {
        guard spatialAudioEnabled, let audioEngine = audioEngine else { return }

        if #available(iOS 17.0, *) {
            let listenerPosition = simd_float3(
                Float(sin(headPosition.yaw)) * 5,
                Float(sin(headPosition.pitch)),
                Float(cos(headPosition.yaw)) * 5
            )

            if let renderer = audioEngine.mainMixerNode as? AVAudio3DMixing {
                renderer.position = listenerPosition
            }
        }
    }

    func setupGestureDetection() {
        setupDoubleTabDetection()
        setupLongPressDetection()
    }

    private func setupDoubleTabDetection() {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()

        remoteCommandCenter.playCommand.addTarget { [weak self] _ in
            self?.handleGesture(.doubleTapLeft)
            return .success
        }

        remoteCommandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.handleGesture(.doubleTapRight)
            return .success
        }

        remoteCommandCenter.skipForwardCommand.preferredIntervals = [15]
        remoteCommandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.handleGesture(.tripleTapRight)
            return .success
        }

        remoteCommandCenter.skipBackwardCommand.preferredIntervals = [15]
        remoteCommandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.handleGesture(.tripleTapLeft)
            return .success
        }
    }

    private func setupLongPressDetection() {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()

        remoteCommandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.handleGesture(.longPressLeft)
            return .success
        }
    }

    private func handleGesture(_ gesture: AirPodsGesture) {
        lastGestureDetected = gesture

        DispatchQueue.main.async {
            self.processGesture(gesture)
        }
    }

    private func processGesture(_ gesture: AirPodsGesture) {
        switch gesture {
        case .doubleTapLeft:
            accelerateVehicle()
        case .doubleTapRight:
            brakeSmoothly()
        case .tripleTapLeft:
            activateNitro()
        case .tripleTapRight:
            changeLane()
        case .longPressLeft:
            togglePause()
        case .longPressRight:
            openMenu()
        }
    }

    // Game Control Methods
    private func accelerateVehicle() {
        NotificationCenter.default.post(name: NSNotification.Name("AirPodsAccelerate"), object: nil)
    }

    private func brakeSmoothly() {
        NotificationCenter.default.post(name: NSNotification.Name("AirPodsBrake"), object: nil)
    }

    private func activateNitro() {
        NotificationCenter.default.post(name: NSNotification.Name("AirPodsNitro"), object: nil)
    }

    private func changeLane() {
        NotificationCenter.default.post(name: NSNotification.Name("AirPodsChangeLane"), object: nil)
    }

    private func togglePause() {
        NotificationCenter.default.post(name: NSNotification.Name("AirPodsPause"), object: nil)
    }

    private func openMenu() {
        NotificationCenter.default.post(name: NSNotification.Name("AirPodsMenu"), object: nil)
    }

    func setNoiseControl(_ mode: NoiseControlMode) {
        noiseControlMode = mode

        let isActive = mode != .off
        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: isActive ? .default : .measurement,
                options: isActive ? [] : [.duckOthers]
            )
        } catch {
            print("Failed to set noise control: \(error)")
        }
    }

    func playSpatialAudio(
        file: String,
        position: simd_float3,
        distance: Float = 1.0
    ) {
        guard spatialAudioEnabled, let audioEngine = audioEngine else { return }

        do {
            let audioFile = try AVAudioFile(forReading: URL(fileURLWithPath: file))
            let playerNode = AVAudioPlayerNode()

            audioEngine.attach(playerNode)
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)

            if #available(iOS 17.0, *) {
                if let mixer = playerNode as? AVAudio3DMixing {
                    mixer.position = position
                    mixer.distance = distance
                }
            }

            try audioEngine.start()
            playerNode.play()
            playerNode.scheduleFile(audioFile, at: nil)
        } catch {
            print("Failed to play spatial audio: \(error)")
        }
    }

    func enableAdaptiveAudio(_ enable: Bool) {
        adaptiveAudioEnabled = enable

        if enable {
            setNoiseControl(.adaptiveAudio)
        } else {
            setNoiseControl(.off)
        }
    }

    func getAirPodsInfo() -> String {
        """
        AirPods Information:
        - Connected: \(isAirPodsConnected)
        - Model: \(airPodsModel)
        - Battery: \(batteryLevel)%
        - Spatial Audio: \(spatialAudioEnabled)
        - Adaptive Audio: \(adaptiveAudioEnabled)
        - Noise Control: \(noiseControlMode.rawValue)
        """
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Notification Extensions
extension NSNotification.Name {
    static let airPodsAccelerate = NSNotification.Name("AirPodsAccelerate")
    static let airPodsBrake = NSNotification.Name("AirPodsBrake")
    static let airPodsNitro = NSNotification.Name("AirPodsNitro")
    static let airPodsChangeLane = NSNotification.Name("AirPodsChangeLane")
    static let airPodsPause = NSNotification.Name("AirPodsPause")
    static let airPodsMenu = NSNotification.Name("AirPodsMenu")
}
