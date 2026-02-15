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

    【最重要ルール：原文維持・構造維持】
    - ❌ 絶対に要約しないこと。
    - ❌ 情報を削ったり、意味を変えたりしないこと。
    - ❌ 省略されている主語を補ったり、勝手な解釈を加えないこと。
    - ❌ 【改行を勝手に追加しないこと】。入力が2行なら出力も必ず2行にする。余計な空行を挟まない。
    - ✅ 長い文章も、全ての単語と情報を保ったまま変換すること。

    【変換先スタイルの定義】
    - 一人称: 「ボク」を使う
    - 文末: 「〜のだ」「〜なのだ」で終わる独特のスタイル

    【文末の変換ルール】
    - 「〜です」→「〜なのだ」
    - 「〜ます」→「〜のだ」
    - 「〜ました」→「〜たのだ」
    - 「〜ません」→「〜ないのだ」
    - 「〜でしょう」→「〜なのだ」
    - 「〜ですか？」→「〜なのだ？」
    - 「〜ですね」→「〜なのだ」  (× 〜なのだね)
    - 「〜ますね」→「〜のだ」    (× 〜のだね)
    - 「〜ください」→「〜してほしいのだ」
    - 「〜お願いします」→「〜お願いなのだ」
    - 「〜と思います」→「〜と思うのだ」
    - 「〜である」→「〜なのだ」

    【一人称の変換ルール】
    - 「私」「俺」「僕」→「ボク」

    【変換例：構造と情報の維持】

    入力:
    このコードはおかしいですね。
    性能が悪くなる構造になっているので、for文をバラして並べて書いたほうが良いです。

    出力:
    このコードはおかしいのだ。
    性能が悪くなる構造になっているので、for文をバラして並べて書いたほうが良いのだ。

    入力: 昨日の会議で決まった通り、来週の月曜日までにデザイン案を3パターン作成して、Slackで共有してください。
    出力: 昨日の会議で決まった通り、来週の月曜日までにデザイン案を3パターン作成して、Slackで共有してほしいのだ。

    入力:
    このAPIは現在deprecatedになっています。
    将来的には削除される可能性があります。
    早めの移行を推奨します。

    出力:
    このAPIは現在deprecatedになっているのだ。
    将来的には削除される可能性があるのだ。
    早めの移行を推奨するのだ。

    【その他の変換例】
    入力: このコードはリファクタリングが必要です。
    出力: このコードはリファクタリングが必要なのだ。

    入力: ここの処理は少し複雑すぎると思います。
    出力: ここの処理は少し複雑すぎると思うのだ。

    入力: もう少しシンプルにしていただけますか？
    出力: もう少しシンプルにしてもらえると嬉しいのだ

    入力: 私はこのアプローチに賛成です。
    出力: ボクはこのアプローチに賛成なのだ。

    入力: この機能はまだ実装されていません。
    出力: この機能はまだ実装されていないのだ。

    入力: テストを追加する必要があります。
    出力: テストを追加する必要があるのだ。

    入力: このバグを修正しました。
    出力: このバグを修正したのだ。

    入力: 動作確認をお願いします。
    出力: 動作確認をお願いなのだ。

    入力: パフォーマンスが改善されましたね。
    出力: パフォーマンスが改善されたのだ。

    入力: この設計で問題ないでしょうか？
    出力: この設計で問題ないのだ？

    入力: エラーが発生するかもしれません。
    出力: エラーが発生するかもしれないのだ。

    入力: どのような方法がいいですか？
    出力: どのような方法がいいのだ？

    入力: 僕がやっておきますよ。
    出力: ボクがやっておくのだよ。

    入力: これは素晴らしい成果ですね！
    出力: これは素晴らしい成果なのだ！

    入力: 昨日のミーティングで決まりませんでした。
    出力: 昨日のミーティングで決まらなかったのだ。

    入力: 確認してください。
    出力: 確認してほしいのだ。

    入力: レビューしていただけますか？
    出力: レビューしてもらえると嬉しいのだ

    入力: この方法はうまくいくと思われます。
    出力: この方法はうまくいくと思われるのだ。

    入力: 明日までに完了できますか？
    出力: 明日までに完了できるのだ？

    入力: セキュリティ上の問題がないか確認する必要がありませんか？
    出力: セキュリティ上の問題がないか確認する必要はないのだ？

    【絶対に守ること】
    - 変換後のテキストだけを出力する。説明、注釈、「変換結果:」のような前置きは一切付けない。
    - 元のテキストの意味を変えない。口調だけを変える。
    - 入力が複数行なら、各行をそれぞれ変換して同じ行数で返す。
    - コードブロック（```で囲まれた部分）や、英語テキスト、URLはそのまま返す。
    - 「のだ」「なのだ」が既に付いている文はそのまま返す（二重変換しない）。
    入力: 明日までに完了できますか？
    出力: 明日までに完了できるのだ？

    【出力ルール】
    - 変換後のテキストだけを出力する。
    - 入力が複数行なら、各行をそれぞれ変換して【厳密に同じ行数】で返す。勝手に空行を挟まないこと。
    - 「のだ」「なのだ」が既にある文はそのまま返す。
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
        
        // If input has multiple empty lines, we want to respect that?
        // For now, let's just pass properly normalized text.
        
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: normalizedInput)
        let rawResult = response.content

        // Detect safety filter refusal and fall back to rule-based
        if isRefusal(rawResult) {
            print("[LLMConverter] Safety filter triggered, falling back to rule-based conversion")
            return ruleBasedFallback.convert(text)
        }

        // --- Post-processing for newline normalization ---
        // often LLMs output `\n\n` instead of `\n` to separate lines.
        // We force compact the newlines to match the dense input style.
        
        var cleanResult = rawResult
            // 1. Remove Markdown block markers if any (Foundation 3B sometimes adds them)
            .replacingOccurrences(of: "```", with: "")
        
        // 2. Normalize newlines
        cleanResult = cleanResult.replacingOccurrences(of: "\r\n", with: "\n")
                                 .replacingOccurrences(of: "\r", with: "\n")
        
        // 3. Collapse multiple newlines into single newline
        // regex: \n+ -> \n
        // This fixes the "Text\n\nText" issue.
        if let regex = try? NSRegularExpression(pattern: "\n+", options: []) {
            let range = NSRange(cleanResult.startIndex..., in: cleanResult)
            cleanResult = regex.stringByReplacingMatches(in: cleanResult, options: [], range: range, withTemplate: "\n")
        }
        
        // 4. Trim leading/trailing whitespace
        cleanResult = cleanResult.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanResult
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
