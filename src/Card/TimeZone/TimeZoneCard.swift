import CoreLocation
import MapKit
import SwiftUI

/// A curated set of time zones with a representative coordinate for the map treatment.
/// Keeping the coordinate with the IANA identifier makes the card deterministic and avoids
/// trying to infer geography from a time-zone name at render time.
nonisolated struct TimeZoneCardPreset: Identifiable, Sendable {
    let identifier: String
    let city: String
    let latitude: Double
    let longitude: Double

    var id: String { identifier }

    var timeZone: Foundation.TimeZone {
        Foundation.TimeZone(identifier: identifier) ?? .gmt
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let all: [Self] = [
        Self(identifier: "America/Los_Angeles", city: "Los Angeles", latitude: 34.0522, longitude: -118.2437),
        Self(identifier: "America/New_York", city: "New York", latitude: 40.7128, longitude: -74.0060),
        Self(identifier: "America/Sao_Paulo", city: "São Paulo", latitude: -23.5505, longitude: -46.6333),
        Self(identifier: "Europe/London", city: "London", latitude: 51.5072, longitude: -0.1276),
        Self(identifier: "Europe/Rome", city: "Rome", latitude: 41.9028, longitude: 12.4964),
        Self(identifier: "Europe/Berlin", city: "Berlin", latitude: 52.5200, longitude: 13.4050),
        Self(identifier: "Africa/Cairo", city: "Cairo", latitude: 30.0444, longitude: 31.2357),
        Self(identifier: "Asia/Kolkata", city: "Mumbai", latitude: 19.0760, longitude: 72.8777),
        Self(identifier: "Asia/Tokyo", city: "Tokyo", latitude: 35.6762, longitude: 139.6503),
        Self(identifier: "Australia/Sydney", city: "Sydney", latitude: -33.8688, longitude: 151.2093),
    ]

    static let defaultPreset = all.first(where: { $0.identifier == "Asia/Tokyo" })!

    static func preset(for identifier: String?) -> Self {
        guard let identifier,
              let preset = all.first(where: { $0.identifier == identifier }) else {
            return defaultPreset
        }
        return preset
    }

}

/// Pure time-zone display calculations kept separate from the SwiftUI rendering layer.
nonisolated enum TimeZoneCardLogic {
    static func isDaytime(at date: Date, in timeZone: Foundation.TimeZone) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let hour = calendar.component(.hour, from: date)
        return (6..<18).contains(hour)
    }

    static func offsetText(at date: Date, in timeZone: Foundation.TimeZone) -> String {
        let seconds = timeZone.secondsFromGMT(for: date)
        let sign = seconds < 0 ? "−" : "+"
        let absoluteSeconds = abs(seconds)
        let hours = absoluteSeconds / 3_600
        let minutes = (absoluteSeconds % 3_600) / 60
        let minuteText = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        return "\(sign)\(hours):\(minuteText)"
    }
}

private struct TimeZoneCardMetrics {
    let scale: CGFloat

    init(size: CGSize) {
        scale = max(0.1, min(size.width / 704, size.height / 704))
    }

    func scaled(_ value: CGFloat) -> CGFloat {
        value * scale
    }

    var padding: CGFloat { max(16, scaled(80)) }
    var titleFont: CGFloat { max(15, scaled(56)) }
    var zoneFont: CGFloat { max(18, scaled(50)) }
    var offsetFont: CGFloat { max(30, scaled(88)) }
    var zoneSpacing: CGFloat { -max(1, scaled(4)) }
    var locationCircleDiameter: CGFloat { max(40, scaled(190)) }
}

/// A compact, map-backed time-zone card whose palette follows local daylight at the selected
/// region. The reference composition is authored at the 1×1 footprint and scales from there.
struct TimeZoneCardContent: View {
    @Bindable var card: Card

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let preset = TimeZoneCardPreset.preset(for: card.timeZoneIdentifier)
            let isDaytime = TimeZoneCardLogic.isDaytime(at: context.date, in: preset.timeZone)
            let offset = TimeZoneCardLogic.offsetText(at: context.date, in: preset.timeZone)

            GeometryReader { proxy in
                let metrics = TimeZoneCardMetrics(size: proxy.size)

                ZStack(alignment: .topLeading) {
                    mapSurface(
                        preset: preset,
                        isDaytime: isDaytime,
                        circleDiameter: metrics.locationCircleDiameter
                    )

                    LinearGradient(
                        colors: isDaytime
                            ? [.white.opacity(0.18), .clear, .black.opacity(0.06)]
                            : [.black.opacity(0.26), .clear, .black.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Time Zone")
                            .font(.system(size: metrics.titleFont, weight: .semibold, design: .rounded))

                        Spacer(minLength: 0)

                        VStack(alignment: .leading, spacing: metrics.zoneSpacing) {
                            Text("GMT")
                                .font(.system(size: metrics.zoneFont, weight: .regular, design: .rounded))
                                .foregroundStyle(isDaytime ? .black.opacity(0.48) : .white.opacity(0.68))
                            Text(offset)
                                .font(.system(size: metrics.offsetFont, weight: .medium, design: .rounded))
                        }
                    }
                    .foregroundStyle(isDaytime ? .black : .white)
                    .padding(.horizontal, metrics.padding)
                    .padding(.vertical, metrics.padding)
                }
                .clipShape(.rect(cornerRadius: card.cardSize.cornerRadius))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Time Zone"))
            .accessibilityValue(Text(verbatim: "\(preset.city), GMT \(offset)"))
        }
    }

    @ViewBuilder
    private func mapSurface(
        preset: TimeZoneCardPreset,
        isDaytime: Bool,
        circleDiameter: CGFloat
    ) -> some View {
        Map(
            position: .constant(.region(mapRegion(for: preset))),
            interactionModes: []
        ) {
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll))
        .environment(\.colorScheme, isDaytime ? .light : .dark)
        .saturation(0)
        .contrast(isDaytime ? 0.9 : 1.15)
        .brightness(isDaytime ? 0.08 : -0.16)
        .overlay {
            Circle()
                .fill(isDaytime ? .black.opacity(0.08) : .white.opacity(0.10))
                .overlay {
                    Circle()
                        .stroke(
                            isDaytime ? .black.opacity(0.48) : .white.opacity(0.52),
                            lineWidth: 1
                        )
                }
                .frame(width: circleDiameter, height: circleDiameter)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func mapRegion(for preset: TimeZoneCardPreset) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: preset.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 24, longitudeDelta: 28)
        )
    }
}
