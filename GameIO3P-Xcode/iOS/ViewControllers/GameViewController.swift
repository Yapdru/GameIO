// GameViewController.swift
// GameIO 2P — Game View Controller
// UIViewController with Canvas game rendering and gesture handling.

import UIKit
import SwiftUI
import Combine

// MARK: - Game State

enum GamePhase {
    case countdown(Int)
    case racing
    case finished
    case paused
}

// MARK: - GameViewController

class GameViewController: UIViewController {
    // Sub-views
    private var gameCanvasView: GameCanvasView!
    private var hudHostingController: UIHostingController<GameHUDView>!
    private var pauseHostingController: UIHostingController<PauseMenuView>?

    // State
    private let hudState = HUDState()
    private let raceEngine = RaceEngine()
    private var gamePhase: GamePhase = .countdown(3)
    private var cancellables = Set<AnyCancellable>()

    // Gesture recognizers
    private var panGesture: UIPanGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
    private var swipeLeftGesture: UISwipeGestureRecognizer!
    private var swipeRightGesture: UISwipeGestureRecognizer!

    // Display link for game loop
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0

    // Input state
    private var steerInput: Float = 0    // -1 (left) to 1 (right)
    private var throttleInput: Float = 0  // 0 to 1

    var gameID: Int = 0
    var onGameFinished: ((RaceResultData) -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupGameCanvas()
        setupHUD()
        setupGestures()
        bindRaceEngine()
        startCountdown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startDisplayLink()
        AudioService.shared.playEngineSound()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplayLink()
        AudioService.shared.stopEngineSound()
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }

    // MARK: - Setup

    private func setupGameCanvas() {
        gameCanvasView = GameCanvasView(frame: view.bounds)
        gameCanvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gameCanvasView)
        gameCanvasView.raceEngine = raceEngine
    }

    private func setupHUD() {
        let hudView = GameHUDView(hud: hudState,
                                  onPause: { [weak self] in self?.togglePause() },
                                  onNitro: { [weak self] in self?.activateNitro() })
        hudHostingController = UIHostingController(rootView: hudView)
        hudHostingController.view.backgroundColor = .clear
        addChild(hudHostingController)
        view.addSubview(hudHostingController.view)
        hudHostingController.view.frame = view.bounds
        hudHostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hudHostingController.didMove(toParent: self)
    }

    private func setupGestures() {
        // Steering: pan left/right
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)

        // Throttle: tap
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        // Swipe gestures for quick actions
        swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)

        swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
    }

    // MARK: - Engine Binding

    private func bindRaceEngine() {
        raceEngine.$playerSpeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in self?.hudState.speed = Double(speed) }
            .store(in: &cancellables)

        raceEngine.$currentLap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lap in self?.hudState.currentLap = lap }
            .store(in: &cancellables)

        raceEngine.$playerPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pos in self?.hudState.position = pos }
            .store(in: &cancellables)

        raceEngine.$nitroCharge
            .receive(on: DispatchQueue.main)
            .sink { [weak self] charge in self?.hudState.nitroCharge = Double(charge) }
            .store(in: &cancellables)

        raceEngine.$fuelLevel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fuel in self?.hudState.fuelLevel = Double(fuel) }
            .store(in: &cancellables)

        raceEngine.$raceFinished
            .receive(on: DispatchQueue.main)
            .filter { $0 }
            .sink { [weak self] _ in self?.handleRaceFinished() }
            .store(in: &cancellables)
    }

    // MARK: - Display Link / Game Loop

    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop(_:)))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120)
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func gameLoop(_ link: CADisplayLink) {
        guard case .racing = gamePhase else { return }
        let dt = lastFrameTime == 0 ? 0.016 : Float(link.timestamp - lastFrameTime)
        lastFrameTime = link.timestamp

        raceEngine.update(deltaTime: dt, steer: steerInput, throttle: throttleInput)
        hudState.raceTime = raceEngine.elapsedTime
        hudState.lapTime = raceEngine.currentLapTime
        hudState.carPosition = raceEngine.normalizedCarPosition
        hudState.opponentPosition = raceEngine.normalizedOpponentPosition

        gameCanvasView.setNeedsDisplay()
        AudioService.shared.updateEngineSpeed(raceEngine.playerSpeed)
    }

    // MARK: - Gestures

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: view)
        steerInput = Float(max(-1, min(1, velocity.x / view.bounds.width * 2)))
        if gesture.state == .ended || gesture.state == .cancelled { steerInput = 0 }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let loc = gesture.location(in: view)
        // Right half: accelerate, left half: brake
        throttleInput = loc.x > view.bounds.midX ? 1.0 : -0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in self?.throttleInput = 0 }
    }

    @objc private func handleSwipeLeft() { raceEngine.changeLane(direction: -1) }
    @objc private func handleSwipeRight() { raceEngine.changeLane(direction: 1) }

    // MARK: - Pause / Resume

    private func togglePause() {
        if case .paused = gamePhase {
            resumeGame()
        } else {
            pauseGame()
        }
    }

    private func pauseGame() {
        gamePhase = .paused
        displayLink?.isPaused = true
        AudioService.shared.pauseAll()
        showPauseMenu()
    }

    private func resumeGame() {
        gamePhase = .racing
        displayLink?.isPaused = false
        AudioService.shared.resumeAll()
        hidePauseMenu()
        lastFrameTime = 0
    }

    private func showPauseMenu() {
        let pauseView = PauseMenuView(
            onResume: { [weak self] in self?.resumeGame() },
            onRestart: { [weak self] in self?.restartGame() },
            onSettings: { [weak self] in self?.showSettings() },
            onQuit: { [weak self] in self?.quitGame() }
        )
        let hc = UIHostingController(rootView: pauseView)
        hc.view.backgroundColor = .clear
        hc.modalPresentationStyle = .overFullScreen
        present(hc, animated: false)
        pauseHostingController = hc
    }

    private func hidePauseMenu() {
        pauseHostingController?.dismiss(animated: false)
        pauseHostingController = nil
    }

    // MARK: - Game Control

    private func activateNitro() {
        guard hudState.nitroCharge > 0.2 else { return }
        raceEngine.activateNitro()
        HapticService.shared.nitroBoost()
    }

    private func startCountdown() {
        gamePhase = .countdown(3)
        var count = 3
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            count -= 1
            if count > 0 {
                self?.gamePhase = .countdown(count)
            } else {
                timer.invalidate()
                self?.gamePhase = .racing
                self?.lastFrameTime = 0
            }
        }
    }

    private func restartGame() {
        hidePauseMenu()
        raceEngine.reset()
        startCountdown()
    }

    private func showSettings() {}

    private func quitGame() {
        hidePauseMenu()
        stopDisplayLink()
        dismiss(animated: true)
    }

    private func handleRaceFinished() {
        gamePhase = .finished
        stopDisplayLink()
        let result = raceEngine.buildResult(gameName: "NITRO RACER")
        onGameFinished?(result)
    }
}

// MARK: - Game Canvas UIView

class GameCanvasView: UIView {
    weak var raceEngine: RaceEngine?
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), let engine = raceEngine else { return }
        engine.render(in: ctx, bounds: rect)
    }
}
