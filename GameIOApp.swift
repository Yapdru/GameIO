import SwiftUI
import CoreMotion

@main
struct GameIOApp: App {
    @StateObject private var motionManager = MotionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(motionManager)
        }
    }
}

// Detects if the device is in a moving vehicle using the accelerometer
class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    @Published var isDriving = false
    @Published var speed: Double = 0

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        guard manager.isAccelerometerAvailable else { return }
        manager.accelerometerUpdateInterval = 0.5
        manager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let data = data else { return }
            let magnitude = sqrt(
                pow(data.acceleration.x, 2) +
                pow(data.acceleration.y, 2) +
                pow(data.acceleration.z, 2)
            )
            // Sustained acceleration above threshold indicates driving
            let movementLevel = abs(magnitude - 1.0) // subtract gravity
            self?.speed = movementLevel
            self?.isDriving = movementLevel > 0.08
        }
    }

    deinit {
        manager.stopAccelerometerUpdates()
    }
}
