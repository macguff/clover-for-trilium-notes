# NOTICE — CloverEditor

This package is licensed under the **Mozilla Public License 2.0** (see `LICENSE`).

It contains files copied from **Trinote** (https://github.com/StephenArg/Trinote, commit `64249fc1`, MPL-2.0),
a native iOS client for Trilium. Trinote's Tiptap-based editor reproduces Trilium's CKEditor HTML, which is why
Clover reuses it for *editing* while keeping its own native renderer for *reading*.

| File in this package | Origin in Trinote | Modifications |
|---|---|---|
| `Sources/CloverEditor/Vendored/RichTextEditorView.swift` | `Trinote/Features/NoteDetail/RichTextEditorView.swift` | `patches/RichTextEditorView.swift.patch` — `Bundle.main` → `Bundle.module` + `EditorWeb/` subdirectory for the host page (see `// CLOVER:` comments) |
| `Sources/CloverEditor/Vendored/TriliumImageSchemeHandler.swift` | `Trinote/Core/Media/TriliumImageSchemeHandler.swift` | none |
| `Sources/CloverEditor/Vendored/EditorPasteboardImage.swift` | `Trinote/Features/NoteDetail/EditorPasteboardImage.swift` | none |
| `Sources/CloverEditor/Vendored/TriliumLinkParsers.swift` | two enums extracted from `Trinote/Features/NoteDetail/AttachmentPreviewView.swift` | extracted verbatim |
| `Sources/CloverEditor/Vendored/DataImageExtensions.swift` | `Data` helpers extracted from `Trinote/Core/Utilities/Extensions.swift` | extracted verbatim |
| `Sources/CloverEditor/Shims/NoteDetailFloatingChipLayout.swift` | enum extracted from `Trinote/Features/NoteDetail/NoteDetailScrollOffsetReader.swift` | extracted verbatim |
| `Sources/CloverEditor/Resources/EditorWeb/editor.html`, `tiptap-bundle.min.js`, `*-extension.js`, `*-entry.mjs`, `package.json`, `README.md` | `Trinote/Resources/editor.html`, `Trinote/Resources/editor-vendor/` | editor.html: `patches/editor.html.patch` — single-line collapsible toolbar with an animated toggle (`// CLOVER` CSS + script), custom toggle artwork slot |
| `Sources/CloverEditor/Resources/EditorWeb/*.svg` (25 toolbar icons) | `Trinote/Resources/editor-icons/` | none (loaded by bare filename next to `editor.html`) |
| `Sources/CloverEditor/Resources/EditorWeb/vendor/katex/`, `vendor/mermaid.min.js` | `Trinote/Resources/vendor/` | none (KaTeX: MIT; Mermaid: MIT; Tiptap: MIT) |

Files under `Sources/CloverEditor/Shims/Log.swift` and `Sources/CloverEditor/CloverEditor.swift` are original to Clover and
are also offered under MPL-2.0 as part of this package. Under MPL §3.3 the larger work (the Clover app) may be
distributed under its own terms; the Covered Files above remain MPL-2.0 and their source is published in this repository.

## Re-syncing with upstream

`./scripts/sync-trinote.sh [path-to-Trinote]` copies the files above, re-applies `patches/*.patch` (and stops if
upstream moved under a Clover change), warns when a file we extracted snippets from changed
(`patches/extracted-origins.sha256`), and stamps the upstream commit into this notice.
