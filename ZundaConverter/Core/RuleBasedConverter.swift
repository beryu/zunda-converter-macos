import Foundation

/// Rule-based text converter that transforms Japanese text
/// into Zundamon-style speech using regex pattern matching.
final class RuleBasedConverter: @unchecked Sendable {

    /// Convert input text to Zundamon-style speech
    func convert(_ text: String) -> String {
        // Split into lines to preserve formatting
        let lines = text.components(separatedBy: "\n")
        let convertedLines = lines.map { convertLine($0) }
        return convertedLines.joined(separator: "\n")
    }

    private func convertLine(_ line: String) -> String {
        // Skip empty lines and lines that are just whitespace
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return line }

        // Skip lines that look like code (indented or fenced)
        if trimmed.hasPrefix("```") || trimmed.hasPrefix("    ") || trimmed.hasPrefix("\t") {
            return line
        }

        // Split by sentence-ending punctuation while preserving the punctuation
        var result = line

        // Apply conversion rules
        result = applyRules(to: result)

        return result
    }

    private func applyRules(to text: String) -> String {
        var result = text

        // Apply rules from ZundamonRules
        for rule in ZundamonRules.allRules {
            result = rule.apply(to: result)
        }

        return result
    }
}
