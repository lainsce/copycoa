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
                GLWNFormRow("Date type") {
                    GLWNSegmentedPicker(
                        selection: $dateKind,
                        options: CalendarDateKind.allCases
                    ) { kind in
                        Label(kind.displayName, systemImage: kind.systemImage)
                    }
                }
            } header: {
                Text("Calendar")
            }

            Section("When") {
                GLWNFormRow(dateKind == .dateRange ? "Starts" : "Date and time") {
                    DatePicker(
                        "",
                        selection: $startDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                }

                if dateKind == .dateRange {
                    GLWNFormRow("Ends") {
                        DatePicker(
                            "",
                            selection: $endDate,
                            in: startDate...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                    }
                }
            }

            Section("Details") {
                GLWNFormRow("Event title") {
                    TextField("", text: $eventTitle, prompt: Text("Event"))
                        .textFieldStyle(GLWNTextFieldStyle())
                        .accessibilityLabel("Event title")
                }
                GLWNFormRow("Emoji stickers (in order)") {
                    TextField("", text: $emoji, prompt: Text("Up to 3"))
                        .textFieldStyle(GLWNTextFieldStyle())
                        .accessibilityLabel("Emoji stickers (in order)")
                }

                if dateKind == .recurring {
                    GLWNFormRow("Repeat label") {
                        TextField("", text: $recurrenceLabel, prompt: Text("Weekly"))
                            .textFieldStyle(GLWNTextFieldStyle())
                            .accessibilityLabel("Repeat label")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 540, height: dateKind == .dateRange ? 430 : 390)
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
