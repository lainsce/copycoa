import Foundation

extension CardKind {
    /// The footprint a freshly created card of this kind starts at.
    var defaultCardSize: CardSize {
        switch self {
        case .header: .fourByOne
        case .stickyNote: .oneByOne
        case .image: .twoByTwo
        case .link: .twoByOne
        case .map: .twoByTwo
        // Calendar artwork is authored at the 1×1 footprint and scales with the selected size.
        case .calendar: .oneByOne
        case .timeZone: .oneByOne
        case .weather: .oneByOne
        case .progress: .oneByOne
        case .checklist: .oneByOne
        case .quote: .twoByOne
        case .palette: .oneByOne
        }
    }
}
