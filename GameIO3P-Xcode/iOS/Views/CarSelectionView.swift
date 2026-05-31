// CarSelectionView.swift
// GameIO 2P — Car Selection
// Horizontal scroll of 10 car cards with glassmorphism style.

import SwiftUI

struct CarDefinition: Identifiable {
    let id: Int
    let name: String
    let tagline: String
    let topSpeed: Int      // out of 10
    let acceleration: Int  // out of 10
    let handling: Int      // out of 10
    let nitro: Int         // out of 10
    let bodyColor: Color
    let accentColor: Color
    let rarity: Rarity

    enum Rarity: String {
        case common = "COMMON"
        case rare = "RARE"
        case epic = "EPIC"
        case legendary = "LEGENDARY"

        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return Color(hex: "#4A90E2")
            case .epic: return Color(hex: "#9B59B6")
            case .legendary: return Color(hex: "#F39C12")
            }
        }
    }
}

extension CarDefinition {
    static let all: [CarDefinition] = [
        CarDefinition(id: 0, name: "VOLT RUNNER", tagline: "Electric speed beast", topSpeed: 9, acceleration: 7, handling: 6, nitro: 10, bodyColor: Color(hex: "#00E5FF"), accentColor: Color(hex: "#0066FF"), rarity: .epic),
        CarDefinition(id: 1, name: "DRIFT KING", tagline: "Born to slide", topSpeed: 7, acceleration: 8, handling: 10, nitro: 7, bodyColor: Color(hex: "#FF6B35"), accentColor: Color(hex: "#FF2D00"), rarity: .legendary),
        CarDefinition(id: 2, name: "IRON BULL", tagline: "Unstoppable force", topSpeed: 8, acceleration: 5, handling: 4, nitro: 6, bodyColor: Color(hex: "#778899"), accentColor: Color(hex: "#333344"), rarity: .rare),
        CarDefinition(id: 3, name: "GECKO GTS", tagline: "Grip like glue", topSpeed: 7, acceleration: 8, handling: 9, nitro: 7, bodyColor: Color(hex: "#00FF88"), accentColor: Color(hex: "#007744"), rarity: .rare),
        CarDefinition(id: 4, name: "SHADOW X", tagline: "Dark and fast", topSpeed: 10, acceleration: 9, handling: 5, nitro: 5, bodyColor: Color(hex: "#1A1A2E"), accentColor: Color(hex: "#7B61FF"), rarity: .legendary),
        CarDefinition(id: 5, name: "BLAZE 500", tagline: "Classic muscle", topSpeed: 8, acceleration: 9, handling: 6, nitro: 8, bodyColor: Color(hex: "#E74C3C"), accentColor: Color(hex: "#922B21"), rarity: .epic),
        CarDefinition(id: 6, name: "AURORA GT", tagline: "Aurora on wheels", topSpeed: 7, acceleration: 7, handling: 8, nitro: 9, bodyColor: Color(hex: "#F0E68C"), accentColor: Color(hex: "#DAA520"), rarity: .rare),
        CarDefinition(id: 7, name: "MICRO FURY", tagline: "Small but savage", topSpeed: 6, acceleration: 10, handling: 10, nitro: 6, bodyColor: Color(hex: "#FF69B4"), accentColor: Color(hex: "#C71585"), rarity: .common),
        CarDefinition(id: 8, name: "TITAN ROAD", tagline: "Road dominance", topSpeed: 9, acceleration: 6, handling: 5, nitro: 7, bodyColor: Color(hex: "#4A4A4A"), accentColor: Color(hex: "#FF6B35"), rarity: .epic),
        CarDefinition(id: 9, name: "NEON GHOST", tagline: "A blur in the night", topSpeed: 10, acceleration: 10, handling: 7, nitro: 9, bodyColor: Color(hex: "#0D0D0D"), accentColor: Color(hex: "#FF00FF"), rarity: .legendary),
    ]
}

struct CarSelectionView: View {
    @State private var selectedID: Int = 0
    @State private var hoveredID: Int? = nil
    var onSelect: (CarDefinition) -> Void = { _ in }

    var selectedCar: CarDefinition { CarDefinition.all[selectedID] }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#0A0010"), Color(hex: "#0D0020")],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(spacing: 0) {
                // Title
                Text("SELECT YOUR CAR")
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .kerning(4)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                Text(selectedCar.tagline.uppercased())
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(hex: "#FF6B35"))
                    .padding(.bottom, 16)

                // Horizontal scroll of cars
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(CarDefinition.all) { car in
                            CarCard(car: car, isSelected: car.id == selectedID)
                                .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { selectedID = car.id } }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }

                // Stats panel for selected car
                CarStatsPanel(car: selectedCar)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .transition(.opacity)
                    .id(selectedID) // re-animate on change

                Spacer()

                Button(action: { onSelect(selectedCar) }) {
                    Text("RACE WITH \(selectedCar.name)")
                        .font(.system(size: 17, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedCar.bodyColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
    }
}

struct CarCard: View {
    let car: CarDefinition
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Car drawn on Canvas
            Canvas { ctx, size in
                let w = size.width, h = size.height
                var body = Path()
                body.move(to: CGPoint(x: w * 0.08, y: h * 0.62))
                body.addLine(to: CGPoint(x: w * 0.18, y: h * 0.38))
                body.addLine(to: CGPoint(x: w * 0.32, y: h * 0.22))
                body.addLine(to: CGPoint(x: w * 0.68, y: h * 0.22))
                body.addLine(to: CGPoint(x: w * 0.82, y: h * 0.38))
                body.addLine(to: CGPoint(x: w * 0.92, y: h * 0.62))
                body.closeSubpath()
                ctx.fill(body, with: .color(car.bodyColor))
                ctx.stroke(body, with: .color(car.accentColor), lineWidth: 2)

                let wr: CGFloat = h * 0.2
                for wx in [w * 0.22, w * 0.78] {
                    ctx.fill(Path(ellipseIn: CGRect(x: wx - wr, y: h * 0.6, width: wr * 2, height: wr * 2)), with: .color(.black))
                    ctx.fill(Path(ellipseIn: CGRect(x: wx - wr * 0.5, y: h * 0.6 + wr * 0.5, width: wr, height: wr)), with: .color(Color(white: 0.3)))
                }
            }
            .frame(width: 140, height: 70)

            Text(car.name)
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)

            // Rarity badge
            Text(car.rarity.rawValue)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(car.rarity.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(car.rarity.color.opacity(0.15))
                .cornerRadius(4)

            // Mini stats
            miniStat("SPD", value: car.topSpeed, color: Color(hex: "#00E5FF"))
            miniStat("ACC", value: car.acceleration, color: Color(hex: "#00FF88"))
            miniStat("HND", value: car.handling, color: Color(hex: "#FF6B35"))
        }
        .padding(14)
        .frame(width: 168)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 16).fill(car.bodyColor.opacity(0.08)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? car.bodyColor : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 2.5 : 1)
        )
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .shadow(color: isSelected ? car.bodyColor.opacity(0.5) : .clear, radius: 12)
    }

    @ViewBuilder
    private func miniStat(_ label: String, value: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 24, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                    Capsule().fill(color).frame(width: geo.size.width * CGFloat(value) / 10.0, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

struct CarStatsPanel: View {
    let car: CarDefinition
    var body: some View {
        VStack(spacing: 12) {
            Text(car.name)
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundColor(car.bodyColor)
            HStack(spacing: 16) {
                statItem("TOP SPEED", value: car.topSpeed, color: Color(hex: "#00E5FF"))
                statItem("ACCEL", value: car.acceleration, color: Color(hex: "#00FF88"))
                statItem("HANDLING", value: car.handling, color: Color(hex: "#FF6B35"))
                statItem("NITRO", value: car.nitro, color: Color(hex: "#FF2D95"))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(car.bodyColor.opacity(0.3), lineWidth: 1))
    }

    @ViewBuilder
    private func statItem(_ label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 26, weight: .black, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview { CarSelectionView() }
