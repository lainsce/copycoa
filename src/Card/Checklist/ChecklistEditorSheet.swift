import SwiftUI

/// Edits the three fixed checklist slots. Empty slots are omitted from the card, so users can
/// make a one- or two-item checklist without the editor growing beyond its compact design.
struct ChecklistEditorSheet: View {
    @Bindable var card: Card
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var itemOne: String
    @State private var itemTwo: String
    @State private var itemThree: String
    @State private var completed: [Bool]

    init(card: Card, onSave: @escaping () -> Void = {}) {
        self.card = card
        self.onSave = onSave
        _title = State(initialValue: card.checklistTitleValue)
        _itemOne = State(initialValue: card.checklistItemValueOne)
        _itemTwo = State(initialValue: card.checklistItemValueTwo)
        _itemThree = State(initialValue: card.checklistItemValueThree)
        _completed = State(initialValue: (0..<3).map { card.checklistCompletedMaskValue & (1 << $0) != 0 })
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title, prompt: Text("Checklist"))
            } header: {
                Text("Checklist")
            }

            Section("Checks") {
                ChecklistEditorRow(
                    title: "Check 1",
                    text: $itemOne,
                    isCompleted: $completed[0]
                )
                ChecklistEditorRow(
                    title: "Check 2",
                    text: $itemTwo,
                    isCompleted: $completed[1]
                )
                ChecklistEditorRow(
                    title: "Check 3",
                    text: $itemThree,
                    isCompleted: $completed[2]
                )
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 390)
        .padding(.top, 8)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss.callAsFunction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .keyboardShortcut(.defaultAction)
            }
        }
    }

    private func save() {
        let values = [itemOne, itemTwo, itemThree].map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        card.checklistTitleValue = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Checklist"
            : title.trimmingCharacters(in: .whitespacesAndNewlines)
        card.checklistItemValueOne = values[0]
        card.checklistItemValueTwo = values[1]
        card.checklistItemValueThree = values[2]
        card.checklistCompletedMaskValue = completed.enumerated().reduce(0) { mask, entry in
            entry.element && !values[entry.offset].isEmpty
                ? mask | (1 << entry.offset)
                : mask
        }
        onSave()
        dismiss()
    }
}

private struct ChecklistEditorRow: View {
    let title: LocalizedStringResource
    @Binding var text: String
    @Binding var isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(title, text: $text, prompt: Text("Optional"))
            Toggle("Completed", isOn: $isCompleted)
                .toggleStyle(.checkbox)
                .font(.caption)
        }
    }
}
