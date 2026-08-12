import SwiftUI

/// The editable and display states of a Sticky Note card.
struct StickyNoteCardContent: View {
    @Bindable var card: Card
    let isEditing: Bool
    let cornerRadius: CGFloat

    @FocusState private var focused: Bool

    var body: some View {
        Group {
            if isEditing {
                TextEditor(text: $card.text)
                    .focused($focused)
                    .scrollContentBackground(.hidden)
            } else if card.text.isEmpty {
                Text("Write a note…")
                    .foregroundStyle(.black.opacity(0.35))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                Text(verbatim: card.text)
                    .foregroundStyle(.black.opacity(0.85))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .font(.custom("Marker Felt", size: 16, relativeTo: .body))
        .padding(CanvasMetrics.cardContentInset)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(hex: card.colorHex ?? StickyPalette.yellow))
        }
        .onChange(of: isEditing) { _, editing in
            focused = editing
        }
    }
}
