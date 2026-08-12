import AppKit
import Foundation

nonisolated enum ImageLoadingError: Error {
    case securityScopeDenied
}

/// Reads a user-selected file away from the main actor while holding its security scope.
nonisolated func loadSecurityScopedData(from url: URL) async throws -> Data {
    try await Task.detached(priority: .userInitiated) {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImageLoadingError.securityScopeDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }
        return try Data(contentsOf: url, options: .mappedIfSafe)
    }.value
}

/// Decodes an image away from the main actor for smooth canvas updates.
nonisolated func decodeImage(from data: Data?) async -> NSImage? {
    guard let data else { return nil }
    return await Task.detached(priority: .userInitiated) {
        NSImage(data: data)
    }.value
}
