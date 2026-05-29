import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject var motionManager: MotionManager

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.12)
                .ignoresSafeArea()

            WebViewContainer()
                .ignoresSafeArea()

            // Driving safety overlay - shown when motion detected
            if motionManager.isDriving {
                DrivingOverlay()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Full-screen overlay shown when device detects driving motion
struct DrivingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()
            VStack(spacing: 24) {
                Text("🚗")
                    .font(.system(size: 80))
                Text("YOU'RE DRIVING")
                    .font(.custom("Courier New", size: 22))
                    .bold()
                    .foregroundColor(.green)
                Text("GameIO is paused for your safety.\nPull over to play.")
                    .font(.custom("Courier New", size: 14))
                    .foregroundColor(Color(red: 0, green: 0.67, blue: 0))
                    .multilineTextAlignment(.center)
                Text("🎵 Kenny G - Songbird playing...")
                    .font(.custom("Courier New", size: 11))
                    .foregroundColor(.gray)
            }
            .padding(40)
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        // Enable Web Inspector on iOS 16.4+
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        context.coordinator.loadGameIO(webView: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func loadGameIO(webView: WKWebView) {
            if let htmlPath = Bundle.main.path(forResource: "gameio-max-ult", ofType: "html") {
                webView.load(URLRequest(url: URL(fileURLWithPath: htmlPath)))
            } else if let url = URL(string: "https://raw.githubusercontent.com/Yapdru/GameIO/main/gameio-max-ult.html") {
                webView.load(URLRequest(url: url))
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("🎮 GameIO loading...")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ GameIO loaded successfully")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ GameIO load error:", error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MotionManager())
}
