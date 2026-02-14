import Foundation

/// A single conversion rule represented as a regex pattern and replacement.
struct ConversionRule {
    let name: String
    let pattern: String
    let replacement: String
    let options: NSRegularExpression.Options

    init(name: String, pattern: String, replacement: String, options: NSRegularExpression.Options = []) {
        self.name = name
        self.pattern = pattern
        self.replacement = replacement
        self.options = options
    }

    /// Apply this rule to the given text
    func apply(to text: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return text
        }
        let range = NSRange(text.startIndex..., in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: replacement)
    }
}

/// Defines all Zundamon speech conversion rules in priority order.
enum ZundamonRules {
    static let allRules: [ConversionRule] = [
        // === 一人称変換 ===
        ConversionRule(
            name: "一人称: 私 → ボク",
            pattern: "(?<![\\p{Han}])私(?=[はがもをにのと])",
            replacement: "ボク"
        ),
        ConversionRule(
            name: "一人称: 俺 → ボク",
            pattern: "俺(?=[はがもをにのと])",
            replacement: "ボク"
        ),
        ConversionRule(
            name: "一人称: 僕 → ボク",
            pattern: "僕(?=[はがもをにのと])",
            replacement: "ボク"
        ),

        // ===================================================
        // 複合表現（必ず単純な ます/です より先にマッチさせる）
        // ===================================================

        // ～していただけますか → ～してもらえると嬉しいのだ
        ConversionRule(
            name: "文末: ～していただけますか → ～してもらえると嬉しいのだ",
            pattern: "していただけますか[？?]?",
            replacement: "してもらえると嬉しいのだ"
        ),

        // ～いかがでしょうか → ～どうなのだ？
        ConversionRule(
            name: "文末: ～いかがでしょうか → ～どうなのだ？",
            pattern: "いかがでしょうか[？?]?",
            replacement: "どうなのだ？"
        ),

        // ～ではないでしょうか → ～ではないのだ？
        ConversionRule(
            name: "文末: ～ではないでしょうか → ～ではないのだ？",
            pattern: "ではないでしょうか[？?]?",
            replacement: "ではないのだ？"
        ),

        // ～お願いします → ～お願いなのだ
        ConversionRule(
            name: "文末: ～お願いします → ～お願いなのだ",
            pattern: "お願いします([。！？!?]|$)",
            replacement: "お願いなのだ$1"
        ),

        // ～だと思います → ～だと思うのだ
        ConversionRule(
            name: "文末: ～だと思います → ～だと思うのだ",
            pattern: "だと思います([。！？!?]|$)",
            replacement: "だと思うのだ$1"
        ),

        // ～と思われます → ～と思われるのだ
        ConversionRule(
            name: "文末: ～と思われます → ～と思われるのだ",
            pattern: "と思われます([。！？!?]|$)",
            replacement: "と思われるのだ$1"
        ),

        // ～必要があります → ～必要があるのだ
        ConversionRule(
            name: "文末: ～必要があります → ～必要があるのだ",
            pattern: "必要があります([。！？!?]|$)",
            replacement: "必要があるのだ$1"
        ),

        // ～かもしれません → ～かもしれないのだ
        ConversionRule(
            name: "文末: ～かもしれません → ～かもしれないのだ",
            pattern: "かもしれません([。！？!?]|$)",
            replacement: "かもしれないのだ$1"
        ),

        // ～してください → ～してほしいのだ
        ConversionRule(
            name: "文末: ～してください → ～してほしいのだ",
            pattern: "してください([。！？!?]|$)",
            replacement: "してほしいのだ$1"
        ),

        // ===================================================
        // 単純な文末パターン（長いものから先に）
        // ===================================================

        // ～ませんでした → ～なかったのだ
        ConversionRule(
            name: "文末: ～ませんでした → ～なかったのだ",
            pattern: "ませんでした([。！？!?]|$)",
            replacement: "なかったのだ$1"
        ),

        // ～ません → ～ないのだ
        ConversionRule(
            name: "文末: ～ません → ～ないのだ",
            pattern: "ません([。！？!?]|$)",
            replacement: "ないのだ$1"
        ),

        // ～ますか → ～のだ？
        ConversionRule(
            name: "文末: ～ますか？ → ～のだ？",
            pattern: "ますか[？?]",
            replacement: "のだ？"
        ),

        // ～ました → ～たのだ
        ConversionRule(
            name: "文末: ～ました → ～たのだ",
            pattern: "ました([。！？!?]|$)",
            replacement: "たのだ$1"
        ),

        // ～ますね → ～のだね
        ConversionRule(
            name: "文末: ～ますね → ～のだね",
            pattern: "ますね([。！？!?]|$)",
            replacement: "のだね$1"
        ),

        // ～ますよ → ～のだよ
        ConversionRule(
            name: "文末: ～ますよ → ～のだよ",
            pattern: "ますよ([。！？!?]|$)",
            replacement: "のだよ$1"
        ),

        // ～ます → ～のだ
        ConversionRule(
            name: "文末: ～ます → ～のだ",
            pattern: "ます([。！？!?]|$)",
            replacement: "のだ$1"
        ),

        // ～でしょうか → ～なのだ？
        ConversionRule(
            name: "文末: ～でしょうか？ → ～なのだ？",
            pattern: "でしょうか[？?]?",
            replacement: "なのだ？"
        ),

        // ～でしょう → ～なのだ
        ConversionRule(
            name: "文末: ～でしょう → ～なのだ",
            pattern: "でしょう([。！？!?]|$)",
            replacement: "なのだ$1"
        ),

        // ～ですか → ～なのだ？
        ConversionRule(
            name: "文末: ～ですか？ → ～なのだ？",
            pattern: "ですか[？?]?",
            replacement: "なのだ？"
        ),

        // ～ですね → ～なのだね
        ConversionRule(
            name: "文末: ～ですね → ～なのだね",
            pattern: "ですね([。！？!?]|$)",
            replacement: "なのだね$1"
        ),

        // ～ですよ → ～なのだよ
        ConversionRule(
            name: "文末: ～ですよ → ～なのだよ",
            pattern: "ですよ([。！？!?]|$)",
            replacement: "なのだよ$1"
        ),

        // ～です → ～なのだ
        ConversionRule(
            name: "文末: ～です → ～なのだ",
            pattern: "です([。！？!?]|$)",
            replacement: "なのだ$1"
        ),

        // ～である → ～なのだ
        ConversionRule(
            name: "文末: ～である → ～なのだ",
            pattern: "である([。！？!?]|$)",
            replacement: "なのだ$1"
        ),
    ]
}
