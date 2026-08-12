import SwiftUI

/// Preset sticky-note colors.
nonisolated enum StickyPalette {
    static let yellow = "FFD84D"
    static let all = ["FFD84D", "FF9F45", "9CE29C", "8FD0FF", "FF9DBB", "D0B3FF"]

    static func name(for colorHex: String) -> LocalizedStringResource {
        switch colorHex {
        case "FFD84D": "Yellow"
        case "FF9F45": "Orange"
        case "9CE29C": "Green"
        case "8FD0FF": "Blue"
        case "FF9DBB": "Pink"
        case "D0B3FF": "Purple"
        default: "Note Color"
        }
    }
}
