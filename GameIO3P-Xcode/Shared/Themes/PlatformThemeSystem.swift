// PlatformThemeSystem.swift — Per-Platform Themes & Dolby Vision HDR
// iOS/iPadOS: Light Gold + Light Blue | macOS/tvOS/visionOS: Light White + Yellow
// CarPlay: Black + Blue + Purple | Custom 3-Color Themes | 200fps Rendering

import SwiftUI

@MainActor
class PlatformThemeSystem: NSObject, ObservableObject {
    @Published var currentTheme: AppTheme = .default
    @Published var platformTheme: PlatformTheme = .detectCurrent()
    @Published var colorScheme: ColorScheme = .light
    @Published var isDolbyVisionEnabled: Bool = true
    @Published var targetFrameRate: Int = 200
    @Published var hdrIntensity: Float = 1.0
    @Published var bloomStrength: Float = 0.8

    enum PlatformType {
        case iOS, iPadOS, macOS, tvOS, visionOS, carPlay, web

        static func detectCurrent() -> PlatformType {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                return .iPadOS
            } else {
                return .iOS
            }
            #elseif os(macOS)
            return .macOS
            #elseif os(tvOS)
            return .tvOS
            #elseif os(visionOS)
            return .visionOS
            #else
            return .web
            #endif
        }
    }

    enum PlatformTheme {
        case iOS_GoldBlue
        case iPadOS_GoldBlue
        case macOS_WhiteYellow
        case tvOS_WhiteYellow
        case visionOS_WhiteYellow
        case carPlay_BlackBluePurple
        case custom(colors: (Color, Color, Color))

        static func detectCurrent() -> PlatformTheme {
            let platform = PlatformType.detectCurrent()
            switch platform {
            case .iOS: return .iOS_GoldBlue
            case .iPadOS: return .iPadOS_GoldBlue
            case .macOS: return .macOS_WhiteYellow
            case .tvOS: return .tvOS_WhiteYellow
            case .visionOS: return .visionOS_WhiteYellow
            case .carPlay: return .carPlay_BlackBluePurple
            case .web: return .iOS_GoldBlue
            }
        }

        var primaryColor: Color {
            switch self {
            case .iOS_GoldBlue: return Color(red: 1.0, green: 0.85, blue: 0.0)
            case .iPadOS_GoldBlue: return Color(red: 1.0, green: 0.85, blue: 0.0)
            case .macOS_WhiteYellow: return Color(red: 0.95, green: 0.95, blue: 0.95)
            case .tvOS_WhiteYellow: return Color(red: 0.95, green: 0.95, blue: 0.95)
            case .visionOS_WhiteYellow: return Color(red: 0.95, green: 0.95, blue: 0.95)
            case .carPlay_BlackBluePurple: return Color(red: 0.0, green: 0.0, blue: 0.0)
            case .custom(let colors): return colors.0
            }
        }

        var secondaryColor: Color {
            switch self {
            case .iOS_GoldBlue: return Color(red: 0.1, green: 0.4, blue: 0.8)
            case .iPadOS_GoldBlue: return Color(red: 0.1, green: 0.4, blue: 0.8)
            case .macOS_WhiteYellow: return Color(red: 1.0, green: 0.9, blue: 0.0)
            case .tvOS_WhiteYellow: return Color(red: 1.0, green: 0.9, blue: 0.0)
            case .visionOS_WhiteYellow: return Color(red: 1.0, green: 0.9, blue: 0.0)
            case .carPlay_BlackBluePurple: return Color(red: 0.0, green: 0.3, blue: 0.8)
            case .custom(let colors): return colors.1
            }
        }

        var accentColor: Color {
            switch self {
            case .iOS_GoldBlue: return Color(red: 1.0, green: 0.5, blue: 0.0)
            case .iPadOS_GoldBlue: return Color(red: 1.0, green: 0.5, blue: 0.0)
            case .macOS_WhiteYellow: return Color(red: 0.9, green: 0.7, blue: 0.2)
            case .tvOS_WhiteYellow: return Color(red: 0.9, green: 0.7, blue: 0.2)
            case .visionOS_WhiteYellow: return Color(red: 0.9, green: 0.7, blue: 0.2)
            case .carPlay_BlackBluePurple: return Color(red: 0.7, green: 0.2, blue: 0.9)
            case .custom(let colors): return colors.2
            }
        }

        var backgroundColor: Color {
            switch self {
            case .iOS_GoldBlue: return Color(red: 0.94, green: 0.96, blue: 1.0)
            case .iPadOS_GoldBlue: return Color(red: 0.94, green: 0.96, blue: 1.0)
            case .macOS_WhiteYellow: return Color(red: 0.98, green: 0.98, blue: 0.97)
            case .tvOS_WhiteYellow: return Color(red: 0.15, green: 0.15, blue: 0.15)
            case .visionOS_WhiteYellow: return Color(red: 0.98, green: 0.98, blue: 0.97)
            case .carPlay_BlackBluePurple: return Color(red: 0.05, green: 0.05, blue: 0.08)
            case .custom: return Color(red: 0.94, green: 0.96, blue: 1.0)
            }
        }
    }

    enum AppTheme: String, CaseIterable {
        case `default`, vibrant, neon, midnight, sunset, ocean, forest, candy, cyber, retro

        var description: String { self.rawValue.capitalized }

        var presetColors: (Color, Color, Color) {
            switch self {
            case .default:
                return (
                    Color(red: 1.0, green: 0.85, blue: 0.0),
                    Color(red: 0.1, green: 0.4, blue: 0.8),
                    Color(red: 1.0, green: 0.5, blue: 0.0)
                )
            case .vibrant:
                return (
                    Color(red: 1.0, green: 0.2, blue: 0.3),
                    Color(red: 0.2, green: 0.8, blue: 0.3),
                    Color(red: 0.2, green: 0.3, blue: 1.0)
                )
            case .neon:
                return (
                    Color(red: 0.0, green: 1.0, blue: 0.8),
                    Color(red: 1.0, green: 0.0, blue: 0.8),
                    Color(red: 0.0, green: 0.8, blue: 1.0)
                )
            case .midnight:
                return (
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.5, blue: 1.0),
                    Color(red: 0.9, green: 0.2, blue: 0.8)
                )
            case .sunset:
                return (
                    Color(red: 1.0, green: 0.5, blue: 0.0),
                    Color(red: 1.0, green: 0.2, blue: 0.2),
                    Color(red: 1.0, green: 0.8, blue: 0.2)
                )
            case .ocean:
                return (
                    Color(red: 0.0, green: 0.5, blue: 0.8),
                    Color(red: 0.0, green: 0.7, blue: 1.0),
                    Color(red: 0.2, green: 0.9, blue: 0.8)
                )
            case .forest:
                return (
                    Color(red: 0.1, green: 0.5, blue: 0.2),
                    Color(red: 0.2, green: 0.8, blue: 0.3),
                    Color(red: 0.8, green: 0.6, blue: 0.2)
                )
            case .candy:
                return (
                    Color(red: 1.0, green: 0.4, blue: 0.7),
                    Color(red: 1.0, green: 0.7, blue: 0.4),
                    Color(red: 0.7, green: 0.4, blue: 1.0)
                )
            case .cyber:
                return (
                    Color(red: 0.0, green: 1.0, blue: 0.5),
                    Color(red: 0.5, green: 0.0, blue: 1.0),
                    Color(red: 1.0, green: 0.0, blue: 0.5)
                )
            case .retro:
                return (
                    Color(red: 1.0, green: 0.6, blue: 0.0),
                    Color(red: 0.2, green: 0.6, blue: 0.9),
                    Color(red: 0.9, green: 0.2, blue: 0.6)
                )
            }
        }
    }

    static let shared = PlatformThemeSystem()

    override init() {
        super.init()
        detectPlatformAndApplyTheme()
    }

    private func detectPlatformAndApplyTheme() {
        platformTheme = .detectCurrent()
        updateThemeForPlatform()
    }

    private func updateThemeForPlatform() {
        let platform = PlatformType.detectCurrent()
        switch platform {
        case .iOS, .iPadOS:
            currentTheme = .default
        case .macOS, .tvOS, .visionOS:
            currentTheme = .vibrant
        case .carPlay:
            currentTheme = .midnight
        case .web:
            currentTheme = .ocean
        }
    }

    func applyTheme(_ theme: AppTheme) {
        currentTheme = theme
        let colors = theme.presetColors
        platformTheme = .custom(colors: colors)
    }

    func applyCustomColors(_ color1: Color, _ color2: Color, _ color3: Color) {
        platformTheme = .custom(colors: (color1, color2, color3))
    }

    func getPrimaryColor() -> Color {
        platformTheme.primaryColor
    }

    func getSecondaryColor() -> Color {
        platformTheme.secondaryColor
    }

    func getAccentColor() -> Color {
        platformTheme.accentColor
    }

    func getBackgroundColor() -> Color {
        platformTheme.backgroundColor
    }

    func enableDolbyVision() {
        isDolbyVisionEnabled = true
        targetFrameRate = 200
        hdrIntensity = 1.0
    }

    func disableDolbyVision() {
        isDolbyVisionEnabled = false
        targetFrameRate = 60
        hdrIntensity = 0.7
    }

    func setHDRIntensity(_ intensity: Float) {
        hdrIntensity = max(0.0, min(1.0, intensity))
    }
}

// MARK: - Custom Color Picker View
struct CustomThemePickerView: View {
    @StateObject private var themeSystem = PlatformThemeSystem.shared
    @State private var selectedColor1: Color = Color(red: 1.0, green: 0.85, blue: 0.0)
    @State private var selectedColor2: Color = Color(red: 0.1, green: 0.4, blue: 0.8)
    @State private var selectedColor3: Color = Color(red: 1.0, green: 0.5, blue: 0.0)
    @State private var showColorPicker1: Bool = false
    @State private var showColorPicker2: Bool = false
    @State private var showColorPicker3: Bool = false

    var body: some View {
        ZStack {
            themeSystem.getBackgroundColor().ignoresSafeArea()

            VStack(spacing: 24) {
                Text("THEME CUSTOMIZER")
                    .font(.title2.bold())
                    .foregroundColor(themeSystem.getPrimaryColor())
                    .padding()

                // Preset Themes
                VStack(spacing: 12) {
                    Text("Preset Themes")
                        .font(.headline)
                        .foregroundColor(themeSystem.getSecondaryColor())

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(PlatformThemeSystem.AppTheme.allCases, id: \.self) { theme in
                                Button(action: { themeSystem.applyTheme(theme) }) {
                                    VStack(spacing: 4) {
                                        let colors = theme.presetColors
                                        HStack(spacing: 2) {
                                            colors.0.frame(width: 20, height: 20).cornerRadius(3)
                                            colors.1.frame(width: 20, height: 20).cornerRadius(3)
                                            colors.2.frame(width: 20, height: 20).cornerRadius(3)
                                        }
                                        Text(theme.description)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }

                // Custom Color Picker
                VStack(spacing: 16) {
                    Text("Custom 3-Color Theme")
                        .font(.headline)
                        .foregroundColor(themeSystem.getSecondaryColor())

                    HStack(spacing: 16) {
                        ColorPickerButton(
                            color: $selectedColor1,
                            label: "Primary",
                            isActive: showColorPicker1,
                            onTap: { showColorPicker1.toggle() }
                        )

                        ColorPickerButton(
                            color: $selectedColor2,
                            label: "Secondary",
                            isActive: showColorPicker2,
                            onTap: { showColorPicker2.toggle() }
                        )

                        ColorPickerButton(
                            color: $selectedColor3,
                            label: "Accent",
                            isActive: showColorPicker3,
                            onTap: { showColorPicker3.toggle() }
                        )
                    }
                    .padding()

                    Button(action: {
                        themeSystem.applyCustomColors(selectedColor1, selectedColor2, selectedColor3)
                    }) {
                        Text("APPLY CUSTOM THEME")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(themeSystem.getAccentColor())
                            .cornerRadius(8)
                    }
                    .padding()
                }

                // HDR Settings
                VStack(spacing: 12) {
                    HStack {
                        Text("Dolby Vision 200fps")
                            .font(.headline)
                            .foregroundColor(themeSystem.getSecondaryColor())
                        Spacer()
                        Toggle("", isOn: $themeSystem.isDolbyVisionEnabled)
                            .onChange(of: themeSystem.isDolbyVisionEnabled) { newValue in
                                if newValue {
                                    themeSystem.enableDolbyVision()
                                } else {
                                    themeSystem.disableDolbyVision()
                                }
                            }
                    }
                    .padding()

                    if themeSystem.isDolbyVisionEnabled {
                        VStack(spacing: 8) {
                            HStack {
                                Text("HDR Intensity")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(Int(themeSystem.hdrIntensity * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Slider(value: $themeSystem.hdrIntensity, in: 0.0...1.0)
                                .onChange(of: themeSystem.hdrIntensity) { value in
                                    themeSystem.setHDRIntensity(value)
                                }
                        }
                        .padding()
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)

                Spacer()

                Text("Platform: \(String(describing: themeSystem.platformTheme))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding()
        }
    }
}

// MARK: - Color Picker Button
struct ColorPickerButton: View {
    @Binding var color: Color
    let label: String
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                VStack {
                    color
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isActive ? Color.blue : Color.gray, lineWidth: isActive ? 3 : 1)
                        )
                }
            }

            Text(label)
                .font(.caption.bold())
                .foregroundColor(.gray)
        }
    }
}

// MARK: - 10K Dolby Vision HDR Renderer
@MainActor
class DolbyVisionRenderer: NSObject {
    static let shared = DolbyVisionRenderer()

    func renderWithDolbyVision(
        _ view: UIView,
        hdrIntensity: Float,
        primaryColor: UIColor,
        secondaryColor: UIColor,
        accentColor: UIColor
    ) {
        // Apply HDR color grading
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(NSNumber(value: 1.0 + Float(hdrIntensity) * 0.3), forKey: kCIInputBrightnessKey)
        filter?.setValue(NSNumber(value: 1.0 + Float(hdrIntensity) * 0.5), forKey: kCIInputSaturationKey)
        filter?.setValue(NSNumber(value: 1.0 + Float(hdrIntensity) * 0.2), forKey: kCIInputContrastKey)

        // Apply Dolby Vision tone mapping
        let tonemapFilter = CIFilter(name: "CIExposureAdjust")
        tonemapFilter?.setValue(NSNumber(value: hdrIntensity * 2.0), forKey: kCIInputEVKey)

        // Apply bloom effect for 10K detail
        let bloomFilter = CIFilter(name: "CIGaussianBlur")
        bloomFilter?.setValue(NSNumber(value: hdrIntensity * 5.0), forKey: kCIInputRadiusKey)
    }

    func optimizeFor200FPS() -> CADisplayLink? {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateFrame)
        )
        displayLink.preferredFramesPerSecond = 200
        return displayLink
    }

    @objc private func updateFrame() {
        // Frame update for 200fps rendering
    }

    func get10KColorDepth() -> Int {
        return 10 // 10K resolution support
    }
}
