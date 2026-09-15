import os

/// Minimal stand-in for Trinote's logger so the vendored editor compiles unchanged.
enum Log {
    static let api = Logger(subsystem: "de.ibn5100.clover.editor", category: "api")
    static let ui = Logger(subsystem: "de.ibn5100.clover.editor", category: "ui")
}
