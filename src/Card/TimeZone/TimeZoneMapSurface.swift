import AppKit
import SwiftUI

/// Loads high-resolution crops generated directly from `WorldTimeZonesMap.svg`.
/// The source uses classed paths for each zone and separate `c`/`n` coastline overlays;
/// the crops preserve those paths while making the card deterministic at runtime because
/// AppKit's SVG importer is not reliable for this map's large, CSS-heavy path set.
@MainActor
private enum TimeZoneMapRenderer {
    private static var cache: [String: NSImage] = [:]

    static func image(for preset: TimeZoneCardPreset) -> NSImage? {
        let assetName = preset.mapAssetName
        if let cached = cache[assetName] {
            return cached
        }

        let url = Bundle.main.url(
            forResource: assetName,
            withExtension: "png",
            subdirectory: "TimeZoneMaps"
        ) ?? Bundle.main.url(forResource: assetName, withExtension: "png")

        guard let url, let image = NSImage(contentsOf: url) else {
            return nil
        }

        cache[assetName] = image
        return image
    }
}

struct TimeZoneMapSurface: View {
    let preset: TimeZoneCardPreset
    let isDaytime: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.05)

                if let image = TimeZoneMapRenderer.image(for: preset) {
                    Image(nsImage: image)
                        .interpolation(.high)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(1.04)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }

                // The crops are centered on the selected city, so this restrained marker
                // lands on the city without introducing labels or map chrome.
                Circle()
                    .fill(.white.opacity(0.10))
                    .frame(width: 30, height: 30)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.54), lineWidth: 1)
                    }
                Circle()
                    .fill(.white)
                    .frame(width: 6, height: 6)

                LinearGradient(
                    colors: isDaytime
                        ? [.white.opacity(0.08), .clear, .black.opacity(0.10)]
                        : [.black.opacity(0.18), .clear, .black.opacity(0.24)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
