import XCTest
@testable import ZundaConverter

final class RuleBasedConverterTests: XCTestCase {
    private let converter = RuleBasedConverter()

    // MARK: - 一人称変換

    func test_一人称_私_が変換される() {
        let input = "私はこのコードを確認しました。"
        let result = converter.convert(input)
        XCTAssertTrue(result.contains("ボクは"), "「私は」が「ボクは」に変換されること: \(result)")
    }

    func test_一人称_俺_が変換される() {
        let input = "俺はこう思う。"
        let result = converter.convert(input)
        XCTAssertTrue(result.contains("ボクは"), "「俺は」が「ボクは」に変換されること: \(result)")
    }

    func test_一人称_僕_が変換される() {
        let input = "僕が担当します。"
        let result = converter.convert(input)
        XCTAssertTrue(result.contains("ボクが"), "「僕が」が「ボクが」に変換されること: \(result)")
    }

    // MARK: - 文末変換: ～です

    func test_文末_です_が変換される() {
        let input = "これは問題です。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "これは問題なのだ。")
    }

    func test_文末_ですね_が変換される() {
        let input = "いいですね。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "いいなのだね。")
    }

    func test_文末_ですよ_が変換される() {
        let input = "大丈夫ですよ。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "大丈夫なのだよ。")
    }

    // MARK: - 文末変換: ～ます

    func test_文末_ます_が変換される() {
        let input = "動作します。"
        let result = converter.convert(input)
        // NOTE: ルールベースでは動詞の活用変換ができないため
        // 「動作しのだ」となる。より自然な変換はAIモードで対応。
        XCTAssertEqual(result, "動作しのだ。")
    }

    func test_文末_ました_が変換される() {
        let input = "確認しました。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "確認したのだ。")
    }

    func test_文末_ません_が変換される() {
        let input = "動きません。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "動きないのだ。")
    }

    // MARK: - 疑問文

    func test_文末_ますか_が変換される() {
        let input = "これで動きますか？"
        let result = converter.convert(input)
        XCTAssertEqual(result, "これで動きのだ？")
    }

    func test_文末_ですか_が変換される() {
        let input = "本当ですか？"
        let result = converter.convert(input)
        XCTAssertEqual(result, "本当なのだ？")
    }

    // MARK: - 丁寧な依頼表現

    func test_文末_してください_が変換される() {
        let input = "修正してください。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "修正してほしいのだ。")
    }

    func test_文末_お願いします_が変換される() {
        let input = "レビューお願いします。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "レビューお願いなのだ。")
    }

    func test_文末_していただけますか_が変換される() {
        let input = "確認していただけますか？"
        let result = converter.convert(input)
        XCTAssertEqual(result, "確認してもらえると嬉しいのだ")
    }

    // MARK: - 推量・断定

    func test_文末_でしょう_が変換される() {
        let input = "問題ないでしょう。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "問題ないなのだ。")
    }

    func test_文末_である_が変換される() {
        let input = "これは正しい実装である。"
        let result = converter.convert(input)
        XCTAssertEqual(result, "これは正しい実装なのだ。")
    }

    func test_文末_だと思います_が変換される() {
        let input = "良いと思います。"
        let result = converter.convert(input)
        XCTAssertTrue(result.contains("のだ"), "「思います」が「のだ」系に変換されること: \(result)")
    }

    // MARK: - 複数行

    func test_複数行が正しく変換される() {
        let input = """
        このコードは問題です。
        修正してください。
        """
        let result = converter.convert(input)
        XCTAssertTrue(result.contains("なのだ"), "複数行の各行が変換されること: \(result)")
        XCTAssertTrue(result.contains("してほしいのだ"), "複数行の各行が変換されること: \(result)")
    }

    // MARK: - コードブロックは変換しない

    func test_コードブロックは変換されない() {
        let input = "```swift\nlet x = 1\n```"
        let result = converter.convert(input)
        XCTAssertEqual(result, input, "コードブロックは変換されないこと")
    }

    // MARK: - 空行は保持

    func test_空行が保持される() {
        let input = "一行目です。\n\n三行目です。"
        let result = converter.convert(input)
        let lines = result.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 3, "行数が保持されること")
        XCTAssertEqual(lines[1], "", "空行が保持されること")
    }

    // MARK: - PRレビュー風の実用テスト

    func test_PRレビューコメントの変換() {
        let input = """
        この実装にはいくつか問題があります。
        まず、変数名がわかりにくいです。
        また、エラーハンドリングが不足しています。
        修正してください。
        """
        let result = converter.convert(input)

        // All lines should be converted
        XCTAssertFalse(result.contains("あります。"), "「あります」が変換されていること")
        XCTAssertFalse(result.contains("です。"), "「です」が変換されていること")
        XCTAssertFalse(result.contains("してください"), "「してください」が変換されていること")
    }
}
