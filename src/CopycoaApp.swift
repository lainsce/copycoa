import SwiftData
import SwiftUI

@main
struct CopycoaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        // The detail canvas extends beneath the hidden title bar, so let empty
        // window background space remain a native window-drag region. Card
        // gestures still own their cards; this only fills the gap left by the
        // hidden title bar.
        .windowBackgroundDragBehavior(.enabled)
        .defaultSize(width: 1024, height: 600)
        .windowResizability(.contentSize)
        .commands {
            CopycoaCommands()
        }
        .modelContainer(for: [Board.self, Card.self])

        Window("Privacy Policy", id: "privacy-policy") {
            PrivacyPolicyView()
        }
        .defaultSize(width: 540, height: 540)
        .windowResizability(.contentSize)
    }
}

/// Quits the app once its last window is closed, matching single-window macOS app behaviour.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
