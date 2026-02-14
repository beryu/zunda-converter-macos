import Carbon
import AppKit
import Combine

// Global callback for Carbon Event Handler
private func hotKeyHandler(nextHandler: EventHandlerCallRef?, event: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    ShortcutManager.shared.handleHotKey()
    return noErr
}

/// Manages global hotkey registration using Carbon.
final class ShortcutManager: @unchecked Sendable {
    static let shared = ShortcutManager()

    private var hotKeyRef: EventHotKeyRef?
    private var cancellables = Set<AnyCancellable>()
    private var eventHandlerInstalled = false

    private init() {
        // Observe settings changes to re-register hotkey
        SettingsStore.shared.$shortcutKeyCode
            .combineLatest(SettingsStore.shared.$shortcutModifiers)
            .sink { [weak self] keyCode, modifiers in
                self?.registerHotKey(keyCode: keyCode, modifiers: modifiers)
            }
            .store(in: &cancellables)
    }

    /// Register the hotkey
    private func registerHotKey(keyCode: Int?, modifiers: Int?) {
        // Unregister existing
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }

        guard let keyCode = keyCode, let modifiersRaw = modifiers else { return }

        // Install event handler if not already installed
        if !eventHandlerInstalled {
            var eventType = EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            )

            InstallEventHandler(
                GetApplicationEventTarget(),
                hotKeyHandler,
                1,
                &eventType,
                nil,
                nil
            )
            eventHandlerInstalled = true
        }

        let hotKeyID = EventHotKeyID(signature: OSType(1465209673), id: 1) // 'ZRMC'

        var carbonModifiers: UInt32 = 0
        if UInt(modifiersRaw) & NSEvent.ModifierFlags.shift.rawValue != 0 { carbonModifiers |= UInt32(shiftKey) }
        if UInt(modifiersRaw) & NSEvent.ModifierFlags.control.rawValue != 0 { carbonModifiers |= UInt32(controlKey) }
        if UInt(modifiersRaw) & NSEvent.ModifierFlags.option.rawValue != 0 { carbonModifiers |= UInt32(optionKey) }
        if UInt(modifiersRaw) & NSEvent.ModifierFlags.command.rawValue != 0 { carbonModifiers |= UInt32(cmdKey) }

        let status = RegisterEventHotKey(
            UInt32(keyCode),
            carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            print("Failed to register hotkey: \(status)")
        } else {
            print("Registered hotkey: \(keyCode) with modifiers: \(carbonModifiers)")
        }
    }

    func handleHotKey() {
        print("Hotkey triggered! Starting conversion flow...")
        Task {
            await ClipboardHelper.shared.convertSelection()
        }
    }
}
