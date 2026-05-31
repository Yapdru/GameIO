// MacSettingsView.swift
// GameIO 2P — macOS Preferences Panel
// Tabbed preferences panel following macOS HIG.

import SwiftUI
import AppKit

enum MacSettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case graphics = "Graphics"
    case audio = "Audio"
    case controls = "Controls"
    case account = "Account"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .general: return "gearshape.fill"
        case .graphics: return "display"
        case .audio: return "speaker.wave.3.fill"
        case .controls: return "gamecontroller.fill"
        case .account: return "person.circle.fill"
        }
    }
}

struct MacSettingsView: View {
    @State private var selectedTab: MacSettingsTab = .general
    @State private var settings = AppSettings()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // macOS-style toolbar tabs
            HStack(spacing: 0) {
                ForEach(MacSettingsTab.allCases) { tab in
                    macTabButton(tab)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Content
            TabView(selection: $selectedTab) {
                generalTab.tag(MacSettingsTab.general)
                graphicsTab.tag(MacSettingsTab.graphics)
                audioTab.tag(MacSettingsTab.audio)
                controlsTab.tag(MacSettingsTab.controls)
                accountTab.tag(MacSettingsTab.account)
            }
            .tabViewStyle(.automatic)
            .padding(20)

            Divider()

            // Footer buttons
            HStack {
                Button("Restore Defaults") { settings = AppSettings() }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                Spacer()
                Button("Cancel") { dismiss() }
                Button("OK") { saveSettings(); dismiss() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 580, height: 500)
        .onAppear { loadSettings() }
    }

    @ViewBuilder
    private func macTabButton(_ tab: MacSettingsTab) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon).font(.system(size: 22))
                Text(tab.rawValue).font(.system(size: 11))
            }
            .foregroundColor(selectedTab == tab ? Color(hex: "#FF6B35") : .secondary)
            .frame(width: 80, height: 56)
            .background(selectedTab == tab ? Color(hex: "#FF6B35").opacity(0.1) : .clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tabs

    var generalTab: some View {
        Form {
            Section("Application") {
                Picker("Language", selection: $settings.language) {
                    ForEach(AppSettings.Language.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
                Toggle("Show FPS Counter", isOn: $settings.showFPS)
                Toggle("Motion Blur", isOn: $settings.motionBlur)
                Toggle("Particle Effects", isOn: $settings.particles)
            }
            Section("Notifications") {
                Toggle("Race Invites", isOn: .constant(true))
                Toggle("Friend Activity", isOn: .constant(true))
                Toggle("Daily Bonus", isOn: .constant(false))
            }
        }
        .formStyle(.grouped)
    }

    var graphicsTab: some View {
        Form {
            Section("Rendering") {
                Picker("Graphics Quality", selection: $settings.graphicsQuality) {
                    ForEach(AppSettings.GraphicsQuality.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
                .pickerStyle(.segmented)
                Picker("Resolution Scale", selection: .constant("100%")) {
                    Text("75%").tag("75%")
                    Text("100%").tag("100%")
                    Text("125%").tag("125%")
                }
                Toggle("VSync", isOn: .constant(true))
                Toggle("Anti-Aliasing", isOn: .constant(true))
            }
            Section("Display") {
                Toggle("HDR Output", isOn: .constant(false))
                Picker("Color Blind Mode", selection: $settings.colorBlindMode) {
                    ForEach(AppSettings.ColorBlindMode.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
            }
        }
        .formStyle(.grouped)
    }

    var audioTab: some View {
        Form {
            Section("Volumes") {
                Toggle("Audio Enabled", isOn: $settings.audioEnabled)
                VStack(alignment: .leading) {
                    HStack { Text("Music"); Spacer(); Text("\(Int(settings.musicVolume * 100))%").foregroundColor(.secondary) }
                    Slider(value: $settings.musicVolume).disabled(!settings.audioEnabled)
                }
                VStack(alignment: .leading) {
                    HStack { Text("Sound Effects"); Spacer(); Text("\(Int(settings.sfxVolume * 100))%").foregroundColor(.secondary) }
                    Slider(value: $settings.sfxVolume).disabled(!settings.audioEnabled)
                }
            }
            Section("Output") {
                Picker("Audio Device", selection: .constant("Default")) {
                    Text("Default Output").tag("Default")
                    Text("Built-in Speakers").tag("Speakers")
                }
            }
        }
        .formStyle(.grouped)
    }

    var controlsTab: some View {
        Form {
            Section("Input") {
                Picker("Control Scheme", selection: $settings.controlScheme) {
                    ForEach(AppSettings.ControlScheme.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                }
            }
            Section("Keyboard Shortcuts") {
                keyBinding("Accelerate", key: "W / ↑")
                keyBinding("Brake", key: "S / ↓")
                keyBinding("Steer Left", key: "A / ←")
                keyBinding("Steer Right", key: "D / →")
                keyBinding("Nitro", key: "Space")
                keyBinding("Pause", key: "Esc")
            }
        }
        .formStyle(.grouped)
    }

    var accountTab: some View {
        Form {
            Section("Profile") {
                HStack {
                    Circle().fill(AvatarConfig.skinTones[0]).frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("Player 1").font(.headline)
                        Text("Level 12 • 42,500 pts").font(.caption).foregroundColor(.secondary)
                    }
                }
                Button("Edit Avatar") {}
                Button("Change Username") {}
            }
            Section("Privacy") {
                Toggle("Share Stats Publicly", isOn: .constant(true))
                Toggle("Allow Friend Requests", isOn: .constant(true))
            }
            Section("Data") {
                Button("Export Data") {}
                Button("Delete Account", role: .destructive) {}
            }
        }
        .formStyle(.grouped)
    }

    @ViewBuilder
    private func keyBinding(_ action: String, key: String) -> some View {
        HStack {
            Text(action)
            Spacer()
            Text(key).font(.system(size: 12, design: .monospaced))
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Color.secondary.opacity(0.15)).cornerRadius(4)
        }
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "app_settings")
        }
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "app_settings"),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
}

#Preview { MacSettingsView() }
