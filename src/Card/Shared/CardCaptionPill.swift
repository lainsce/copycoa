import SwiftUI

/// Shared caption treatment used by image and map cards.
struct CardCaptionPill: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .font(.caption.bold())
            .foregroundStyle(.primary)
            .lineLimit(3)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.black.opacity(0.06), lineWidth: 1)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .textBackgroundColor).opacity(0.88))
                    .padding(1)
            }
    }
}
