# GameIO MAX ULT - Xcode Integration Guide

**Status:** ✅ Production Ready for iOS  
**Version:** 2.0 - Xcode Edition  
**Compatibility:** iOS 13.0+, macOS 10.15+

---

## 🍎 Quick Start: Integrating with Xcode

### Step 1: Create iOS App in Xcode

```bash
# Create new iOS app project
open -a Xcode
# File → New → Project → App (SwiftUI/UIKit)
```

### Step 2: Add WebView to ViewController

**SwiftUI (Recommended):**
```swift
import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebViewContainer()
    }
}

struct WebViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Load local HTML file
        if let htmlPath = Bundle.main.path(forResource: "gameio-max-ult", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.load(URLRequest(url: url))
        }
        // Or load from GitHub
        else {
            let url = URL(string: "https://raw.githubusercontent.com/Yapdru/GameIO/main/gameio-max-ult.html")!
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    ContentView()
}
```

**UIKit:**
```swift
import UIKit
import WebKit

class ViewController: UIViewController {
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuration
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Load HTML
        if let htmlPath = Bundle.main.path(forResource: "gameio-max-ult", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.load(URLRequest(url: url))
        }
    }
}
```

### Step 3: Add gameio-max-ult.html to Xcode Project

1. **In Xcode:** Right-click project → Add Files to Project
2. Select `gameio-max-ult.html`
3. ✅ Check "Copy items if needed"
4. ✅ Check "Add to targets"

### Step 4: Configure Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Allow HTTP (for audio files) -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
        <key>NSExceptionDomains</key>
        <dict>
            <key>github.com</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <true/>
            </dict>
        </dict>
    </dict>
    
    <!-- Microphone permission (for future audio recording) -->
    <key>NSMicrophoneUsageDescription</key>
    <string>GameIO needs microphone access for voice chat features</string>
    
    <!-- Camera permission (for future video features) -->
    <key>NSCameraUsageDescription</key>
    <string>GameIO needs camera access for video chat features</string>
    
    <!-- App name -->
    <key>CFBundleDisplayName</key>
    <string>GameIO MAX ULT</string>
    
    <!-- Status bar -->
    <key>UIStatusBarHidden</key>
    <false/>
    <key>UIStatusBarStyle</key>
    <string>UIStatusBarStyleLightContent</string>
</dict>
</plist>
```

### Step 5: Update App Delegate (if using AppKit)

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Enable gesture recognizer for web view
        return true
    }
    
    // MARK: UISceneDelegate Stubs
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
```

---

## 🎮 Complete iOS Example Project Structure

```
GameIO.xcodeproj/
├── GameIO/
│   ├── Assets.xcassets/
│   │   └── AppIcon.appiconset/
│   ├── ContentView.swift
│   ├── GameIOApp.swift
│   ├── Info.plist
│   └── gameio-max-ult.html ← Add here
├── GameIO.xcodeproj
└── Preview Content/
    └── Preview Assets.xcassets/
```

---

## 🔧 WKWebView Configuration (Advanced)

```swift
import WebKit

class GameIOWebViewController: UIViewController, WKNavigationDelegate {
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
    }
    
    func configureWebView() {
        // Setup configuration
        let config = WKWebViewConfiguration()
        
        // JavaScript settings
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // Media settings
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // User agent (optional - masquerade as Safari)
        config.applicationNameForUserAgent = "Version/15.1 Safari/605.1.15"
        
        // Message handlers for JS-to-Swift communication
        config.userContentController.add(self, name: "gameioHandler")
        
        // Create webview with config
        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(webView)
        self.webView = webView
        
        // Load game
        loadGameIO()
    }
    
    func loadGameIO() {
        // Option 1: Load from local file
        if let htmlPath = Bundle.main.path(forResource: "gameio-max-ult", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            let request = URLRequest(url: url)
            webView.load(request)
        }
        // Option 2: Load from GitHub
        else {
            let url = URL(string: "https://raw.githubusercontent.com/Yapdru/GameIO/main/gameio-max-ult.html")!
            webView.load(URLRequest(url: url))
        }
    }
    
    // Handle messages from JavaScript
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "gameioHandler" {
            print("Message from GameIO:", message.body)
        }
    }
}
```

---

## 📱 iOS-Specific Features

### Safe Area Support
```swift
// Automatically handled by viewport-fit=cover meta tag
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
```

### Status Bar Integration
```swift
// Light content on dark background
override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
}
```

### Gesture Support
```swift
// GameIO uses touch events - fully supported
// Pinch to zoom - disabled by default (configure as needed)
webView.scrollView.pinchGestureRecognizer?.isEnabled = false
```

### Safe Audio Loading
```javascript
// In gameio-max-ult.html - handles missing audio gracefully
currentAudio.play().catch(e => {
    console.log('Audio unavailable (iOS may require user interaction)');
});
```

---

## 🎵 Audio Playback on iOS

### Important: User Interaction Required

iOS requires user interaction to play audio. The game handles this by:

1. **First user tap** activates audio context
2. **Subsequent transitions** can play audio

### Setup AudioSession

```swift
import AVFoundation

// In AppDelegate or SceneDelegate
do {
    try AVAudioSession.sharedInstance().setCategory(
        .default,
        options: [.duckOthers, .defaultToSpeaker]
    )
    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
} catch {
    print("Failed to set audio session category:", error)
}
```

### Add Audio File to Bundle

```bash
# Copy Kenny G Songbird to Xcode project
# Right-click project → Add Files
# Select audio file
# ✅ Copy items if needed
# ✅ Add to targets
```

---

## 🎨 Theming for iOS

The game automatically adapts to iOS dark mode:

```swift
// No changes needed - HTML respects system dark mode
// Colors are explicitly set to dark theme anyway
```

---

## 🔐 Privacy & Permissions

### Required Info.plist Entries

```xml
<!-- Microphone (for future voice chat) -->
<key>NSMicrophoneUsageDescription</key>
<string>GameIO uses microphone for voice chat with friends</string>

<!-- Camera (for future video features) -->
<key>NSCameraUsageDescription</key>
<string>GameIO uses camera for video chat features</string>

<!-- Local Network (for future multiplayer) -->
<key>NSBonjourServices</key>
<array>
    <string>_gameio._tcp</string>
</array>
```

---

## 📦 Distribution & App Store

### Checklist for App Store Submission

- [ ] Create App ID in Apple Developer
- [ ] Add Privacy Policy URL
- [ ] Set Age Rating (12+)
- [ ] Configure App Store metadata
- [ ] Add screenshots showing gameplay
- [ ] Create app description
- [ ] Set pricing (Free)
- [ ] Enable In-App Purchases (optional)

### App Store Description Template

```
GameIO MAX ULT - Multiplayer Game Platform

Play 9 exciting games with friends in this retro pixel-style gaming platform!

Features:
• 9 unique games (Fishana, Charades, Cars, and more)
• Multiplayer rooms with friend invitations
• Real-time leaderboards
• Immersive narrative experience
• Pixel retro aesthetic with smooth animations

Create your avatar, join a lobby, and start playing with friends!

Perfect for casual gaming and social play.
```

---

## 🐛 Debugging in Xcode

### Enable Web Inspector

```swift
#if DEBUG
if #available(iOS 16.4, *) {
    webView.isInspectable = true
}
#endif
```

### View Console Logs

```swift
// Add to view controller
func setupWebViewLogging() {
    let script = """
    window.console.log = (function(old) {
        return function(message) {
            window.webkit.messageHandlers.gameioHandler.postMessage({
                type: 'log',
                message: message
            });
            old(message);
        }
    })(window.console.log);
    """
    
    let userScript = WKUserScript(
        source: script,
        injectionTime: .atDocumentStart,
        forMainFrameOnly: true
    )
    webView.configuration.userContentController.addUserScript(userScript)
}
```

---

## 📊 Performance Optimization

### Reduce Bundle Size

```swift
// Minify HTML/CSS/JavaScript before bundling
// Current: 49 KB → Minified: ~28 KB
```

### Memory Management

```swift
// Clean up WebView when done
deinit {
    webView.navigationDelegate = nil
    webView.removeFromSuperview()
}
```

---

## 🚀 Testing on Device

### Steps:

1. **Connect iPhone/iPad** to Mac
2. **Select device** in Xcode
3. **Build & Run** (Cmd+R)
4. **Test gameplay** and all features
5. **Check console** for any errors

### Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Audio not playing | User interaction required first |
| Video slow | Reduce network calls |
| Rotation broken | Set supported orientations in Info.plist |
| Touch unresponsive | Check WKWebView initialization |

---

## 📚 Additional Resources

- [Apple WebKit Documentation](https://developer.apple.com/documentation/webkit)
- [WKWebView Guide](https://developer.apple.com/documentation/webkit/wkwebview)
- [App Store Connect Help](https://help.apple.com/app-store-connect)
- [SwiftUI WebView Tutorial](https://www.hackingwithswift.com)

---

## 🎯 Complete Working Example

See `example-ios-project/` for complete Xcode project with:
- ✅ SwiftUI integration
- ✅ WKWebView configuration
- ✅ Audio handling
- ✅ Privacy settings
- ✅ Proper lifecycle management

---

**Status:** ✅ Ready for iOS App Store  
**Compatibility:** iOS 13+, macOS 10.15+  
**Quality:** Production Ready

---

*GameIO MAX ULT for iOS*  
*Xcode Integration Guide*  
*Version 2.0*
