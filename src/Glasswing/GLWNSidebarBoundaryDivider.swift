import AppKit
import QuartzCore
import SwiftUI

struct GLWNSidebarBoundaryDivider: NSViewRepresentable {
    static let overlayWidth: CGFloat = 14

    func makeNSView(context: Context) -> GLWNSidebarBoundaryOverlayView {
        GLWNSidebarBoundaryOverlayView()
    }

    func updateNSView(_ nsView: GLWNSidebarBoundaryOverlayView, context: Context) {
        nsView.needsDisplay = true
    }
}

