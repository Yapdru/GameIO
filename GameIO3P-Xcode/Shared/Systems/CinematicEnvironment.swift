// CinematicEnvironment.swift — 3D World Generation & Visual Storytelling
// Dynamic environments with elevation, weather, lighting, and world detail

import SwiftUI
import SceneKit
import AVFoundation

@MainActor
class CinematicEnvironment: NSObject, ObservableObject {
    @Published var currentScene: EnvironmentScene?
    @Published var weatherCondition: WeatherType = .clear
    @Published var timeOfDay: TimeOfDay = .morning
    @Published var ambientLighting: (Float, Float, Float) = (1.0, 1.0, 1.0)
    @Published var visibility: Float = 100.0
    @Published var windIntensity: Float = 0.0

    private var sceneManager: SCNScene?
    private let cameraController = CinematicCameraController()

    enum WeatherType: String, CaseIterable {
        case clear, rainy, foggy, stormy, sunset
        var description: String { self.rawValue.capitalized }
    }

    enum TimeOfDay: String, CaseIterable {
        case dawn, morning, afternoon, sunset, night
        var description: String { self.rawValue.capitalized }
    }

    enum EnvironmentScene: String, CaseIterable {
        case urbanStreet, coastalRoad, mountainPass, desertHighway, cityNights, forestTrail, highwayLoop
        var description: String { self.rawValue.replacingOccurrences(of: " ", with: "-").capitalized }
    }

    static let shared = CinematicEnvironment()

    override init() {
        super.init()
        initializeEnvironment()
    }

    private func initializeEnvironment() {
        sceneManager = SCNScene()
        currentScene = .urbanStreet
        updateLighting()
    }

    func loadScene(_ scene: EnvironmentScene) {
        currentScene = scene
        buildWorldGeometry(for: scene)
        updateLighting()
    }

    private func buildWorldGeometry(for scene: EnvironmentScene) {
        guard let sceneKit = sceneManager else { return }

        sceneKit.rootNode.childNodes.forEach { $0.removeFromParentNode() }

        switch scene {
        case .urbanStreet:
            buildUrbanEnvironment(sceneKit)
        case .coastalRoad:
            buildCoastalEnvironment(sceneKit)
        case .mountainPass:
            buildMountainEnvironment(sceneKit)
        case .desertHighway:
            buildDesertEnvironment(sceneKit)
        case .cityNights:
            buildCityNightsEnvironment(sceneKit)
        case .forestTrail:
            buildForestEnvironment(sceneKit)
        case .highwayLoop:
            buildHighwayLoopEnvironment(sceneKit)
        }

        addEnvironmentalDetails(to: sceneKit)
    }

    private func buildUrbanEnvironment(_ scene: SCNScene) {
        let groundPlane = SCNPlane(width: 500, height: 1500)
        groundPlane.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
        let groundNode = SCNNode(geometry: groundPlane)
        groundNode.eulerAngles.x = -CGFloat.pi / 2
        groundNode.position.y = -1
        scene.rootNode.addChildNode(groundNode)

        // Buildings with varied heights and colors
        let buildingPositions = [
            (x: -150, z: -200, h: 200, c: UIColor(red: 0.8, green: 0.75, blue: 0.7, alpha: 1.0)),
            (x: 150, z: -150, h: 250, c: UIColor(red: 0.7, green: 0.8, blue: 0.85, alpha: 1.0)),
            (x: -120, z: 200, h: 180, c: UIColor(red: 0.85, green: 0.8, blue: 0.75, alpha: 1.0)),
            (x: 180, z: 250, h: 220, c: UIColor(red: 0.75, green: 0.85, blue: 0.8, alpha: 1.0)),
        ]

        for (x, z, h, color) in buildingPositions {
            let building = createBuilding(width: 80, height: CGFloat(h), depth: 100, color: color)
            building.position = SCNVector3(x, CGFloat(h) / 2, z)
            scene.rootNode.addChildNode(building)
        }

        // Street lights
        for i in stride(from: -300, through: 600, by: 150) {
            let light = createStreetLight(position: SCNVector3(-200, 50, CGFloat(i)))
            scene.rootNode.addChildNode(light)
        }
    }

    private func buildCoastalEnvironment(_ scene: SCNScene) {
        // Ocean water
        let water = SCNPlane(width: 800, height: 2000)
        water.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 0.7)
        let waterNode = SCNNode(geometry: water)
        waterNode.eulerAngles.x = -CGFloat.pi / 2
        waterNode.position = SCNVector3(-300, -0.5, 0)
        scene.rootNode.addChildNode(waterNode)

        // Sand beach
        let sand = SCNPlane(width: 300, height: 2000)
        sand.firstMaterial?.diffuse.contents = UIColor(red: 0.95, green: 0.85, blue: 0.6, alpha: 1.0)
        let sandNode = SCNNode(geometry: sand)
        sandNode.eulerAngles.x = -CGFloat.pi / 2
        sandNode.position = SCNVector3(-150, -0.9, 0)
        scene.rootNode.addChildNode(sandNode)

        // Road asphalt
        let road = SCNPlane(width: 120, height: 2000)
        road.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        let roadNode = SCNNode(geometry: road)
        roadNode.eulerAngles.x = -CGFloat.pi / 2
        roadNode.position.y = -1
        scene.rootNode.addChildNode(roadNode)

        // Palm trees
        for i in stride(from: -300, through: 600, by: 200) {
            let tree = createPalmTree()
            tree.position = SCNVector3(50, 0, CGFloat(i))
            scene.rootNode.addChildNode(tree)
        }
    }

    private func buildMountainEnvironment(_ scene: SCNScene) {
        // Mountain terrain (simplified elevation)
        let terrain = SCNPyramid(width: 400, height: 300, length: 1500)
        terrain.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.5, blue: 0.3, alpha: 1.0)
        let terrainNode = SCNNode(geometry: terrain)
        terrainNode.position = SCNVector3(0, 100, 0)
        scene.rootNode.addChildNode(terrainNode)

        // Road cutting through mountains
        let road = SCNPlane(width: 120, height: 1500)
        road.firstMaterial?.diffuse.contents = UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0)
        let roadNode = SCNNode(geometry: road)
        roadNode.eulerAngles.x = -CGFloat.pi / 2
        roadNode.position = SCNVector3(0, 10, 0)
        scene.rootNode.addChildNode(roadNode)

        // Pine trees on mountains
        for i in stride(from: -600, through: 600, by: 150) {
            let tree = createPineTree()
            tree.position = SCNVector3(CGFloat.random(in: -300...300), CGFloat.random(in: 150...250), CGFloat(i))
            scene.rootNode.addChildNode(tree)
        }
    }

    private func buildDesertEnvironment(_ scene: SCNScene) {
        // Sand dunes
        let dune = SCNPyramid(width: 600, height: 200, length: 2000)
        dune.firstMaterial?.diffuse.contents = UIColor(red: 0.95, green: 0.8, blue: 0.5, alpha: 1.0)
        let duneNode = SCNNode(geometry: dune)
        duneNode.position = SCNVector3(-200, 50, 0)
        scene.rootNode.addChildNode(duneNode)

        // Desert road (asphalt)
        let road = SCNPlane(width: 120, height: 2000)
        road.firstMaterial?.diffuse.contents = UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0)
        let roadNode = SCNNode(geometry: road)
        roadNode.eulerAngles.x = -CGFloat.pi / 2
        roadNode.position.y = -1
        scene.rootNode.addChildNode(roadNode)

        // Cacti
        for i in stride(from: -400, through: 600, by: 250) {
            let cactus = createCactus()
            cactus.position = SCNVector3(CGFloat.random(in: -250...250), 0, CGFloat(i))
            scene.rootNode.addChildNode(cactus)
        }
    }

    private func buildCityNightsEnvironment(_ scene: SCNScene) {
        buildUrbanEnvironment(scene)
        timeOfDay = .night
        updateLighting()
    }

    private func buildForestEnvironment(_ scene: SCNScene) {
        let forestFloor = SCNPlane(width: 400, height: 2000)
        forestFloor.firstMaterial?.diffuse.contents = UIColor(red: 0.3, green: 0.4, blue: 0.2, alpha: 1.0)
        let floorNode = SCNNode(geometry: forestFloor)
        floorNode.eulerAngles.x = -CGFloat.pi / 2
        floorNode.position.y = -1
        scene.rootNode.addChildNode(floorNode)

        // Dense trees
        for _ in 0..<30 {
            let tree = createDenseTree()
            tree.position = SCNVector3(
                CGFloat.random(in: -200...200),
                0,
                CGFloat.random(in: -800...800)
            )
            scene.rootNode.addChildNode(tree)
        }
    }

    private func buildHighwayLoopEnvironment(_ scene: SCNScene) {
        // Highway surface
        let highway = SCNPlane(width: 150, height: 2000)
        highway.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
        let highwayNode = SCNNode(geometry: highway)
        highwayNode.eulerAngles.x = -CGFloat.pi / 2
        highwayNode.position.y = -1
        scene.rootNode.addChildNode(highwayNode)

        // Lane markers (white dashes)
        for i in stride(from: -800, through: 800, by: 100) {
            let marker = SCNPlane(width: 2, height: 60)
            marker.firstMaterial?.diffuse.contents = UIColor.white
            let markerNode = SCNNode(geometry: marker)
            markerNode.eulerAngles.x = -CGFloat.pi / 2
            markerNode.position = SCNVector3(0, 0, CGFloat(i))
            scene.rootNode.addChildNode(markerNode)
        }

        // Guard rails
        createGuardRails(for: scene)
    }

    private func createBuilding(width: CGFloat, height: CGFloat, depth: CGFloat, color: UIColor) -> SCNNode {
        let box = SCNBox(width: width, height: height, length: depth, chamferRadius: 2)
        box.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: box)
        return node
    }

    private func createStreetLight() -> SCNNode {
        let pole = SCNCylinder(radius: 2, height: 50)
        pole.firstMaterial?.diffuse.contents = UIColor.darkGray
        let poleNode = SCNNode(geometry: pole)
        poleNode.position.y = 25

        let lamp = SCNSphere(radius: 8)
        lamp.firstMaterial?.diffuse.contents = UIColor.yellow
        let lampNode = SCNNode(geometry: lamp)
        lampNode.position.y = 50

        let container = SCNNode()
        container.addChildNode(poleNode)
        container.addChildNode(lampNode)
        return container
    }

    private func createStreetLight(position: SCNVector3) -> SCNNode {
        let light = createStreetLight()
        light.position = position
        return light
    }

    private func createPalmTree() -> SCNNode {
        let trunk = SCNCylinder(radius: 3, height: 30)
        trunk.firstMaterial?.diffuse.contents = UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        let trunkNode = SCNNode(geometry: trunk)
        trunkNode.position.y = 15

        let fronds = SCNSphere(radius: 25)
        fronds.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
        let frondsNode = SCNNode(geometry: fronds)
        frondsNode.position.y = 40

        let container = SCNNode()
        container.addChildNode(trunkNode)
        container.addChildNode(frondsNode)
        return container
    }

    private func createPineTree() -> SCNNode {
        let trunk = SCNCylinder(radius: 2, height: 40)
        trunk.firstMaterial?.diffuse.contents = UIColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
        let trunkNode = SCNNode(geometry: trunk)
        trunkNode.position.y = 20

        let canopy = SCNPyramid(width: 30, height: 60, length: 30)
        canopy.firstMaterial?.diffuse.contents = UIColor(red: 0.1, green: 0.4, blue: 0.2, alpha: 1.0)
        let canopyNode = SCNNode(geometry: canopy)
        canopyNode.position.y = 45

        let container = SCNNode()
        container.addChildNode(trunkNode)
        container.addChildNode(canopyNode)
        return container
    }

    private func createDenseTree() -> SCNNode {
        let trunk = SCNCylinder(radius: 2.5, height: 35)
        trunk.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0)
        let trunkNode = SCNNode(geometry: trunk)
        trunkNode.position.y = 17.5

        let foliage = SCNSphere(radius: 20)
        foliage.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 0.5, blue: 0.1, alpha: 1.0)
        let foliageNode = SCNNode(geometry: foliage)
        foliageNode.position.y = 40

        let container = SCNNode()
        container.addChildNode(trunkNode)
        container.addChildNode(foliageNode)
        return container
    }

    private func createCactus() -> SCNNode {
        let main = SCNCylinder(radius: 4, height: 40)
        main.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.6, blue: 0.2, alpha: 1.0)
        let mainNode = SCNNode(geometry: main)
        mainNode.position.y = 20

        let arm = SCNCylinder(radius: 2, height: 20)
        arm.firstMaterial?.diffuse.contents = UIColor(red: 0.4, green: 0.6, blue: 0.2, alpha: 1.0)
        let armNode = SCNNode(geometry: arm)
        armNode.position = SCNVector3(15, 25, 0)
        armNode.eulerAngles.z = CGFloat.pi / 4

        let container = SCNNode()
        container.addChildNode(mainNode)
        container.addChildNode(armNode)
        return container
    }

    private func createGuardRails(for scene: SCNScene) {
        for i in stride(from: -800, through: 800, by: 100) {
            let rail = SCNBox(width: 8, height: 5, length: 80, chamferRadius: 0)
            rail.firstMaterial?.diffuse.contents = UIColor.gray

            let leftRail = SCNNode(geometry: rail)
            leftRail.position = SCNVector3(-80, 5, CGFloat(i))
            scene.rootNode.addChildNode(leftRail)

            let rightRail = SCNNode(geometry: rail)
            rightRail.position = SCNVector3(80, 5, CGFloat(i))
            scene.rootNode.addChildNode(rightRail)
        }
    }

    private func addEnvironmentalDetails(to scene: SCNScene) {
        // Add clouds
        for _ in 0..<5 {
            let cloud = createCloud()
            cloud.position = SCNVector3(
                CGFloat.random(in: -400...400),
                CGFloat.random(in: 300...400),
                CGFloat.random(in: -400...400)
            )
            scene.rootNode.addChildNode(cloud)
        }
    }

    private func createCloud() -> SCNNode {
        let cloud = SCNSphere(radius: 30)
        cloud.firstMaterial?.diffuse.contents = UIColor.white
        cloud.firstMaterial?.transparency = 0.7
        return SCNNode(geometry: cloud)
    }

    func updateLighting() {
        guard let scene = sceneManager else { return }

        // Remove existing lights
        scene.rootNode.childNodes.forEach { node in
            if node.light != nil {
                node.removeFromParentNode()
            }
        }

        // Ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient

        switch timeOfDay {
        case .dawn:
            ambientLight.color = UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
            ambientLighting = (0.8, 0.6, 0.4)
        case .morning:
            ambientLight.color = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
            ambientLighting = (1.0, 1.0, 0.95)
        case .afternoon:
            ambientLight.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            ambientLighting = (1.0, 1.0, 1.0)
        case .sunset:
            ambientLight.color = UIColor(red: 1.0, green: 0.7, blue: 0.5, alpha: 1.0)
            ambientLighting = (1.0, 0.7, 0.5)
        case .night:
            ambientLight.color = UIColor(red: 0.3, green: 0.35, blue: 0.4, alpha: 1.0)
            ambientLighting = (0.3, 0.35, 0.4)
        }

        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)

        // Directional light (sun/moon)
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 800

        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.eulerAngles = SCNVector3(-CGFloat.pi / 4, CGFloat.pi / 4, 0)
        scene.rootNode.addChildNode(directionalNode)

        // Weather effects on lighting
        switch weatherCondition {
        case .foggy, .stormy:
            visibility = 50.0
        case .rainy:
            visibility = 70.0
        default:
            visibility = 100.0
        }
    }

    func setWeather(_ weather: WeatherType) {
        weatherCondition = weather
        updateLighting()
    }

    func setTimeOfDay(_ time: TimeOfDay) {
        timeOfDay = time
        updateLighting()
    }

    func getCameraPosition(for track: String) -> (position: SCNVector3, target: SCNVector3) {
        return cameraController.getCameraFrame(for: track)
    }
}

// MARK: - Cinematic Camera Controller
@MainActor
class CinematicCameraController {
    func getCameraFrame(for track: String) -> (position: SCNVector3, target: SCNVector3) {
        switch track {
        case "urbanStreet":
            return (SCNVector3(0, 50, -200), SCNVector3(0, 20, 100))
        case "coastalRoad":
            return (SCNVector3(-100, 80, -150), SCNVector3(0, 10, 200))
        case "mountainPass":
            return (SCNVector3(150, 200, -300), SCNVector3(0, 50, 300))
        case "desertHighway":
            return (SCNVector3(200, 100, -400), SCNVector3(0, 20, 300))
        case "cityNights":
            return (SCNVector3(100, 80, -250), SCNVector3(0, 40, 100))
        case "forestTrail":
            return (SCNVector3(-150, 60, -200), SCNVector3(0, 20, 200))
        default:
            return (SCNVector3(0, 80, -200), SCNVector3(0, 20, 150))
        }
    }
}
