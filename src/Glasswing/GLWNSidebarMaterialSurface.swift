import AppKit
import SwiftUI

struct GLWNSidebarMaterialSurface: View {
    private static let tintOpacity: Double = 0.11

    var body: some View {
        ZStack {
            GLWNSidebarMaterialBackground()
            Color(nsColor: .windowBackgroundColor)
                .opacity(Self.tintOpacity)
        }
        .accessibilityHidden(true)
    }
}

