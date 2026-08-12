import SwiftUI
#if os(macOS)
import AppKit
#endif

extension Color {
    /// Creates a color from a 6-digit hex string (for example, "FFD84D").
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }

    /// Returns the resolved sRGB color as a six-digit hex value for SwiftData persistence.
    var hexValue: String? {
        #if os(macOS)
        guard let color = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        let red = Int((color.redComponent * 255).rounded())
        let green = Int((color.greenComponent * 255).rounded())
        let blue = Int((color.blueComponent * 255).rounded())
        return String(format: "%02X%02X%02X", red, green, blue)
        #else
        return nil
        #endif
    }
}
