import SwiftUI

/// Compact inset-glass search field for Copycoa toolbars.
///
/// This is intentionally reusable without adding search behavior to a view
/// that does not already provide it. Callers own the binding and filtering.
struct GLWNToolbarSearchField: View {
    @Binding var text: String
    var prompt: LocalizedStringKey = "Search"

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused

    private let cornerRadius: CGFloat = 999

    private var isDarkMode: Bool { colorScheme == .dark }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
                .font(.body)
                .focused($isFocused)
                .submitLabel(.search)
                .accessibilityLabel(prompt)

            if !text.isEmpty {
                Button("Clear search", systemImage: "xmark.circle.fill") {
                    text = ""
                    isFocused = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .help(Text("Clear search"))
                .accessibilityLabel(Text("Clear search"))
            }
        }
        .padding(.horizontal, 12)
        .frame(minWidth: 200, idealWidth: 200, maxWidth: 200)
        .frame(height: 38)
        .contentShape(.rect(cornerRadius: cornerRadius))
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.thinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.primary.opacity(reduceTransparency ? 0.10 : (isDarkMode ? 0.06 : 0.025)))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(isFocused ? (isDarkMode ? 0.18 : 0.14) : (isDarkMode ? 0.12 : 0.08)),
                                    .clear,
                                    .black.opacity(isDarkMode ? 0.12 : 0.035),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .black.opacity(isDarkMode ? 0.22 : 0.12),
                            .black.opacity(isDarkMode ? 0.08 : 0.03),
                            .white.opacity(isFocused ? (isDarkMode ? 0.52 : 0.38) : (isDarkMode ? 0.38 : 0.28)),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .inset(by: 1)
                .strokeBorder(
                    LinearGradient(
                    colors: [
                        .black.opacity(isDarkMode ? 0.24 : 0.10),
                        .clear,
                        .white.opacity(isDarkMode ? 0.24 : 0.18),
                    ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.accent.opacity(isFocused ? 0.42 : 0), lineWidth: 1)
        }
        .shadow(color: .black.opacity(isFocused ? (isDarkMode ? 0.16 : 0.045) : (isDarkMode ? 0.12 : 0.03)), radius: 1, x: 0, y: 0)
        .onTapGesture {
            isFocused = true
        }
        .animation(
            reduceMotion ? nil : .easeOut(duration: 0.12),
            value: isFocused
        )
    }
}
