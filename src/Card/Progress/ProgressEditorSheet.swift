import SwiftUI

/// Edits a Progress card's date range, label, and dot-grid colors. Draft state keeps Cancel
/// reversible while ColorPicker values remain native macOS controls.
struct ProgressEditorSheet: View {
    @Bindable var card: Card
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var startDate: Date
    @State private var goalDate: Date
    @State private var dotColor: Color
    @State private var backgroundColor: Color

    init(card: Card, onSave: @escaping () -> Void = {}) {
        self.card = card
        self.onSave = onSave
        _title = State(initialValue: card.progressTitleValue)
        _startDate = State(initialValue: card.progressStartDateValue)
        _goalDate = State(initialValue: max(card.progressStartDateValue, card.progressGoalDateValue))
        _dotColor = State(initialValue: Color(hex: card.progressDotColorHexValue))
        _backgroundColor = State(initialValue: Color(hex: card.progressBackgroundColorHexValue))
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title, prompt: Text("Progress"))
            } header: {
                Text("Progress")
            }

            Section("Goal") {
                DatePicker(
                    "Starts",
                    selection: $startDate,
                    displayedComponents: [.date]
                )
                DatePicker(
                    "Goal date",
                    selection: $goalDate,
                    in: startDate...,
                    displayedComponents: [.date]
                )
            }

            Section("Appearance") {
                ColorPicker("Dot color", selection: $dotColor, supportsOpacity: false)
                ColorPicker("Background", selection: $backgroundColor, supportsOpacity: false)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 370)
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
        .onChange(of: startDate) { _, newValue in
            if goalDate < newValue {
                goalDate = newValue
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        card.progressTitleValue = trimmedTitle.isEmpty ? "Progress" : trimmedTitle
        card.progressStartDateValue = startDate
        card.progressGoalDateValue = max(startDate, goalDate)
        card.progressDotColorHexValue = dotColor.hexValue ?? ProgressCardDefaults.dotColorHex
        card.progressBackgroundColorHexValue = backgroundColor.hexValue ?? ProgressCardDefaults.backgroundColorHex
        onSave()
        dismiss()
    }
}
