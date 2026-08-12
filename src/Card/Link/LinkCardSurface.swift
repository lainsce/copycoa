import SwiftUI

/// The link card's favicon, metadata hierarchy, and theme-color/fallback surface.
struct LinkCardSurface: View {
    let card: Card
    let cornerRadius: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardFaviconContent(card: card)
                .frame(width: 40, height: 40)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.black.opacity(0.04), lineWidth: 1)
                }

            Spacer(minLength: 8)

            Text(verbatim: card.title ?? card.urlString ?? String(localized: "Link"))
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
            if let host = URL(string: card.urlString ?? "")?.host {
                Text(verbatim: host)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.top, 2)
            }
            if let detail = card.detail, !detail.isEmpty {
                Text(verbatim: detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(CanvasMetrics.cardContentInset)
        .background(linkCardSurface)
    }

    private var linkCardSurface: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(nsColor: .textBackgroundColor))
            .overlay {
                if let themeColor = linkThemeColor {
                    LinearGradient(
                        colors: [
                            themeColor.opacity(0.16),
                            themeColor.opacity(0.06),
                            .clear,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(.rect(cornerRadius: cornerRadius))
                } else {
                    CardFaviconBlurBackground(card: card)
                        .clipShape(.rect(cornerRadius: cornerRadius))
                }
            }
    }

    private var linkThemeColor: Color? {
        guard let hex = card.themeColorHex,
              hex.count == 6,
              hex.allSatisfy(\.isHexDigit) else {
            return nil
        }
        return Color(hex: hex)
    }
}
