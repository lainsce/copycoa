import SwiftUI

/// Edits a five-chip Pantone-style palette. Each chip stays a fixed slot so the card remains
/// visually compact and its colors can be changed without reordering state.
struct PaletteEditorSheet: View {
    @Bindable var card: Card
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var colors: [Color]

    init(card: Card, onSave: @escaping () -> Void = {}) {
        self.card = card
        self.onSave = onSave
        _title = State(initialValue: card.paletteTitleValue)
        _colors = State(initialValue: card.paletteColorHexValues.map(Color.init(hex:)))
    }

    var body: some View {
        Form {
            Section {
                GLWNFormRow("Title") {
                    TextField("", text: $title, prompt: Text("Palette"))
                        .textFieldStyle(GLWNTextFieldStyle())
                        .accessibilityLabel("Title")
                }
            } header: {
                Text("Palette")
            }

            Section("Pantone chips") {
                ForEach(PaletteChipSlot.allCases) { slot in
                    GLWNFormRow("Chip \(slot.rawValue + 1)") {
                        ColorPicker(
                            "",
                            selection: $colors[slot.rawValue],
                            supportsOpacity: false
                        )
                        .labelsHidden()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 400)
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
            }
        }
    }

    private func save() {
        card.paletteTitleValue = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Palette"
            : title.trimmingCharacters(in: .whitespacesAndNewlines)
        card.paletteColorHexValues = colors.enumerated().map { index, color in
            color.hexValue ?? PaletteCardDefaults.defaultColors[index]
        }
        onSave()
        dismiss()
    }
}
