import AppKit
import SwiftUI

/// Manages the Settings window lifecycle.
/// Uses NSWindow + NSHostingController instead of SwiftUI's Settings scene,
/// which resolves the "Please use SettingsLink" issue on macOS 14+.
final class SettingsWindowController: @unchecked Sendable {
    static let shared = SettingsWindowController()

    private var window: NSWindow?

    private init() {}

    func showSettings() {
        if let window = window {
            // Window already exists — bring it to front
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create a new window hosting the SwiftUI SettingsView
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "ZundaConverter 設定"
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 520, height: 580))
        window.minSize = NSSize(width: 480, height: 400)
        window.center()
        window.isReleasedWhenClosed = false

        // Clean up reference when user closes the window
        window.delegate = WindowCloseDelegate.shared

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }

    func windowWillClose() {
        window = nil
    }
}

// Simple delegate to clear the window reference on close
private final class WindowCloseDelegate: NSObject, NSWindowDelegate, @unchecked Sendable {
    static let shared = WindowCloseDelegate()

    func windowWillClose(_ notification: Notification) {
        SettingsWindowController.shared.windowWillClose()
    }
}
