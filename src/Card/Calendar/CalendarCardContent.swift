import Foundation
import SwiftUI

/// The three ways a calendar card can describe a date.
nonisolated enum CalendarDateKind: String, Codable, CaseIterable, Identifiable {
    case dateRange
    case singleDate
    case recurring

    var id: String { rawValue }

    var displayName: LocalizedStringResource {
        switch self {
        case .dateRange: "Date Range"
        case .singleDate: "Single Date"
        case .recurring: "Recurring"
        }
    }

    var systemImage: String {
        switch self {
        case .dateRange: "calendar.badge.clock"
        case .singleDate: "calendar"
        case .recurring: "repeat"
        }
    }
}

/// Keeps emoji entry ordered while limiting a calendar card to its three sticker positions.
nonisolated func calendarStickerValues(from input: String) -> [String] {
    input
        .filter { !$0.isWhitespace && !$0.isNewline }
        .map(String.init)
        .prefix(3)
        .map { $0 }
}

/// Calendar artwork is authored at the 1×1 footprint (160 points). Larger cards use the same
/// composition and scale it from the shortest available edge, so a 2×1 card stays as legible
/// as the baseline while a 2×2 card gets the extra breathing room shown in the reference.
private struct CalendarCardMetrics {
    let size: CGSize
    let scale: CGFloat

    init(size: CGSize) {
        self.size = size
        scale = max(0.1, min(size.width / 160, size.height / 160))
    }

    func scaled(_ value: CGFloat) -> CGFloat {
        value * scale
    }

    var padding: CGFloat { CanvasMetrics.cardContentInset }
    var sectionSpacing: CGFloat { scaled(6) }
    var labelFont: CGFloat { scaled(14) }
    var dateRangeDayFont: CGFloat { scaled(38) }
    var singleDateDayFont: CGFloat { scaled(42) }
    var yearFont: CGFloat { scaled(12) }
    var eventTitleFont: CGFloat { scaled(10) }
    var recurringWeekdayFont: CGFloat { scaled(30) }
    var recurringLabelFont: CGFloat { scaled(14) }
    var timelineFont: CGFloat { scaled(9) }
    var timelineLabelWidth: CGFloat { scaled(44) }
    var timelineSpacing: CGFloat { scaled(5) }
    var timelineEventHeight: CGFloat { scaled(24) }
    var timelineStroke: CGFloat { max(1, scaled(1.5)) }
    var stickerFont: CGFloat { scaled(24) }
    var stickerPadding: CGFloat { CanvasMetrics.cardContentInset }
    var gridColumns: Int { size.width >= 280 ? 7 : 6 }
    var gridRows: Int { size.height >= 280 ? 5 : 4 }
    var gridCell: CGFloat { scaled(11) }
    var gridSpacing: CGFloat { scaled(3) }
    var gridIdealHeight: CGFloat {
        CGFloat(gridRows) * gridCell * 1.35
            + CGFloat(max(0, gridRows - 1)) * gridSpacing
    }
}

/// A compact event card inspired by the supplied Calendar reference: bold date hierarchy,
/// a lightweight time rail, and an optional emoji sticker layered over the surface.
struct CalendarCardContent: View {
    @Bindable var card: Card
    @Environment(\.locale) private var locale

    var body: some View {
        GeometryReader { proxy in
            let metrics = CalendarCardMetrics(size: proxy.size)

            ZStack(alignment: .topLeading) {
                content(metrics: metrics)
                sticker(metrics: metrics)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(surface)
        .clipShape(.rect(cornerRadius: card.cardSize.cornerRadius))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func content(metrics: CalendarCardMetrics) -> some View {
        switch card.calendarDateKind {
        case .dateRange:
            dateRange(metrics: metrics)
        case .singleDate:
            singleDate(metrics: metrics)
        case .recurring:
            recurring(metrics: metrics)
        }
    }

    private func dateRange(metrics: CalendarCardMetrics) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(monthText(card.calendarStartDateValue))
                    .foregroundStyle(.red)
                Spacer(minLength: metrics.sectionSpacing)
                Text("\(rangeDays)d")
                    .foregroundStyle(.secondary)
                Spacer(minLength: metrics.sectionSpacing)
                Text(monthText(card.calendarEndDateValue))
                    .foregroundStyle(.red)
            }
            .font(.system(size: metrics.labelFont, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            HStack(alignment: .firstTextBaseline) {
                Text(dayText(card.calendarStartDateValue))
                Spacer(minLength: metrics.sectionSpacing)
                Image(systemName: "arrow.right")
                    .font(.system(size: metrics.scaled(13), weight: .bold))
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)
                Spacer(minLength: metrics.sectionSpacing)
                Text(dayText(card.calendarEndDateValue))
            }
            .font(.system(size: metrics.dateRangeDayFont, weight: .black, design: .rounded))
            .foregroundStyle(.primary)

            Spacer(minLength: metrics.sectionSpacing)

            CalendarTimeline(
                date: card.calendarStartDateValue,
                eventTitle: card.calendarEventTitleValue,
                eventTitleBelowActiveLine: true,
                metrics: metrics
            )
        }
        .padding(metrics.padding)
    }

    private func singleDate(metrics: CalendarCardMetrics) -> some View {
        VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
            HStack(alignment: .firstTextBaseline, spacing: metrics.sectionSpacing) {
                Text(monthOnlyText(card.calendarStartDateValue))
                    .foregroundStyle(.red)
                Text(shortWeekdayText(card.calendarStartDateValue))
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: metrics.labelFont, weight: .bold, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            VStack(alignment: .leading, spacing: 0) {
                Text(dayText(card.calendarStartDateValue))
                    .font(.system(size: metrics.singleDateDayFont, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)


                HStack {
                    if let year = yearText(card.calendarStartDateValue) {
                        Text(verbatim: year)
                            .font(.system(size: metrics.yearFont, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: metrics.sectionSpacing)
                    let eventTitle = card.calendarEventTitleValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !eventTitle.isEmpty {
                        Text(verbatim: eventTitle)
                            .font(.system(size: metrics.eventTitleFont, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .minimumScaleFactor(0.7)
                    }
                }
            }

            GeometryReader { proxy in
                let gridScale = min(
                    1,
                    max(0.1, proxy.size.height / max(1, metrics.gridIdealHeight))
                )

                MonthDotGrid(
                    date: card.calendarStartDateValue,
                    calendar: calendar,
                    metrics: metrics,
                    scale: gridScale
                )
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    alignment: .topLeading
                )
            }
            .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .padding(metrics.padding)
    }

    private func recurring(metrics: CalendarCardMetrics) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Every")
                .font(.system(size: metrics.labelFont, weight: .bold, design: .rounded))
                .foregroundStyle(.red)

            Text(weekdayText(card.calendarStartDateValue))
                .font(.system(size: metrics.recurringWeekdayFont, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(card.calendarRecurrenceLabelValue)
                .font(.system(size: metrics.recurringLabelFont, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)

            Spacer(minLength: metrics.sectionSpacing)

            CalendarTimeline(
                date: card.calendarStartDateValue,
                eventTitle: card.calendarEventTitleValue,
                metrics: metrics
            )
        }
        .padding(metrics.padding)
    }

    @ViewBuilder
    private func sticker(metrics: CalendarCardMetrics) -> some View {
        ForEach(Array(calendarStickerValues(from: card.calendarEmojiValue).enumerated()), id: \.offset) { index, value in
            stickerView(value, index: index, metrics: metrics)
        }
    }

    @ViewBuilder
    private func stickerView(
        _ value: String,
        index: Int,
        metrics: CalendarCardMetrics
    ) -> some View {
        let base = Text(verbatim: value)
            .font(.system(size: metrics.stickerFont))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .allowsHitTesting(false)
            .accessibilityLabel(Text("Sticker \(value)"))

        switch index {
        case 0:
            base
                .rotationEffect(.degrees(-8))
                .padding(metrics.stickerPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: firstStickerAlignment)
        case 1:
            base
                .rotationEffect(.degrees(8))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .offset(secondStickerOffset(metrics: metrics))
        default:
            base
                .rotationEffect(.degrees(-6))
                .padding(metrics.stickerPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(thirdStickerOffset(metrics: metrics))
        }
    }

    private var firstStickerAlignment: Alignment {
        switch card.calendarDateKind {
        case .dateRange: .bottomTrailing
        case .singleDate, .recurring: .topTrailing
        }
    }

    private func secondStickerOffset(metrics: CalendarCardMetrics) -> CGSize {
        switch card.calendarDateKind {
        case .dateRange:
            CGSize(
                width: metrics.padding + metrics.dateRangeDayFont * 0.86,
                height: metrics.padding + metrics.labelFont + metrics.sectionSpacing * 0.35
            )
        case .singleDate:
            CGSize(
                width: metrics.padding + metrics.singleDateDayFont * 0.84,
                height: metrics.padding + metrics.labelFont + metrics.sectionSpacing + metrics.singleDateDayFont * 0.10
            )
        case .recurring:
            CGSize(
                width: metrics.padding + metrics.recurringWeekdayFont * 0.84,
                height: metrics.padding + metrics.labelFont + metrics.recurringWeekdayFont * 0.10
            )
        }
    }

    private func thirdStickerOffset(metrics: CalendarCardMetrics) -> CGSize {
        guard card.calendarDateKind == .dateRange else { return .zero }
        return CGSize(width: -metrics.scaled(24), height: -metrics.scaled(10))
    }

    private var surface: some ShapeStyle {
        LinearGradient(
            colors: [
                .red.opacity(0.08),
                Color(nsColor: .textBackgroundColor),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var calendar: Foundation.Calendar {
        var value = Foundation.Calendar(identifier: .gregorian)
        value.locale = locale
        value.timeZone = .current
        return value
    }

    private var rangeDays: Int {
        let components = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: card.calendarStartDateValue),
            to: calendar.startOfDay(for: card.calendarEndDateValue)
        )
        return max(1, abs(components.day ?? 1))
    }

    private func monthText(_ date: Date) -> String {
        let month = date.formatted(.dateTime.month(.abbreviated))
        guard !calendar.isDate(date, equalTo: .now, toGranularity: .year) else {
            return month
        }

        return date.formatted(.dateTime.month(.abbreviated).year())
    }

    private func monthOnlyText(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated))
    }

    private func yearText(_ date: Date) -> String? {
        guard !calendar.isDate(date, equalTo: .now, toGranularity: .year) else {
            return nil
        }

        return date.formatted(.dateTime.year())
    }

    private func dayText(_ date: Date) -> String {
        date.formatted(.dateTime.day())
    }

    private func weekdayText(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide))
    }

    private func shortWeekdayText(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }
}

private struct MonthDotGrid: View {
    let date: Date
    let calendar: Foundation.Calendar
    let metrics: CalendarCardMetrics
    let scale: CGFloat

    private var cellSize: CGFloat { metrics.gridCell * scale }
    private var rowHeight: CGFloat { cellSize * 1.35 }
    private var spacing: CGFloat { metrics.gridSpacing * scale }

    private var days: [Int?] {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return []
        }

        let leading = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7
        let values = Array(repeating: Optional<Int>.none, count: leading)
            + range.map(Optional.some)
        let capacity = metrics.gridColumns * metrics.gridRows
        var compactValues = Array(values.prefix(capacity))
        let selectedDay = calendar.component(.day, from: date)
        if !compactValues.contains(selectedDay), !compactValues.isEmpty {
            compactValues[compactValues.count - 1] = selectedDay
        }
        return compactValues
    }

    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: spacing),
                count: metrics.gridColumns
            ),
            spacing: spacing
        ) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                dayCell(day)
            }
        }
    }

    @ViewBuilder
    private func dayCell(_ day: Int?) -> some View {
        if let day {
            if day == calendar.component(.day, from: date) {
                ZStack {
                    Circle()
                        .strokeBorder(.red, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    Text(verbatim: "\(day)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .fixedSize()
                }
                .frame(width: rowHeight, height: rowHeight)
            } else {
                Circle()
                    .fill(.secondary.opacity(0.14))
                    .frame(width: cellSize, height: cellSize)
                    .frame(width: rowHeight, height: rowHeight)
            }
        } else {
            Color.clear
                .frame(width: rowHeight, height: rowHeight)
        }
    }
}

private struct CalendarTimeline: View {
    let date: Date
    var eventTitle: String?
    var eventTitleBelowActiveLine = false
    let metrics: CalendarCardMetrics

    var body: some View {
        VStack(spacing: metrics.timelineSpacing) {
            timelineRow(date: date.addingTimeInterval(-60 * 60), isActive: false)
            timelineRow(date: date, isActive: true)
            timelineRow(date: date.addingTimeInterval(60 * 60), isActive: false)
        }
    }

    @ViewBuilder
    private func timelineRow(date: Date, isActive: Bool) -> some View {
        HStack(alignment: .center, spacing: metrics.sectionSpacing) {
            Text(date.formatted(date: .omitted, time: .shortened))
                .font(.system(
                    size: metrics.timelineFont,
                    weight: isActive ? .bold : .regular,
                    design: .rounded
                ))
                .foregroundStyle(isActive ? Color.primary : Color.secondary.opacity(0.45))
                .frame(width: metrics.timelineLabelWidth, alignment: .leading)

            if let eventTitle, isActive, eventTitleBelowActiveLine {
                VStack(alignment: .leading, spacing: metrics.scaled(2)) {
                    timelineLine(isActive: true)

                    Text(verbatim: eventTitle)
                        .font(.system(size: metrics.timelineFont, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if let eventTitle, isActive {
                RoundedRectangle(cornerRadius: metrics.scaled(6), style: .continuous)
                    .stroke(.secondary.opacity(0.3), lineWidth: metrics.timelineStroke)
                    .frame(height: metrics.timelineEventHeight)
                    .overlay {
                            Text(verbatim: eventTitle)
                            .font(.system(size: metrics.timelineFont, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, metrics.sectionSpacing)
                    }
            } else {
                timelineLine(isActive: isActive)
            }
        }
    }

    private func timelineLine(isActive: Bool) -> some View {
        Rectangle()
            .fill(isActive ? .red : .secondary.opacity(0.22))
            .frame(height: isActive ? metrics.timelineStroke : max(1, metrics.scaled(1)))
            .overlay(alignment: .leading) {
                if isActive {
                    Image(systemName: "play.fill")
                        .font(.system(size: metrics.scaled(7), weight: .bold))
                        .foregroundStyle(.red)
                        .offset(x: -2)
                }
            }
    }
}
