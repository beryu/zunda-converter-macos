import SwiftUI

@main
struct ZundaConverterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Settings window is managed by SettingsWindowController (NSWindow).
        // Menu bar app requires at least one Scene, so we use a hidden WindowGroup.
        WindowGroup {
            EmptyView()
        }
        .defaultSize(width: 0, height: 0)
        .windowResizability(.contentSize)
    }
}
