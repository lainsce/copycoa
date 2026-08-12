import SwiftUI

/// Shared visual treatment for card surfaces and their sidebar representations.
/// Keep these values in one place so full-size cards and previews cannot drift apart.
nonisolated enum CardChromeMetrics {
    static let outlineOpacity: Double = 0.06
    static let outlineWidth: CGFloat = 1
    static let innerHighlightStartOpacity: Double = 0.22
    static let innerHighlightEndOpacity: Double = 0
    static let innerHighlightWidth: CGFloat = 1
    static let innerHighlightInset: CGFloat = 1
    static let shadowOpacity: Double = 0.03
    static let shadowRadius: CGFloat = 3
    static let shadowYOffset: CGFloat = 2

    /// The 64×72 preview uses a smaller radius while keeping the same chrome values.
    static let previewCornerRadius: CGFloat = 10
}

struct CardChromeModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay {
                CardChromeOutline(cornerRadius: cornerRadius)
            }
            .shadow(
                color: .black.opacity(CardChromeMetrics.shadowOpacity),
                radius: CardChromeMetrics.shadowRadius,
                x: 0,
                y: CardChromeMetrics.shadowYOffset
            )
    }
}

private struct CardChromeOutline: View {
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    .black.opacity(CardChromeMetrics.outlineOpacity),
                    lineWidth: CardChromeMetrics.outlineWidth
                )

            RoundedRectangle(
                cornerRadius: max(0, cornerRadius - CardChromeMetrics.innerHighlightInset),
                style: .continuous
            )
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(CardChromeMetrics.innerHighlightStartOpacity),
                        .white.opacity(CardChromeMetrics.innerHighlightEndOpacity),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: CardChromeMetrics.innerHighlightWidth
            )
            .padding(CardChromeMetrics.innerHighlightInset)
        }
        .allowsHitTesting(false)
    }
}

extension View {
    /// Applies the canonical card outline, inner highlight, and elevation treatment.
    func cardChrome(cornerRadius: CGFloat) -> some View {
        modifier(CardChromeModifier(cornerRadius: cornerRadius))
    }
}
