#if os(macOS)
import AppKit
import SwiftUI

/// A compact, native About surface with the app identity, release metadata, and
/// the existing privacy-policy route close at hand.
struct CopycoaAboutView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 18) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 128, height: 128)
                .shadow(color: .black.opacity(0.18), radius: 12, y: 6)

            VStack(spacing: 6) {
                Text("Copycoa")
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                Text("A calm, spatial canvas for ideas.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Text("Keep notes, references, dates, places, and useful fragments together on a canvas you can return to.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .lineLimit(2...2)
                .frame(width: 310)

            Divider()

            VStack(spacing: 4) {
                Text("Version \(versionString)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Made with SwiftUI for Mac.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Button("Privacy Policy") {
                openWindow(id: CopycoaWindowID.privacyPolicy)
            }
            .buttonStyle(.link)
        }
        .padding(32)
        .frame(width: 400)
        .background {
            LinearGradient(
                colors: [Color.accent.opacity(0.10), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var versionString: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            ?? "1"
        return "\(version) (\(build))"
    }
}
#endif
