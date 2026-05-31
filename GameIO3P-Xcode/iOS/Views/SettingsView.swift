// SettingsView.swift
// GameIO 2P — Settings Screen
// Graphics quality, audio toggle, sliders, haptics, language.

import SwiftUI
import AVFoundation

struct AppSettings: Codable {
    var graphicsQuality: GraphicsQuality = .high
    var audioEnabled: Bool = true
    var musicVolume: Float = 0.8
    var sfxVolume: Float = 1.0
    var hapticsEnabled: Bool = true
    var language: Language = .english
    var showFPS: Bool = false
    var motionBlur: Bool = true
    var particles: Bool = true
    var colorBlindMode: ColorBlindMode = .none
    var controlScheme: ControlScheme = .tilt

    enum GraphicsQuality: String, Codable, CaseIterable { case low, medium, high, ultra }
    enum Language: String, Codable, CaseIterable { case english, spanish, french, german, japanese, korean, chinese }
    enum ColorBlindMode: String, Codable, CaseIterable { case none, deuteranopia, protanopia, tritanopia }
    enum ControlScheme: String, Codable, CaseIterable { case tilt, touch, gamepad }
}

class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings = AppSettings()

    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "app_settings")
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "app_settings"),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    func reset() { settings = AppSettings() }
}

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @State private var showResetAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0A0010").ignoresSafeArea()

                List {
                    // Graphics
                    Section {
                        graphicsSection
                    } header: { sectionHeader("GRAPHICS") }

                    // Audio
                    Section {
                        audioSection
                    } header: { sectionHeader("AUDIO") }

                    // Controls
                    Section {
                        controlsSection
                    } header: { sectionHeader("CONTROLS") }

                    // Accessibility
                    Section {
                        accessibilitySection
                    } header: { sectionHeader("ACCESSIBILITY") }

                    // Language
                    Section {
                        languageSection
                    } header: { sectionHeader("LANGUAGE") }

                    // Account
                    Section {
                        accountSection
                    } header: { sectionHeader("ACCOUNT") }

                    // Danger zone
                    Section {
                        Button(role: .destructive) { showResetAlert = true } label: {
                            Label("Reset All Settings", systemImage: "arrow.counterclockwise")
                        }
                    } header: { sectionHeader("ADVANCED") }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("SETTINGS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("SAVE") {
                        vm.save()
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "#00FF88"))
                }
            }
            .alert("Reset Settings?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) { vm.reset() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All settings will be restored to defaults.")
            }
        }
        .onAppear { vm.load() }
    }

    @ViewBuilder
    private var graphicsSection: some View {
        Picker("Quality", selection: $vm.settings.graphicsQuality) {
            ForEach(AppSettings.GraphicsQuality.allCases, id: \.self) { q in
                Text(q.rawValue.uppercased()).tag(q)
            }
        }
        .pickerStyle(.segmented)
        .listRowBackground(Color.white.opacity(0.05))

        Toggle(isOn: $vm.settings.motionBlur) {
            Label("Motion Blur", systemImage: "camera.filters")
        }
        .tint(Color(hex: "#FF6B35"))
        .listRowBackground(Color.white.opacity(0.05))

        Toggle(isOn: $vm.settings.particles) {
            Label("Particles", systemImage: "sparkles")
        }
        .tint(Color(hex: "#FF6B35"))
        .listRowBackground(Color.white.opacity(0.05))

        Toggle(isOn: $vm.settings.showFPS) {
            Label("Show FPS Counter", systemImage: "gauge.high")
        }
        .tint(Color(hex: "#FF6B35"))
        .listRowBackground(Color.white.opacity(0.05))
    }

    @ViewBuilder
    private var audioSection: some View {
        Toggle(isOn: $vm.settings.audioEnabled) {
            Label("Audio Enabled", systemImage: "speaker.wave.2.fill")
        }
        .tint(Color(hex: "#00FF88"))
        .listRowBackground(Color.white.opacity(0.05))

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Music", systemImage: "music.note")
                    .font(.system(size: 14))
                Spacer()
                Text("\(Int(vm.settings.musicVolume * 100))%")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Slider(value: $vm.settings.musicVolume, in: 0...1)
                .tint(Color(hex: "#7B61FF"))
                .disabled(!vm.settings.audioEnabled)
        }
        .listRowBackground(Color.white.opacity(0.05))

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("SFX", systemImage: "waveform")
                    .font(.system(size: 14))
                Spacer()
                Text("\(Int(vm.settings.sfxVolume * 100))%")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Slider(value: $vm.settings.sfxVolume, in: 0...1)
                .tint(Color(hex: "#00E5FF"))
                .disabled(!vm.settings.audioEnabled)
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    @ViewBuilder
    private var controlsSection: some View {
        Toggle(isOn: $vm.settings.hapticsEnabled) {
            Label("Haptic Feedback", systemImage: "hand.tap.fill")
        }
        .tint(Color(hex: "#FF6B35"))
        .listRowBackground(Color.white.opacity(0.05))

        Picker("Control Scheme", selection: $vm.settings.controlScheme) {
            ForEach(AppSettings.ControlScheme.allCases, id: \.self) { s in
                Text(s.rawValue.uppercased()).tag(s)
            }
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    @ViewBuilder
    private var accessibilitySection: some View {
        Picker("Color Blind Mode", selection: $vm.settings.colorBlindMode) {
            ForEach(AppSettings.ColorBlindMode.allCases, id: \.self) { m in
                Text(m.rawValue.capitalized).tag(m)
            }
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    @ViewBuilder
    private var languageSection: some View {
        Picker("Language", selection: $vm.settings.language) {
            ForEach(AppSettings.Language.allCases, id: \.self) { l in
                Text(l.rawValue.capitalized).tag(l)
            }
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    @ViewBuilder
    private var accountSection: some View {
        NavigationLink(destination: Text("Profile Editor")) {
            Label("Edit Profile", systemImage: "person.crop.circle")
        }
        .listRowBackground(Color.white.opacity(0.05))

        NavigationLink(destination: Text("Privacy Settings")) {
            Label("Privacy", systemImage: "lock.shield")
        }
        .listRowBackground(Color.white.opacity(0.05))

        Button(action: {}) {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .foregroundColor(.red)
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .black, design: .monospaced))
            .foregroundColor(Color(hex: "#FF6B35"))
            .kerning(3)
    }
}

#Preview { SettingsView() }
