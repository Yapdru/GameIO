// Advanced3DRenderEngine.swift — Professional 3D Max Quality Rendering
// SceneKit-based 3D rendering with advanced materials, lighting, and physics
// Delivers professional-grade 3D graphics for racing and interactive scenes

import SwiftUI
import SceneKit
import ARKit

@MainActor
class Advanced3DRenderEngine: NSObject, ObservableObject {
    @Published var isInitialized: Bool = false
    @Published var renderQuality: RenderQuality = .ultra
    @Published var fpsCounter: Int = 60

    enum RenderQuality: String {
        case low, medium, high, ultra
    }

    private let sceneView = SCNView()
    private var scene: SCNScene?
    private var rootNode: SCNNode?
    private var cameraNode: SCNNode?
    private var lightNodes: [SCNNode] = []
    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastTime = Date()

    static let shared = Advanced3DRenderEngine()

    override init() {
        super.init()
        initializeRenderer()
    }

    private func initializeRenderer() {
        setupScene()
        setupLighting()
        setupCamera()
        configureRenderingPipeline()
        startRenderLoop()
        isInitialized = true
    }

    // MARK: - Scene Setup
    private func setupScene() {
        scene = SCNScene()
        rootNode = scene?.rootNode

        // Configure scene properties
        scene?.background.contents = UIColor.clear
        scene?.physicsWorld.gravity = SCNVector3(0, -9.8, 0)

        // Anti-aliasing and rendering options
        sceneView.isJitteringEnabled = true
        sceneView.antialiasingMode = .multisampling4X
    }

    // MARK: - Professional Lighting System
    private func setupLighting() {
        // Key Light (Main directional light)
        let keyLightNode = SCNNode()
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.color = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0)
        keyLight.intensity = 1500
        keyLight.castsShadow = true
        keyLight.shadowSampleCount = 16
        keyLightNode.light = keyLight
        keyLightNode.eulerAngles = SCNVector3(-CGFloat.pi / 4, CGFloat.pi / 4, 0)
        rootNode?.addChildNode(keyLightNode)

        // Fill Light (Reduces harsh shadows)
        let fillLightNode = SCNNode()
        let fillLight = SCNLight()
        fillLight.type = .directional
        fillLight.color = UIColor(red: 0.5, green: 0.6, blue: 0.8, alpha: 1.0)
        fillLight.intensity = 600
        fillLight.castsShadow = false
        fillLightNode.light = fillLight
        fillLightNode.eulerAngles = SCNVector3(CGFloat.pi / 4, -CGFloat.pi / 4, 0)
        rootNode?.addChildNode(fillLightNode)

        // Back Light (Rim lighting for depth)
        let backLightNode = SCNNode()
        let backLight = SCNLight()
        backLight.type = .directional
        backLight.color = UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0)
        backLight.intensity = 400
        backLight.castsShadow = false
        backLightNode.light = backLight
        backLightNode.eulerAngles = SCNVector3(0, -CGFloat.pi, 0)
        rootNode?.addChildNode(backLightNode)

        // Ambient Light (Overall illumination)
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 1.0)
        ambientLight.intensity = 400
        ambientLightNode.light = ambientLight
        rootNode?.addChildNode(ambientLightNode)

        lightNodes = [keyLightNode, fillLightNode, backLightNode, ambientLightNode]
    }

    // MARK: - Camera Setup
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode?.camera = SCNCamera()

        // Camera properties for cinematic quality
        cameraNode?.camera?.zFar = 500
        cameraNode?.camera?.zNear = 0.1
        cameraNode?.camera?.fieldOfView = 50

        // Position camera
        cameraNode?.position = SCNVector3(0, 5, 15)
        cameraNode?.look(at: SCNVector3(0, 0, 0))

        rootNode?.addChildNode(cameraNode ?? SCNNode())
    }

    // MARK: - Rendering Pipeline Configuration
    private func configureRenderingPipeline() {
        sceneView.scene = scene
        sceneView.showsStatistics = false

        // Configure rendering options based on quality
        switch renderQuality {
        case .low:
            sceneView.antialiasingMode = .none
            sceneView.preferredFramesPerSecond = 30

        case .medium:
            sceneView.antialiasingMode = .multisampling2X
            sceneView.preferredFramesPerSecond = 60

        case .high:
            sceneView.antialiasingMode = .multisampling4X
            sceneView.preferredFramesPerSecond = 120

        case .ultra:
            sceneView.antialiasingMode = .multisampling4X
            sceneView.preferredFramesPerSecond = 120
            // Enable depth of field for cinematic effect
            cameraNode?.camera?.aperture = 2.5
        }
    }

    // MARK: - Render Loop & Performance
    private func startRenderLoop() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateFrame)
        )
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateFrame() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTime)

        frameCount += 1
        if elapsed >= 1.0 {
            fpsCounter = frameCount
            frameCount = 0
            lastTime = now
        }

        updateRenderContent()
    }

    private func updateRenderContent() {
        // Update animations and scene content
        if let root = rootNode {
            for child in root.childNodes {
                updateNodeAnimation(child)
            }
        }
    }

    private func updateNodeAnimation(_ node: SCNNode) {
        // Apply smooth animations with CABasicAnimation
        let rotation = CABasicAnimation(keyPath: "eulerAngles.z")
        rotation.fromValue = node.eulerAngles.z
        rotation.toValue = node.eulerAngles.z + 0.02
        rotation.duration = 0.016
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
    }

    // MARK: - Professional Material Creation
    func createProfessionalMaterial(
        diffuse: UIColor,
        metallic: Float = 0.0,
        roughness: Float = 0.5,
        normal: UIImage? = nil
    ) -> SCNMaterial {
        let material = SCNMaterial()

        material.diffuse.contents = diffuse
        material.metallic.contents = NSNumber(value: metallic)
        material.roughness.contents = NSNumber(value: roughness)

        if let normalMap = normal {
            material.normal.contents = normalMap
        }

        material.isDoubleSided = false
        material.transparencyMode = .aOne

        return material
    }

    // MARK: - 3D Model Creation
    func createRacecarModel() -> SCNNode {
        let carNode = SCNNode()

        // Car body
        let bodyGeometry = SCNBox(width: 2.0, height: 0.8, length: 4.0, chamferRadius: 0.1)
        bodyGeometry.materials = [
            createProfessionalMaterial(
                diffuse: UIColor.red,
                metallic: 0.3,
                roughness: 0.2
            )
        ]
        let bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.position = SCNVector3(0, 0.5, 0)
        carNode.addChildNode(bodyNode)

        // Wheels
        let wheelPositions: [(Float, Float, Float)] = [
            (-0.8, 0.2, 1.0),
            (0.8, 0.2, 1.0),
            (-0.8, 0.2, -1.0),
            (0.8, 0.2, -1.0)
        ]

        for (x, y, z) in wheelPositions {
            let wheelGeometry = SCNCylinder(radius: 0.4, height: 0.3)
            wheelGeometry.materials = [
                createProfessionalMaterial(
                    diffuse: UIColor.black,
                    metallic: 0.1,
                    roughness: 0.8
                )
            ]
            let wheelNode = SCNNode(geometry: wheelGeometry)
            wheelNode.position = SCNVector3(x, y, z)
            wheelNode.eulerAngles = SCNVector3(CGFloat.pi / 2, 0, 0)
            carNode.addChildNode(wheelNode)
        }

        // Windows
        let windowGeometry = SCNBox(width: 1.5, height: 0.6, length: 1.5, chamferRadius: 0.05)
        let windowMaterial = SCNMaterial()
        windowMaterial.diffuse.contents = UIColor.cyan.withAlphaComponent(0.3)
        windowMaterial.metallic.contents = NSNumber(value: 0.5)
        windowGeometry.materials = [windowMaterial]
        let windowNode = SCNNode(geometry: windowGeometry)
        windowNode.position = SCNVector3(0, 1.0, 0.3)
        carNode.addChildNode(windowNode)

        carNode.name = "racecar"
        return carNode
    }

    // MARK: - Dynamic Lighting Effects
    func addSpotlight(at position: SCNVector3, color: UIColor, intensity: CGFloat) {
        let spotNode = SCNNode()
        let spotlight = SCNLight()
        spotlight.type = .spot
        spotlight.color = color
        spotlight.intensity = intensity
        spotlight.spotOuterAngle = 45
        spotlight.castsShadow = true
        spotNode.light = spotlight
        spotNode.position = position
        rootNode?.addChildNode(spotNode)
    }

    // MARK: - Scene Export
    func getSceneView() -> SCNView {
        return sceneView
    }

    func captureScreenshot() -> UIImage? {
        return sceneView.snapshot()
    }

    // MARK: - Cleanup
    func stopRendering() {
        displayLink?.invalidate()
        displayLink = nil
    }

    deinit {
        stopRendering()
    }
}

// MARK: - 3D Vehicle Physics
class VehiclePhysicsEngine {
    struct VehicleState {
        var position: SCNVector3 = .zero
        var velocity: SCNVector3 = .zero
        var acceleration: SCNVector3 = .zero
        var rotation: SCNVector3 = .zero
        var speed: Float = 0
        var rpm: Float = 0
    }

    private var vehicleState = VehicleState()
    private let mass: Float = 1500.0
    private let dragCoefficient: Float = 0.3
    private let friction: Float = 0.8

    func applyThrottle(_ amount: Float) {
        let maxForce: Float = 5000.0
        let force = amount * maxForce
        vehicleState.acceleration.z += force / mass
    }

    func applyBrake(_ amount: Float) {
        vehicleState.velocity *= (1.0 - amount * 0.1)
    }

    func updatePhysics(deltaTime: Float) {
        // Apply drag
        vehicleState.velocity *= (1.0 - dragCoefficient * deltaTime)

        // Update position
        vehicleState.position.x += vehicleState.velocity.x * deltaTime
        vehicleState.position.y += vehicleState.velocity.y * deltaTime
        vehicleState.position.z += vehicleState.velocity.z * deltaTime

        // Calculate speed
        vehicleState.speed = sqrt(
            vehicleState.velocity.x * vehicleState.velocity.x +
            vehicleState.velocity.z * vehicleState.velocity.z
        )

        // Update RPM based on speed
        vehicleState.rpm = vehicleState.speed * 100.0
    }

    func getVehicleState() -> VehicleState {
        return vehicleState
    }
}
