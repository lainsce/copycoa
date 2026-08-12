import CoreGraphics
import Foundation

/// The fixed footprints a card can occupy, measured in grid cells.
nonisolated enum CardSize: String, Codable, CaseIterable, Identifiable {
    case oneByOne
    case twoByOne
    case twoByTwo
    case fourByOne

    var id: String { rawValue }

    /// Footprints a user can pick via the size toggle. Headers are locked to `fourByOne`.
    static let selectable: [CardSize] = [.oneByOne, .twoByOne, .twoByTwo]

    var cols: Int {
        switch self {
        case .oneByOne: 1
        case .twoByOne, .twoByTwo: 2
        case .fourByOne: 4
        }
    }

    var rows: Int {
        switch self {
        case .oneByOne, .twoByOne, .fourByOne: 1
        case .twoByTwo: 2
        }
    }

    var label: String {
        switch self {
        case .oneByOne: "1×1"
        case .twoByOne: "2×1"
        case .twoByTwo: "2×2"
        case .fourByOne: "4×1"
        }
    }

    var accessibilityLabel: LocalizedStringResource {
        switch self {
        case .oneByOne: "Resize to 1 by 1"
        case .twoByOne: "Resize to 2 by 1"
        case .twoByTwo: "Resize to 2 by 2"
        case .fourByOne: "Resize to 4 by 1"
        }
    }

    /// The surface radius for this footprint. Only 2×2 cards use the larger treatment.
    var cornerRadius: CGFloat {
        self == .twoByTwo
            ? CanvasMetrics.bigCardCornerRadius
            : CanvasMetrics.cardCornerRadius
    }

    /// Pixel dimensions of this footprint.
    var pointSize: CGSize {
        switch self {
        case .fourByOne:
            // Header banner: wide enough for four 1×1 cards each separated by one dot.
            let height = CanvasMetrics.headerHeight
            return CGSize(width: CanvasMetrics.fourColumnWidth, height: height)
        default:
            // Multi-cell footprints span their cells plus one dot between each adjacent cell.
            return CanvasMetrics.footprintSize(columns: cols, rows: rows)
        }
    }
}
