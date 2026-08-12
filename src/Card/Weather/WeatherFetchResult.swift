import Foundation

/// Distinguishes a fresh forecast body from a successful HTTP cache revalidation.
nonisolated enum WeatherFetchResult: Sendable {
    case updated(WeatherSnapshot, lastModified: String?)
    case notModified(expirationDate: Date, lastModified: String?)
}
