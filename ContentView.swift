import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        ZStack {
            // Dark background to match game theme
            Color(red: 0.06, green: 0.06, blue: 0.12)
                .ignoresSafeArea()

            // WebView container
            WebViewContainer()
                .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }
}

struct WebViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // Enable JavaScript
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Media settings - allow audio/video playback
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // Create WebView
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        // Load GameIO
        context.coordinator.loadGameIO(webView: webView)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func loadGameIO(webView: WKWebView) {
            // Try to load from local bundle first
            if let htmlPath = Bundle.main.path(forResource: "gameio-max-ult", ofType: "html") {
                let url = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: url)
                webView.load(request)
            }
            // Fallback to GitHub
            else if let url = URL(string: "https://raw.githubusercontent.com/Yapdru/GameIO/main/gameio-max-ult.html") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }

        // Handle navigation
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
}
