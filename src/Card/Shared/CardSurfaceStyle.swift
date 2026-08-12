import SwiftUI

/// Shared neutral surface treatment for cards whose content should remain visually quiet.
enum CardSurfaceStyle {
    static var subtleGrayGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(nsColor: .textBackgroundColor),
                .gray.opacity(0.08),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
