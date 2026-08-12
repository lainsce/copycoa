import Foundation

/// Produces short, warm editorial copy from objective forecast values.
nonisolated enum WeatherSummaryGenerator {
    static var referenceSummary: String {
        summary(temperatureCelsius: 1, condition: .partlyCloudy, isDaylight: true)
    }

    static func summary(
        temperatureCelsius: Double,
        condition: WeatherCondition,
        isDaylight: Bool
    ) -> String {
        [
            temperatureSentence(for: temperatureCelsius),
            conditionSentence(
                for: condition,
                temperatureCelsius: temperatureCelsius,
                isDaylight: isDaylight
            )
        ]
        .joined(separator: " ")
    }

    private static func temperatureSentence(for temperature: Double) -> String {
        switch temperature {
        case ...(-15):
            String(localized: "The cold is taking this personally.")
        case ...0:
            String(localized: "Properly freezing out there.")
        case ...8:
            String(localized: "Still cold out there.")
        case ...15:
            String(localized: "A little crisp out there.")
        case ...22:
            String(localized: "Nicely mild out there.")
        case ...29:
            String(localized: "Warm one out there.")
        case ...35:
            String(localized: "Hot out there.")
        default:
            String(localized: "The heat has entered the chat.")
        }
    }

    private static func conditionSentence(
        for condition: WeatherCondition,
        temperatureCelsius: Double,
        isDaylight: Bool
    ) -> String {
        switch condition {
        case .clear:
            if isDaylight {
                if temperatureCelsius <= 0 {
                    String(localized: "Clear skies, chilly intentions.")
                } else if temperatureCelsius >= 30 {
                    String(localized: "The sun is doing overtime.")
                } else {
                    String(localized: "The sun has no notes.")
                }
            } else {
                if temperatureCelsius <= 0 {
                    String(localized: "Clear skies, cold night.")
                } else {
                    String(localized: "The sky kept things simple tonight.")
                }
            }
        case .partlyCloudy:
            if isDaylight {
                if temperatureCelsius <= 8 {
                    String(localized: "The clouds are sharing what little sun there is.")
                } else if temperatureCelsius >= 29 {
                    String(localized: "A little shade is doing the heavy lifting.")
                } else {
                    String(localized: "Great day for ice cream.")
                }
            } else {
                if temperatureCelsius >= 20 {
                    String(localized: "A soft night with a little cloud cover.")
                } else {
                    String(localized: "The clouds left room for stars.")
                }
            }
        case .cloudy:
            isDaylight
                ? String(localized: "The clouds have committed to the bit.")
                : String(localized: "The clouds are keeping the stars to themselves.")
        case .rain:
            if isDaylight {
                if temperatureCelsius <= 8 {
                    String(localized: "Cold rain: the least glamorous forecast.")
                } else if temperatureCelsius >= 22 {
                    String(localized: "Warm rain is making an appearance.")
                } else {
                    String(localized: "Bring the umbrella that behaves.")
                }
            } else {
                if temperatureCelsius <= 8 {
                    String(localized: "Cold rain is taking the night shift.")
                } else {
                    String(localized: "The rain has taken the night shift.")
                }
            }
        case .storm:
            isDaylight
                ? String(localized: "The sky is being dramatic.")
                : String(localized: "The night sky is putting on a show.")
        case .snow:
            isDaylight
                ? String(localized: "Everything outside is becoming a snow globe.")
                : String(localized: "Snow is making the night cinematic.")
        case .fog:
            isDaylight
                ? String(localized: "The horizon has gone incognito.")
                : String(localized: "The world is in soft focus tonight.")
        }
    }
}
