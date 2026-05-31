// SplashScreenView.swift
// GameIO 2P — iOS Splash Screen
// Animated logo, car silhouette, particle background, PRESS START button.

import SwiftUI
import Combine

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var carOffset: CGFloat = -400
    @State private var pressStartOpacity: Double = 0
    @State private var pressStartVisible: Bool = true
    @State private var particles: [SplashParticle] = SplashParticle.generate(count: 60)
    @State private var particleTimer: Timer? = nil
    @State private var shimmerOffset: CGFloat = -300

    var onStart: () -> Void = {}

    var body: some View {
        ZStack {
            // Deep space background
            LinearGradient(
                colors: [Color(hex: "#0A0010"), Color(hex: "#1A0030"), Color(hex: "#0A0010")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Particle layer
            Canvas { ctx, size in
                for p in particles {
                    let rect = CGRect(x: p.x * size.width, y: p.y * size.height, width: p.size, height: p.size)
                    ctx.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(p.alpha)))
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Grid lines
            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 40
                    var x: CGFloat = 0
                    while x < geo.size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                        x += spacing
                    }
                    var y: CGFloat = 0
                    while y < geo.size.height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                        y += spacing
                    }
                }
                .stroke(Color.purple.opacity(0.12), lineWidth: 0.5)
            }
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // GAMEIO 2P logo
                VStack(spacing: 4) {
                    Text("GAMEIO")
                        .font(.system(size: 56, weight: .black, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(colors: [Color(hex: "#FF6B35"), Color(hex: "#FF2D95")],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: Color(hex: "#FF6B35").opacity(0.8), radius: 20)
                        .overlay(
                            Rectangle()
                                .fill(LinearGradient(colors: [.clear, .white.opacity(0.6), .clear],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: 80)
                                .offset(x: shimmerOffset)
                                .clipped()
                        )
                        .clipped()

                    Text("2P")
                        .font(.system(size: 72, weight: .black, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(colors: [Color(hex: "#00E5FF"), Color(hex: "#7B61FF")],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: Color(hex: "#00E5FF").opacity(0.9), radius: 24)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Car silhouette
                CarSilhouetteView()
                    .frame(width: 280, height: 80)
                    .offset(x: carOffset)

                Spacer()

                // PRESS START button
                if pressStartVisible {
                    Button(action: onStart) {
                        Text("► PRESS START ◄")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "#00FF88"))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: "#00FF88"), lineWidth: 2)
                            )
                    }
                    .opacity(pressStartOpacity)
                }

                Spacer().frame(height: 60)
            }
        }
        .onAppear { runAnimations() }
    }

    private func runAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.7)) {
            carOffset = 0
        }
        withAnimation(.easeIn(duration: 0.6).delay(1.4)) {
            pressStartOpacity = 1.0
        }
        withAnimation(.linear(duration: 1.6).delay(1.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 300
        }
        // Blink PRESS START
        Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                pressStartVisible.toggle()
            }
        }
    }
}

struct CarSilhouetteView: View {
    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            var car = Path()
            car.move(to: CGPoint(x: w * 0.05, y: h * 0.65))
            car.addLine(to: CGPoint(x: w * 0.15, y: h * 0.40))
            car.addLine(to: CGPoint(x: w * 0.35, y: h * 0.22))
            car.addLine(to: CGPoint(x: w * 0.65, y: h * 0.22))
            car.addLine(to: CGPoint(x: w * 0.85, y: h * 0.40))
            car.addLine(to: CGPoint(x: w * 0.95, y: h * 0.65))
            car.closeSubpath()
            ctx.fill(car, with: .color(Color(hex: "#FF6B35").opacity(0.9)))

            // Wheels
            let wheelR: CGFloat = h * 0.22
            ctx.fill(Path(ellipseIn: CGRect(x: w * 0.18 - wheelR, y: h * 0.65 - wheelR / 2, width: wheelR * 2, height: wheelR * 2)), with: .color(.black))
            ctx.fill(Path(ellipseIn: CGRect(x: w * 0.75 - wheelR, y: h * 0.65 - wheelR / 2, width: wheelR * 2, height: wheelR * 2)), with: .color(.black))
        }
    }
}

struct SplashParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var alpha: Double

    static func generate(count: Int) -> [SplashParticle] {
        (0..<count).map { _ in
            SplashParticle(x: CGFloat.random(in: 0...1),
                           y: CGFloat.random(in: 0...1),
                           size: CGFloat.random(in: 1...4),
                           alpha: Double.random(in: 0.1...0.7))
        }
    }
}

#Preview {
    SplashScreenView()
}
