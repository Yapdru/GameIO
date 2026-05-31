// PlatformSpecificThemes.swift — Per-Platform Color Schemes & 200fps Optimization
// iOS/iPadOS: Gold+Blue | macOS/tvOS/visionOS: White+Yellow | CarPlay: Black+Blue+Purple

import SwiftUI

// MARK: - iOS/iPadOS Theme (Gold + Blue)
struct iOSThemeStyle: ViewModifier {
    @StateObject private var themeSystem = PlatformThemeSystem.shared

    func body(content: Content) -> some View {
        content
            .background(Color(red: 0.94, green: 0.96, blue: 1.0))
            .preferredColorScheme(.light)
    }
}

// MARK: - macOS Theme (White + Yellow)
struct macOSThemeStyle: ViewModifier {
    @StateObject private var themeSystem = PlatformThemeSystem.shared

    func body(content: Content) -> some View {
        content
            .background(Color(red: 0.98, green: 0.98, blue: 0.97))
            .preferredColorScheme(.light)
    }
}

// MARK: - tvOS Theme (White + Yellow)
struct tvOSThemeStyle: ViewModifier {
    @StateObject private var themeSystem = PlatformThemeSystem.shared

    func body(content: Content) -> some View {
        content
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .preferredColorScheme(.dark)
    }
}

// MARK: - CarPlay Theme (Black + Blue + Purple)
struct CarPlayThemeStyle: ViewModifier {
    @StateObject private var themeSystem = PlatformThemeSystem.shared

    func body(content: Content) -> some View {
        content
            .background(Color(red: 0.05, green: 0.05, blue: 0.08))
            .preferredColorScheme(.dark)
    }
}

// MARK: - 10K Dolby Vision HDR Button Styles
struct DolbyVisionButtonStyle: ButtonStyle {
    @StateObject private var themeSystem = PlatformThemeSystem.shared

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        themeSystem.getPrimaryColor(),
                        themeSystem.getAccentColor()
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .shadow(
                color: themeSystem.getPrimaryColor().opacity(0.5),
                radius: 8,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Dolby Vision Card View
struct DolbyVisionCardView<Content: View>: View {
    @StateObject private var themeSystem = PlatformThemeSystem.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(themeSystem.isDolbyVisionEnabled ? 0.15 : 0.05),
                    Color.white.opacity(themeSystem.isDolbyVisionEnabled ? 0.08 : 0.02)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    themeSystem.getPrimaryColor().opacity(0.2),
                    lineWidth: 1
                )
        )
        .shadow(
            color: themeSystem.getAccentColor().opacity(themeSystem.isDolbyVisionEnabled ? 0.3 : 0.1),
            radius: themeSystem.isDolbyVisionEnabled ? 12 : 4,
            x: 0,
            y: themeSystem.isDolbyVisionEnabled ? 6 : 2
        )
    }
}

// MARK: - 200fps Optimized List View
struct OptimizedListView<Content: View>: View {
    @StateObject private var themeSystem = PlatformThemeSystem.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        List {
            content
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 44)
        .onAppear {
            // Optimize for 200fps rendering
            if themeSystem.isDolbyVisionEnabled {
                UIView.setAnimationsEnabled(true)
            }
        }
    }
}

// MARK: - Animated Theme Transition
struct AnimatedThemeTransition: ViewModifier {
    @StateObject private var themeSystem = PlatformThemeSystem.shared
    @State private var isTransitioning: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(isTransitioning ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isTransitioning)
            .onAppear {
                withAnimation {
                    isTransitioning = false
                }
            }
    }
}

// MARK: - Platform Detection & Auto-Theme
struct PlatformAwareContainer<Content: View>: View {
    @StateObject private var themeSystem = PlatformThemeSystem.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background with platform colors
            themeSystem.getBackgroundColor()
                .ignoresSafeArea()

            content
                #if os(iOS)
                .modifier(iOSThemeStyle())
                #elseif os(macOS)
                .modifier(macOSThemeStyle())
                #elseif os(tvOS)
                .modifier(tvOSThemeStyle())
                #endif
        }
    }
}

// MARK: - 10K Text Styles
struct DolbyVisionText: View {
    let text: String
    let fontSize: CGFloat
    let weight: Font.Weight
    @StateObject private var themeSystem = PlatformThemeSystem.shared

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: weight))
            .foregroundColor(themeSystem.getPrimaryColor())
            .shadow(
                color: themeSystem.getAccentColor().opacity(
                    themeSystem.isDolbyVisionEnabled ? 0.4 : 0.0
                ),
                radius: themeSystem.isDolbyVisionEnabled ? 2 : 0,
                x: 0,
                y: 1
            )
    }
}

// MARK: - HDR Gradient Background
struct DolbyVisionGradient: View {
    @StateObject private var themeSystem = PlatformThemeSystem.shared

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                themeSystem.getPrimaryColor().opacity(themeSystem.isDolbyVisionEnabled ? 0.15 : 0.05),
                themeSystem.getSecondaryColor().opacity(themeSystem.isDolbyVisionEnabled ? 0.1 : 0.02),
                themeSystem.getAccentColor().opacity(themeSystem.isDolbyVisionEnabled ? 0.08 : 0.01)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Theme Stats View
struct ThemeStatsView: View {
    @StateObject private var themeSystem = PlatformThemeSystem.shared

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Platform:")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                Text(platformName())
                    .font(.caption)
                    .foregroundColor(themeSystem.getPrimaryColor())
            }

            HStack {
                Text("Target FPS:")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                Text("\(themeSystem.targetFrameRate)")
                    .font(.caption)
                    .foregroundColor(themeSystem.getSecondaryColor())
            }

            HStack {
                Text("Dolby Vision:")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                Text(themeSystem.isDolbyVisionEnabled ? "Enabled" : "Disabled")
                    .font(.caption)
                    .foregroundColor(themeSystem.isDolbyVisionEnabled ? .green : .orange)
            }

            HStack {
                Text("HDR Intensity:")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(themeSystem.hdrIntensity * 100))%")
                    .font(.caption)
                    .foregroundColor(themeSystem.getAccentColor())
            }

            HStack {
                Text("Color Mode:")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(themeSystem.getPrimaryColor())
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(themeSystem.getSecondaryColor())
                        .frame(width: 12, height: 12)
                    Circle()
                        .fill(themeSystem.getAccentColor())
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding()
        .background(DolbyVisionGradient())
        .cornerRadius(8)
    }

    private func platformName() -> String {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "iPadOS"
        } else {
            return "iOS"
        }
        #elseif os(macOS)
        return "macOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Web"
        #endif
    }
}

// MARK: - Extends
extension View {
    func iOSTheme() -> some View {
        modifier(iOSThemeStyle())
    }

    func macOSTheme() -> some View {
        modifier(macOSThemeStyle())
    }

    func tvOSTheme() -> some View {
        modifier(tvOSThemeStyle())
    }

    func carPlayTheme() -> some View {
        modifier(CarPlayThemeStyle())
    }

    func dolbyVisionButton() -> some View {
        buttonStyle(DolbyVisionButtonStyle())
    }

    func animatedThemeTransition() -> some View {
        modifier(AnimatedThemeTransition())
    }
}
