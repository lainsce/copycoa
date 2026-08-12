import SwiftUI

/// Edits the event data shown by a Calendar card. Draft state keeps Cancel genuinely reversible.
struct CalendarEditorSheet: View {
    @Bindable var card: Card
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var dateKind: CalendarDateKind
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var eventTitle: String
    @State private var emoji: String
    @State private var recurrenceLabel: String

    init(card: Card, onSave: @escaping () -> Void = {}) {
        self.card = card
        self.onSave = onSave
        _dateKind = State(initialValue: card.calendarDateKind)
        _startDate = State(initialValue: card.calendarStartDateValue)
        _endDate = State(initialValue: card.calendarEndDateValue)
        _eventTitle = State(initialValue: card.calendarEventTitleValue)
        _emoji = State(initialValue: card.calendarEmojiValue)
        _recurrenceLabel = State(initialValue: card.calendarRecurrenceLabelValue)
    }

    var body: some View {
        Form {
            Section {
                Picker("Date type", selection: $dateKind) {
                    ForEach(CalendarDateKind.allCases) { kind in
                        Label(kind.displayName, systemImage: kind.systemImage)
                            .tag(kind)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Calendar")
            }

            Section("When") {
                DatePicker(
                    dateKind == .dateRange ? "Starts" : "Date and time",
                    selection: $startDate,
                    displayedComponents: [.date, .hourAndMinute]
                )

                if dateKind == .dateRange {
                    DatePicker(
                        "Ends",
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }

            Section("Details") {
                TextField("Event title", text: $eventTitle, prompt: Text("Event"))
                TextField("Emoji stickers (in order)", text: $emoji, prompt: Text("Up to 3"))

                if dateKind == .recurring {
                    TextField("Repeat label", text: $recurrenceLabel, prompt: Text("Weekly"))
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 540, height: dateKind == .dateRange ? 430 : 390)
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
            if endDate < newValue {
                endDate = newValue.addingTimeInterval(24 * 60 * 60)
            }
        }
    }

    private func save() {
        card.calendarDateKind = dateKind
        card.calendarStartDateValue = startDate
        card.calendarEndDateValue = max(endDate, startDate)
        card.calendarEventTitleValue = eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Event"
            : eventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        card.calendarEmojiValue = calendarStickerValues(from: emoji).joined()
        card.calendarRecurrenceLabelValue = recurrenceLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Weekly"
            : recurrenceLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave()
        dismiss()
    }
}
