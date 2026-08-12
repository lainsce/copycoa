import SwiftUI

/// Decodes link icon data asynchronously and caches it in view-local state.
struct CardFaviconContent: View {
    let card: Card
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Color.secondary.opacity(0.12)
                    Image(systemName: "globe")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .background(.white)
        .task(id: card.faviconRevision) {
            image = await decodeImage(from: card.faviconData)
        }
        .accessibilityHidden(true)
    }
}

/// Uses the favicon as a low-contrast, heavily blurred fallback when a page does not declare a
/// theme color. The image is intentionally enlarged before blurring so it reads as atmosphere,
/// not as a second copy of the favicon.
struct CardFaviconBlurBackground: View {
    let card: Card
    @State private var image: NSImage?

    var body: some View {
        GeometryReader { proxy in
            let blurRadius = max(18, min(proxy.size.width, proxy.size.height) * 0.16)

            ZStack {
                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(2)
                        .blur(radius: blurRadius)
                        .opacity(0.3)

                    LinearGradient(
                        colors: [.white.opacity(0.24), .clear, .black.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .task(id: card.faviconRevision) {
            image = await decodeImage(from: card.faviconData)
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}
