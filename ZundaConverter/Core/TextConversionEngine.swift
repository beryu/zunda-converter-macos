import Foundation

/// Facade for text conversion, dispatching to the appropriate converter
/// based on the current settings.
final class TextConversionEngine {
    static let shared = TextConversionEngine()

    private let ruleBasedConverter = RuleBasedConverter()

    private init() {}

    /// Convert text to Zundamon-style speech
    /// - Parameter text: The input text to convert
    /// - Returns: Converted text in Zundamon style
    func convert(_ text: String) -> String {
        switch SettingsStore.shared.conversionMode {
        case .ruleBased:
            return ruleBasedConverter.convert(text)
        }
    }
}
