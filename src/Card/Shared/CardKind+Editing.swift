import Foundation

extension CardKind {
    var editActionName: LocalizedStringResource {
        switch self {
        case .header: "Edit Header"
        case .stickyNote: "Edit Note"
        case .image: "Edit Caption"
        case .link: "Edit Link"
        case .map: "Edit Location"
        case .calendar: "Edit Calendar"
        case .timeZone: "Edit Time Zone"
        case .weather: "Edit Weather"
        case .progress: "Edit Progress"
        case .checklist: "Edit Checklist"
        case .quote: "Edit Quote"
        case .palette: "Edit Palette"
        }
    }
}
