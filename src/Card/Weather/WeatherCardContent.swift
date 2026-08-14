import SwiftUI

/// Displays a weather snapshot using the supplied 1×1 composition as its base design.
struct WeatherCardContent: View {
    let card: Card

    var body: some View {
        GeometryReader { proxy in
            let scale = min(max(min(proxy.size.width, proxy.size.height) / CanvasMetrics.cell, 1), 2)
            let inset = 20 * scale
            let condition = card.weatherCondition
            let colors = condition.gradientHexes

            ZStack {
                LinearGradient(
                    colors: [Color(hex: colors.top), Color(hex: colors.bottom)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: card.weatherSummaryValue)
                        .font(.system(size: 12, weight: .regular))
                        .lineSpacing(0.24)
                        .lineLimit(card.cardSize == .oneByOne ? 4 : 3)
                        .frame(
                            maxWidth: messageWidth(in: proxy.size, inset: inset),
                            alignment: .leading
                        )

                    Spacer(minLength: 8 * scale)

                    HStack(alignment: .bottom, spacing: 12 * scale) {
                        VStack(alignment: .leading, spacing: -7 * scale) {
                            temperature(card.weatherHighTemperatureValue, scale: scale)
                            temperature(card.weatherLowTemperatureValue, scale: scale)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: card.weatherSymbolNameValue)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color(hex: condition.secondaryIconColorHex))
                            .font(.system(size: 36 * scale, weight: .medium))
                            .accessibilityHidden(true)
                    }
                }
                .foregroundStyle(.white)
                .padding(inset)
            }
            .clipShape(.rect(cornerRadius: card.cardSize.cornerRadius))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Weather"))
        .accessibilityValue(Text(verbatim: accessibilityValue))
    }

    private func temperature(_ value: Int, scale: CGFloat) -> some View {
        Text(verbatim: "\(value)°")
            .font(.system(size: 33 * scale, weight: .regular, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
    }

    private func messageWidth(in size: CGSize, inset: CGFloat) -> CGFloat {
        let available = max(0, size.width - 2 * inset)
        guard card.cardSize != .oneByOne else { return available }
        return min(available, size.width * 0.62)
    }

    private var accessibilityValue: String {
        let location = card.weatherLocationValue.isEmpty ? "" : "\(card.weatherLocationValue), "
        let condition = String(localized: card.weatherCondition.displayName)
        return "\(location)\(condition), \(card.weatherSummaryValue), high \(card.weatherHighTemperatureValue)\(card.weatherTemperatureUnitLabel), low \(card.weatherLowTemperatureValue)\(card.weatherTemperatureUnitLabel)"
    }
}
