import Foundation

/// The kinds of cards a user can place on a board.
nonisolated enum CardKind: String, Codable, CaseIterable, Identifiable {
    case header
    case stickyNote
    case image
    case link
    case map
    case calendar
    case timeZone
    case weather
    case progress
    case checklist
    case quote
    case palette

    var id: String { rawValue }
}
