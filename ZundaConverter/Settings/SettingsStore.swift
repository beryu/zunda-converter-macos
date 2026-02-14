import Foundation

/// Conversion mode enumeration
enum ConversionMode: String, CaseIterable, Identifiable {
    case ruleBased = "ruleBased"
    case ai = "ai"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ruleBased:
            return "ルールベース（高速）"
        case .ai:
            return "AIモード（高精度・実験的）"
        }
    }

    var description: String {
        switch self {
        case .ruleBased:
            return "正規表現による即時変換。高速だが機械的。"
        case .ai:
            return "Apple Intelligence によるオンデバイス変換。自然な口調変換。"
        }
    }
}

/// Persistent settings store using UserDefaults
final class SettingsStore: ObservableObject, @unchecked Sendable {
    static let shared = SettingsStore()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let conversionMode = "conversionMode"
        static let launchAtLogin = "launchAtLogin"
        static let showNotification = "showNotification"
        static let shortcutKeyCode = "shortcutKeyCode"
        static let shortcutModifiers = "shortcutModifiers"
    }

    @Published var conversionMode: ConversionMode {
        didSet {
            defaults.set(conversionMode.rawValue, forKey: Keys.conversionMode)
        }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
        }
    }

    @Published var showNotification: Bool {
        didSet {
            defaults.set(showNotification, forKey: Keys.showNotification)
        }
    }

    @Published var shortcutKeyCode: Int? {
        didSet {
            defaults.set(shortcutKeyCode, forKey: Keys.shortcutKeyCode)
        }
    }

    @Published var shortcutModifiers: Int? {
        didSet {
            defaults.set(shortcutModifiers, forKey: Keys.shortcutModifiers)
        }
    }

    private init() {
        let modeRaw = defaults.string(forKey: Keys.conversionMode) ?? ConversionMode.ruleBased.rawValue
        self.conversionMode = ConversionMode(rawValue: modeRaw) ?? .ruleBased
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.showNotification = defaults.bool(forKey: Keys.showNotification)
        
        if defaults.object(forKey: Keys.shortcutKeyCode) != nil {
            self.shortcutKeyCode = defaults.integer(forKey: Keys.shortcutKeyCode)
            self.shortcutModifiers = defaults.integer(forKey: Keys.shortcutModifiers)
        } else {
            self.shortcutKeyCode = nil
            self.shortcutModifiers = nil
        }
    }
}
