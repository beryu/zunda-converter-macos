import SwiftUI
import Carbon

struct ShortcutRecorderView: View {
    @ObservedObject var settings = SettingsStore.shared
    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack {
            Text("ショートカットキー:")
            
            Button(action: {
                startRecording()
            }) {
                Text(displayString)
                    .frame(width: 140, alignment: .center)
                    .padding(.vertical, 4)
                    .background(isRecording ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isRecording ? Color.accentColor : Color(nsColor: .separatorColor), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            
            if settings.shortcutKeyCode != nil {
                Button(action: {
                    settings.shortcutKeyCode = nil
                    settings.shortcutModifiers = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("ショートカットを削除")
            }
        }
    }
    
    private var displayString: String {
        if isRecording {
            return "キーを入力..."
        }
        guard let code = settings.shortcutKeyCode,
              let mods = settings.shortcutModifiers else {
            return "未設定"
        }
        return KeyUtils.string(for: code, modifiers: mods)
    }
    
    private func startRecording() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Ignore single modifier keys
            if event.modifierFlags.intersection(.deviceIndependentFlagsMask).isEmpty {
                return event
            }
            
            // Save shortcut
            settings.shortcutKeyCode = Int(event.keyCode)
            settings.shortcutModifiers = Int(event.modifierFlags.rawValue)
            
            stopRecording()
            return nil // Consume event
        }
    }
    
    private func stopRecording() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        isRecording = false
    }
}

struct KeyUtils {
    static func string(for keyCode: Int, modifiers: Int) -> String {
        var str = ""
        let flags = NSEvent.ModifierFlags(rawValue: UInt(modifiers))
        
        if flags.contains(.control) { str += "⌃" }
        if flags.contains(.option) { str += "⌥" }
        if flags.contains(.shift) { str += "⇧" }
        if flags.contains(.command) { str += "⌘" }
        
        str += keyString(keyCode)
        return str
    }
    
    static func keyString(_ keyCode: Int) -> String {
        switch keyCode {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_Equal: return "="
        case kVK_ANSI_9: return "9"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_Minus: return "-"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_RightBracket: return "]"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_LeftBracket: return "["
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_Quote: return "'"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_Semicolon: return ";"
        case kVK_ANSI_Backslash: return "\\"
        case kVK_ANSI_Comma: return ","
        case kVK_ANSI_Slash: return "/"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_Period: return "."
        case kVK_ANSI_Grave: return "`"
        case kVK_ANSI_KeypadDecimal: return "."
        case kVK_ANSI_KeypadMultiply: return "*"
        case kVK_ANSI_KeypadPlus: return "+"
        case kVK_ANSI_KeypadClear: return "Clear"
        case kVK_ANSI_KeypadDivide: return "/"
        case kVK_ANSI_KeypadEnter: return "Enter"
        case kVK_ANSI_KeypadMinus: return "-"
        case kVK_ANSI_KeypadEquals: return "="
        case kVK_ANSI_Keypad0: return "0"
        case kVK_ANSI_Keypad1: return "1"
        case kVK_ANSI_Keypad2: return "2"
        case kVK_ANSI_Keypad3: return "3"
        case kVK_ANSI_Keypad4: return "4"
        case kVK_ANSI_Keypad5: return "5"
        case kVK_ANSI_Keypad6: return "6"
        case kVK_ANSI_Keypad7: return "7"
        case kVK_ANSI_Keypad8: return "8"
        case kVK_ANSI_Keypad9: return "9"
        case kVK_Space: return "Space"
        case kVK_Return: return "Return"
        case kVK_Tab: return "Tab"
        case kVK_Delete: return "Delete"
        case kVK_Escape: return "Esc"
        case kVK_ForwardDelete: return "Del"
        default: return "Key \(keyCode)"
        }
    }
}
