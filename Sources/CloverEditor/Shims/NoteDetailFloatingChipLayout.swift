// Extracted verbatim from Trinote (MPL-2.0): Trinote/Features/NoteDetail/NoteDetailScrollOffsetReader.swift
import Foundation

enum NoteDetailFloatingChipLayout {
    static let chipHeight: CGFloat = 16
    static let breathingRoom: CGFloat = 3
    static let saveChipBottomInset: CGFloat = 62
    static let editChipBottomInset: CGFloat = 12
    static let editChipBottomInsetWithFindBar: CGFloat = 56

    /// Extra scrollable space below the last line so content can sit above the floating chip.
    static func scrollClearance(findBarPresented: Bool, editing: Bool) -> CGFloat {
        if editing {
            return saveChipBottomInset + chipHeight + breathingRoom
        }
        let chipBottom = findBarPresented ? editChipBottomInsetWithFindBar : editChipBottomInset
        return chipBottom + chipHeight + breathingRoom
    }
}
