import AppKit

/// Handles macOS Services menu integration.
/// This class provides the service method that receives selected text,
/// converts it to Zundamon-style, and returns it for replacement.
final class ServiceProvider: NSObject {

    /// Service method called by macOS Services menu.
    /// The method name must match the NSMessage value in Info.plist.
    @objc func convertToZundamon(
        _ pboard: NSPasteboard,
        userData: String?,
        error: AutoreleasingUnsafeMutablePointer<NSString?>
    ) {
        guard let text = pboard.string(forType: .string) else {
            error.pointee = "テキストを取得できませんでした" as NSString
            return
        }

        let convertedText = TextConversionEngine.shared.convert(text)

        pboard.clearContents()
        pboard.setString(convertedText, forType: .string)
    }
}
