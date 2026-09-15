// Extracted verbatim from Trinote (MPL-2.0): Trinote/Core/Utilities/Extensions.swift (Data image helpers)
import Foundation

extension Data {
    func detectImageMIME() -> String {
        guard count >= 2 else { return "image/png" }
        var header = [UInt8](repeating: 0, count: Swift.min(12, count))
        copyBytes(to: &header, count: header.count)

        if header[0] == 0xFF && header[1] == 0xD8 { return "image/jpeg" }
        if header.count >= 8 && header[0...3] == [0x89, 0x50, 0x4E, 0x47] { return "image/png" }
        if header.count >= 4 && header[0...3] == [0x47, 0x49, 0x46, 0x38] { return "image/gif" }
        if header.count >= 12 && header[0...3] == [0x52, 0x49, 0x46, 0x46] && header[8...11] == [0x57, 0x45, 0x42, 0x50] { return "image/webp" }

        if isSVG { return "image/svg+xml" }

        return "image/png"
    }

    var isPlausibleInlineImagePayload: Bool {
        if isEmpty { return false }
        if isSVG { return true }
        guard count >= 2 else { return false }
        var header = [UInt8](repeating: 0, count: Swift.min(12, count))
        copyBytes(to: &header, count: header.count)
        if header[0] == 0xFF && header[1] == 0xD8 { return true }
        if header.count >= 8 && header[0...3] == [0x89, 0x50, 0x4E, 0x47] { return true }
        if header.count >= 4 && header[0...3] == [0x47, 0x49, 0x46, 0x38] { return true }
        if header.count >= 12 && header[0...3] == [0x52, 0x49, 0x46, 0x46] && header[8...11] == [0x57, 0x45, 0x42, 0x50] { return true }
        // Obvious non-binary payloads (canvas JSON, mermaid text, HTML)
        if let prefix = String(data: prefix(Swift.min(64, count)), encoding: .utf8) {
            let trimmed = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("{") || trimmed.hasPrefix("[") { return false }
            if trimmed.hasPrefix("<!DOCTYPE") || trimmed.hasPrefix("<html") { return false }
        }
        return false
    }

    var isSVG: Bool {
        guard let str = String(data: prefix(512), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        return str.hasPrefix("<svg") || (str.hasPrefix("<?xml") && str.contains("<svg"))
    }
}
