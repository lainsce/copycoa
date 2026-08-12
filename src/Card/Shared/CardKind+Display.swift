import Foundation

extension CardKind {
    var displayName: LocalizedStringResource {
        switch self {
        case .header: "Header"
        case .stickyNote: "Note"
        case .image: "Image"
        case .link: "Link"
        case .map: "Location"
        case .calendar: "Calendar"
        case .timeZone: "Timezone"
        case .weather: "Weather"
        case .progress: "Progress"
        case .checklist: "Checklist"
        case .quote: "Quote"
        case .palette: "Palette"
        }
    }

    var systemImage: String {
        switch self {
        case .header: "textformat.size.larger"
        case .stickyNote: "note.text"
        case .image: "photo"
        case .link: "link"
        case .map: "mappin.and.ellipse"
        case .calendar: "calendar.badge.clock"
        case .timeZone: "globe"
        case .weather: "cloud.sun.fill"
        case .progress: "chart.bar.xaxis"
        case .checklist: "checklist"
        case .quote: "quote.bubble"
        case .palette: "paintpalette"
        }
    }
}
