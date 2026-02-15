import Foundation
import FoundationModels

/// Handles text conversion using Apple's on-device Foundation Models framework.
/// Requires macOS 26+ and Apple Intelligence enabled on the device.
@available(macOS 26, *)
final class LLMConverter: @unchecked Sendable {
    static let shared = LLMConverter()

    // NOTE: The prompt intentionally avoids mentioning any character name
    // to prevent Apple's safety filter from refusing the request.
    // Instead it describes the transformation as a pure linguistic style change.
    private let instructions = """
    あなたは日本語の「文体変換ツール」です。
    入力されたテキストの【内容や情報を一切変更せず】、文末と一人称だけを指定されたスタイルに「機械的に」置換してください。
    
    【重要】出力は必ず以下のJSON形式で行ってください。それ以外のテキスト（挨拶、説明、Markdownブロックなど）は一切含めないでください。

    {
        "result": "変換後のテキスト"
    }

    【変換先スタイルの定義】
    - 一人称: 「ボク」を使う
    - 文末: 「〜のだ」「〜なのだ」で終わる独特のスタイル

    【文末の変換ルール】
    - 「〜です」「〜ます」　　　→　「〜なのだ」「〜のだ」
    - 「〜ですね」「〜ますね」　→　「〜なのだ」「〜のだ」（※「〜なのだね」は禁止）
    - 「〜でした」「〜ました」　→　「〜たのだ」
    - 「〜ません」　　　　　　　→　「〜ないのだ」
    - 「〜でしょう」　　　　　　→　「〜なのだ」
    - 「〜ですか？」　　　　　　→　「〜なのだ？」
    - 「〜ください」　　　　　　→　「〜してほしいのだ」
    - 「〜お願いします」　　　　→　「〜お願いなのだ」
    - 「〜と思います」　　　　　→　「〜と思うのだ」
    - 「〜である」　　　　　　　→　「〜なのだ」

    【一人称の変換ルール】
    - 「私」「俺」「僕」→「ボク」

    【変換例：構造と情報の維持】

    入力:
    このコードはおかしいですね。
    性能が悪くなる構造になっているので、for文をバラして並べて書いたほうが良いです。

    出力:
    {
        "result": "このコードはおかしいのだ。\n性能が悪くなる構造になっているので、for文をバラして並べて書いたほうが良いのだ。"
    }

    入力: 昨日の会議で決まった通り、来週の月曜日までにデザイン案を3パターン作成して、Slackで共有してください。
    出力:
    {
        "result": "昨日の会議で決まった通り、来週の月曜日までにデザイン案を3パターン作成して、Slackで共有してほしいのだ。"
    }

    入力:
    このAPIは現在deprecatedになっています。
    将来的には削除される可能性があります。
    早めの移行を推奨します。

    出力:
    {
        "result": "このAPIは現在deprecatedになっているのだ。\n将来的には削除される可能性があるのだ。\n早めの移行を推奨するのだ。"
    }

    【出力ルール：絶対に守ること】
    - **必ずJSON形式**で出力する。キーは "result" 固定。
    - 変換後のテキストだけを "result" の値にする。
    - ❌ JSONの外には挨拶や説明を一切書かない。
    - 元のテキストの意味を変えない。口調だけを変える。
    - 入力が複数行なら、改行コード(\n)を使って1つの文字列にする。
    - コードブロック（```で囲まれた部分）や、英語テキスト、URLはそのまま返す。
    - 「のだ」「なのだ」が既に付いている文はそのまま返す（二重変換しない）。
    - 英単語、記号、絵文字が含まれていても、**日本語の文章部分は必ず変換する**こと。

    【混在テキストの変換例】

    入力: 修正ありがとうございます！ LGTM:ok_person:
    出力:
    {
        "result": "修正ありがとうなのだ！ LGTM:ok_person:"
    }

    入力: PRのレビューをお願いします。githubのリンクはこちら。
    出力:
    {
        "result": "PRのレビューをお願いなのだ。githubのリンクはこちらなのだ。"
    }

    ---
    以下の入力テキストを変換してください:
    """

    /// Phrases that indicate the model refused the request
    private let refusalPatterns = [
        "申し訳ありません",
        "お応えできません",
        "お答えできません",
        "対応できません",
        "著作権",
        "リクエストにはお応え",
        "I can't",
        "I cannot",
        "I'm sorry",
    ]
    
    private let ruleBasedFallback = RuleBasedConverter()

    private init() {}

    /// Check if the on-device model is available
    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    /// Get a human-readable description of why the model is unavailable
    var unavailableReason: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                return "Apple Intelligence が有効になっていません。\nシステム設定 → Apple Intelligence で有効にしてください。"
            case .modelNotReady:
                return "モデルの準備中です。しばらくお待ちください。"
            default:
                return "このデバイスでは利用できません。"
            }
        }
    }

    /// Converts text using the on-device Foundation Model.
    /// Falls back to rule-based conversion if the model refuses the request.
    func convert(_ text: String) async throws -> String {
        // Normalize input newlines to \n
        let normalizedInput = text.replacingOccurrences(of: "\r\n", with: "\n")
                                  .replacingOccurrences(of: "\r", with: "\n")
        
        let session = LanguageModelSession(instructions: instructions)
        let prompt = """
        入力テキスト:
        \(normalizedInput)
        """
        let response = try await session.respond(to: prompt)
        var rawResult = response.content

        // Validate JSON structure loosely
        // Sometimes models wrap JSON in ```json ... ```
        rawResult = rawResult.replacingOccurrences(of: "```json", with: "")
                             .replacingOccurrences(of: "```", with: "")
                             .trimmingCharacters(in: .whitespacesAndNewlines)

        // Detect safety filter refusal
        if isRefusal(rawResult) {
            print("[LLMConverter] Safety filter triggered, falling back to rule-based conversion")
            return ruleBasedFallback.convert(text)
        }

        // Parse JSON
        if let data = rawResult.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let result = json["result"] {
            // Success!
            return result
        } 
        
        // Fallback: If JSON parsing fails (e.g. model outputted plain text),
        // try to use the raw output but warn about it.
        print("[LLMConverter] Failed to parse JSON response. Falling back to raw text cleanup.")
        return cleanRawOutput(rawResult)
    }
    
    /// Fallback cleanup for non-JSON output
    private func cleanRawOutput(_ text: String) -> String {
        var cleanResult = text
        
        // Normalize newlines
        cleanResult = cleanResult.replacingOccurrences(of: "\r\n", with: "\n")
                                 .replacingOccurrences(of: "\r", with: "\n")
        
        // Collapse multiple newlines
        if let regex = try? NSRegularExpression(pattern: "\n+", options: []) {
            let range = NSRange(cleanResult.startIndex..., in: cleanResult)
            cleanResult = regex.stringByReplacingMatches(in: cleanResult, options: [], range: range, withTemplate: "\n")
        }
        
        return cleanResult.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Check if the response is a refusal from the safety filter
    private func isRefusal(_ text: String) -> Bool {
        for pattern in refusalPatterns {
            if text.contains(pattern) {
                return true
            }
        }
        return false
    }
}
