// StoryboardManager.swift — Narrative Flow & Cinematic Storytelling
// Roblox-inspired game progression with cinematic sequences and world narrative

import SwiftUI

@MainActor
class StoryboardManager: NSObject, ObservableObject {
    @Published var currentChapter: StoryChapter = .prologue
    @Published var cinematicSequence: CinematicSequence?
    @Published var narrative: String = ""
    @Published var objectiveText: String = ""
    @Published var progressInChapter: Double = 0.0

    enum StoryChapter: String, CaseIterable {
        case prologue, urbanChallenge, coastalRushChapter, mountainLegend, desertKing, nightCity, forestMystery, epicGrandFinale

        var description: String {
            switch self {
            case .prologue: return "Welcome to GameIO"
            case .urbanChallenge: return "City Streets Challenge"
            case .coastalRushChapter: return "Coastal Rush"
            case .mountainLegend: return "Mountain Legend"
            case .desertKing: return "Desert King"
            case .nightCity: return "Neon Nights"
            case .forestMystery: return "Forest Trail Mystery"
            case .epicGrandFinale: return "Epic Grand Finale"
            }
        }

        var narrative: String {
            switch self {
            case .prologue:
                return "You stand at the garage entrance. Your crew challenges you to prove your driving skills across legendary tracks. The road awaits."
            case .urbanChallenge:
                return "The city streets pulse with energy. Navigate through traffic, showcase your precision, and earn street credibility."
            case .coastalRushChapter:
                return "The ocean breeze guides you along scenic coastal roads. Speed and precision are your allies in this breathtaking race."
            case .mountainLegend:
                return "Alpine passes test your skill. Master the elevation, master the mountain. Legends are forged here."
            case .desertKing:
                return "Endless horizons stretch before you. The desert challenges your endurance. Only the fastest claim the crown."
            case .nightCity:
                return "Neon lights illuminate the city. Urban racing reaches new heights. The night is yours to conquer."
            case .forestMystery:
                return "Hidden trails wind through ancient forests. Speed meets nature. Discover what lies beyond the trees."
            case .epicGrandFinale:
                return "All skills converged. All challenges overcome. Face the ultimate test. Your legacy awaits."
            }
        }

        var objective: String {
            switch self {
            case .prologue: return "Create your avatar and select your first vehicle"
            case .urbanChallenge: return "Complete 3 laps on Urban Street • Time: 5:00"
            case .coastalRushChapter: return "Navigate coastal roads • Avoid 5 obstacles • Maintain speed"
            case .mountainLegend: return "Conquer elevation • Complete without crashing • Collect 5 coins"
            case .desertKing: return "Cross the desert • Manage fuel wisely • Beat target time"
            case .nightCity: return "Race through neon streets • 2-minute sprint • Avoid traffic"
            case .forestMystery: return "Trail navigation • Dodge trees and obstacles • Find hidden shortcut"
            case .epicGrandFinale: return "Final race • All opponents • Win to unlock rewards"
            }
        }
    }

    struct CinematicSequence {
        let id: String
        let title: String
        let duration: TimeInterval
        let cameraPath: [SCNVector3]
        let voiceOver: String?
        let musicTrack: String
    }

    static let shared = StoryboardManager()

    override init() {
        super.init()
    }

    func loadChapter(_ chapter: StoryChapter) {
        currentChapter = chapter
        narrative = chapter.narrative
        objectiveText = chapter.objective
        progressInChapter = 0.0

        playIntroSequence(for: chapter)
    }

    private func playIntroSequence(for chapter: StoryChapter) {
        let sequence = createIntroSequence(for: chapter)
        cinematicSequence = sequence
    }

    private func createIntroSequence(for chapter: StoryChapter) -> CinematicSequence {
        switch chapter {
        case .prologue:
            return CinematicSequence(
                id: "prologue_intro",
                title: "Welcome to GameIO 3P",
                duration: 8.0,
                cameraPath: [
                    SCNVector3(0, 100, -200),
                    SCNVector3(100, 80, -100),
                    SCNVector3(0, 50, 50)
                ],
                voiceOver: "Welcome to GameIO. The ultimate racing experience.",
                musicTrack: "prologue_theme"
            )

        case .urbanChallenge:
            return CinematicSequence(
                id: "urban_intro",
                title: "City Streets Challenge",
                duration: 6.0,
                cameraPath: [
                    SCNVector3(0, 80, -300),
                    SCNVector3(150, 100, -150),
                    SCNVector3(0, 60, 50)
                ],
                voiceOver: "The city awakens. Showcase your skills.",
                musicTrack: "urban_beat"
            )

        case .coastalRushChapter:
            return CinematicSequence(
                id: "coastal_intro",
                title: "Coastal Rush",
                duration: 7.0,
                cameraPath: [
                    SCNVector3(-300, 120, -300),
                    SCNVector3(0, 80, 0),
                    SCNVector3(200, 60, 200)
                ],
                voiceOver: "Ocean winds embrace the coastal race.",
                musicTrack: "coastal_adventure"
            )

        case .mountainLegend:
            return CinematicSequence(
                id: "mountain_intro",
                title: "Mountain Legend",
                duration: 8.0,
                cameraPath: [
                    SCNVector3(0, 300, -500),
                    SCNVector3(300, 250, -200),
                    SCNVector3(0, 100, 0)
                ],
                voiceOver: "Mountains test the greatest drivers.",
                musicTrack: "mountain_epic"
            )

        case .desertKing:
            return CinematicSequence(
                id: "desert_intro",
                title: "Desert King",
                duration: 7.0,
                cameraPath: [
                    SCNVector3(400, 150, -400),
                    SCNVector3(0, 100, 0),
                    SCNVector3(-300, 80, 200)
                ],
                voiceOver: "Endless desert. Endless possibilities.",
                musicTrack: "desert_whisper"
            )

        case .nightCity:
            return CinematicSequence(
                id: "night_intro",
                title: "Neon Nights",
                duration: 7.0,
                cameraPath: [
                    SCNVector3(0, 100, -300),
                    SCNVector3(250, 80, -100),
                    SCNVector3(-150, 60, 50)
                ],
                voiceOver: "Neon lights guide your path.",
                musicTrack: "neon_pulse"
            )

        case .forestMystery:
            return CinematicSequence(
                id: "forest_intro",
                title: "Forest Mystery",
                duration: 8.0,
                cameraPath: [
                    SCNVector3(-400, 150, -400),
                    SCNVector3(0, 80, 0),
                    SCNVector3(300, 60, 200)
                ],
                voiceOver: "Nature reveals its secrets.",
                musicTrack: "forest_whispers"
            )

        case .epicGrandFinale:
            return CinematicSequence(
                id: "finale_intro",
                title: "Epic Grand Finale",
                duration: 12.0,
                cameraPath: [
                    SCNVector3(0, 200, -500),
                    SCNVector3(300, 250, -300),
                    SCNVector3(-300, 150, 200),
                    SCNVector3(0, 100, 0)
                ],
                voiceOver: "This is it. Prove yourself. Become a legend.",
                musicTrack: "finale_epic"
            )
        }
    }

    func updateProgress(to percentage: Double) {
        progressInChapter = min(1.0, percentage)
    }

    func advanceToNextChapter() {
        let chapters = StoryChapter.allCases
        if let currentIndex = chapters.firstIndex(of: currentChapter),
           currentIndex < chapters.count - 1 {
            loadChapter(chapters[currentIndex + 1])
        }
    }

    func getChapterRewards(for chapter: StoryChapter) -> ChapterReward {
        switch chapter {
        case .prologue:
            return ChapterReward(
                xp: 100,
                credits: 500,
                unlocks: ["Urban Street Track"],
                cosmetics: ["Red Paint Job"]
            )
        case .urbanChallenge:
            return ChapterReward(
                xp: 250,
                credits: 1500,
                unlocks: ["Coastal Road Track"],
                cosmetics: ["Chrome Wheels"]
            )
        case .coastalRushChapter:
            return ChapterReward(
                xp: 300,
                credits: 2000,
                unlocks: ["Mountain Pass Track"],
                cosmetics: ["Blue Neon Kit"]
            )
        case .mountainLegend:
            return ChapterReward(
                xp: 350,
                credits: 2500,
                unlocks: ["Desert Highway Track"],
                cosmetics: ["Gold Engine Kit"]
            )
        case .desertKing:
            return ChapterReward(
                xp: 400,
                credits: 3000,
                unlocks: ["Neon City Track"],
                cosmetics: ["Matrix Green Lights"]
            )
        case .nightCity:
            return ChapterReward(
                xp: 400,
                credits: 3000,
                unlocks: ["Forest Trail Track"],
                cosmetics: ["Cyberpunk Hood"]
            )
        case .forestMystery:
            return ChapterReward(
                xp: 450,
                credits: 3500,
                unlocks: [],
                cosmetics: ["Legendary Badge"]
            )
        case .epicGrandFinale:
            return ChapterReward(
                xp: 500,
                credits: 5000,
                unlocks: ["Championship Mode"],
                cosmetics: ["Platinum Finish", "Victory Crown"]
            )
        }
    }

    struct ChapterReward {
        let xp: Int
        let credits: Int
        let unlocks: [String]
        let cosmetics: [String]
    }
}

// MARK: - Cinematic Transition View
struct CinematicTransitionView: View {
    let sequence: StoryboardManager.CinematicSequence
    let onComplete: () -> Void

    @State private var displayedTime: TimeInterval = 0
    @State private var alphaIn: Double = 0

    var body: some View {
        ZStack {
            // Background with depth
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Cinematic text
                VStack(spacing: 16) {
                    Text(sequence.title)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    if let voiceOver = sequence.voiceOver {
                        Text(voiceOver)
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                .padding(40)
                .frame(maxWidth: 500)
                .opacity(alphaIn)

                Spacer()

                // Progress indicator
                ProgressView(value: displayedTime, total: sequence.duration)
                    .tint(Color(red: 0.1, green: 0.4, blue: 0.8))
                    .padding(40)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                alphaIn = 1.0
            }

            Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
                displayedTime += 0.016
                if displayedTime >= sequence.duration {
                    timer.invalidate()
                    withAnimation {
                        alphaIn = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
        }
    }
}
