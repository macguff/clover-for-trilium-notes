// Extracted verbatim from Trinote (MPL-2.0): Trinote/Features/NoteDetail/AttachmentPreviewView.swift
import Foundation

enum TriliumHashLinkNavigation {
    struct Parsed: Sendable {
        let noteId: String?
        let viewMode: String?
        let attachmentId: String?
    }

    static func parse(url: URL) -> Parsed? {
        if let fragment = url.fragment?.trimmingCharacters(in: .whitespacesAndNewlines), !fragment.isEmpty {
            return parse(fragment: fragment)
        }
        let absolute = url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines)
        if absolute.contains("#") {
            return parse(href: absolute)
        }
        return nil
    }

    /// Parses Trilium hash links from a raw `href` (`#root/…?viewMode=attachments&attachmentId=…`).
    static func parse(href: String) -> Parsed? {
        var h = href.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !h.isEmpty else { return nil }
        if let hashIndex = h.firstIndex(of: "#") {
            h = String(h[h.index(after: hashIndex)...])
        }
        return parse(fragment: h)
    }

    private static func parse(fragment: String) -> Parsed? {
        var fragment = fragment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !fragment.isEmpty else { return nil }

        let queryPart: String?
        if let queryIndex = fragment.firstIndex(of: "?") {
            queryPart = String(fragment[fragment.index(after: queryIndex)...])
            fragment = String(fragment[..<queryIndex])
        } else {
            queryPart = nil
        }

        fragment = fragment.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let parts = fragment.split(separator: "/").map(String.init).filter { !$0.isEmpty }
        let noteId: String? = {
            guard let last = parts.last, last != "root" else { return nil }
            return last
        }()

        var viewMode: String?
        var attachmentId: String?
        if let queryPart {
            for pair in queryPart.split(separator: "&") {
                let kv = pair.split(separator: "=", maxSplits: 1).map(String.init)
                guard kv.count == 2 else { continue }
                let key = kv[0]
                let value = kv[1].removingPercentEncoding ?? kv[1]
                switch key {
                case "viewMode": viewMode = value
                case "attachmentId": attachmentId = value
                default: break
                }
            }
        }

        guard noteId != nil || viewMode != nil || attachmentId != nil else { return nil }
        return Parsed(noteId: noteId, viewMode: viewMode, attachmentId: attachmentId)
    }
}

enum TriliumAttachmentURLParser {
    private static let pattern = try! NSRegularExpression(
        pattern: #"(?i)api/(attachments|images)/([a-zA-Z0-9_-]+)/"#,
        options: []
    )

    /// Returns `(routeType, entityId)` for Trilium `api/attachments/{id}/…` or `api/images/{id}/…` URLs.
    static func entityReference(from url: URL) -> (routeType: String, entityId: String)? {
        entityReference(in: url.absoluteString)
    }

    static func entityReference(in urlString: String) -> (routeType: String, entityId: String)? {
        let ns = urlString as NSString
        let range = NSRange(location: 0, length: ns.length)
        guard let match = pattern.firstMatch(in: urlString, options: [], range: range),
              match.numberOfRanges >= 3 else { return nil }
        let routeType = ns.substring(with: match.range(at: 1)).lowercased()
        let entityId = ns.substring(with: match.range(at: 2))
        guard !entityId.isEmpty else { return nil }
        return (routeType, entityId)
    }

    /// Parses attachment IDs from Trilium upload responses (`api/attachments/{id}/…` or `#…?attachmentId=`).
    static func attachmentId(fromUploadResultURL urlString: String?) -> String? {
        guard let urlString, !urlString.isEmpty else { return nil }
        if let ref = entityReference(in: urlString) {
            return ref.entityId
        }
        guard let range = urlString.range(of: "attachmentId=") else { return nil }
        let remainder = urlString[range.upperBound...]
        let id = remainder.split(separator: "&").first.map(String.init)
        guard let id, !id.isEmpty else { return nil }
        return id
    }
}
