// GameIO 2P — AudioManager.swift
// AVAudioEngine-based audio system
// Handles: background music, SFX, engine sounds, spatial audio
// Platforms: iPhone, iPad, Mac, tvOS (not Watch — limited audio)

import AVFoundation
import Combine
import Foundation

// MARK: - Sound Effect Types
public enum SoundEffect: String, CaseIterable {
    case engineStart     = "engine_start"
    case engineIdle      = "engine_idle"
    case engineRev       = "engine_rev"
    case tireSquealing   = "tire_squeal"
    case collision       = "collision"
    case nitroBoost      = "nitro"
    case countdownBeep   = "countdown_beep"
    case countdownGo     = "countdown_go"
    case lapComplete     = "lap_complete"
    case raceWin         = "race_win"
    case raceLose        = "race_lose"
    case buttonTap       = "button_tap"
    case menuSelect      = "menu_select"
    case achievementUnlock = "achievement"
    case carSelect       = "car_select"
    case avatarChange    = "avatar_change"
    case elevatorDing    = "elevator_ding"
    case doorOpen        = "door_open"
    case coin            = "coin"
    case portalEnter     = "portal_enter"
}

// MARK: - Music Track Types
public enum MusicTrack: String {
    case menu        = "menu_music"
    case racing      = "racing_music"
    case lobby       = "lobby_music"
    case carSelect   = "car_select_music"
    case victory     = "victory_music"
    case garage      = "garage_music"
}

// MARK: - AudioManager
@MainActor
public final class AudioManager: ObservableObject {

    // MARK: - Published State
    @Published public var isMusicPlaying: Bool = false
    @Published public var currentTrack: MusicTrack?
    @Published public var musicVolume: Float = 0.8 {
        didSet { updateMusicVolume() }
    }
    @Published public var sfxVolume: Float = 1.0 {
        didSet { updateSFXVolume() }
    }
    @Published public var isAudioEnabled: Bool = true {
        didSet {
            if !isAudioEnabled { stopAll() }
        }
    }

    // MARK: - Private
    private let audioEngine = AVAudioEngine()
    private var musicPlayer: AVAudioPlayerNode?
    private var sfxNodes: [SoundEffect: AVAudioPlayerNode] = [:]
    private var musicMixer = AVAudioMixerNode()
    private var sfxMixer   = AVAudioMixerNode()
    private var reverbNode  = AVAudioUnitReverb()
    private var eqNode      = AVAudioUnitEQ(numberOfBands: 5)
    private var engineTonePlayer: AVAudioPlayerNode?
    private var engineFrequency: Float = 80.0

    // Procedural audio buffers (generated in memory)
    private var generatedBuffers: [SoundEffect: AVAudioPCMBuffer] = [:]
    private var musicBuffers: [MusicTrack: AVAudioPCMBuffer] = [:]

    // MARK: - Singleton
    public static let shared = AudioManager()
    private init() {
        setupAudioSession()
        setupAudioEngine()
        generateProceduralSounds()
    }

    // MARK: - Audio Session
    private func setupAudioSession() {
        #if os(iOS) || os(tvOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("GameIO 2P AudioManager: Audio session setup failed: \(error)")
        }
        #endif
    }

    // MARK: - Engine Setup
    private func setupAudioEngine() {
        // Attach mixer nodes
        audioEngine.attach(musicMixer)
        audioEngine.attach(sfxMixer)
        audioEngine.attach(reverbNode)
        audioEngine.attach(eqNode)

        // Configure reverb
        reverbNode.loadFactoryPreset(.mediumHall)
        reverbNode.wetDryMix = 15.0

        // Configure EQ for HDR-like sound (boosted highs and bass)
        configureEQ()

        // Connect nodes
        let format = audioEngine.mainMixerNode.outputFormat(forBus: 0)
        audioEngine.connect(musicMixer, to: reverbNode, format: format)
        audioEngine.connect(reverbNode, to: audioEngine.mainMixerNode, format: format)
        audioEngine.connect(sfxMixer, to: eqNode, format: format)
        audioEngine.connect(eqNode, to: audioEngine.mainMixerNode, format: format)

        // Set initial volumes
        musicMixer.outputVolume = musicVolume
        sfxMixer.outputVolume = sfxVolume

        // Start engine
        do {
            try audioEngine.start()
        } catch {
            print("GameIO 2P: Audio engine start failed: \(error)")
        }
    }

    private func configureEQ() {
        // Sub-bass boost (for car engine rumble feel)
        eqNode.bands[0].filterType = .lowShelf
        eqNode.bands[0].frequency  = 60.0
        eqNode.bands[0].gain       = 3.0
        eqNode.bands[0].bypass     = false

        // Bass presence
        eqNode.bands[1].filterType = .parametric
        eqNode.bands[1].frequency  = 200.0
        eqNode.bands[1].bandwidth  = 1.0
        eqNode.bands[1].gain       = 1.5
        eqNode.bands[1].bypass     = false

        // Mid cut (reduce boxiness)
        eqNode.bands[2].filterType = .parametric
        eqNode.bands[2].frequency  = 800.0
        eqNode.bands[2].bandwidth  = 1.0
        eqNode.bands[2].gain       = -1.0
        eqNode.bands[2].bypass     = false

        // High-mid presence (clarity for SFX)
        eqNode.bands[3].filterType = .parametric
        eqNode.bands[3].frequency  = 4000.0
        eqNode.bands[3].bandwidth  = 1.5
        eqNode.bands[3].gain       = 2.0
        eqNode.bands[3].bypass     = false

        // High-frequency sparkle (HDR "air")
        eqNode.bands[4].filterType = .highShelf
        eqNode.bands[4].frequency  = 12000.0
        eqNode.bands[4].gain       = 2.5
        eqNode.bands[4].bypass     = false
    }

    // MARK: - Procedural Sound Generation
    /// Generates all SFX in memory using DSP — no audio files needed
    private func generateProceduralSounds() {
        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!

        // Engine start sound
        generatedBuffers[.engineStart] = generateEngineStartBuffer(format: format, sampleRate: sampleRate)

        // Button tap — short click
        generatedBuffers[.buttonTap] = generateClickBuffer(format: format, sampleRate: sampleRate, frequency: 800, duration: 0.05)

        // Menu select — slightly lower click
        generatedBuffers[.menuSelect] = generateClickBuffer(format: format, sampleRate: sampleRate, frequency: 600, duration: 0.07)

        // Countdown beep
        generatedBuffers[.countdownBeep] = generateToneBuffer(format: format, sampleRate: sampleRate, frequency: 880, duration: 0.2)

        // Countdown GO!
        generatedBuffers[.countdownGo] = generateToneBuffer(format: format, sampleRate: sampleRate, frequency: 1320, duration: 0.5)

        // Coin/reward
        generatedBuffers[.coin] = generateCoinBuffer(format: format, sampleRate: sampleRate)

        // Achievement
        generatedBuffers[.achievementUnlock] = generateFanfareBuffer(format: format, sampleRate: sampleRate)

        // Elevator ding
        generatedBuffers[.elevatorDing] = generateDingBuffer(format: format, sampleRate: sampleRate)
    }

    private func generateEngineStartBuffer(format: AVAudioFormat, sampleRate: Double) -> AVAudioPCMBuffer {
        let duration = 1.5
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let left  = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = min(1.0, t / 0.3) * max(0.0, 1.0 - (t - 1.0) / 0.5)
            // Rising pitch engine start
            let freq = 80.0 + t * 200.0
            let fundamental = sin(2.0 * .pi * freq * t)
            let harmonic2   = sin(2.0 * .pi * freq * 2 * t) * 0.5
            let harmonic3   = sin(2.0 * .pi * freq * 3 * t) * 0.25
            let noise = Float.random(in: -0.02...0.02)
            let sample = Float((fundamental + harmonic2 + harmonic3) * envelope * 0.3) + noise
            left[i]  = sample
            right[i] = sample * 0.95
        }
        return buffer
    }

    private func generateClickBuffer(format: AVAudioFormat, sampleRate: Double, frequency: Double, duration: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let left  = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = exp(-t * 50.0)
            let sample = Float(sin(2.0 * .pi * frequency * t) * envelope * 0.4)
            left[i]  = sample
            right[i] = sample
        }
        return buffer
    }

    private func generateToneBuffer(format: AVAudioFormat, sampleRate: Double, frequency: Double, duration: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let left  = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let attackTime  = 0.01
            let releaseTime = 0.1
            let sustainEnd  = duration - releaseTime
            let env: Double
            if t < attackTime {
                env = t / attackTime
            } else if t > sustainEnd {
                env = (duration - t) / releaseTime
            } else {
                env = 1.0
            }
            let sample = Float(sin(2.0 * .pi * frequency * t) * env * 0.5)
            left[i]  = sample
            right[i] = sample
        }
        return buffer
    }

    private func generateCoinBuffer(format: AVAudioFormat, sampleRate: Double) -> AVAudioPCMBuffer {
        let duration = 0.3
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let left  = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        // Two-note coin sound (like Mario)
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let freq = t < 0.1 ? 988.0 : 1319.0  // B5 then E6
            let env = exp(-t * 8.0)
            let sample = Float(sin(2.0 * .pi * freq * t) * env * 0.5)
            left[i]  = sample
            right[i] = sample
        }
        return buffer
    }

    private func generateFanfareBuffer(format: AVAudioFormat, sampleRate: Double) -> AVAudioPCMBuffer {
        let duration = 1.2
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let left  = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        // C major arpeggio fanfare
        let notes: [(Double, Double)] = [(0.0, 523.25), (0.15, 659.25), (0.3, 783.99), (0.45, 1046.5)]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            var sample: Double = 0
            for (startTime, freq) in notes {
                if t >= startTime {
                    let localT = t - startTime
                    let env = exp(-localT * 5.0)
                    sample += sin(2.0 * .pi * freq * t) * env * 0.25
                }
            }
            left[i]  = Float(sample)
            right[i] = Float(sample * 0.9)
        }
        return buffer
    }

    private func generateDingBuffer(format: AVAudioFormat, sampleRate: Double) -> AVAudioPCMBuffer {
        let duration = 0.8
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let left  = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let env = exp(-t * 4.0)
            let sample = Float((sin(2.0 * .pi * 440 * t) + sin(2.0 * .pi * 880 * t) * 0.3) * env * 0.4)
            left[i]  = sample
            right[i] = sample * 0.9 + Float(sin(2.0 * .pi * 660 * t) * env * 0.1)
        }
        return buffer
    }

    // MARK: - Play SFX
    public func playSFX(_ effect: SoundEffect) {
        guard isAudioEnabled, let buffer = generatedBuffers[effect] else { return }
        let node = AVAudioPlayerNode()
        audioEngine.attach(node)
        audioEngine.connect(node, to: sfxMixer, format: buffer.format)
        node.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.audioEngine.detach(node)
            }
        }
        node.play()
    }

    // MARK: - Music
    public func playMusic(_ track: MusicTrack) {
        guard isAudioEnabled else { return }
        currentTrack = track
        isMusicPlaying = true
        // In production, load from bundle. For now, play generated ambient
        playGeneratedMusic(track: track)
    }

    private func playGeneratedMusic(track: MusicTrack) {
        // Ambient procedural music based on track type
        stopMusic()
        let node = AVAudioPlayerNode()
        musicPlayer = node
        audioEngine.attach(node)
        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let buffer = generateAmbientMusicBuffer(track: track, format: format, sampleRate: sampleRate)
        audioEngine.connect(node, to: musicMixer, format: format)
        node.scheduleBuffer(buffer, at: nil, options: .loops)
        node.play()
    }

    private func generateAmbientMusicBuffer(track: MusicTrack, format: AVAudioFormat, sampleRate: Double) -> AVAudioPCMBuffer {
        let duration = 8.0  // Loop length
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let left  = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]

        // Track-specific chord progressions
        let chord: [Double]
        switch track {
        case .menu:       chord = [261.63, 329.63, 392.00, 523.25]  // C major
        case .racing:     chord = [220.00, 277.18, 329.63, 440.00]  // A minor
        case .lobby:      chord = [293.66, 369.99, 440.00, 587.33]  // D major
        case .carSelect:  chord = [246.94, 311.13, 369.99, 493.88]  // B minor
        case .victory:    chord = [261.63, 329.63, 392.00, 523.25]  // C major bright
        case .garage:     chord = [196.00, 246.94, 293.66, 392.00]  // G major warm
        }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            var sample: Double = 0
            for (j, freq) in chord.enumerated() {
                let phase = Double(j) * 0.5
                sample += sin(2.0 * .pi * freq * t + phase) * 0.08
                sample += sin(2.0 * .pi * freq * 0.5 * t + phase) * 0.04  // Sub octave
            }
            // Slow LFO tremolo
            let lfo = 0.8 + 0.2 * sin(2.0 * .pi * 0.25 * t)
            let fadeIn = min(1.0, t / 2.0)
            let fadeOut = min(1.0, (duration - t) / 2.0)
            let env = min(fadeIn, fadeOut)
            left[i]  = Float(sample * lfo * env)
            right[i] = Float(sample * lfo * env * 0.95 + sin(2.0 * .pi * chord[0] * 0.99 * t) * 0.02)
        }
        return buffer
    }

    public func stopMusic() {
        musicPlayer?.stop()
        if let node = musicPlayer {
            audioEngine.detach(node)
        }
        musicPlayer = nil
        isMusicPlaying = false
    }

    public func stopAll() {
        stopMusic()
        engineTonePlayer?.stop()
    }

    // MARK: - Volume
    private func updateMusicVolume() {
        musicMixer.outputVolume = musicVolume
    }
    private func updateSFXVolume() {
        sfxMixer.outputVolume = sfxVolume
    }

    // MARK: - Engine Sound (continuous, pitch follows speed)
    public func startEngineSound(rpm: Float = 1000) {
        guard isAudioEnabled else { return }
        updateEngineRPM(rpm)
    }

    public func updateEngineRPM(_ rpm: Float) {
        // Map RPM to frequency (idle ~80Hz, redline ~200Hz)
        engineFrequency = 80.0 + (rpm / 8000.0) * 120.0
    }

    public func stopEngineSound() {
        engineTonePlayer?.stop()
        if let node = engineTonePlayer {
            audioEngine.detach(node)
        }
        engineTonePlayer = nil
    }
}
