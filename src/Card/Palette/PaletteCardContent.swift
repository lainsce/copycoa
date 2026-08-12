import Foundation
import SwiftUI

nonisolated enum PaletteCardDefaults {
    static let maximumColors = 5
    static let defaultColors = ["FFD84D", "FF9F45", "9CE29C", "8FD0FF", "D0B3FF"]
    static let defaultColorsJSON = "[\"FFD84D\",\"FF9F45\",\"9CE29C\",\"8FD0FF\",\"D0B3FF\"]"
}

nonisolated enum PaletteChipSlot: Int, CaseIterable, Identifiable {
    case one
    case two
    case three
    case four
    case five

    var id: Int { rawValue }

    var label: String {
        "C\(rawValue + 1)"
    }
}

struct PaletteCardContent: View {
    @Bindable var card: Card

    var body: some View {
        GeometryReader { proxy in
            let metrics = PaletteCardMetrics(size: proxy.size)
            let colors = card.paletteColorHexValues

            VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                Text(verbatim: card.paletteTitleValue)
                    .font(.system(size: metrics.titleFont, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: metrics.sectionSpacing)

                HStack(alignment: .bottom, spacing: metrics.chipSpacing) {
                    ForEach(PaletteChipSlot.allCases) { slot in
                        PaletteChip(
                            label: slot.label,
                            colorHex: colors.indices.contains(slot.rawValue)
                                ? colors[slot.rawValue]
                                : PaletteCardDefaults.defaultColors[slot.rawValue],
                            metrics: metrics
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
            }
            .padding(metrics.inset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background {
            RoundedRectangle(cornerRadius: card.cardSize.cornerRadius, style: .continuous)
                .fill(CardSurfaceStyle.subtleGrayGradient)
        }
        .clipShape(.rect(cornerRadius: card.cardSize.cornerRadius))
        .accessibilityElement(children: .contain)
    }
}

private struct PaletteCardMetrics {
    let size: CGSize

    var scale: CGFloat {
        max(0.75, min(size.width / CanvasMetrics.cell, size.height / CanvasMetrics.cell))
    }

    var inset: CGFloat { CanvasMetrics.cardContentInset }
    var sectionSpacing: CGFloat { max(8, 10 * scale) }
    var titleFont: CGFloat { max(13, 17 * scale) }
    var chipSpacing: CGFloat { max(3, 5 * scale) }
    var chipWidth: CGFloat {
        let available = max(40, size.width - inset * 2)
        return max(16, (available - CGFloat(PaletteCardDefaults.maximumColors - 1) * chipSpacing) / 5)
    }
    var chipHeight: CGFloat { max(46, min(70, 64 * scale)) }
    var chipLabelFont: CGFloat { max(7, 9 * scale) }
}

private struct PaletteChip: View {
    let label: String
    let colorHex: String
    let metrics: PaletteCardMetrics

    var body: some View {
        VStack(spacing: 0) {
            Color(hex: colorHex)
                .frame(width: metrics.chipWidth, height: metrics.chipHeight)

            Text(verbatim: label)
                .font(.system(size: metrics.chipLabelFont, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: metrics.chipWidth, height: metrics.chipLabelFont * 1.8)
                .background(.white)
        }
        .clipShape(.rect(cornerRadius: max(5, 8 * metrics.scale)))
        .overlay {
            RoundedRectangle(cornerRadius: max(5, 8 * metrics.scale), style: .continuous)
                .strokeBorder(.black.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 1.5, y: 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(label), \(colorHex)"))
    }
}
