import SwiftUI

/// Chooses the forecast location and whether Copycoa should write the summary.
struct WeatherEditorSheet: View {
    let card: Card
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var location: String
    @State private var summary: String
    @State private var usesAutomaticSummary: Bool

    init(card: Card, onSave: @escaping () -> Void = {}) {
        self.card = card
        self.onSave = onSave
        _location = State(initialValue: card.weatherLocationValue)
        _summary = State(initialValue: card.weatherSummaryValue)
        _usesAutomaticSummary = State(initialValue: card.weatherUsesAutomaticSummaryValue)
    }

    var body: some View {
        Form {
            Section("Location") {
                GLWNFormRow("Place") {
                    TextField("", text: $location, prompt: Text("City or address"))
                        .textFieldStyle(GLWNTextFieldStyle())
                        .accessibilityLabel("Place")
                }
            }

            Section {
                GLWNFormRow("Automatic summary") {
                    Toggle("", isOn: $usesAutomaticSummary)
                        .labelsHidden()
                        .toggleStyle(GLWNAquaToggleStyle())
                        .accessibilityLabel("Automatic summary")
                }

                if !usesAutomaticSummary {
                    GLWNFormRow("Custom summary") {
                        TextField("", text: $summary, axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(GLWNTextFieldStyle())
                            .accessibilityLabel("Custom summary")
                    }
                }
            } header: {
                Text("Summary")
            } footer: {
                Text("Copycoa writes this from the live conditions in the same playful tone as the card design.")
            }
        }
        .formStyle(.grouped)
        .frame(width: 520, height: 390)
        .padding(.top, 8)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss.callAsFunction)
                    .buttonStyle(GLWNInContentButtonStyle(tone: .neutral))
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save & Update", action: save)
                    .buttonStyle(GLWNInContentButtonStyle(tone: .accent))
                    .keyboardShortcut(.defaultAction)
                    .disabled(cleanedLocation.isEmpty)
            }
        }
    }

    private func save() {
        card.weatherLocationValue = cleanedLocation
        card.weatherUsesAutomaticSummaryValue = usesAutomaticSummary
        if !usesAutomaticSummary {
            let cleanedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
            card.weatherSummaryValue = cleanedSummary.isEmpty
                ? WeatherSummaryGenerator.referenceSummary
                : cleanedSummary
        }
        onSave()
        dismiss()
    }

    private var cleanedLocation: String {
        location.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
