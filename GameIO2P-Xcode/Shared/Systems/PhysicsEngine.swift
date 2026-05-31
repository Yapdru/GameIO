// PhysicsEngine.swift — Advanced physics simulation for racing games
// Friction, acceleration, drag, tire grip, suspension, weight transfer, collision detection

import Foundation
import CoreGraphics

// MARK: - Physics Constants
struct PhysicsConstants {
    static let gravity: CGFloat = 9.81
    static let airDensity: CGFloat = 1.225
    static let groundFriction: CGFloat = 0.85
    static let rollingResistance: CGFloat = 0.015
    static let maxSpeedLimiter: CGFloat = 300
    static let tireGripMultiplier: CGFloat = 1.2
    static let suspensionStiffness: CGFloat = 5000
    static let dampingCoefficient: CGFloat = 100
    static let transferRate: CGFloat = 0.08
}

// MARK: - Tire Model
struct TireModel {
    var grip: CGFloat = 1.0
    var temperature: CGFloat = 20.0
    var wear: CGFloat = 1.0
    var pressure: CGFloat = 1.0
    var slipAngle: CGFloat = 0
    var slipRatio: CGFloat = 0
    var lateralForce: CGFloat = 0
    var longitudinalForce: CGFloat = 0

    var optimalTemperature: CGFloat { 80.0 }
    var criticalTemperature: CGFloat { 120.0 }
    var peakGrip: CGFloat { 1.3 }

    mutating func updateTemperature(friction: CGFloat, deltaTime: CGFloat) {
        let heatGeneration = friction * 5.0
        let cooling = (temperature - 20.0) * 0.02
        temperature += (heatGeneration - cooling) * deltaTime
        temperature = min(max(temperature, 20), 150)

        grip = calculateGrip()
    }

    private func calculateGrip() -> CGFloat {
        let tempFactor = 1.0 - pow(abs(temperature - optimalTemperature) / 40.0, 2)
        let wearFactor = 0.5 + (wear * 0.5)
        let pressureFactor = 0.8 + (pressure * 0.2)
        return peakGrip * tempFactor * wearFactor * pressureFactor
    }

    mutating func addWear(stress: CGFloat) {
        wear = max(0, wear - stress * 0.0001)
    }
}

// MARK: - Vehicle Properties
struct VehicleProperties {
    var mass: CGFloat
    var dragCoefficient: CGFloat
    var frontalArea: CGFloat
    var wheelbase: CGFloat
    var trackWidth: CGFloat
    var centerOfGravityHeight: CGFloat
    var enginePower: CGFloat
    var engineTorque: CGFloat
    var maxRPM: Int
    var gearRatio: [CGFloat]
    var brakePower: CGFloat
    var suspensionTravel: CGFloat

    static let lamborghini = VehicleProperties(
        mass: 1575,
        dragCoefficient: 0.27,
        frontalArea: 2.2,
        wheelbase: 2.7,
        trackWidth: 1.64,
        centerOfGravityHeight: 0.48,
        enginePower: 630000,
        engineTorque: 600,
        maxRPM: 8250,
        gearRatio: [3.5, 2.1, 1.5, 1.15, 0.95, 0.80],
        brakePower: 1500,
        suspensionTravel: 0.08
    )

    static let ferrari = VehicleProperties(
        mass: 1380,
        dragCoefficient: 0.33,
        frontalArea: 2.3,
        wheelbase: 2.65,
        trackWidth: 1.60,
        centerOfGravityHeight: 0.46,
        enginePower: 660000,
        engineTorque: 560,
        maxRPM: 9000,
        gearRatio: [3.5, 2.3, 1.6, 1.25, 1.0, 0.82],
        brakePower: 1450,
        suspensionTravel: 0.07
    )

    static let bugatti = VehicleProperties(
        mass: 1888,
        dragCoefficient: 0.356,
        frontalArea: 2.5,
        wheelbase: 2.72,
        trackWidth: 1.66,
        centerOfGravityHeight: 0.52,
        enginePower: 1479000,
        engineTorque: 1106,
        maxRPM: 6600,
        gearRatio: [3.4, 2.0, 1.45, 1.15, 0.9, 0.65, 0.5],
        brakePower: 2000,
        suspensionTravel: 0.10
    )
}

// MARK: - Suspension System
struct SuspensionSystem {
    var compression: CGFloat = 0
    var velocity: CGFloat = 0
    var force: CGFloat = 0
    let stiffness: CGFloat
    let damping: CGFloat
    let maxTravel: CGFloat

    init(stiffness: CGFloat, damping: CGFloat, maxTravel: CGFloat) {
        self.stiffness = stiffness
        self.damping = damping
        self.maxTravel = maxTravel
    }

    mutating func update(load: CGFloat, deltaTime: CGFloat) {
        let springForce = -stiffness * compression
        let dampingForce = -damping * velocity
        force = springForce + dampingForce

        let acceleration = (load + force) / 1000.0
        velocity += acceleration * deltaTime
        compression += velocity * deltaTime
        compression = min(max(compression, 0), maxTravel)
    }
}

// MARK: - Aerodynamic Effects
struct AerodynamicModel {
    var yawAngle: CGFloat = 0
    var dragForce: CGFloat = 0
    var downforce: CGFloat = 0
    var sideForcce: CGFloat = 0
    var liftCoefficient: CGFloat = -0.3
    var wingSpoilerAngle: CGFloat = 0

    mutating func calculateForces(velocity: CGFloat, properties: VehicleProperties) {
        let velocity2 = velocity * velocity
        let dynamicPressure = 0.5 * PhysicsConstants.airDensity * velocity2 * properties.frontalArea

        dragForce = properties.dragCoefficient * dynamicPressure
        downforce = abs(liftCoefficient) * dynamicPressure * properties.frontalArea

        sideForcce = sin(yawAngle) * dragForce * 0.3
    }

    mutating func adjustWing(angle: CGFloat) {
        wingSpoilerAngle = min(max(angle, 0), 45)
        liftCoefficient = -0.3 - (wingSpoilerAngle / 150.0)
    }
}

// MARK: - Powertrain System
struct PowertrainSystem {
    var rpm: Int = 800
    var currentGear: Int = 0
    var throttlePosition: CGFloat = 0
    var clutchPosition: CGFloat = 1.0
    var wheelSlip: CGFloat = 0
    let properties: VehicleProperties

    var engineBrake: CGFloat {
        CGFloat(rpm) / CGFloat(properties.maxRPM) * 200
    }

    var availableTorque: CGFloat {
        let rpmRatio = CGFloat(rpm) / CGFloat(properties.maxRPM)
        let torqueCurve = sin(rpmRatio * CGFloat.pi / 2) * properties.engineTorque
        return torqueCurve * throttlePosition * (1.0 - wheelSlip)
    }

    mutating func updateRPM(wheelSpeed: CGFloat, deltaTime: CGFloat) {
        let targetRPM = wheelSpeed * properties.gearRatio[currentGear] * 60.0
        let rpmDifference = targetRPM - CGFloat(rpm)
        let rpmChange = rpmDifference * 0.1 * deltaTime
        rpm = Int(CGFloat(rpm) + rpmChange)
        rpm = min(max(rpm, 800), properties.maxRPM)
    }

    mutating func shiftGear(to newGear: Int) {
        guard newGear >= 0, newGear < properties.gearRatio.count else { return }
        currentGear = newGear
        clutchPosition = 0
    }
}

// MARK: - Physics Engine Class
@MainActor
class PhysicsEngine: ObservableObject {
    @Published var velocity: CGFloat = 0
    @Published var acceleration: CGFloat = 0
    @Published var lateralAcceleration: CGFloat = 0
    @Published var position: CGPoint = .zero
    @Published var rotation: CGFloat = 0

    var vehicleProperties: VehicleProperties
    var tireFront: TireModel = TireModel()
    var tireRear: TireModel = TireModel()
    var suspensionFront: SuspensionSystem
    var suspensionRear: SuspensionSystem
    var aerodynamics: AerodynamicModel = AerodynamicModel()
    var powertrain: PowertrainSystem

    var throttle: CGFloat = 0
    var brake: CGFloat = 0
    var steering: CGFloat = 0
    var handbrake: Bool = false

    init(vehicleProperties: VehicleProperties = .lamborghini) {
        self.vehicleProperties = vehicleProperties
        self.suspensionFront = SuspensionSystem(
            stiffness: PhysicsConstants.suspensionStiffness,
            damping: PhysicsConstants.dampingCoefficient,
            maxTravel: vehicleProperties.suspensionTravel
        )
        self.suspensionRear = SuspensionSystem(
            stiffness: PhysicsConstants.suspensionStiffness * 1.1,
            damping: PhysicsConstants.dampingCoefficient * 1.1,
            maxTravel: vehicleProperties.suspensionTravel
        )
        self.powertrain = PowertrainSystem(properties: vehicleProperties)
    }

    func update(deltaTime: CGFloat) {
        updateAerodynamics()
        updatePowertrain(deltaTime)
        updateTires(deltaTime)
        updateSuspension(deltaTime)
        updateDynamics(deltaTime)
        updatePosition(deltaTime)
    }

    private func updateAerodynamics() {
        aerodynamics.calculateForces(velocity: velocity, properties: vehicleProperties)
    }

    private func updatePowertrain(_ deltaTime: CGFloat) {
        powertrain.updateRPM(wheelSpeed: velocity, deltaTime: deltaTime)
    }

    private func updateTires(_ deltaTime: CGFloat) {
        let slipRatio = abs(powertrain.wheelSlip)
        tireFront.slipRatio = slipRatio
        tireRear.slipRatio = slipRatio

        let friction = (tireFront.grip + tireRear.grip) / 2.0
        tireFront.updateTemperature(friction: friction, deltaTime: deltaTime)
        tireRear.updateTemperature(friction: friction, deltaTime: deltaTime)
    }

    private func updateSuspension(_ deltaTime: CGFloat) {
        let weight = vehicleProperties.mass * PhysicsConstants.gravity
        suspensionFront.update(load: weight / 2.0, deltaTime: deltaTime)
        suspensionRear.update(load: weight / 2.0, deltaTime: deltaTime)
    }

    private func updateDynamics(_ deltaTime: CGFloat) {
        let dragForce = aerodynamics.dragForce
        let engineForce = powertrain.availableTorque / 0.3
        let brakeForce = brake * vehicleProperties.brakePower
        let frictionForce = velocity * PhysicsConstants.rollingResistance * vehicleProperties.mass

        let netLongitudinalForce = engineForce - dragForce - brakeForce - frictionForce
        acceleration = netLongitudinalForce / vehicleProperties.mass
        velocity = max(0, velocity + acceleration * deltaTime)
        velocity = min(velocity, PhysicsConstants.maxSpeedLimiter)

        lateralAcceleration = steering * velocity * velocity / (vehicleProperties.wheelbase * 9.81)
        rotation += (steering * velocity / vehicleProperties.wheelbase) * deltaTime
    }

    private func updatePosition(_ deltaTime: CGFloat) {
        let radians = rotation * CGFloat.pi / 180.0
        position.x += velocity * cos(radians) * deltaTime
        position.y += velocity * sin(radians) * deltaTime
    }

    func setControls(throttle: CGFloat, brake: CGFloat, steering: CGFloat) {
        self.throttle = min(max(throttle, 0), 1.0)
        self.brake = min(max(brake, 0), 1.0)
        self.steering = min(max(steering, -1.0), 1.0)
        powertrain.throttlePosition = self.throttle
    }

    func getGForces() -> (lateral: CGFloat, longitudinal: CGFloat) {
        let lateralG = abs(lateralAcceleration) / PhysicsConstants.gravity
        let longitudinalG = abs(acceleration) / PhysicsConstants.gravity
        return (lateralG, longitudinalG)
    }

    func getEngineLoad() -> CGFloat {
        CGFloat(powertrain.rpm) / CGFloat(powertrain.properties.maxRPM)
    }
}

// MARK: - Collision Detection
struct CollisionDetection {
    static func checkCircleCollision(car1Pos: CGPoint, car2Pos: CGPoint, radius: CGFloat) -> Bool {
        let distance = hypot(car2Pos.x - car1Pos.x, car2Pos.y - car1Pos.y)
        return distance < radius * 2
    }

    static func checkRectangleCollision(rect1: CGRect, rect2: CGRect) -> Bool {
        return rect1.intersects(rect2)
    }

    static func resolveCollision(car1: inout CGPoint, car2: inout CGPoint, car1Vel: inout CGFloat, car2Vel: inout CGFloat) {
        let minDistance = 60.0
        let distance = hypot(car2.x - car1.x, car2.y - car1.y)

        if distance < minDistance {
            let overlap = minDistance - distance
            let angle = atan2(car2.y - car1.y, car2.x - car1.x)

            car1.x -= overlap / 2 * cos(angle)
            car1.y -= overlap / 2 * sin(angle)
            car2.x += overlap / 2 * cos(angle)
            car2.y += overlap / 2 * sin(angle)

            let tempVel = car1Vel
            car1Vel = car2Vel * 0.8
            car2Vel = tempVel * 0.8
        }
    }
}

// MARK: - Race Track Surface Properties
enum TrackSurface: String {
    case asphalt, concrete, gravel, grass, ice, water, sand

    var frictionCoefficient: CGFloat {
        switch self {
        case .asphalt: return 1.0
        case .concrete: return 1.05
        case .gravel: return 0.75
        case .grass: return 0.6
        case .ice: return 0.1
        case .water: return 0.3
        case .sand: return 0.5
        }
    }

    var bumpiness: CGFloat {
        switch self {
        case .asphalt: return 0.05
        case .concrete: return 0.1
        case .gravel: return 0.4
        case .grass: return 0.3
        case .ice: return 0.02
        case .water: return 0.6
        case .sand: return 0.35
        }
    }
}
