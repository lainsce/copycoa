import SwiftUI

/// Restrained pressed treatment for sidebar board rows.
struct GLWNSidebarRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.primary.opacity(configuration.isPressed ? 0.10 : 0))
                    .allowsHitTesting(false)
            }
    }
}
