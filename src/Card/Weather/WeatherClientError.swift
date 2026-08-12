import Foundation

nonisolated enum WeatherClientError: LocalizedError {
    case invalidResponse
    case missingForecast
    case serviceStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            String(localized: "The weather service returned an invalid response.")
        case .missingForecast:
            String(localized: "MET Norway did not return enough forecast data.")
        case .serviceStatus(let status):
            String(localized: "The weather service returned an error (HTTP \(status)).")
        }
    }
}
