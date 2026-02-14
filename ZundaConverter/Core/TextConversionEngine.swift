import Foundation

/// Facade for text conversion, dispatching to the appropriate converter
/// based on the current settings.
final class TextConversionEngine: @unchecked Sendable {
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
        case .ai:
            if #available(macOS 26, *) {
                // NSServices expects synchronous return, so we block.
                return runBlocking {
                    try await LLMConverter.shared.convert(text)
                } ?? ruleBasedConverter.convert(text) // Fallback to rule-based on error
            } else {
                // Foundation Models requires macOS 26+; fallback to rule-based
                return ruleBasedConverter.convert(text)
            }
        }
    }

    private final class ResultBox: @unchecked Sendable {
        var value: String?
    }

    private func runBlocking(_ operation: @Sendable @escaping () async throws -> String) -> String? {
        let box = ResultBox()
        let semaphore = DispatchSemaphore(value: 0)
        
        Task.detached {
            box.value = try? await operation()
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 15.0)
        return box.value
    }
}
