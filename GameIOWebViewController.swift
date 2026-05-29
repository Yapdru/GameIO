import UIKit
import WebKit
import AVFoundation

class GameIOWebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    let loadingIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure audio session for iOS
        configureAudioSession()

        // Setup WebView
        setupWebView()

        // Setup loading indicator
        setupLoadingIndicator()

        // Load GameIO
        loadGameIO()
    }

    // MARK: - Audio Configuration

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .default,
                options: [.duckOthers, .defaultToSpeaker]
            )
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session configured")
        } catch {
            print("❌ Audio configuration error:", error.localizedDescription)
        }
    }

    // MARK: - WebView Setup

    private func setupWebView() {
        // Create WebView configuration
        let config = WKWebViewConfiguration()

        // JavaScript settings
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Media settings
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true

        // User agent
        config.applicationNameForUserAgent = "Version/15.1 Safari/605.1.15"

        // Add message handlers for JS-to-Swift communication
        config.userContentController.add(self, name: "gameioHandler")
        config.userContentController.add(self, name: "console")

        // Enable inspector for debugging (iOS 16.4+)
        if #available(iOS 16.4, *) {
            config.ignoresViewportScaleLimits = false
        }

        // Create WebView
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Appearance
        webView.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 1.0)
        webView.isOpaque = false
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        // Disable zoom
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0

        view.addSubview(webView)
    }

    // MARK: - Loading Indicator

    private func setupLoadingIndicator() {
        loadingIndicator.color = UIColor(red: 0.0, green: 1.0, blue: 0.0) // Neon green
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }

    // MARK: - Load GameIO

    private func loadGameIO() {
        // Option 1: Load from local file bundle (preferred for offline)
        if let htmlPath = Bundle.main.path(forResource: "gameio-max-ult", ofType: "html") {
            print("📁 Loading GameIO from local bundle...")
            let url = URL(fileURLWithPath: htmlPath)
            let request = URLRequest(url: url)
            webView.load(request)
            loadingIndicator.startAnimating()
        }
        // Option 2: Load from GitHub (requires internet)
        else if let url = URL(string: "https://raw.githubusercontent.com/Yapdru/GameIO/main/gameio-max-ult.html") {
            print("🌐 Loading GameIO from GitHub...")
            let request = URLRequest(url: url)
            webView.load(request)
            loadingIndicator.startAnimating()
        }
        // Fallback: Show error
        else {
            print("❌ GameIO file not found")
            showErrorAlert()
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("🎮 GameIO loading started...")
        loadingIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ GameIO loaded successfully")
        loadingIndicator.stopAnimating()

        // Inject JavaScript utilities
        injectJavaScriptBridge()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ GameIO load failed:", error.localizedDescription)
        loadingIndicator.stopAnimating()
        showErrorAlert()
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        print("❌ Provisional navigation failed:", error.localizedDescription)
        loadingIndicator.stopAnimating()
        showErrorAlert()
    }

    // MARK: - Message Handling

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "gameioHandler" {
            handleGameIOMessage(message.body)
        } else if message.name == "console" {
            print("📱 [JS Console]:", message.body)
        }
    }

    private func handleGameIOMessage(_ body: Any) {
        if let dict = body as? [String: Any] {
            if let type = dict["type"] as? String {
                switch type {
                case "gameStarted":
                    print("🎮 Game started")
                case "gameStopped":
                    print("🏁 Game ended")
                case "roomCreated":
                    if let code = dict["code"] as? String {
                        print("🏠 Room created:", code)
                    }
                case "playerJoined":
                    if let name = dict["playerName"] as? String {
                        print("👤 Player joined:", name)
                    }
                default:
                    print("📨 Message:", dict)
                }
            }
        }
    }

    // MARK: - JavaScript Bridge

    private func injectJavaScriptBridge() {
        let javascript = """
        // Bridge to communicate with Swift
        window.swiftBridge = {
            sendMessage: function(message) {
                window.webkit.messageHandlers.gameioHandler.postMessage(message);
            },
            log: function(msg) {
                window.webkit.messageHandlers.console.postMessage(msg);
            }
        };

        // Override console for debugging
        window.console.log = function(...args) {
            window.swiftBridge.log(args.join(' '));
        };

        console.log('✅ JavaScript bridge loaded');
        """

        webView.evaluateJavaScript(javascript) { result, error in
            if let error = error {
                print("❌ JavaScript injection error:", error.localizedDescription)
            } else {
                print("✅ JavaScript bridge injected")
            }
        }
    }

    // MARK: - Error Handling

    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "GameIO Load Error",
            message: "Failed to load GameIO. Please check your internet connection and try again.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.loadGameIO()
        })

        alert.addAction(UIAlertAction(title: "Offline Mode", style: .default) { _ in
            // Could load cached version if available
        })

        present(alert, animated: true)
    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
