import Foundation
import SwiftData

/// A board is a fixed-width, vertically scrolling canvas holding a collection of cards.
@Model
final class Board {
    var id: UUID
    var name: String
    var createdAt: Date
    /// Legacy offsets retained so existing SwiftData stores can migrate without losing the
    /// board record. CanvasView no longer reads or writes them; scrolling is vertical-only.
    var panX: Double
    var panY: Double

    @Relationship(deleteRule: .cascade, inverse: \Card.board)
    var cards: [Card]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = .now
        self.panX = 0
        self.panY = 0
        self.cards = []
    }
}

