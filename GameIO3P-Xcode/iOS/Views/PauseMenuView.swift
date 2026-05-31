// PauseMenuView.swift
// GameIO 2P — Pause Menu Overlay
// Resume, restart, settings, quit with blur background.

import SwiftUI

struct PauseMenuView: View {
    @State private var isAnimatingIn = false
    var onResume: () -> Void = {}
    var onRestart: () -> Void = {}
    var onSettings: () -> Void = {}
    var onQuit: () -> Void = {}

    var body: some View {
        ZStack {
            // Blurred dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 0) {
                // Pause icon + title
                VStack(spacing: 8) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(
                            LinearGradient(colors: [Color(hex: "#FF6B35"), Color(hex: "#FF2D95")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: Color(hex: "#FF6B35").opacity(0.6), radius: 16)
                        .scaleEffect(isAnimatingIn ? 1.0 : 0.5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimatingIn)

                    Text("PAUSED")
                        .font(.system(size: 30, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .kerning(6)
                        .opacity(isAnimatingIn ? 1 : 0)
                        .animation(.easeIn(duration: 0.3).delay(0.1), value: isAnimatingIn)
                }
                .padding(.bottom, 32)

                // Menu buttons
                VStack(spacing: 14) {
                    pauseButton(title: "RESUME", icon: "play.fill",
                                color: Color(hex: "#00FF88"), textColor: .black,
                                delay: 0.1, action: onResume)

                    pauseButton(title: "RESTART", icon: "arrow.counterclockwise",
                                color: Color.white.opacity(0.1), textColor: .white,
                                border: Color.white.opacity(0.25),
                                delay: 0.15, action: onRestart)

                    pauseButton(title: "SETTINGS", icon: "gear",
                                color: Color.white.opacity(0.1), textColor: .white,
                                border: Color.white.opacity(0.25),
                                delay: 0.2, action: onSettings)

                    pauseButton(title: "QUIT RACE", icon: "xmark.circle",
                                color: Color(hex: "#FF2D00").opacity(0.2), textColor: Color(hex: "#FF5555"),
                                border: Color(hex: "#FF2D00").opacity(0.4),
                                delay: 0.25, action: onQuit)
                }
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "#0D0D1A").opacity(0.95))
                    .overlay(RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1))
            )
            .scaleEffect(isAnimatingIn ? 1.0 : 0.85)
            .opacity(isAnimatingIn ? 1 : 0)
            .animation(.spring(response: 0.45, dampingFraction: 0.72), value: isAnimatingIn)
        }
        .onAppear { isAnimatingIn = true }
    }

    @ViewBuilder
    private func pauseButton(title: String, icon: String, color: Color,
                              textColor: Color, border: Color = .clear,
                              delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .kerning(2)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(12)
            .overlay(
                border != .clear ? RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1) : nil
            )
        }
        .buttonStyle(PauseButtonStyle())
        .opacity(isAnimatingIn ? 1 : 0)
        .offset(y: isAnimatingIn ? 0 : 20)
        .animation(.spring(response: 0.4, dampingFraction: 0.75).delay(delay), value: isAnimatingIn)
    }
}

struct PauseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        Image(systemName: "road.lanes").resizable().scaledToFill().ignoresSafeArea().opacity(0.3)
        PauseMenuView()
    }
}
