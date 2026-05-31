// GameIO 2P — ParticleSystem.swift
// High-performance particle system supporting 500+ simultaneous particles
// Used for: tire smoke, exhaust, sparks, rain, snow, confetti, portal effects
// Renderer: CoreGraphics canvas (for UIKit) / Metal (for performance mode)

import Foundation
import CoreGraphics
import UIKit
import SwiftUI

// MARK: - Particle Types
public enum ParticleType: String, CaseIterable {
    case tireSmoke    = "tire_smoke"
    case exhaust      = "exhaust"
    case spark        = "spark"
    case confetti     = "confetti"
    case rain         = "rain"
    case snow         = "snow"
    case portal       = "portal"
    case dust         = "dust"
    case nitro        = "nitro"
    case explosion    = "explosion"
    case coin         = "coin"
    case star         = "star"
    case fire         = "fire"
    case waterSplash  = "water_splash"
    case skid         = "skid"
}

// MARK: - Particle
/// A single particle in the simulation
public struct Particle {
    var position: CGPoint
    var velocity: CGVector
    var acceleration: CGVector
    var life: Double          // Current life (0..maxLife)
    var maxLife: Double       // Total lifetime in seconds
    var size: CGFloat         // Current render size
    var startSize: CGFloat
    var endSize: CGFloat
    var rotation: CGFloat     // Current rotation in radians
    var rotationSpeed: CGFloat
    var color: UIColor
    var startColor: UIColor
    var endColor: UIColor
    var alpha: CGFloat
    var type: ParticleType
    var isAlive: Bool
    var gravity: CGVector     // Per-particle gravity override

    /// Normalized life progress (0.0 = just born, 1.0 = dead)
    var progress: Double { life / maxLife }

    /// Current interpolated size
    var currentSize: CGFloat {
        CGFloat(lerp(Double(startSize), Double(endSize), progress))
    }

    /// Current interpolated alpha
    var currentAlpha: CGFloat {
        let fadeIn  = min(1.0, progress * 5)      // Fast fade in
        let fadeOut = max(0.0, 1.0 - (progress - 0.7) / 0.3)  // Fade out last 30%
        return CGFloat(min(fadeIn, fadeOut)) * alpha
    }

    init(
        position: CGPoint,
        velocity: CGVector,
        life: Double,
        size: CGFloat,
        color: UIColor,
        type: ParticleType,
        gravity: CGVector = CGVector(dx: 0, dy: 9.8)
    ) {
        self.position = position
        self.velocity = velocity
        self.acceleration = .zero
        self.life = 0
        self.maxLife = life
        self.size = size
        self.startSize = size
        self.endSize = size * 2.5
        self.rotation = CGFloat.random(in: 0...(.pi * 2))
        self.rotationSpeed = CGFloat.random(in: -2.0...2.0)
        self.color = color
        self.startColor = color
        self.endColor = color.withAlphaComponent(0)
        self.alpha = 1.0
        self.type = type
        self.isAlive = true
        self.gravity = gravity
    }
}

// MARK: - Emitter Configuration
public struct EmitterConfig {
    var type: ParticleType
    var emissionRate: Double    // Particles per second
    var burstCount: Int?        // If set, emit all at once (burst)
    var maxParticles: Int
    var minLife: Double
    var maxLife: Double
    var minSpeed: Double
    var maxSpeed: Double
    var emissionAngle: CGFloat  // Radians, base emission direction
    var emissionSpread: CGFloat // Radians, ± spread around base angle
    var minSize: CGFloat
    var maxSize: CGFloat
    var endSizeMultiplier: CGFloat  // End size = start * this
    var colors: [UIColor]
    var gravity: CGVector
    var turbulence: Double      // Random velocity perturbation

    /// Tire smoke preset
    public static var tireSmoke: EmitterConfig {
        EmitterConfig(
            type: .tireSmoke,
            emissionRate: 30,
            burstCount: nil,
            maxParticles: 200,
            minLife: 0.8,
            maxLife: 1.5,
            minSpeed: 20,
            maxSpeed: 60,
            emissionAngle: -.pi / 2,
            emissionSpread: .pi / 4,
            minSize: 8,
            maxSize: 20,
            endSizeMultiplier: 4.0,
            colors: [
                UIColor(white: 0.8, alpha: 0.6),
                UIColor(white: 0.7, alpha: 0.5),
                UIColor(white: 0.9, alpha: 0.4)
            ],
            gravity: CGVector(dx: 0, dy: -20),
            turbulence: 10.0
        )
    }

    /// Exhaust smoke preset
    public static var exhaust: EmitterConfig {
        EmitterConfig(
            type: .exhaust,
            emissionRate: 20,
            burstCount: nil,
            maxParticles: 80,
            minLife: 0.5,
            maxLife: 1.0,
            minSpeed: 10,
            maxSpeed: 30,
            emissionAngle: .pi,
            emissionSpread: .pi / 8,
            minSize: 4,
            maxSize: 10,
            endSizeMultiplier: 3.0,
            colors: [
                UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.5),
                UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.4)
            ],
            gravity: CGVector(dx: 0, dy: -30),
            turbulence: 5.0
        )
    }

    /// Spark burst preset
    public static var sparks: EmitterConfig {
        EmitterConfig(
            type: .spark,
            emissionRate: 0,
            burstCount: 40,
            maxParticles: 40,
            minLife: 0.3,
            maxLife: 0.8,
            minSpeed: 80,
            maxSpeed: 200,
            emissionAngle: 0,
            emissionSpread: .pi * 2,  // All directions
            minSize: 2,
            maxSize: 4,
            endSizeMultiplier: 0.1,
            colors: [
                UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
                UIColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 1.0),
                UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
            ],
            gravity: CGVector(dx: 0, dy: 150),
            turbulence: 20.0
        )
    }

    /// Confetti burst preset
    public static var confetti: EmitterConfig {
        EmitterConfig(
            type: .confetti,
            emissionRate: 0,
            burstCount: 100,
            maxParticles: 100,
            minLife: 1.5,
            maxLife: 3.0,
            minSpeed: 100,
            maxSpeed: 300,
            emissionAngle: -.pi / 2,
            emissionSpread: .pi / 1.5,
            minSize: 6,
            maxSize: 12,
            endSizeMultiplier: 1.0,
            colors: [
                UIColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0),
                UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0),
                UIColor(red: 0.9, green: 0.8, blue: 0.1, alpha: 1.0),
                UIColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1.0),
                UIColor(red: 0.8, green: 0.2, blue: 0.9, alpha: 1.0)
            ],
            gravity: CGVector(dx: 0, dy: 80),
            turbulence: 30.0
        )
    }

    /// Nitro boost preset
    public static var nitro: EmitterConfig {
        EmitterConfig(
            type: .nitro,
            emissionRate: 60,
            burstCount: nil,
            maxParticles: 120,
            minLife: 0.2,
            maxLife: 0.5,
            minSpeed: 50,
            maxSpeed: 150,
            emissionAngle: .pi,
            emissionSpread: .pi / 6,
            minSize: 3,
            maxSize: 8,
            endSizeMultiplier: 0.2,
            colors: [
                UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.8),
                UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.7),
                UIColor(red: 0.5, green: 0.2, blue: 1.0, alpha: 0.6)
            ],
            gravity: CGVector(dx: 0, dy: -10),
            turbulence: 8.0
        )
    }

    /// Portal entry effect preset
    public static var portalEffect: EmitterConfig {
        EmitterConfig(
            type: .portal,
            emissionRate: 40,
            burstCount: nil,
            maxParticles: 150,
            minLife: 0.5,
            maxLife: 1.2,
            minSpeed: 30,
            maxSpeed: 80,
            emissionAngle: 0,
            emissionSpread: .pi * 2,
            minSize: 3,
            maxSize: 8,
            endSizeMultiplier: 0.5,
            colors: [
                UIColor(red: 0.6, green: 0.0, blue: 1.0, alpha: 0.8),
                UIColor(red: 0.9, green: 0.4, blue: 1.0, alpha: 0.7),
                UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.6)
            ],
            gravity: CGVector(dx: 0, dy: -5),
            turbulence: 15.0
        )
    }
}

// MARK: - ParticleSystem
/// High-performance particle simulation — update at 60fps via CADisplayLink
public final class ParticleSystem {

    // MARK: - Properties
    public var particles: [Particle] = []
    public var emitters: [ParticleEmitter] = []
    public var maxParticles: Int = 500
    public var isActive: Bool = true

    private var lastUpdateTime: CFTimeInterval = 0
    private var displayLink: CADisplayLink?

    // MARK: - Init
    public init(maxParticles: Int = 500) {
        self.maxParticles = maxParticles
        self.particles.reserveCapacity(maxParticles)
    }

    // MARK: - Start / Stop
    public func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }

    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    // MARK: - Update Loop
    @objc private func update() {
        let now = CACurrentMediaTime()
        let dt = lastUpdateTime == 0 ? 0.016 : min(now - lastUpdateTime, 0.033)
        lastUpdateTime = now
        guard isActive else { return }

        // Update emitters
        for i in 0..<emitters.count {
            emitters[i].update(dt: dt) { [weak self] particle in
                self?.spawnParticle(particle)
            }
        }

        // Update particles
        for i in 0..<particles.count {
            guard particles[i].isAlive else { continue }
            updateParticle(index: i, dt: dt)
        }

        // Remove dead particles
        particles.removeAll { !$0.isAlive }
    }

    private func updateParticle(index: Int, dt: Double) {
        var p = particles[index]
        p.life += dt

        if p.life >= p.maxLife {
            p.isAlive = false
            particles[index] = p
            return
        }

        // Apply gravity
        p.velocity.dx += p.gravity.dx * CGFloat(dt)
        p.velocity.dy += p.gravity.dy * CGFloat(dt)

        // Apply turbulence
        let turb = CGFloat.random(in: -1...1)
        p.velocity.dx += turb * 2
        p.velocity.dy += turb * 2

        // Update position
        p.position.x += p.velocity.dx * CGFloat(dt)
        p.position.y += p.velocity.dy * CGFloat(dt)

        // Update rotation
        p.rotation += p.rotationSpeed * CGFloat(dt)

        // Update size
        p.size = p.currentSize

        particles[index] = p
    }

    // MARK: - Spawn
    public func spawnParticle(_ particle: Particle) {
        guard particles.count < maxParticles else { return }
        particles.append(particle)
    }

    // MARK: - Burst Emitters
    public func burst(at position: CGPoint, config: EmitterConfig) {
        let count = config.burstCount ?? 20
        for _ in 0..<count {
            let particle = createParticle(at: position, config: config)
            spawnParticle(particle)
        }
    }

    // MARK: - Add Continuous Emitter
    public func addEmitter(at position: CGPoint, config: EmitterConfig) -> ParticleEmitter {
        let emitter = ParticleEmitter(position: position, config: config)
        emitters.append(emitter)
        return emitter
    }

    public func removeEmitter(_ emitter: ParticleEmitter) {
        emitters.removeAll { $0 === emitter }
    }

    // MARK: - Particle Factory
    private func createParticle(at position: CGPoint, config: EmitterConfig) -> Particle {
        let speed = Double.random(in: config.minSpeed...config.maxSpeed)
        let angle = config.emissionAngle + CGFloat.random(in: -config.emissionSpread/2...config.emissionSpread/2)
        let vx = cos(angle) * CGFloat(speed)
        let vy = sin(angle) * CGFloat(speed)
        let life = Double.random(in: config.minLife...config.maxLife)
        let size = CGFloat.random(in: config.minSize...config.maxSize)
        let color = config.colors.randomElement() ?? .white

        var p = Particle(
            position: position,
            velocity: CGVector(dx: vx, dy: vy),
            life: life,
            size: size,
            color: color,
            type: config.type,
            gravity: config.gravity
        )
        p.endSize = size * config.endSizeMultiplier
        return p
    }

    // MARK: - Render
    /// Call this from a UIView.draw(_ rect:) or CALayer.draw(in:)
    public func render(in context: CGContext) {
        context.saveGState()
        for particle in particles {
            guard particle.isAlive else { continue }
            renderParticle(particle, in: context)
        }
        context.restoreGState()
    }

    private func renderParticle(_ p: Particle, in context: CGContext) {
        let alpha = p.currentAlpha
        guard alpha > 0.01 else { return }

        context.saveGState()
        context.translateBy(x: p.position.x, y: p.position.y)
        context.rotate(by: p.rotation)

        switch p.type {
        case .spark, .nitro, .star:
            // Draw as a line/streak
            context.setStrokeColor(p.color.withAlphaComponent(alpha).cgColor)
            context.setLineWidth(p.size * 0.4)
            context.move(to: CGPoint(x: -p.size, y: 0))
            context.addLine(to: CGPoint(x: p.size, y: 0))
            context.strokePath()

        case .confetti:
            // Draw as rectangle
            p.color.withAlphaComponent(alpha).setFill()
            let rect = CGRect(x: -p.size/2, y: -p.size/4, width: p.size, height: p.size/2)
            context.fill(rect)

        case .tireSmoke, .exhaust, .dust:
            // Draw as soft circle
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    p.color.withAlphaComponent(alpha).cgColor,
                    p.color.withAlphaComponent(0).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            context.drawRadialGradient(
                gradient,
                startCenter: .zero,
                startRadius: 0,
                endCenter: .zero,
                endRadius: p.size,
                options: []
            )

        default:
            // Draw as filled circle
            p.color.withAlphaComponent(alpha).setFill()
            let halfSize = p.size / 2
            context.fillEllipse(in: CGRect(x: -halfSize, y: -halfSize, width: p.size, height: p.size))
        }

        context.restoreGState()
    }
}

// MARK: - ParticleEmitter
/// Continuously spawns particles at a position
public class ParticleEmitter {
    public var position: CGPoint
    public var config: EmitterConfig
    public var isActive: Bool = true
    private var accumulator: Double = 0

    init(position: CGPoint, config: EmitterConfig) {
        self.position = position
        self.config = config
    }

    func update(dt: Double, spawn: (Particle) -> Void) {
        guard isActive, config.burstCount == nil else { return }
        accumulator += dt * config.emissionRate
        while accumulator >= 1.0 {
            accumulator -= 1.0
            let particle = makeParticle()
            spawn(particle)
        }
    }

    private func makeParticle() -> Particle {
        let speed = Double.random(in: config.minSpeed...config.maxSpeed)
        let angle = config.emissionAngle + CGFloat.random(in: -config.emissionSpread/2...config.emissionSpread/2)
        let vx = cos(angle) * CGFloat(speed)
        let vy = sin(angle) * CGFloat(speed)
        let life = Double.random(in: config.minLife...config.maxLife)
        let size = CGFloat.random(in: config.minSize...config.maxSize)
        let color = config.colors.randomElement() ?? .white
        var p = Particle(
            position: position,
            velocity: CGVector(dx: vx, dy: vy),
            life: life,
            size: size,
            color: color,
            type: config.type,
            gravity: config.gravity
        )
        p.endSize = size * config.endSizeMultiplier
        return p
    }
}

// MARK: - Math Helpers
private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
    return a + (b - a) * t
}
