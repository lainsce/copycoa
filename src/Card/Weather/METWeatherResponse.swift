import Foundation

/// The compact subset of MET Norway's Locationforecast GeoJSON used by Weather cards.
nonisolated struct METWeatherResponse: Decodable, Sendable {
    let geometry: Geometry
    let properties: Properties

    struct Geometry: Decodable, Sendable {
        let coordinates: [Double]
    }

    struct Properties: Decodable, Sendable {
        let timeseries: [TimeSeries]
    }

    struct TimeSeries: Decodable, Sendable {
        let time: Date
        let data: ForecastData
    }

    struct ForecastData: Decodable, Sendable {
        let instant: Instant
        let next1Hours: Period?
        let next6Hours: Period?
        let next12Hours: Period?
    }

    struct Instant: Decodable, Sendable {
        let details: InstantDetails
    }

    struct InstantDetails: Decodable, Sendable {
        let airTemperature: Double
    }

    struct Period: Decodable, Sendable {
        let summary: Summary
    }

    struct Summary: Decodable, Sendable {
        let symbolCode: String
    }
}
