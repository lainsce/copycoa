import SwiftUI

/// Edits the quote copy and optional attribution while keeping the card's typographic layout
/// independent from the modal draft state.
struct QuoteEditorSheet: View {
    @Bindable var card: Card
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var quote: String
    @State private var attribution: String

    init(card: Card, onSave: @escaping () -> Void = {}) {
        self.card = card
        self.onSave = onSave
        _quote = State(initialValue: card.quoteTextValue)
        _attribution = State(initialValue: card.quoteAttributionValue)
    }

    var body: some View {
        Form {
            Section {
                GLWNFormRow("Quote") {
                    TextEditor(text: $quote)
                        .font(.body)
                        .frame(minHeight: 110)
                }
            } header: {
                Text("Quote")
            }

            Section("Attribution") {
                GLWNFormRow("Author or source") {
                    TextField("", text: $attribution, prompt: Text("Optional"))
                        .textFieldStyle(GLWNTextFieldStyle())
                        .accessibilityLabel("Author or source")
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 350)
        .padding(.top, 8)
        .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                        .buttonStyle(GLWNInContentButtonStyle(tone: .neutral))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .buttonStyle(GLWNInContentButtonStyle(tone: .accent))
                    .keyboardShortcut(.defaultAction)
                    .disabled(trimmedQuote.isEmpty)
            }
        }
    }

    private var trimmedQuote: String {
        quote.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        guard !trimmedQuote.isEmpty else { return }
        card.quoteTextValue = trimmedQuote
        card.quoteAttributionValue = attribution.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave()
        dismiss()
    }
}
