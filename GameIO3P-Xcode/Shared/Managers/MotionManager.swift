// GameIO 2P — MotionManager.swift
// CoreMotion driving detection for CarPlay safety feature
// Detects driving via accelerometer threshold, publishes isDriving state
// Supports: iPhone, iPad, Mac (via CoreMotion), Apple Watch

import Foundation
import CoreMotion
import Combine
import SwiftUI

// MARK: - MotionManager
/// Detects whether the device is in a moving vehicle using CoreMotion.
/// When acceleration exceeds threshold, isDriving publishes true → safety overlay appears.
/// When stationary for stationaryThreshold seconds → showStartButton publishes true.
@MainActor
public final class MotionManager: ObservableObject {

    // MARK: - Published State
    @Published public var isDriving: Bool = false
    @Published public var showStartButton: Bool = false
    @Published public var accelerationMagnitude: Double = 0.0
    @Published public var motionAvailable: Bool = false
    @Published public var currentSpeed: Double = 0.0  // Estimated speed in m/s
    @Published public var stationaryDuration: TimeInterval = 0.0

    // MARK: - Configuration
    /// Acceleration magnitude (m/s²) above which device is considered in a vehicle
    public var drivingThreshold: Double = 0.5

    /// Seconds stationary before START button appears
    public var stationaryThreshold: TimeInterval = 120.0  // 2 minutes

    /// How often to sample motion data (seconds)
    public var updateInterval: TimeInterval = 0.1

    // MARK: - Private State
    private let motionManager = CMMotionManager()
    private var stationaryTimer: Timer?
    private var stationaryStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    private let operationQueue = OperationQueue()

    // Smoothing window for acceleration readings
    private var recentAccelerations: [Double] = []
    private let smoothingWindowSize = 10

    // MARK: - Singleton
    public static let shared = MotionManager()

    private init() {
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        checkMotionAvailability()
    }

    // MARK: - Start / Stop
    /// Begin sampling device motion. Call this when the app foregrounds.
    public func startMonitoring() {
        guard motionManager.isAccelerometerAvailable else {
            motionAvailable = false
            // Simulator/Mac fallback: never show as driving
            isDriving = false
            showStartButton = true
            return
        }

        motionAvailable = true
        motionManager.accelerometerUpdateInterval = updateInterval

        motionManager.startAccelerometerUpdates(to: operationQueue) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            Task { @MainActor in
                self.processAccelerometer(data: data)
            }
        }

        // Also monitor device motion for more accurate readings
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = updateInterval
            motionManager.startDeviceMotionUpdates(to: operationQueue) { [weak self] motion, error in
                guard let self = self, let motion = motion, error == nil else { return }
                Task { @MainActor in
                    self.processDeviceMotion(motion: motion)
                }
            }
        }
    }

    /// Stop all motion sampling. Call this when app backgrounds or in lobby.
    public func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        stationaryTimer?.invalidate()
        stationaryTimer = nil
    }

    // MARK: - Processing
    private func processAccelerometer(data: CMAccelerometerData) {
        let x = data.acceleration.x
        let y = data.acceleration.y
        let z = data.acceleration.z

        // Remove gravity (approximate) — use magnitude deviation from 1G
        let rawMagnitude = sqrt(x*x + y*y + z*z)
        // Subtract 1G (gravity) to get linear acceleration magnitude
        let linearMag = abs(rawMagnitude - 1.0)

        // Smooth using rolling window
        recentAccelerations.append(linearMag)
        if recentAccelerations.count > smoothingWindowSize {
            recentAccelerations.removeFirst()
        }
        let smoothed = recentAccelerations.reduce(0, +) / Double(recentAccelerations.count)

        accelerationMagnitude = smoothed

        // Driving detection
        let wasDrivering = isDriving
        isDriving = smoothed > drivingThreshold

        if isDriving != wasDrivering {
            handleDrivingStateChange(isDriving: isDriving)
        }

        if !isDriving {
            updateStationaryTimer()
        } else {
            resetStationaryTimer()
        }
    }

    private func processDeviceMotion(motion: CMDeviceMotion) {
        // Use user acceleration (gravity-removed) for more accuracy
        let ua = motion.userAcceleration
        let magnitude = sqrt(ua.x*ua.x + ua.y*ua.y + ua.z*ua.z)

        // Estimate speed from acceleration (rough integration — resets on direction change)
        currentSpeed = max(0, currentSpeed + magnitude * updateInterval * 9.81)
        currentSpeed *= 0.98  // Decay factor
    }

    // MARK: - Driving State Change Handler
    private func handleDrivingStateChange(isDriving: Bool) {
        if isDriving {
            // Became driving — hide start button, reset stationary timer
            showStartButton = false
            stationaryDuration = 0
            GameState.shared.isDriving = true
            GameState.shared.showSafetyOverlay = true

            // Haptic feedback (iOS)
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            #endif
        } else {
            // Stopped driving
            GameState.shared.isDriving = false
            startStationaryCountdown()
        }
    }

    // MARK: - Stationary Timer
    private func startStationaryCountdown() {
        stationaryStartTime = Date()
        stationaryTimer?.invalidate()
        stationaryTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.updateStationaryTimer()
            }
        }
        RunLoop.main.add(stationaryTimer!, forMode: .common)
    }

    private func updateStationaryTimer() {
        guard let start = stationaryStartTime else {
            stationaryStartTime = Date()
            return
        }
        stationaryDuration = Date().timeIntervalSince(start)
        if stationaryDuration >= stationaryThreshold {
            showStartButton = true
            GameState.shared.showSafetyOverlay = false
        }
    }

    private func resetStationaryTimer() {
        stationaryTimer?.invalidate()
        stationaryTimer = nil
        stationaryStartTime = nil
        stationaryDuration = 0
        showStartButton = false
    }

    // MARK: - Manual Start (user presses START while stationary)
    /// Call this when user explicitly taps START and device is not moving
    public func userPressedStartWhileStationary() {
        guard !isDriving else { return }
        showStartButton = true
        GameState.shared.showSafetyOverlay = false
    }

    // MARK: - Availability Check
    private func checkMotionAvailability() {
        motionAvailable = motionManager.isAccelerometerAvailable
    }

    // MARK: - Debug Simulation (for Simulator/Mac)
    /// Simulates a driving event for testing purposes
    public func simulateDriving(duration: TimeInterval = 5.0) {
        isDriving = true
        GameState.shared.showSafetyOverlay = true
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.isDriving = false
            self?.startStationaryCountdown()
        }
    }

    deinit {
        stationaryTimer?.invalidate()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - SwiftUI View Extension
extension View {
    /// Attaches driving safety overlay to any view
    public func withDrivingSafetyOverlay() -> some View {
        self.overlay(DrivingSafetyOverlay())
    }
}

// MARK: - DrivingSafetyOverlay SwiftUI View
public struct DrivingSafetyOverlay: View {
    @StateObject private var motionManager = MotionManager.shared
    @StateObject private var gameState = GameState.shared
    @State private var opacity: Double = 0
    @State private var logoScale: Double = 0.8
    @State private var pulseScale: Double = 1.0

    public init() {}

    public var body: some View {
        ZStack {
            if gameState.showSafetyOverlay || motionManager.isDriving {
                safetyOverlayContent
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1.5), value: motionManager.isDriving)
            }

            if motionManager.showStartButton && !motionManager.isDriving {
                startButtonContent
                    .transition(.opacity.combined(with: .scale))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: motionManager.showStartButton)
            }
        }
    }

    // MARK: Safety Overlay
    private var safetyOverlayContent: some View {
        ZStack {
            // Blurred background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // GameIO 2P Logo
                Text("GAMEIO 2P")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "#f5a623") ?? .orange)
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            logoScale = 1.0
                        }
                    }

                // Car icon
                Image(systemName: "car.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
                    .symbolEffect(.pulse)

                // Safety message
                VStack(spacing: 12) {
                    Text("It's Unsafe to drive while playing a game.")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Text("Please stop your vehicle before playing.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Driving indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                        .scaleEffect(pulseScale)
                        .animation(.easeInOut(duration: 0.8).repeatForever(), value: pulseScale)
                    Text("Driving detected")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red.opacity(0.8))
                }
                .onAppear { pulseScale = 1.3 }
            }
            .padding(40)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) { opacity = 1 }
        }
        .onDisappear {
            withAnimation(.easeOut(duration: 1.5)) { opacity = 0 }
        }
    }

    // MARK: Start Button
    private var startButtonContent: some View {
        VStack(spacing: 24) {
            Text("GAMEIO 2P")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "#f5a623") ?? .orange)

            Button(action: {
                motionManager.userPressedStartWhileStationary()
                withAnimation(.easeInOut(duration: 0.8)) {
                    GameState.shared.transitionTo(.splash)
                }
            }) {
                Text("START")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .frame(width: 200, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: "#f5a623") ?? .orange)
                            .shadow(color: (Color(hex: "#f5a623") ?? .orange).opacity(0.6), radius: 20)
                    )
                    .scaleEffect(pulseScale)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)
            }
            .onAppear { pulseScale = 1.05 }

            Text("Vehicle stopped — safe to play!")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(radius: 30)
        )
    }
}
