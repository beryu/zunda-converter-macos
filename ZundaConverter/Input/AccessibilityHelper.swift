import AppKit

final class AccessibilityHelper: @unchecked Sendable {
    static let shared = AccessibilityHelper()

    private init() {}

    /// Check if the app has accessibility permissions
    var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    /// Open System Settings to the Accessibility privacy pane
    func promptForPermission() {
        // First, trigger the system prompt (adds the app to the list if not present)
        let options: NSDictionary = ["AXTrustedCheckOptionPrompt" as CFString: true]
        AXIsProcessTrustedWithOptions(options)

        // Also open System Settings directly to the Accessibility pane
        // macOS 13+ uses the new URL scheme
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
