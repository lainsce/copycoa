import SwiftUI

/// The field of positioning dots for the fixed-width, vertically scrolling canvas.
/// The 5px micro-grid contains every card origin, with every fifth intersection emphasized.
struct DotGrid: View {
    let origin: CGPoint

    var body: some View {
        Canvas { context, size in
            let spacing = CanvasMetrics.dotSpacing
            let majorInterval = CanvasMetrics.majorDotInterval
            let firstX = origin.x.truncatingRemainder(dividingBy: spacing)
            let firstY = origin.y.truncatingRemainder(dividingBy: spacing)
            var regularDots = Path()
            var majorDots = Path()
            var column = Int(((firstX - origin.x) / spacing).rounded())
            var x = firstX

            while x <= size.width {
                var row = Int(((firstY - origin.y) / spacing).rounded())
                var y = firstY

                while y <= size.height {
                    let isMajor = column.isMultiple(of: majorInterval)
                        && row.isMultiple(of: majorInterval)
                    let diameter = isMajor
                        ? CanvasMetrics.majorDotDiameter
                        : CanvasMetrics.dotDiameter
                    let rect = CGRect(
                        x: x - diameter / 2,
                        y: y - diameter / 2,
                        width: diameter,
                        height: diameter
                    )

                    if isMajor {
                        majorDots.addEllipse(in: rect)
                    } else {
                        regularDots.addEllipse(in: rect)
                    }

                    row += 1
                    y += spacing
                }

                column += 1
                x += spacing
            }

            context.fill(regularDots, with: .color(.primary.opacity(0.01)))
            context.fill(majorDots, with: .color(.primary.opacity(0.08)))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
