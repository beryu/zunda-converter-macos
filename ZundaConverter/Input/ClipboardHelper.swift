import AppKit
import Carbon

final class ClipboardHelper: @unchecked Sendable {
    static let shared = ClipboardHelper()
    
    private init() {}

    /// Main entry point: simulates Copy -> Convert -> Paste flow
    func convertSelection() async {
        guard AccessibilityHelper.shared.isTrusted else {
            print("Accessibility permission missing")
            // Ideally show UI alert here
            return
        }

        // 1. Capture current clipboard change count to detect when copy finishes
        let originalChangeCount = NSPasteboard.general.changeCount
        
        // 2. Simulate Cmd+C
        simulateKeyPress(keyCode: kVK_ANSI_C, modifiers: .maskCommand)

        // 3. Wait for clipboard to update (max 1 sec)
        var newText: String? = nil
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < 1.0 {
            if NSPasteboard.general.changeCount > originalChangeCount {
                newText = NSPasteboard.general.string(forType: .string)
                break
            }
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }

        guard let text = newText, !text.isEmpty else {
            print("Clipboard did not update or is empty")
            return
        }

        // 4. Convert text
        let convertedText = TextConversionEngine.shared.convert(text)

        // 5. Write converted text to clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(convertedText, forType: .string)

        // 6. Simulate Cmd+V
        simulateKeyPress(keyCode: kVK_ANSI_V, modifiers: .maskCommand)
    }

    private func simulateKeyPress(keyCode: Int, modifiers: CGEventFlags) {
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Key Down
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: true)
        keyDown?.flags = modifiers
        keyDown?.post(tap: .cghidEventTap)

        // Key Up
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: false)
        keyUp?.flags = modifiers
        keyUp?.post(tap: .cghidEventTap)
    }
}
