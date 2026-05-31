// iPadCarSelectView.swift
// GameIO 2P — iPad Car Selection (Grid Layout)
// Uses adaptive grid instead of horizontal scroll for larger screen.

import SwiftUI

struct iPadCarSelectView: View {
    @State private var selectedID: Int = 0
    @State private var hoveredID: Int? = nil
    var onSelect: (CarDefinition) -> Void = { _ in }

    let columns = [GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 20)]
    var selectedCar: CarDefinition { CarDefinition.all[selectedID] }

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Left: car grid
                ZStack {
                    Color(hex: "#0A0010").ignoresSafeArea()
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(CarDefinition.all) { car in
                                iPadCarCell(car: car, isSelected: car.id == selectedID)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedID = car.id
                                        }
                                    }
                            }
                        }
                        .padding(24)
                    }
                }
                .frame(maxWidth: .infinity)

                // Right: detail panel
                carDetailPanel
                    .frame(width: 320)
            }
            .navigationTitle("SELECT YOUR CAR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("SELECT") { onSelect(selectedCar) }
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                        .foregroundColor(selectedCar.bodyColor)
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Car Cell

    @ViewBuilder
    private func iPadCarCell(_ car: CarDefinition, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Canvas { ctx, size in
                let w = size.width, h = size.height
                var body = Path()
                body.move(to: CGPoint(x: w*0.08, y: h*0.62))
                body.addLine(to: CGPoint(x: w*0.18, y: h*0.38))
                body.addLine(to: CGPoint(x: w*0.32, y: h*0.22))
                body.addLine(to: CGPoint(x: w*0.68, y: h*0.22))
                body.addLine(to: CGPoint(x: w*0.82, y: h*0.38))
                body.addLine(to: CGPoint(x: w*0.92, y: h*0.62))
                body.closeSubpath()
                ctx.fill(body, with: .color(car.bodyColor))
                ctx.stroke(body, with: .color(car.accentColor), lineWidth: 2.5)
                let wr: CGFloat = h * 0.2
                for wx in [w * 0.22, w * 0.78] {
                    ctx.fill(Path(ellipseIn: CGRect(x: wx-wr, y: h*0.6, width: wr*2, height: wr*2)), with: .color(.black))
                }
            }
            .frame(height: 90)

            Text(car.name)
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.white)

            Text(car.rarity.rawValue)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(car.rarity.color)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(car.rarity.color.opacity(0.15))
                .cornerRadius(4)

            // Compact stats
            ForEach([("SPD", car.topSpeed, Color(hex: "#00E5FF")),
                     ("HND", car.handling, Color(hex: "#FF6B35")),
                     ("NIT", car.nitro, Color(hex: "#00FF88"))], id: \.0) { stat in
                HStack(spacing: 6) {
                    Text(stat.0).font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4)).frame(width: 22, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                            Capsule().fill(stat.2).frame(width: geo.size.width * CGFloat(stat.1) / 10, height: 4)
                        }
                    }.frame(height: 4)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? car.bodyColor.opacity(0.15) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? car.bodyColor : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.03 : 1)
        .shadow(color: isSelected ? car.bodyColor.opacity(0.4) : .clear, radius: 10)
    }

    // MARK: - Detail Panel

    var carDetailPanel: some View {
        ZStack {
            Color(hex: "#0D0D1A").ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    Canvas { ctx, size in
                        let w = size.width, h = size.height
                        var body = Path()
                        body.move(to: CGPoint(x: w*0.08, y: h*0.62))
                        body.addLine(to: CGPoint(x: w*0.18, y: h*0.38))
                        body.addLine(to: CGPoint(x: w*0.32, y: h*0.22))
                        body.addLine(to: CGPoint(x: w*0.68, y: h*0.22))
                        body.addLine(to: CGPoint(x: w*0.82, y: h*0.38))
                        body.addLine(to: CGPoint(x: w*0.92, y: h*0.62))
                        body.closeSubpath()
                        ctx.fill(body, with: .color(selectedCar.bodyColor))
                        let wr: CGFloat = h * 0.2
                        for wx in [w*0.22, w*0.78] {
                            ctx.fill(Path(ellipseIn: CGRect(x: wx-wr, y: h*0.6, width: wr*2, height: wr*2)), with: .color(.black))
                        }
                    }
                    .frame(height: 120)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Text(selectedCar.name)
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(selectedCar.bodyColor)

                    Text(selectedCar.tagline)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))

                    Divider().background(Color.white.opacity(0.1))

                    VStack(spacing: 16) {
                        detailStat("TOP SPEED", value: selectedCar.topSpeed, color: Color(hex: "#00E5FF"))
                        detailStat("ACCELERATION", value: selectedCar.acceleration, color: Color(hex: "#00FF88"))
                        detailStat("HANDLING", value: selectedCar.handling, color: Color(hex: "#FF6B35"))
                        detailStat("NITRO", value: selectedCar.nitro, color: Color(hex: "#FF2D95"))
                    }
                    .padding(.horizontal, 20)

                    Button(action: { onSelect(selectedCar) }) {
                        Text("RACE WITH THIS CAR")
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(selectedCar.bodyColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .id(selectedID)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: selectedID)
    }

    @ViewBuilder
    private func detailStat(_ label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(label).font(.system(size: 12, design: .monospaced)).foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("\(value)/10").font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 6)
                    Capsule().fill(color).frame(width: geo.size.width * CGFloat(value) / 10, height: 6)
                }
            }.frame(height: 6)
        }
    }
}

#Preview { iPadCarSelectView() }
