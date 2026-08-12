import Foundation

/// Normalizes user-typed text into a URL, adding a scheme when missing.
nonisolated func normalizedURL(_ text: String) -> URL? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    let candidate = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
    guard var components = URLComponents(string: candidate),
          let scheme = components.scheme?.lowercased(),
          scheme == "http" || scheme == "https",
          let host = components.host,
          !host.isEmpty else { return nil }

    components.scheme = scheme
    return components.url
}
