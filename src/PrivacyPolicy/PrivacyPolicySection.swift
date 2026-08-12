import SwiftUI

struct PrivacyPolicySection: View {
    let title: LocalizedStringResource
    let systemImage: String
    let text: LocalizedStringResource

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            Text(text)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
