import Foundation

/// Conversion mode enumeration
enum ConversionMode: String, CaseIterable, Identifiable {
    case ruleBased = "ruleBased"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ruleBased:
            return "ルールベース（高速）"
        }
    }

    var description: String {
        switch self {
        case .ruleBased:
            return "正規表現による即時変換。高速だが機械的。"
        }
    }
}

/// Persistent settings store using UserDefaults
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let conversionMode = "conversionMode"
        static let launchAtLogin = "launchAtLogin"
        static let showNotification = "showNotification"
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

    private init() {
        let modeRaw = defaults.string(forKey: Keys.conversionMode) ?? ConversionMode.ruleBased.rawValue
        self.conversionMode = ConversionMode(rawValue: modeRaw) ?? .ruleBased
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.showNotification = defaults.bool(forKey: Keys.showNotification)
    }
}
