// AdvancedUIComponents.swift — Comprehensive reusable UI components with animations
// Progress bars, gauges, panels, notifications, modals, sheets, popovers

import SwiftUI

// MARK: - Circular Progress View
struct CircularProgressView: View {
    var progress: Double
    var lineWidth: CGFloat = 8
    var foregroundColor: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.2)
    var label: String?
    var animated: Bool = true

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animated ? progress : progress)
                .stroke(foregroundColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            if let label = label {
                VStack {
                    Text(label)
                        .font(.system(size: 24, weight: .bold))
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Linear Progress View
struct LinearProgressView: View {
    var progress: Double
    var height: CGFloat = 8
    var foregroundColor: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.2)
    var cornerRadius: CGFloat = 4
    var animated: Bool = true
    var showLabel: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(foregroundColor)
                    .frame(width: animated ? max(0, max(CGFloat(progress) * 300, 20)) : max(CGFloat(progress) * 300, 20))
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
            .frame(height: height)

            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Gauge View
struct GaugeView: View {
    var value: Double
    var minValue: Double = 0
    var maxValue: Double = 100
    var label: String = ""
    var unit: String = ""
    var needleColor: Color = .red
    var backgroundColor: Color = Color(red: 0.95, green: 0.97, blue: 0.99)

    var normalizedValue: Double {
        (value - minValue) / (maxValue - minValue)
    }

    var rotation: Double {
        -180 + (normalizedValue * 180)
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(backgroundColor)

                Canvas { context, size in
                    var path = Path()
                    path.addArc(center: CGPoint(x: size.width/2, y: size.height/2), radius: size.width/2 * 0.8, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)

                    context.stroke(
                        path,
                        with: .color(.gray.opacity(0.3)),
                        lineWidth: 4
                    )

                    for i in 0..<9 {
                        let angle = Double(i) * 20
                        let startRadius = size.width / 2 * 0.7
                        let endRadius = size.width / 2 * 0.8
                        let startPoint = CGPoint(
                            x: size.width/2 + startRadius * cos(CGFloat(angle - 90) * .pi / 180),
                            y: size.height/2 + startRadius * sin(CGFloat(angle - 90) * .pi / 180)
                        )
                        let endPoint = CGPoint(
                            x: size.width/2 + endRadius * cos(CGFloat(angle - 90) * .pi / 180),
                            y: size.height/2 + endRadius * sin(CGFloat(angle - 90) * .pi / 180)
                        )

                        var tickPath = Path()
                        tickPath.move(to: startPoint)
                        tickPath.addLine(to: endPoint)
                        context.stroke(tickPath, with: .color(.gray), lineWidth: 2)
                    }
                }

                VStack(spacing: 4) {
                    ZStack {
                        Circle().fill(needleColor).frame(width: 12, height: 12)

                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(needleColor)
                                .frame(width: 4, height: 80)
                            Spacer()
                        }
                        .frame(height: 80)
                        .rotationEffect(.degrees(rotation))
                    }

                    Spacer()

                    Text("\(Int(value)) \(unit)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(needleColor)
                }
                .padding(40)
            }

            if !label.isEmpty {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
    var value: Int
    var duration: Double = 1.0
    @State private var displayValue: Int = 0

    var body: some View {
        Text("\(displayValue)")
            .onReceive(Timer.publish(every: duration / Double(value), on: .main, in: .common).autoconnect()) { _ in
                if displayValue < value {
                    displayValue += 1
                }
            }
    }
}

// MARK: - Status Indicator
struct StatusIndicator: View {
    enum Status { case good, warning, critical, inactive }

    var status: Status
    var size: CGFloat = 12

    var color: Color {
        switch status {
        case .good: return .green
        case .warning: return .yellow
        case .critical: return .red
        case .inactive: return .gray
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))

            Circle()
                .fill(color)
                .scaleEffect(0.6)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: status)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Color(red: 0.98, green: 0.98, blue: 0.99)
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 4

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}

// MARK: - Glass Morphism Panel
struct GlassPanel<Content: View>: View {
    let content: Content
    var opacity: Double = 0.2

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(Color.white.opacity(opacity))
            .backdrop()
            .cornerRadius(12)
    }
}

// MARK: - Backdrop Modifier
struct BackdropModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            return AnyView(content.background(.ultraThinMaterial))
        } else {
            return AnyView(content.background(Color.white.opacity(0.3)))
        }
    }
}

extension View {
    func backdrop() -> some View {
        modifier(BackdropModifier())
    }
}

// MARK: - Notification Badge
struct NotificationBadge: View {
    var count: Int
    var maxCount: Int = 99
    var backgroundColor: Color = .red
    var textColor: Color = .white

    var body: some View {
        ZStack {
            Circle().fill(backgroundColor)

            Text("\(min(count, maxCount))\(count > maxCount ? "+" : "")")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(textColor)
        }
        .frame(width: 20, height: 20)
    }
}

// MARK: - Shimmer Loading View
struct ShimmerView: View {
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.3),
                    Color.gray.opacity(0.1),
                    Color.gray.opacity(0.3)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isLoading ? 300 : -300)
            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isLoading)
        }
        .onAppear { isLoading = true }
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color(red: 0.1, green: 0.4, blue: 0.8)
    var foregroundColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color.gray.opacity(0.2)
    var foregroundColor: Color = .black

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(8)
            .border(Color.gray.opacity(0.3), width: 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.red)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Expandable Section
struct ExpandableSection: View {
    @State private var isExpanded: Bool = false
    let title: String
    let content: String

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(title).font(.headline).foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut, value: isExpanded)
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
            }

            if isExpanded {
                Text(content)
                    .font(.body)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .transition(.opacity)
            }
        }
        .cornerRadius(8)
        .border(Color.gray.opacity(0.2))
    }
}

// MARK: - Swipe Action Card
struct SwipeActionCard<Content: View>: View {
    @State private var offset: CGFloat = 0
    let content: Content
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void

    init(
        @ViewBuilder content: () -> Content,
        onSwipeLeft: @escaping () -> Void = {},
        onSwipeRight: @escaping () -> Void = {}
    ) {
        self.content = content()
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
    }

    var body: some View {
        ZStack {
            if offset < -50 {
                HStack {
                    Spacer()
                    Button(action: onSwipeLeft) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.red)
                }
            }

            if offset > 50 {
                HStack {
                    Button(action: onSwipeRight) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.blue)
                    Spacer()
                }
            }

            content
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation.width
                        }
                        .onEnded { gesture in
                            withAnimation {
                                if offset < -100 {
                                    onSwipeLeft()
                                    offset = 0
                                } else if offset > 100 {
                                    onSwipeRight()
                                    offset = 0
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
    }
}

// MARK: - Carousel View
struct CarouselView<Content: View, ID: Hashable>: View {
    let items: [ID]
    let content: (ID) -> Content
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    content(item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var imageName: String
    var title: String
    var message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: imageName)
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(red: 0.1, green: 0.4, blue: 0.8))
                        .cornerRadius(8)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.98, green: 0.98, blue: 0.99))
    }
}
