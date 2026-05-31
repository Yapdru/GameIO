// AvatarCreatorView.swift
// GameIO 2P — Avatar Creator
// SwiftUI avatar creator with face/skin/hair/eyes/mouth pickers.

import SwiftUI
import UIKit

// MARK: - Avatar Model

struct AvatarConfig: Equatable {
    var skinTone: Int = 0       // 0-5
    var hairStyle: Int = 0      // 0-5
    var hairColor: Int = 0      // 0-7
    var eyeStyle: Int = 0       // 0-4
    var mouthStyle: Int = 0     // 0-4
    var faceShape: Int = 0      // 0-3
    var accessory: Int = 0      // 0-5 (0=none)

    static let skinTones: [Color] = [
        Color(hex: "#FDDBB4"), Color(hex: "#F5CFA0"), Color(hex: "#D4956A"),
        Color(hex: "#B07545"), Color(hex: "#8B5E3C"), Color(hex: "#5C3317")
    ]
    static let hairColors: [Color] = [
        .black, Color(hex: "#4A2C0A"), Color(hex: "#8B5E3C"),
        Color(hex: "#D4A043"), Color(hex: "#F4E04D"), Color(hex: "#E05C5C"),
        Color(hex: "#5C9EE0"), Color(hex: "#CCCCCC")
    ]
}

// MARK: - UIKit Avatar View

class AvatarUIView: UIView {
    var config: AvatarConfig = AvatarConfig() {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let cx = rect.midX, cy = rect.midY
        let r: CGFloat = min(rect.width, rect.height) * 0.38

        // Face shape
        let faceRect = CGRect(x: cx - r, y: cy - r * 1.05, width: r * 2, height: r * 2.1)
        let skinUI = UIColor(AvatarConfig.skinTones[config.skinTone])
        skinUI.setFill()
        let cornerRadius: CGFloat = [r * 0.3, r * 0.5, r * 0.2, r * 0.45][config.faceShape]
        let facePath = UIBezierPath(roundedRect: faceRect, cornerRadius: cornerRadius)
        facePath.fill()
        UIColor(white: 0, alpha: 0.15).setStroke()
        facePath.lineWidth = 1.5
        facePath.stroke()

        // Hair (top)
        let hairUI = UIColor(AvatarConfig.hairColors[config.hairColor])
        hairUI.setFill()
        let hairStyles: [() -> Void] = [
            { // Short
                let p = UIBezierPath(roundedRect: CGRect(x: cx - r, y: cy - r * 1.15, width: r * 2, height: r * 0.7), cornerRadius: r * 0.3)
                p.fill()
            },
            { // Long
                let p = UIBezierPath(roundedRect: CGRect(x: cx - r * 1.05, y: cy - r * 1.15, width: r * 2.1, height: r * 1.5), cornerRadius: r * 0.2)
                p.fill()
            },
            { // Curly
                for i in 0..<5 {
                    let ox = cx - r + CGFloat(i) * (r * 2 / 4)
                    let p = UIBezierPath(ovalIn: CGRect(x: ox - r * 0.25, y: cy - r * 1.25, width: r * 0.6, height: r * 0.6))
                    p.fill()
                }
            },
            { // Bun
                let p = UIBezierPath(ovalIn: CGRect(x: cx - r * 0.35, y: cy - r * 1.5, width: r * 0.7, height: r * 0.7))
                p.fill()
            },
            { // Mohawk
                let p = UIBezierPath(roundedRect: CGRect(x: cx - r * 0.15, y: cy - r * 1.45, width: r * 0.3, height: r * 0.8), cornerRadius: r * 0.1)
                p.fill()
            },
            { // Hat (baseball)
                let p = UIBezierPath(roundedRect: CGRect(x: cx - r, y: cy - r * 1.1, width: r * 2, height: r * 0.5), cornerRadius: r * 0.15)
                p.fill()
                let brim = UIBezierPath(roundedRect: CGRect(x: cx - r * 1.1, y: cy - r * 0.7, width: r * 2.2, height: r * 0.2), cornerRadius: r * 0.1)
                brim.fill()
            }
        ]
        if config.hairStyle < hairStyles.count { hairStyles[config.hairStyle]() }

        // Eyes
        let eyeY = cy - r * 0.15
        let eyeOffsets: [CGFloat] = [r * 0.38, r * 0.32, r * 0.44, r * 0.35, r * 0.40]
        let ex = eyeOffsets[min(config.eyeStyle, eyeOffsets.count - 1)]
        for sign: CGFloat in [-1, 1] {
            let eyeRect = CGRect(x: cx + sign * ex - r * 0.12, y: eyeY - r * 0.12, width: r * 0.24, height: r * 0.24)
            UIColor.white.setFill()
            UIBezierPath(ovalIn: eyeRect).fill()
            let pupilRect = eyeRect.insetBy(dx: r * 0.05, dy: r * 0.05)
            UIColor.black.setFill()
            UIBezierPath(ovalIn: pupilRect).fill()
        }

        // Mouth
        ctx.setStrokeColor(UIColor(white: 0, alpha: 0.7).cgColor)
        ctx.setLineWidth(2.5)
        let mouthY = cy + r * 0.45
        switch config.mouthStyle {
        case 0: // Smile
            ctx.addArc(center: CGPoint(x: cx, y: mouthY - r * 0.1), radius: r * 0.25, startAngle: 0.3, endAngle: .pi - 0.3, clockwise: false)
        case 1: // Grin
            ctx.addArc(center: CGPoint(x: cx, y: mouthY - r * 0.15), radius: r * 0.33, startAngle: 0.2, endAngle: .pi - 0.2, clockwise: false)
        case 2: // Neutral
            ctx.move(to: CGPoint(x: cx - r * 0.2, y: mouthY))
            ctx.addLine(to: CGPoint(x: cx + r * 0.2, y: mouthY))
        case 3: // Surprised O
            ctx.addEllipse(in: CGRect(x: cx - r * 0.1, y: mouthY - r * 0.1, width: r * 0.2, height: r * 0.2))
        default: // Smirk
            ctx.move(to: CGPoint(x: cx - r * 0.2, y: mouthY + r * 0.05))
            ctx.addCurve(to: CGPoint(x: cx + r * 0.2, y: mouthY - r * 0.05),
                         control1: CGPoint(x: cx - r * 0.05, y: mouthY + r * 0.1),
                         control2: CGPoint(x: cx + r * 0.1, y: mouthY))
        }
        ctx.strokePath()
    }
}

// MARK: - UIViewRepresentable

struct AvatarPreviewView: UIViewRepresentable {
    let config: AvatarConfig
    func makeUIView(context: Context) -> AvatarUIView {
        let v = AvatarUIView()
        v.backgroundColor = .clear
        return v
    }
    func updateUIView(_ uiView: AvatarUIView, context: Context) {
        uiView.config = config
    }
}

// MARK: - SwiftUI Creator

struct AvatarCreatorView: View {
    @State private var config = AvatarConfig()
    @State private var playerName: String = "Player 1"
    var onSave: (AvatarConfig, String) -> Void = { _, _ in }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0D0D1A").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        AvatarPreviewView(config: config)
                            .frame(width: 160, height: 160)
                            .background(Color.white.opacity(0.07))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(hex: "#FF6B35"), lineWidth: 3))
                            .shadow(color: Color(hex: "#FF6B35").opacity(0.5), radius: 20)
                            .padding(.top, 20)

                        TextField("Your name", text: $playerName)
                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 40)

                        pickerRow(title: "SKIN TONE", count: 6, selected: $config.skinTone) { i in
                            Circle().fill(AvatarConfig.skinTones[i]).frame(width: 32, height: 32)
                                .overlay(i == config.skinTone ? Circle().stroke(Color.white, lineWidth: 2) : nil)
                        }

                        pickerRow(title: "HAIR STYLE", count: 6, selected: $config.hairStyle) { i in
                            Text(["✂️", "💇", "🌀", "🎀", "⚡", "🧢"][i]).font(.title2)
                        }

                        pickerRow(title: "HAIR COLOR", count: 8, selected: $config.hairColor) { i in
                            Circle().fill(AvatarConfig.hairColors[i]).frame(width: 32, height: 32)
                                .overlay(i == config.hairColor ? Circle().stroke(Color.white, lineWidth: 2) : nil)
                        }

                        pickerRow(title: "EYES", count: 5, selected: $config.eyeStyle) { i in
                            Text(["👀", "😌", "😍", "😎", "🥴"][i]).font(.title2)
                        }

                        pickerRow(title: "MOUTH", count: 5, selected: $config.mouthStyle) { i in
                            Text(["😊", "😁", "😐", "😮", "😏"][i]).font(.title2)
                        }

                        Button(action: { onSave(config, playerName) }) {
                            Text("SAVE AVATAR")
                                .font(.system(size: 18, weight: .black, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#00FF88"))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("CREATE AVATAR")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func pickerRow<Content: View>(title: String, count: Int, selected: Binding<Int>, @ViewBuilder label: @escaping (Int) -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "#FF6B35"))
                .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<count, id: \.self) { i in
                        Button(action: { selected.wrappedValue = i }) {
                            label(i)
                                .frame(width: 48, height: 48)
                                .background(selected.wrappedValue == i ? Color.white.opacity(0.2) : Color.white.opacity(0.07))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview { AvatarCreatorView() }
