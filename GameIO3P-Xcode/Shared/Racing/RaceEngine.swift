// GameIO 2P — RaceEngine.swift
// Core pseudo-3D racing simulation engine
// Forza Horizon-inspired: perspective road, parallax layers, AI opponents
// Renders to UIView canvas at 60fps via CADisplayLink

import Foundation
import UIKit
import CoreGraphics
import Combine
import CoreMotion

// MARK: - Race Configuration
public struct RaceConfig {
    public var laps: Int = 3
    public var aiCount: Int = 3
    public var trackID: String = "circuit_01"
    public var weather: WeatherType = .clear
    public var timeOfDay: TimeOfDay = .day
    public var difficulty: Difficulty = .medium

    public enum WeatherType { case clear, cloudy, rain, snow, foggy }
    public enum TimeOfDay   { case dawn, day, dusk, night }
    public enum Difficulty  { case easy, medium, hard, expert }
}

// MARK: - Car State (physics)
public struct CarState {
    var position: Double    = 0.0    // Track position (0..1 per lap)
    var lane: Double        = 0.5    // 0 = far left, 1 = far right
    var speed: Double       = 0.0    // m/s
    var maxSpeed: Double    = 90.0   // m/s (Lamborghini default)
    var acceleration: Double = 8.0   // m/s²
    var braking: Double     = 18.0   // m/s²
    var steering: Double    = 0.0    // -1..1
    var drift: Double       = 0.0    // Drift angle (0..1)
    var nitro: Double       = 0.0    // 0..1
    var fuel: Double        = 1.0    // 0..1
    var lap: Int            = 0
    var lapProgress: Double = 0.0    // 0..1 within current lap
    var racePosition: Int   = 1
    var totalTime: Double   = 0.0
    var lapTimes: [Double]  = []
    var currentLapStart: Double = 0.0
    var isFinished: Bool    = false
    var isPlayer: Bool      = true
    var carBrand: CarBrand  = .lamborghini
    var carColor: UIColor   = .systemOrange

    init(brand: CarBrand, isPlayer: Bool) {
        carBrand = brand
        self.isPlayer = isPlayer
        maxSpeed = Double(brand.topSpeedMPH) * 0.44704  // mph to m/s
        acceleration = isPlayer ? 10.0 : Double.random(in: 7.0...9.0)
        carColor = isPlayer
            ? UIColor(red: 0.96, green: 0.65, blue: 0.14, alpha: 1.0)
            : [UIColor.systemRed, UIColor.systemBlue, UIColor.systemGreen, UIColor.white].randomElement()!
    }
}

// MARK: - Road Geometry (perspective)
public struct RoadGeometry {
    // Road is rendered as a perspective trapezoid
    // Bottom of screen = near, top = far (vanishing point)
    var roadWidth: CGFloat   = 0.6      // Fraction of screen width at bottom
    var horizonY: CGFloat    = 0.45     // Normalized horizon position (0..1)
    var vanishX: CGFloat     = 0.5      // Horizontal vanishing point (0..1)
    var curvature: CGFloat   = 0.0      // Current curve amount (-1..1)
    var targetCurvature: CGFloat = 0.0  // Animated curvature target
    var segmentLength: Double = 200.0   // Virtual road segment length (m)

    // Scroll position in road texture
    var scrollOffset: Double = 0.0

    mutating func update(dt: Double, speed: Double) {
        // Animate curvature smoothly
        curvature += (targetCurvature - curvature) * CGFloat(dt * 3)
        // Scroll road based on speed
        scrollOffset += speed * dt / segmentLength
        if scrollOffset >= 1.0 { scrollOffset -= 1.0 }
    }
}

// MARK: - Parallax Layer
public struct ParallaxLayer {
    var scrollFactor: CGFloat   // How fast this layer scrolls (0=static, 1=same as road)
    var yPosition: CGFloat      // Normalized y position on screen (0=top)
    var height: CGFloat         // Normalized height
    var drawFunc: (CGContext, CGRect, Double) -> Void  // Draw callback

    init(scrollFactor: CGFloat, yPosition: CGFloat, height: CGFloat,
         drawFunc: @escaping (CGContext, CGRect, Double) -> Void) {
        self.scrollFactor = scrollFactor
        self.yPosition = yPosition
        self.height = height
        self.drawFunc = drawFunc
    }
}

// MARK: - RaceEngine
public final class RaceEngine: NSObject {

    // MARK: - Public State
    @Published public var playerCar: CarState
    @Published public var aiCars: [CarState]
    @Published public var raceTime: Double = 0.0
    @Published public var isRaceStarted: Bool = false
    @Published public var isRaceFinished: Bool = false
    @Published public var countdown: Int = 3
    @Published public var currentSpeed: Double = 0.0    // For HUD display (mph)
    @Published public var racePosition: Int = 1
    @Published public var currentLap: Int = 1

    // MARK: - Private
    private var config: RaceConfig
    private var road: RoadGeometry = RoadGeometry()
    private var displayLink: CADisplayLink?
    private var lastTime: CFTimeInterval = 0
    private var countdownTimer: Timer?
    private var throttleInput: Double = 0.0
    private var brakeInput: Double = 0.0
    private var steeringInput: Double = 0.0  // -1..1
    private var isNitroActive: Bool = false
    private var motionManager = CMMotionManager()
    private var renderView: UIView?
    public var particleSystem: ParticleSystem = ParticleSystem(maxParticles: 500)

    // Track scroll offset for dash lines
    private var dashOffset: Double = 0.0

    // MARK: - Init
    public init(config: RaceConfig, playerBrand: CarBrand) {
        self.config = config
        self.playerCar = CarState(brand: playerBrand, isPlayer: true)
        let brands: [CarBrand] = [.ferrari, .porsche, .nissan]
        self.aiCars = brands.prefix(config.aiCount).map { CarState(brand: $0, isPlayer: false) }
        super.init()
    }

    // MARK: - Start Race
    public func startRace(in view: UIView) {
        renderView = view
        particleSystem.start()
        startCountdown()
        setupMotionInput()
    }

    private func startCountdown() {
        countdown = 3
        AudioManager.shared.playSFX(.countdownBeep)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdown > 1 {
                self.countdown -= 1
                AudioManager.shared.playSFX(.countdownBeep)
            } else if self.countdown == 1 {
                self.countdown = 0
                AudioManager.shared.playSFX(.countdownGo)
                self.beginRace()
                self.countdownTimer?.invalidate()
            }
        }
    }

    private func beginRace() {
        isRaceStarted = true
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink?.add(to: .main, forMode: .common)
        AudioManager.shared.playMusic(.racing)
        AudioManager.shared.startEngineSound(rpm: 3000)
    }

    // MARK: - Game Loop
    @objc private func gameLoop() {
        let now = CACurrentMediaTime()
        let dt = lastTime == 0 ? 0.016 : min(now - lastTime, 0.033)
        lastTime = now

        updatePlayer(dt: dt)
        updateAI(dt: dt)
        updatePositions()
        updateRoad(dt: dt)
        raceTime += dt
        currentSpeed = playerCar.speed * 2.237  // m/s to mph

        // Update engine sound pitch based on speed
        let rpm = Float(1000 + playerCar.speed * 100)
        AudioManager.shared.updateEngineRPM(rpm)

        // Tire smoke when drifting
        if playerCar.drift > 0.5 {
            spawnTireSmoke()
        }

        renderView?.setNeedsDisplay()
    }

    // MARK: - Player Physics
    private func updatePlayer(dt: Double) {
        // Throttle / brake
        let effectiveAccel = playerCar.acceleration * (isNitroActive ? 2.0 : 1.0)
        if throttleInput > 0 {
            playerCar.speed = min(playerCar.maxSpeed, playerCar.speed + effectiveAccel * throttleInput * dt)
        } else if brakeInput > 0 {
            playerCar.speed = max(0, playerCar.speed - playerCar.braking * brakeInput * dt)
        } else {
            // Natural deceleration
            playerCar.speed = max(0, playerCar.speed - 3.0 * dt)
        }

        // Steering
        let steerSens = 0.4 * (1.0 - playerCar.speed / playerCar.maxSpeed * 0.5)
        playerCar.lane = max(0.05, min(0.95, playerCar.lane + steeringInput * steerSens * dt))
        playerCar.steering = steeringInput

        // Drift calculation
        let targetDrift = abs(steeringInput) * (playerCar.speed / playerCar.maxSpeed)
        playerCar.drift += (targetDrift - playerCar.drift) * dt * 5

        // Advance track position
        let trackSpeedFactor = playerCar.speed / 100.0
        playerCar.position += trackSpeedFactor * dt
        playerCar.lapProgress = playerCar.position.truncatingRemainder(dividingBy: 1.0)

        // Lap detection
        let newLap = Int(playerCar.position)
        if newLap > playerCar.lap && newLap <= config.laps {
            playerCar.lapTimes.append(raceTime - playerCar.currentLapStart)
            playerCar.currentLapStart = raceTime
            playerCar.lap = newLap
            currentLap = newLap + 1
            AudioManager.shared.playSFX(.lapComplete)
        }

        // Race finish
        if playerCar.lap >= config.laps && !playerCar.isFinished {
            playerCar.isFinished = true
            finishRace()
        }

        // Nitro depletion
        if isNitroActive {
            playerCar.nitro = max(0, playerCar.nitro - dt * 0.25)
            if playerCar.nitro <= 0 { isNitroActive = false }
        } else {
            playerCar.nitro = min(1.0, playerCar.nitro + dt * 0.05)
        }

        // Fuel consumption
        playerCar.fuel = max(0, playerCar.fuel - dt * 0.003)
    }

    // MARK: - AI Update
    private func updateAI(dt: Double) {
        for i in 0..<aiCars.count {
            // Simple rubber band AI
            let gap = playerCar.position - aiCars[i].position
            let speedMult = gap > 0 ? 1.05 : 0.95  // Speed up if behind, slow if ahead
            let targetSpeed = aiCars[i].maxSpeed * 0.85 * speedMult
            aiCars[i].speed += (targetSpeed - aiCars[i].speed) * dt
            aiCars[i].speed = max(0, min(aiCars[i].maxSpeed, aiCars[i].speed))

            // Slight lane wandering
            aiCars[i].lane += Double.random(in: -0.3...0.3) * dt
            aiCars[i].lane = max(0.1, min(0.9, aiCars[i].lane))

            aiCars[i].position += (aiCars[i].speed / 100.0) * dt

            let aiLap = Int(aiCars[i].position)
            if aiLap > aiCars[i].lap && aiLap <= config.laps {
                aiCars[i].lap = aiLap
            }
        }
    }

    // MARK: - Update Race Positions
    private func updatePositions() {
        var allCars = [playerCar] + aiCars
        allCars.sort { $0.position > $1.position }
        racePosition = (allCars.firstIndex { $0.isPlayer } ?? 0) + 1
        playerCar.racePosition = racePosition
    }

    // MARK: - Road Update
    private func updateRoad(dt: Double) {
        road.update(dt: dt, speed: playerCar.speed)

        // Generate gentle curves
        if Int(raceTime * 10) % 50 == 0 {
            road.targetCurvature = CGFloat.random(in: -0.3...0.3)
        }

        dashOffset += playerCar.speed * dt * 0.01
        if dashOffset > 1.0 { dashOffset -= 1.0 }
    }

    // MARK: - Finish Race
    private func finishRace() {
        isRaceFinished = true
        displayLink?.invalidate()
        AudioManager.shared.stopEngineSound()
        AudioManager.shared.playSFX(racePosition == 1 ? .raceWin : .raceLose)
        AudioManager.shared.playMusic(.victory)
        particleSystem.burst(at: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY * 0.5), config: .confetti)
    }

    // MARK: - Particle Spawning
    private func spawnTireSmoke() {
        guard let view = renderView else { return }
        let bounds = view.bounds
        let carX = bounds.midX + CGFloat(playerCar.steering) * 20
        let carY = bounds.height * 0.72
        particleSystem.burst(
            at: CGPoint(x: carX - 15, y: carY + 10),
            config: EmitterConfig.tireSmoke
        )
    }

    // MARK: - Input
    public func setThrottle(_ value: Double) { throttleInput = max(0, min(1, value)) }
    public func setBrake(_ value: Double)    { brakeInput    = max(0, min(1, value)) }
    public func setSteering(_ value: Double) { steeringInput = max(-1, min(1, value)) }
    public func activateNitro() {
        guard playerCar.nitro > 0.1 else { return }
        isNitroActive = true
        AudioManager.shared.playSFX(.nitroBoost)
        guard let view = renderView else { return }
        let pos = CGPoint(x: view.bounds.midX, y: view.bounds.height * 0.75)
        particleSystem.burst(at: pos, config: .nitro)
    }

    // MARK: - Motion (tilt steering)
    private func setupMotionInput() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.016
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion = motion else { return }
            let tilt = motion.attitude.roll  // -π..π
            let normalized = max(-1.0, min(1.0, tilt / 0.5))
            self?.setSteering(normalized)
        }
    }

    // MARK: - Rendering (called from UIView.draw)
    public func render(in context: CGContext, bounds: CGRect) {
        renderSky(in: context, bounds: bounds)
        renderMountains(in: context, bounds: bounds)
        renderTrees(in: context, bounds: bounds)
        renderRoad(in: context, bounds: bounds)
        renderRoadMarkings(in: context, bounds: bounds)
        renderAICars(in: context, bounds: bounds)
        renderPlayerCar(in: context, bounds: bounds)
        particleSystem.render(in: context)
    }

    // MARK: - Sky Rendering (HDR gradient)
    private func renderSky(in context: CGContext, bounds: CGRect) {
        let horizonY = bounds.height * road.horizonY
        let skyRect = CGRect(x: 0, y: 0, width: bounds.width, height: horizonY)

        let skyGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor(red: 0.05, green: 0.1, blue: 0.25, alpha: 1).cgColor,  // Deep blue top
                UIColor(red: 0.15, green: 0.35, blue: 0.65, alpha: 1).cgColor,  // Mid blue
                UIColor(red: 0.55, green: 0.75, blue: 0.95, alpha: 1).cgColor   // Light at horizon
            ] as CFArray,
            locations: [0, 0.5, 1.0]
        )!
        context.drawLinearGradient(skyGradient,
            startPoint: CGPoint(x: bounds.midX, y: 0),
            endPoint: CGPoint(x: bounds.midX, y: horizonY),
            options: []
        )

        // Sun glow at horizon
        let sunX = bounds.width * (0.65 + road.curvature * 0.1)
        let sunGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 0.6).cgColor,
                UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.0).cgColor
            ] as CFArray,
            locations: [0, 1]
        )!
        context.drawRadialGradient(sunGradient,
            startCenter: CGPoint(x: sunX, y: horizonY * 0.9),
            startRadius: 0,
            endCenter: CGPoint(x: sunX, y: horizonY * 0.9),
            endRadius: 120,
            options: []
        )
    }

    // MARK: - Mountains Parallax
    private func renderMountains(in context: CGContext, bounds: CGRect) {
        let horizonY = bounds.height * road.horizonY
        let scrollX = CGFloat(playerCar.position * 200).truncatingRemainder(dividingBy: bounds.width * 2)

        // Far mountains
        context.setFillColor(UIColor(red: 0.25, green: 0.3, blue: 0.45, alpha: 1).cgColor)
        var farPath = UIBezierPath()
        farPath.move(to: CGPoint(x: -scrollX * 0.1, y: horizonY))
        let farMountainCount = 8
        for i in 0...farMountainCount {
            let x = CGFloat(i) * bounds.width / CGFloat(farMountainCount) - scrollX * 0.1
            let h = CGFloat.random(in: 0.08...0.18) * horizonY
            farPath.addLine(to: CGPoint(x: x - 30, y: horizonY - h))
            farPath.addLine(to: CGPoint(x: x, y: horizonY - h * 1.2))
            farPath.addLine(to: CGPoint(x: x + 30, y: horizonY - h))
        }
        farPath.addLine(to: CGPoint(x: bounds.width + 50, y: horizonY))
        farPath.close()
        context.addPath(farPath.cgPath)
        context.fillPath()

        // Mid mountains
        context.setFillColor(UIColor(red: 0.18, green: 0.22, blue: 0.35, alpha: 1).cgColor)
        var midPath = UIBezierPath()
        midPath.move(to: CGPoint(x: -scrollX * 0.3, y: horizonY))
        for i in 0...6 {
            let x = CGFloat(i) * bounds.width / 5.0 - scrollX * 0.3
            let h = CGFloat(50 + (i * 31) % 60)
            midPath.addLine(to: CGPoint(x: x - 40, y: horizonY - h))
            midPath.addLine(to: CGPoint(x: x, y: horizonY - h - 20))
            midPath.addLine(to: CGPoint(x: x + 40, y: horizonY - h))
        }
        midPath.addLine(to: CGPoint(x: bounds.width + 100, y: horizonY))
        midPath.close()
        context.addPath(midPath.cgPath)
        context.fillPath()
    }

    // MARK: - Tree Rows Parallax
    private func renderTrees(in context: CGContext, bounds: CGRect) {
        let horizonY = bounds.height * road.horizonY
        let scrollX = CGFloat(playerCar.position * 500).truncatingRemainder(dividingBy: 120)

        // Draw tree silhouettes on both sides of road
        let roadLeftX  = bounds.width * (road.vanishX - road.roadWidth/2)
        let roadRightX = bounds.width * (road.vanishX + road.roadWidth/2)
        let treeY = horizonY + 15

        // Left trees
        for i in 0..<12 {
            let x = CGFloat(i) * 80 - scrollX * 0.8 - 60
            if x < roadLeftX - 10 {
                drawTree(in: context, at: CGPoint(x: x, y: treeY), height: 40)
            }
        }
        // Right trees
        for i in 0..<12 {
            let x = roadRightX + CGFloat(i) * 80 - scrollX * 0.8
            if x > roadRightX + 10 {
                drawTree(in: context, at: CGPoint(x: x, y: treeY), height: 40)
            }
        }
    }

    private func drawTree(in context: CGContext, at point: CGPoint, height: CGFloat) {
        // Trunk
        context.setFillColor(UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1).cgColor)
        context.fill(CGRect(x: point.x - 3, y: point.y, width: 6, height: height * 0.3))
        // Foliage (triangle)
        context.setFillColor(UIColor(red: 0.05, green: 0.25, blue: 0.08, alpha: 1).cgColor)
        let foliage = UIBezierPath()
        foliage.move(to: CGPoint(x: point.x, y: point.y - height))
        foliage.addLine(to: CGPoint(x: point.x - height * 0.4, y: point.y))
        foliage.addLine(to: CGPoint(x: point.x + height * 0.4, y: point.y))
        foliage.close()
        context.addPath(foliage.cgPath)
        context.fillPath()
    }

    // MARK: - Road Surface
    private func renderRoad(in context: CGContext, bounds: CGRect) {
        let horizonY = bounds.height * road.horizonY
        let vx = bounds.width * road.vanishX

        // Road trapezoid: wide at bottom, narrow at horizon
        let roadTopHalfWidth  = bounds.width * road.roadWidth * 0.12
        let roadBotHalfWidth  = bounds.width * road.roadWidth * 0.5
        let roadTopY = horizonY
        let roadBotY = bounds.height

        let curvOffset = road.curvature * (bounds.width * 0.1)

        let roadPath = UIBezierPath()
        roadPath.move(to: CGPoint(x: vx - roadTopHalfWidth + curvOffset * 0.5, y: roadTopY))
        roadPath.addLine(to: CGPoint(x: vx + roadTopHalfWidth + curvOffset * 0.5, y: roadTopY))
        roadPath.addLine(to: CGPoint(x: bounds.midX + roadBotHalfWidth + curvOffset, y: roadBotY))
        roadPath.addLine(to: CGPoint(x: bounds.midX - roadBotHalfWidth + curvOffset, y: roadBotY))
        roadPath.close()

        // Asphalt gradient (darker at top/distance, lighter near camera)
        let asphaltGrad = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor(white: 0.28, alpha: 1).cgColor,
                UIColor(white: 0.38, alpha: 1).cgColor
            ] as CFArray,
            locations: [0, 1]
        )!
        context.saveGState()
        context.addPath(roadPath.cgPath)
        context.clip()
        context.drawLinearGradient(asphaltGrad,
            startPoint: CGPoint(x: bounds.midX, y: roadTopY),
            endPoint: CGPoint(x: bounds.midX, y: roadBotY),
            options: []
        )
        context.restoreGState()

        // Road edges (rumble strips)
        let edgeWidth: CGFloat = 12
        // Left edge
        let leftEdge = UIBezierPath()
        leftEdge.move(to: CGPoint(x: vx - roadTopHalfWidth + curvOffset * 0.5 - edgeWidth, y: roadTopY))
        leftEdge.addLine(to: CGPoint(x: vx - roadTopHalfWidth + curvOffset * 0.5, y: roadTopY))
        leftEdge.addLine(to: CGPoint(x: bounds.midX - roadBotHalfWidth + curvOffset, y: roadBotY))
        leftEdge.addLine(to: CGPoint(x: bounds.midX - roadBotHalfWidth + curvOffset - edgeWidth * 4, y: roadBotY))
        leftEdge.close()
        drawRumbleStrip(in: context, path: leftEdge)

        // Right edge
        let rightEdge = UIBezierPath()
        rightEdge.move(to: CGPoint(x: vx + roadTopHalfWidth + curvOffset * 0.5, y: roadTopY))
        rightEdge.addLine(to: CGPoint(x: vx + roadTopHalfWidth + curvOffset * 0.5 + edgeWidth, y: roadTopY))
        rightEdge.addLine(to: CGPoint(x: bounds.midX + roadBotHalfWidth + curvOffset + edgeWidth * 4, y: roadBotY))
        rightEdge.addLine(to: CGPoint(x: bounds.midX + roadBotHalfWidth + curvOffset, y: roadBotY))
        rightEdge.close()
        drawRumbleStrip(in: context, path: rightEdge)
    }

    private func drawRumbleStrip(in context: CGContext, path: UIBezierPath) {
        // Alternating red/white stripes
        context.saveGState()
        context.addPath(path.cgPath)
        context.clip()
        let stripeCount = 20
        for i in 0..<stripeCount {
            let color = i % 2 == 0 ? UIColor.red : UIColor.white
            context.setFillColor(color.cgColor)
            let rect = path.bounds
            let stripeH = rect.height / CGFloat(stripeCount)
            context.fill(CGRect(x: rect.minX, y: rect.minY + CGFloat(i) * stripeH,
                                width: rect.width, height: stripeH))
        }
        context.restoreGState()
    }

    // MARK: - Road Markings (dashes)
    private func renderRoadMarkings(in context: CGContext, bounds: CGRect) {
        let horizonY = bounds.height * road.horizonY
        let vx = bounds.width * road.vanishX
        let curvOffset = road.curvature * (bounds.width * 0.1)
        let roadTopHalfWidth  = bounds.width * road.roadWidth * 0.12
        let roadBotHalfWidth  = bounds.width * road.roadWidth * 0.5

        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)

        // Center dashed line with perspective
        let dashSegments = 12
        for i in 0..<dashSegments {
            let t0 = CGFloat(i) / CGFloat(dashSegments) + CGFloat(dashOffset)
            let t1 = t0 + CGFloat(0.4) / CGFloat(dashSegments)
            if t1.truncatingRemainder(dividingBy: 1.0 / CGFloat(dashSegments)) > 0.2 / CGFloat(dashSegments) {
                continue
            }

            let ta = min(1.0, max(0.0, t0.truncatingRemainder(dividingBy: 1.0)))
            let tb = min(1.0, max(0.0, t1.truncatingRemainder(dividingBy: 1.0)))

            let topHW = roadTopHalfWidth
            let botHW = roadBotHalfWidth

            func xAt(_ t: CGFloat) -> CGFloat {
                let hw = topHW + (botHW - topHW) * t
                let cx = vx + curvOffset * t
                return cx  // Center of road
            }
            func yAt(_ t: CGFloat) -> CGFloat {
                return horizonY + (bounds.height - horizonY) * t
            }

            context.move(to: CGPoint(x: xAt(ta), y: yAt(ta)))
            context.addLine(to: CGPoint(x: xAt(tb), y: yAt(tb)))
            context.strokePath()
        }
    }

    // MARK: - AI Cars
    private func renderAICars(in context: CGContext, bounds: CGRect) {
        let horizonY = bounds.height * road.horizonY
        for ai in aiCars {
            let depthDiff = ai.position - playerCar.position
            guard depthDiff > -0.1 && depthDiff < 0.5 else { continue }
            // Map depth to screen Y (positive = ahead = higher on screen)
            let t = CGFloat(0.5 - depthDiff * 0.8)
            let y = horizonY + (bounds.height - horizonY) * max(0.05, min(0.9, t))
            let scale = 0.3 + 0.7 * t
            let x = bounds.width * CGFloat(ai.lane) + road.curvature * (bounds.width * 0.1) * (1 - t)
            drawCarShape(in: context, at: CGPoint(x: x, y: y), scale: scale, color: ai.carColor)
        }
    }

    // MARK: - Player Car
    private func renderPlayerCar(in context: CGContext, bounds: CGRect) {
        let carY = bounds.height * 0.72
        let carX = bounds.midX + road.curvature * -30 + CGFloat(playerCar.lane - 0.5) * 80
        drawCarShape(in: context, at: CGPoint(x: carX, y: carY), scale: 1.0, color: playerCar.carColor)

        // Exhaust particles
        if playerCar.speed > 5 {
            let exhaustPos = CGPoint(x: carX - 30, y: carY + 15)
            particleSystem.burst(at: exhaustPos, config: .exhaust)
        }
    }

    // MARK: - Car Shape Drawing
    private func drawCarShape(in context: CGContext, at center: CGPoint, scale: CGFloat, color: UIColor) {
        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: scale, y: scale)

        let w: CGFloat = 50
        let h: CGFloat = 22

        // Car body
        let bodyPath = UIBezierPath(roundedRect: CGRect(x: -w/2, y: -h/2, width: w, height: h), cornerRadius: 5)
        color.setFill()
        context.addPath(bodyPath.cgPath)
        context.fillPath()

        // Car roof
        let roofPath = UIBezierPath()
        roofPath.move(to: CGPoint(x: -15, y: -h/2))
        roofPath.addLine(to: CGPoint(x: -20, y: -h/2 - 12))
        roofPath.addLine(to: CGPoint(x: 10, y: -h/2 - 12))
        roofPath.addLine(to: CGPoint(x: 18, y: -h/2))
        roofPath.close()
        color.darker(by: 0.2).setFill()
        context.addPath(roofPath.cgPath)
        context.fillPath()

        // Windshield
        UIColor(white: 0.8, alpha: 0.7).setFill()
        let windshield = UIBezierPath(roundedRect: CGRect(x: -8, y: -h/2 - 11, width: 16, height: 10), cornerRadius: 2)
        context.addPath(windshield.cgPath)
        context.fillPath()

        // Wheels
        UIColor.black.setFill()
        for wx in [-18, 15] {
            let wheelPath = UIBezierPath(ovalIn: CGRect(x: CGFloat(wx) - 7, y: h/2 - 4, width: 14, height: 9))
            context.addPath(wheelPath.cgPath)
            context.fillPath()
            UIColor.darkGray.setFill()
            let rimPath = UIBezierPath(ovalIn: CGRect(x: CGFloat(wx) - 4, y: h/2 - 2, width: 8, height: 5))
            context.addPath(rimPath.cgPath)
            context.fillPath()
        }

        // Headlights
        UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1).setFill()
        context.fillEllipse(in: CGRect(x: w/2 - 10, y: -6, width: 8, height: 5))
        context.fillEllipse(in: CGRect(x: w/2 - 10, y: 1, width: 8, height: 5))

        // Taillights
        UIColor.red.setFill()
        context.fillEllipse(in: CGRect(x: -w/2 + 2, y: -6, width: 7, height: 5))
        context.fillEllipse(in: CGRect(x: -w/2 + 2, y: 1, width: 7, height: 5))

        context.restoreGState()
    }
}

// MARK: - UIColor Helpers
extension UIColor {
    func darker(by factor: CGFloat = 0.2) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: max(0, b - factor), alpha: a)
    }
}
