import SwiftUI

struct AddCardFanView: View {
    @Binding var isExpanded: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let addCard: (CardKind) -> Void

    private let glassTint = Color(.accent)

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isExpanded {
                AddCardPickerView(addCard: selectCard, animation: fanAnimation)
                    .padding(.bottom, 72)
                    .transition(
                        .move(edge: .bottom)
                            .combined(with: .scale(scale: 0.96, anchor: .bottomTrailing))
                            .combined(with: .opacity)
                    )
                    .zIndex(1)
            }

            addButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(8)
        .animation(fanAnimation, value: isExpanded)
    }

    private var addButton: some View {
        Button {
            withAnimation(fanAnimation) {
                isExpanded.toggle()
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .rotationEffect(.degrees(isExpanded ? 45 : 0))
                .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
        .background(anchorGradient)
        .foregroundStyle(.white)
        .clipShape(.circle)
        .cardChrome(cornerRadius: 999)
        .accessibilityLabel(Text(anchorTitle))
        .accessibilityHint(Text("Shows card types"))
        .help(Text(anchorTitle))
    }

    private func selectCard(_ kind: CardKind) {
        withAnimation(fanAnimation) {
            isExpanded = false
        }
        addCard(kind)
    }

    private var anchorTitle: LocalizedStringResource {
        isExpanded ? "Close" : "Add Card"
    }

    private var fanAnimation: Animation? {
        reduceMotion ? nil : .snappy
    }

    private var anchorGradient: LinearGradient {
        LinearGradient(
            colors: [
                glassTint.opacity(0.72),
                glassTint,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
