import Foundation

/// The small, persistence-ready subset of forecast data used by a Weather card.
nonisolated struct WeatherSnapshot: Sendable {
    let highTemperature: Int
    let lowTemperature: Int
    let temperatureUnit: String
    let currentTemperatureCelsius: Double
    let condition: WeatherCondition
    let symbolName: String
    let isDaylight: Bool
    let observedAt: Date
    let expirationDate: Date
}
