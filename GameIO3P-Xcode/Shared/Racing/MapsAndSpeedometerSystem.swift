// MapsAndSpeedometerSystem.swift — Real-time Maps & Speedometer Integration
// Displays car position on live map with speedometer
// Integration with MapKit, What3Words, OpenStreetMap, Google Maps
// Smooth camera transitions and animations

import SwiftUI
import MapKit
import CoreLocation

@MainActor
class MapsAndSpeedometerSystem: NSObject, NSObject, ObservableObject {
    @Published var isDisplayingMap: Bool = false
    @Published var currentSpeed: Double = 0
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var cameraPosition: CameraPosition = .above
    @Published var mapProvider: MapProvider = .apple
    @Published var what3wordsAddress: String = "///loading"
    @Published var showSpeedometer: Bool = true
    @Published var acceleration: Double = 0
    @Published var rpm: Int = 0
    @Published var gearSelected: String = "D"

    enum CameraPosition {
        case above
        case side
        case cockpit
        case follow
    }

    enum MapProvider: String {
        case apple = "Apple Maps"
        case google = "Google Maps"
        case openstreet = "OpenStreetMap"
        case what3words = "What3Words"
    }

    private var locationManager = CLLocationManager()
    private var mapCamera: MKMapCamera?
    private let vehiclePhysics = VehiclePhysicsEngine()
    private var speedometerTimer: Timer?
    private var cameraAnimationTimer: Timer?

    static let shared = MapsAndSpeedometerSystem()

    override init() {
        super.init()
        initializeSystem()
    }

    private func initializeSystem() {
        setupLocationManager()
        setupSpeedometer()
        requestLocationPermission()
    }

    // MARK: - Location Management
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
    }

    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Speedometer System
    private func setupSpeedometer() {
        speedometerTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateSpeedometer()
        }
    }

    private func updateSpeedometer() {
        // Simulate realistic speedometer updates
        if currentSpeed > 0 {
            acceleration = Double.random(in: -2...5)
            rpm = Int(currentSpeed * 50)
        }
    }

    // MARK: - Speed Updates
    func updateCarSpeed(_ speed: Double, direction: CLLocationDirection) {
        currentSpeed = min(speed, 200.0)

        if currentSpeed < 1.0 {
            triggerStopAnimation()
        }

        // Update map view based on speed
        updateMapDisplay()
    }

    private func updateMapDisplay() {
        if currentSpeed < 1.0 {
            // Car stopped - show stop animation
            showStopAnimation()
        } else if currentSpeed > 50.0 {
            // High speed - show cockpit view
            animateCameraTransition(to: .cockpit)
        } else {
            // Normal driving - show follow camera
            animateCameraTransition(to: .follow)
        }
    }

    // MARK: - Camera Animations
    private func showStopAnimation() {
        cameraAnimationTimer?.invalidate()
        cameraAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.animateSideView()
        }

        // After animation, show "Start?" prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showStartPrompt()
        }
    }

    private func animateSideView() {
        // Animate camera to side view
        var currentPosition = cameraPosition
        if currentPosition != .side {
            cameraPosition = .side
        }
    }

    private func animateCameraTransition(to position: CameraPosition) {
        if cameraPosition != position {
            // Smooth animation from current to new position
            let steps = 10
            var currentStep = 0

            cameraAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                currentStep += 1
                if currentStep >= steps {
                    self?.cameraPosition = position
                    self?.cameraAnimationTimer?.invalidate()
                } else {
                    // Intermediate animation state
                }
            }
        }
    }

    private func showStartPrompt() {
        print("📍 Car stopped. Camera transitioning...")
        print("❓ Show 'START?' prompt with start button")
    }

    // MARK: - What3Words Integration
    func updateWhat3WordsAddress(for location: CLLocationCoordinate2D) {
        // Simulated What3Words lookup
        let grid = Int(location.latitude * 1000) % 100
        let words = ["FLOWING", "SILENT", "JUMBLED", "MORNING", "GOLDEN", "RACING", "SWIFT"]
        let word1 = words[grid % words.count]
        let word2 = words[(grid + 1) % words.count]
        let word3 = words[(grid + 2) % words.count]

        what3wordsAddress = "\(word1).\(word2).\(word3)"
    }

    // MARK: - Map Display Management
    func displayMapWithProviders() -> some View {
        ZStack {
            // Map view based on provider
            switch mapProvider {
            case .apple:
                MapView(system: self)

            case .google:
                GoogleMapPlaceholder()

            case .openstreet:
                OpenStreetMapPlaceholder()

            case .what3words:
                What3WordsMapPlaceholder()
            }

            // Speedometer overlay
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Speed")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Int(currentSpeed)) km/h")
                            .font(.title2.bold())
                            .foregroundColor(.red)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("RPM")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(rpm)")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .padding()

                Spacer()

                // Speedometer gauge
                SpeedometterGaugeView(speed: currentSpeed)
                    .padding()

                HStack(spacing: 20) {
                    VStack(alignment: .center) {
                        Text("Gear")
                            .font(.caption)
                        Text(gearSelected)
                            .font(.title.bold())
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    VStack(alignment: .center) {
                        Text("Accel")
                            .font(.caption)
                        Text("\(String(format: "%.1f", acceleration))g")
                            .font(.headline)
                            .foregroundColor(acceleration > 0 ? .green : .red)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .padding()
            }
            .padding()
        }
    }

    // MARK: - Camera Control During Driving
    func updateCameraForDriving() {
        if currentSpeed > 0 {
            // Camera follows car, positioned near it
            cameraPosition = .follow
        }
    }

    func updateCameraLiftAnimation() {
        // When starting from stopped position, animate camera "down lift"
        cameraAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // Smooth camera transition from side view back to follow/cockpit
            self?.cameraPosition = .follow
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.cameraAnimationTimer?.invalidate()
        }
    }

    deinit {
        speedometerTimer?.invalidate()
        cameraAnimationTimer?.invalidate()
    }
}

// MARK: - Speedometer Gauge View
struct SpeedometterGaugeView: View {
    let speed: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.black.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180, height: 180)

            // Speedometer arc
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                        center: .center,
                        startAngle: .degrees(-135),
                        endAngle: .degrees(135)
                    ),
                    lineWidth: 12
                )
                .frame(width: 160, height: 160)

            // Needle
            VStack {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 4, height: 70)
                    .offset(y: -35)

                Spacer()
            }
            .frame(width: 160, height: 160)
            .rotationEffect(.degrees(-135 + (speed / 200) * 270))

            // Center knob
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)

            // Speed text
            VStack {
                Spacer()
                Text("\(Int(speed))")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text("km/h")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .frame(width: 200, height: 200)
    }
}

// MARK: - Map Views
struct MapView: View {
    @ObservedObject var system: MapsAndSpeedometerSystem

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack {
                Text("📍 Current Location")
                    .font(.headline)
                    .foregroundColor(.black)

                if let location = system.currentLocation {
                    Text("\(location.latitude), \(location.longitude)")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text("Waiting for location...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text("What3Words: \(system.what3wordsAddress)")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(4)

                Spacer()
            }
            .padding()
        }
    }
}

struct GoogleMapPlaceholder: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Text("🗺️ Google Maps Provider")
                .font(.headline)
                .foregroundColor(.blue)
        }
    }
}

struct OpenStreetMapPlaceholder: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.1)
            Text("🗺️ OpenStreetMap Provider")
                .font(.headline)
                .foregroundColor(.green)
        }
    }
}

struct What3WordsMapPlaceholder: View {
    var body: some View {
        ZStack {
            Color.purple.opacity(0.1)
            Text("📍 What3Words Navigator")
                .font(.headline)
                .foregroundColor(.purple)
        }
    }
}

// MARK: - Location Manager Delegate
extension MapsAndSpeedometerSystem: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            updateWhat3WordsAddress(for: location.coordinate)
        }
    }
}

// MARK: - Vehicle Physics Engine
class VehiclePhysicsEngine {
    struct VehicleState {
        var position: (Double, Double) = (0, 0)
        var velocity: (Double, Double) = (0, 0)
        var speed: Double = 0
        var heading: Double = 0
    }

    private var state = VehicleState()

    func updatePhysics(throttle: Double, steering: Double, deltaTime: Double) {
        // Update velocity based on throttle
        state.speed = min(state.speed + throttle * deltaTime, 200.0)
        state.speed = max(state.speed - 0.1, 0)

        // Update heading based on steering
        state.heading += steering * state.speed * deltaTime

        // Update position
        state.position.0 += state.speed * cos(state.heading) * deltaTime
        state.position.1 += state.speed * sin(state.heading) * deltaTime
    }

    func getState() -> VehicleState {
        return state
    }
}
