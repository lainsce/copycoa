import CoreGraphics

/// Pure placement logic shared by the canvas and its unit tests.
nonisolated enum CanvasPlacement {
    /// Finds the grid-aligned, collision-free origin nearest a requested point.
    ///
    /// The x-axis is finite: cards stay inside the one-dot margins around the four-column
    /// canvas. Both axes use the card module lattice; the y-axis has no upper bound and rows are
    /// searched until a free one is found.
    static func nearestFreePosition(
        for pointSize: CGSize,
        nearX: Double,
        nearY: Double,
        canvasWidth: Double,
        occupiedRects: [CGRect],
        minimumY: Double? = nil
    ) -> CGPoint {
        let unit = Double(CanvasMetrics.gridUnit)
        let xPitch = Double(CanvasMetrics.module)
        let margin = Double(CanvasMetrics.canvasMargin)
        let yPitch = Double(CanvasMetrics.module)
        let rowOrigin = max(margin, minimumY ?? margin)
        let width = Double(pointSize.width)
        let height = Double(pointSize.height)

        func isClear(_ x: Double, _ y: Double) -> Bool {
            // Inflate by just under one dot so a candidate exactly one dot away still clears.
            let inset = unit - 1
            let candidate = CGRect(
                x: x - inset,
                y: y - inset,
                width: width + 2 * inset,
                height: height + 2 * inset
            )
            return !occupiedRects.contains(where: candidate.intersects)
        }

        let availableWidth = canvasWidth - 2 * margin
        guard width <= availableWidth + 0.5 else {
            // Every built-in card fits, but keep the fallback safe for future card sizes.
            return CGPoint(x: margin, y: margin)
        }

        let lastColumn = Int(floor((availableWidth - width + 0.5) / xPitch))
        let columns = Array(0...max(0, lastColumn))

        func xPosition(for column: Int) -> Double {
            margin + xPitch * Double(column)
        }

        func yPosition(for row: Int) -> Double {
            rowOrigin + yPitch * Double(row)
        }

        let requestedColumn = Int(((nearX - margin) / xPitch).rounded())
        let baseColumn = min(max(requestedColumn, 0), max(0, lastColumn))
        let requestedRow = Int(((nearY - rowOrigin) / yPitch).rounded())
        let baseRow = max(requestedRow, 0)
        let columnsByDistance = columns.sorted {
            let lhsDistance = abs(xPosition(for: $0) - nearX)
            let rhsDistance = abs(xPosition(for: $1) - nearX)
            if lhsDistance == rhsDistance { return abs($0 - baseColumn) < abs($1 - baseColumn) }
            return lhsDistance < rhsDistance
        }

        // There are only four columns, so search rows outwards from the requested one. The
        // finite set of occupied cards guarantees that the fallback below eventually succeeds.
        let searchLimit = max(64, occupiedRects.count * 8 + 8)
        for distance in 0...searchLimit {
            let rows: [Int]
            if distance == 0 {
                rows = [baseRow]
            } else {
                rows = [baseRow - distance, baseRow + distance].filter { $0 >= 0 }
            }

            for row in rows {
                for column in columnsByDistance {
                    let candidateX = xPosition(for: column)
                    let candidateY = yPosition(for: row)
                    if isClear(candidateX, candidateY) {
                        return CGPoint(x: candidateX, y: candidateY)
                    }
                }
            }
        }

        // Fall back to a row below all occupied content. Since y is intentionally unbounded,
        // this loop always finds a free slot for the finite board.
        let rowBelowContent = occupiedRects.map {
            Int(ceil(($0.maxY + unit - 1 - rowOrigin) / yPitch))
        }.max() ?? 0
        var fallbackRow = max(baseRow, rowBelowContent)
        while true {
            for column in columnsByDistance {
                let candidateX = xPosition(for: column)
                let candidateY = yPosition(for: fallbackRow)
                if isClear(candidateX, candidateY) {
                    return CGPoint(x: candidateX, y: candidateY)
                }
            }
            fallbackRow += 1
        }
    }
}
