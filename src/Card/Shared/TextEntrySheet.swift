import Foundation
import SwiftUI

/// A small modal sheet that collects one line of text for links and map searches.
struct TextEntrySheet: View {
    let title: LocalizedStringResource
    let fieldLabel: LocalizedStringResource
    let prompt: LocalizedStringResource
    let systemImage: String
    let submitTitle: LocalizedStringResource
    let onSubmit: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String

    init(
        title: LocalizedStringResource,
        fieldLabel: LocalizedStringResource,
        prompt: LocalizedStringResource,
        systemImage: String,
        initialText: String = "",
        submitTitle: LocalizedStringResource = "Add",
        onSubmit: @escaping (String) -> Void
    ) {
        self.title = title
        self.fieldLabel = fieldLabel
        self.prompt = prompt
        self.systemImage = systemImage
        self.submitTitle = submitTitle
        self.onSubmit = onSubmit
        _text = State(initialValue: initialText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            TextField(fieldLabel, text: $text, prompt: Text(prompt))
                .textFieldStyle(.roundedBorder)
                .onSubmit(submit)
            HStack {
                Spacer()
                Button("Cancel", action: dismiss.callAsFunction)
                Button(submitTitle, action: submit)
                    .keyboardShortcut(.defaultAction)
                    .disabled(trimmedText.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit() {
        guard !trimmedText.isEmpty else { return }
        onSubmit(trimmedText)
        dismiss()
    }
}
