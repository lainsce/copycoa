import CoreGraphics

/// Shared geometry values for the canvas grid and magnetic snapping.
nonisolated enum CanvasMetrics {
    /// One-dot gutter between adjacent cards, in points.
    static let gridUnit: CGFloat = 40
    /// Fine positioning-dot spacing. Both the 40px gutter and card pitch are exact multiples.
    static let dotSpacing: CGFloat = 5
    /// Diameter of a regular positioning dot.
    static let dotDiameter: CGFloat = 2
    /// Diameter of the emphasized dot at every fifth grid intersection.
    static let majorDotDiameter: CGFloat = 3
    /// Number of fine-grid steps between emphasized intersections.
    static let majorDotInterval = 5
    /// Base size of a 1×1 card cell, in points.
    static let cell: CGFloat = 175
    /// Fixed footprint height for a header card.
    static let headerHeight: CGFloat = 60
    /// Minimum breathing room between a header's divider and the cards below it.
    static let headerContentSpacing: CGFloat = 8
    /// Shared radius for every card surface and its selection/drag chrome.
    static let cardCornerRadius: CGFloat = 24
    /// Shared radius for every card surface that's 2x2 and its selection/drag chrome.
    static let bigCardCornerRadius: CGFloat = 28
    /// Shared design-pixel inset between card content and its card edge.
    static let cardContentInset: CGFloat = 16
    /// Maximum rotation applied to a card while it is being dragged.
    static let cardDragTiltLimit: Double = 3
    /// Horizontal drag distance that reaches the tilt limit.
    static let cardDragTiltDistance: CGFloat = 80
    /// Placement pitch: one cell plus its trailing one-dot gutter.
    static let module: CGFloat = cell + gridUnit
    /// Width occupied by a 4×1 card, including the three internal one-dot gutters.
    static let fourColumnWidth: CGFloat = 4 * cell + 3 * gridUnit
    /// The fixed inset around the canvas content.
    static let canvasMargin: CGFloat = gridUnit
    /// The canvas is four columns wide with one dot of space on either side.
    static let canvasWidth: CGFloat = fourColumnWidth + 2 * canvasMargin

    /// Returns a card footprint using the current base cell and dot gutter metrics.
    static func footprintSize(columns: Int, rows: Int) -> CGSize {
        let columns = max(1, columns)
        let rows = max(1, rows)
        return CGSize(
            width: CGFloat(columns) * cell + CGFloat(columns - 1) * gridUnit,
            height: CGFloat(rows) * cell + CGFloat(rows - 1) * gridUnit
        )
    }

    /// Rounds a value to the nearest multiple of an arbitrary pitch.
    static func snap(_ value: Double, to pitch: Double) -> Double {
        (value / pitch).rounded() * pitch
    }

    /// Rounds a value to the nearest grid line.
    static func snap(_ value: Double) -> Double {
        snap(value, to: Double(gridUnit))
    }

    /// Maps horizontal drag distance to a bounded card tilt.
    static func cardDragTiltDegrees(for horizontalTranslation: CGFloat) -> Double {
        let normalized = min(max(horizontalTranslation / cardDragTiltDistance, -1), 1)
        return Double(normalized) * cardDragTiltLimit
    }
}
