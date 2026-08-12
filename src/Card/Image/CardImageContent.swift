import SwiftUI

/// Decodes persisted image data asynchronously and caches it in view-local state.
struct CardImageContent: View {
    let card: Card
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
            } else {
                ZStack {
                    Color.secondary.opacity(0.12)
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task(id: card.imageRevision) {
            image = await decodeImage(from: card.imageData)
        }
        .accessibilityHidden(true)
    }
}
