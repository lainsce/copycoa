import AppKit
import QuartzCore
import SwiftUI

final class GLWNSidebarBoundaryOverlayView: NSView {
    private static let lineOffset = GLWNSidebarBoundaryDivider.overlayWidth - 1

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.height]
        wantsLayer = true
        layer?.isOpaque = false
        layer?.masksToBounds = true
        layer?.zPosition = 1_000
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func draw(_ dirtyRect: NSRect) {
        // Draw the falloff as clipped strips instead of relying on a shadow
        // outside the view's bounds. This keeps the effect visible above the
        // HStack host while stopping it a few points into the sidebar.
        let shadowWidth = max(0, Int(Self.lineOffset))
        for index in 0..<shadowWidth {
            let progress = CGFloat(index) / CGFloat(max(1, shadowWidth - 1))
            let alpha = 0.03 * progress
            NSColor.black.withAlphaComponent(alpha).setFill()
            NSBezierPath(
                rect: NSRect(
                    x: CGFloat(index),
                    y: bounds.minY,
                    width: 1,
                    height: bounds.height
                )
            ).fill()
        }

        NSColor.separatorColor.withAlphaComponent(0.12).setFill()
        NSBezierPath(
            rect: NSRect(
                x: Self.lineOffset,
                y: bounds.minY,
                width: 1,
                height: bounds.height
            )
        ).fill()
    }
}

