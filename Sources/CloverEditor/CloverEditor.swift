import SwiftUI
import WebKit

/// Public surface of the vendored Trinote editor for Clover.
///
/// Reading stays native in Clover; *editing* uses this Tiptap-based editor, which produces the same HTML shapes as
/// Trilium's CKEditor — so no Markdown projection, no lossless guard, no read-only blocks.
public struct CloverRichTextEditor: View {
    public typealias ImageProvider = @MainActor (_ routeType: String, _ entityId: String) async -> Data?

    let initialHTML: String
    let imageProvider: ImageProvider?
    let onContentChanged: (String) -> Void
    let onRequestSave: (String?) -> Void
    /// The editor toolbar's image button (bridge message `pickImage`) — the host presents its picker.
    let onPickImage: (() -> Void)?
    /// Set to a `data:` URI to insert an image at the caret (the host resets it to nil once consumed).
    @Binding var imageToInsert: String?
    @State private var attachmentToInsert: EditorAttachmentInsert?

    public init(initialHTML: String, imageProvider: ImageProvider? = nil, imageToInsert: Binding<String?> = .constant(nil),
                onPickImage: (() -> Void)? = nil,
                onContentChanged: @escaping (String) -> Void, onRequestSave: @escaping (String?) -> Void) {
        self.initialHTML = initialHTML; self.imageProvider = imageProvider; _imageToInsert = imageToInsert
        self.onPickImage = onPickImage
        self.onContentChanged = onContentChanged; self.onRequestSave = onRequestSave
    }

    public var body: some View {
        RichTextEditorView(
            initialHTML: initialHTML,
            onContentChanged: onContentChanged,
            onPickImage: onPickImage,
            onRequestSave: { html, _ in onRequestSave(html) },
            imageBytes: imageProvider,
            imageToInsert: $imageToInsert,
            attachmentToInsert: $attachmentToInsert
        )
        .ignoresSafeArea(.keyboard)
    }
}

/// Location of the editor's web assets (`vendor/mermaid.min.js`, `vendor/katex/…`) so the reader can render
/// diagrams and math with the same libraries.
public enum CloverEditorResources {
    public static var webRoot: URL? { Bundle.module.url(forResource: "EditorWeb", withExtension: nil) }
}

/// Note HTML uses server-relative image paths; the editor's WebView resolves images through the
/// `trinote-img://` scheme. Rewrite on the way in, restore the original `src` on the way out.
public struct EditorHTMLBridge {
    public private(set) var originalSources: [String: String] = [:]   // "images/<id>" | "attachments/<id>" → original src

    public init() {}

    public mutating func toEditor(_ html: String) -> String {
        var out = html
        let patterns: [(String, String)] = [
            ("src=\"(api/images/([A-Za-z0-9_-]+)/[^\"]*)\"", "images"),
            ("src=\"(api/attachments/([A-Za-z0-9_-]+)/image/[^\"]*)\"", "attachments"),
        ]
        for (pattern, route) in patterns {
            guard let re = try? NSRegularExpression(pattern: pattern) else { continue }
            let ns = out as NSString
            var result = out
            for m in re.matches(in: out, range: NSRange(location: 0, length: ns.length)).reversed() {
                let original = ns.substring(with: m.range(at: 1)), id = ns.substring(with: m.range(at: 2))
                originalSources["\(route)/\(id)"] = original
                let r = Range(m.range, in: result)!
                result.replaceSubrange(r, with: "src=\"\(TriliumImageScheme.url(routeType: route, entityId: id))\"")
            }
            out = result
        }
        return out
    }

    public func fromEditor(_ html: String) -> String {
        guard let re = try? NSRegularExpression(pattern: "src=\"\(TriliumImageScheme.scheme)://(images|attachments)/([A-Za-z0-9_-]+)\"") else { return html }
        let ns = html as NSString
        var result = html
        for m in re.matches(in: html, range: NSRange(location: 0, length: ns.length)).reversed() {
            let route = ns.substring(with: m.range(at: 1)), id = ns.substring(with: m.range(at: 2))
            let src = originalSources["\(route)/\(id)"] ?? (route == "images" ? "api/images/\(id)/image" : "api/attachments/\(id)/image/image")
            result.replaceSubrange(Range(m.range, in: result)!, with: "src=\"\(src)\"")
        }
        return result
    }

    /// The `src` a provider should fetch for a `trinote-img://` reference (original when known).
    public func serverPath(routeType: String, entityId: String) -> String {
        originalSources["\(routeType)/\(entityId)"] ?? (routeType == "images" ? "api/images/\(entityId)/image" : "api/attachments/\(entityId)/image/image")
    }
}
