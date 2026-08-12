import SwiftUI

/// The bottom add-card surface. Each option keeps the full-color visual language of
/// the sidebar previews while remaining compact enough for a four-column grid.
struct AddCardPickerView: View {
    let addCard: (CardKind) -> Void
    let animation: Animation?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            ForEach(pickerRows.indices, id: \.self) { rowIndex in
                HStack(spacing: 12) {
                    ForEach(pickerRows[rowIndex]) { kind in
                        AddCardPickerItem(
                            kind: kind,
                            foreground: foreground,
                            hoverBackground: hoverBackground,
                            animation: animation
                        ) {
                            addCard(kind)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .frame(minWidth: 360, maxWidth: 420)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(panelGradient)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.black.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Add Card"))
    }

    private var pickerRows: [[CardKind]] {
        let kinds = Array(CardKind.allCases)
        return stride(from: 0, to: kinds.count, by: 4).map { start in
            Array(kinds[start..<min(start + 4, kinds.count)])
        }
    }

    private var foreground: Color {
        colorScheme == .dark ? .white : .black
    }

    private var hoverBackground: Color {
        colorScheme == .dark
            ? Color(hex: "#523822")
            : Color(hex: "#F5E5D2")
    }

    private var panelGradient: LinearGradient {
        LinearGradient(
            colors: [
                colorScheme == .dark
                    ? Color(hex: "#222222")
                    : Color(hex: "#FFFFFF"),
                colorScheme == .dark
                    ? Color(hex: "#323232")
                    : Color(hex: "#FAFAFA"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct AddCardPickerItem: View {
    let kind: CardKind
    let foreground: Color
    let hoverBackground: Color
    let animation: Animation?
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                AddCardOptionIcon(kind: kind)

                Text(kind.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isHovered ? hoverBackground : .clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        isHovered ? foreground.opacity(0.75) : .clear,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(animation, value: isHovered)
        .accessibilityLabel(Text(kind.displayName))
        .help(Text(kind.displayName))
    }
}

private struct AddCardOptionIcon: View {
    let kind: CardKind

    var body: some View {
        Image(assetName)
            .resizable()
            .interpolation(.high)
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .cardChrome(cornerRadius: 8)
            .accessibilityHidden(true)
    }

    private var assetName: String {
        switch kind {
        case .header: "AddCardOptionHeader"
        case .stickyNote: "AddCardOptionStickyNote"
        case .image: "AddCardOptionImage"
        case .link: "AddCardOptionLink"
        case .map: "AddCardOptionMap"
        case .calendar: "AddCardOptionCalendar"
        case .timeZone: "AddCardOptionTimeZone"
        case .weather: "AddCardOptionWeather"
        case .progress: "AddCardOptionProgress"
        case .checklist: "AddCardOptionChecklist"
        case .quote: "AddCardOptionQuote"
        case .palette: "AddCardOptionPalette"
        }
    }
}
