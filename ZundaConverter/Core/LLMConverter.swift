import Foundation
import FoundationModels

/// Handles text conversion using Apple's on-device Foundation Models framework.
/// Requires macOS 26+ and Apple Intelligence enabled on the device.
@available(macOS 26, *)
final class LLMConverter: @unchecked Sendable {
    static let shared = LLMConverter()

    private let instructions = """
    あなたは「ずんだもん」というキャラクターです。
    ユーザーから与えられたテキストを、ずんだもんの口調に変換してください。

    ずんだもんの口調ルール:
    - 一人称は「ボク」を使う
    - 文末は「〜のだ」「〜なのだ」にする
    - 「〜です」→「〜なのだ」
    - 「〜ます」→「〜のだ」
    - 「〜ません」→「〜ないのだ」
    - 「〜でしょうか」→「〜なのだ？」
    - 「〜ください」→「〜ほしいのだ」
    - 「私」「俺」「僕」→「ボク」
    - 元気で明るく、少し子供っぽい話し方

    重要な制約:
    - 元のテキストの意味は絶対に変えない
    - 口調のみをずんだもん風に変換する
    - 英語やプログラミングのコードは変換しない
    - 変換後のテキストのみを出力する（説明や注釈は一切不要）
    - 入力テキストが複数行の場合は、各行を変換して返す
    """

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
    func convert(_ text: String) async throws -> String {
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: text)
        return response.content
    }
}
