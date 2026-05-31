// GameIO 2P — CarPlaySceneDelegate.swift
// CarPlay integration with driving safety detection
// Uses CPTemplateApplicationSceneDelegate to show safety information
// when driving is detected via CoreMotion

import CarPlay
import CoreMotion
import UIKit
import Combine

// MARK: - CarPlay Scene Delegate
public class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    // MARK: - Properties
    private var interfaceController: CPInterfaceController?
    private let motionManager = CMMotionManager()
    private var drivingTimer: Timer?
    private var stationaryTimer: Timer?
    private var isDriving: Bool = false
    private var stationarySeconds: Int = 0

    // Driving threshold (m/s²)
    private let drivingThreshold: Double = 0.5
    private let stationaryGoalSeconds: Int = 120  // 2 minutes

    // Current CarPlay templates
    private var safetyTemplate: CPInformationTemplate?
    private var dashboardTemplate: CPInformationTemplate?
    private var startTemplate: CPInformationTemplate?

    // MARK: - CPTemplateApplicationSceneDelegate
    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        setupInitialTemplate()
        startMotionMonitoring()
    }

    public func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        stopMotionMonitoring()
        self.interfaceController = nil
    }

    // MARK: - Initial Template Setup
    private func setupInitialTemplate() {
        // Start with driving safety check template
        let template = buildSafetyTemplate(isDriving: false)
        safetyTemplate = template
        interfaceController?.setRootTemplate(template, animated: false, completion: nil)
    }

    // MARK: - Template Builders
    private func buildSafetyTemplate(isDriving: Bool) -> CPInformationTemplate {
        var items: [CPInformationItem] = []
        var actions: [CPTextButton] = []

        if isDriving {
            items = [
                CPInformationItem(
                    title: "🚗 Driving Detected",
                    detail: "It's unsafe to play while driving."
                ),
                CPInformationItem(
                    title: "Safety First",
                    detail: "Please stop your vehicle before playing GameIO 2P."
                ),
                CPInformationItem(
                    title: "GameIO 2P",
                    detail: "Your game will be ready when you stop."
                )
            ]
        } else {
            items = [
                CPInformationItem(
                    title: "✅ Vehicle Stopped",
                    detail: "Safe to play GameIO 2P!"
                ),
                CPInformationItem(
                    title: "GameIO 2P",
                    detail: "Press Start to begin your game."
                )
            ]

            let startButton = CPTextButton(
                title: "START GAME",
                textStyle: .confirm
            ) { [weak self] _ in
                self?.handleStartPressed()
            }
            actions = [startButton]
        }

        return CPInformationTemplate(
            title: "GAMEIO 2P",
            layout: .leading,
            items: items,
            actions: actions
        )
    }

    private func buildDashboardTemplate() -> CPInformationTemplate {
        let gameState = GameState.shared

        let items: [CPInformationItem] = [
            CPInformationItem(title: "Player", detail: gameState.playerName),
            CPInformationItem(title: "Car",    detail: gameState.selectedCar.rawValue),
            CPInformationItem(title: "Score",  detail: gameState.displayScore),
            CPInformationItem(title: "Wins",   detail: "\(gameState.totalWins)")
        ]

        return CPInformationTemplate(
            title: "GAMEIO 2P",
            layout: .twoColumn,
            items: items,
            actions: []
        )
    }

    // MARK: - Start Handler
    private func handleStartPressed() {
        // Transition to dashboard and notify app
        let dashboard = buildDashboardTemplate()
        dashboardTemplate = dashboard
        interfaceController?.pushTemplate(dashboard, animated: true, completion: nil)

        // Notify main app to start game
        NotificationCenter.default.post(name: .carPlayStartPressed, object: nil)
        DispatchQueue.main.async {
            GameState.shared.transitionTo(.splash)
        }
    }

    // MARK: - Motion Monitoring
    private func startMotionMonitoring() {
        guard motionManager.isAccelerometerAvailable else {
            // Simulator: assume stopped
            handleDrivingStateChange(driving: false)
            return
        }

        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(
            to: OperationQueue()
        ) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let magnitude = abs(sqrt(x*x + y*y + z*z) - 1.0)
            DispatchQueue.main.async {
                self.processAcceleration(magnitude: magnitude)
            }
        }
    }

    private func stopMotionMonitoring() {
        motionManager.stopAccelerometerUpdates()
        drivingTimer?.invalidate()
        stationaryTimer?.invalidate()
    }

    private func processAcceleration(magnitude: Double) {
        let newDriving = magnitude > drivingThreshold
        if newDriving != isDriving {
            handleDrivingStateChange(driving: newDriving)
        }
    }

    private func handleDrivingStateChange(driving: Bool) {
        isDriving = driving

        if driving {
            // Show safety warning
            stationaryTimer?.invalidate()
            stationarySeconds = 0
            let template = buildSafetyTemplate(isDriving: true)
            safetyTemplate = template
            interfaceController?.setRootTemplate(template, animated: true, completion: nil)
        } else {
            // Start countdown to show START button
            startStationaryCountdown()
        }

        // Notify main app
        DispatchQueue.main.async {
            GameState.shared.isDriving = driving
            GameState.shared.showSafetyOverlay = driving
        }
    }

    private func startStationaryCountdown() {
        stationarySeconds = 0
        stationaryTimer?.invalidate()

        // Show "stopped" template immediately
        let template = buildSafetyTemplate(isDriving: false)
        safetyTemplate = template
        interfaceController?.setRootTemplate(template, animated: true, completion: nil)

        stationaryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.stationarySeconds += 1
            if self.stationarySeconds >= self.stationaryGoalSeconds {
                self.stationaryTimer?.invalidate()
                // Already showing start button in template
            }
        }
    }
}

// MARK: - GameState CarPlay Extension
extension GameState {
    var displayScore: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let carPlayStartPressed = Notification.Name("GameIO3P.carPlayStartPressed")
    static let carPlayConnected    = Notification.Name("GameIO3P.carPlayConnected")
    static let carPlayDisconnected = Notification.Name("GameIO3P.carPlayDisconnected")
}
