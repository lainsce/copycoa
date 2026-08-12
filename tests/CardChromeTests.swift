import CoreGraphics
import Testing
@testable import Copycoa

struct CardChromeTests {
    @Test
    func usesOneCanonicalSurfaceTreatment() {
        #expect(CardChromeMetrics.outlineOpacity == 0.06)
        #expect(CardChromeMetrics.outlineWidth == 1)
        #expect(CardChromeMetrics.innerHighlightStartOpacity == 0.22)
        #expect(CardChromeMetrics.innerHighlightEndOpacity == 0)
        #expect(CardChromeMetrics.innerHighlightWidth == 1)
        #expect(CardChromeMetrics.innerHighlightInset == 1)
        #expect(CardChromeMetrics.shadowOpacity == 0.03)
        #expect(CardChromeMetrics.shadowRadius == 3)
        #expect(CardChromeMetrics.shadowYOffset == 2)
        #expect(CardChromeMetrics.previewCornerRadius == 10)
    }
}
