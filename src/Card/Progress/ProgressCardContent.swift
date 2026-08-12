import Foundation
import SwiftUI

nonisolated enum ProgressCardDefaults {
    static let dotColorHex = "7B4B2A"
    static let backgroundColorHex = "F3EDE7"
}

/// Date math for Progress cards is kept separate from the view so the same rules can be
/// exercised by tests and used by CanvasView's accessibility summary.
nonisolated enum ProgressCardLogic {
    static func totalDays(
        start: Date,
        goal: Date,
        calendar: Calendar = .current
    ) -> Int {
        let startDay = calendar.startOfDay(for: start)
        let goalDay = max(startDay, calendar.startOfDay(for: goal))
        let difference = calendar.dateComponents([.day], from: startDay, to: goalDay).day ?? 0
        return max(1, difference)
    }

    static func completedDays(
        start: Date,
        goal: Date,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let startDay = calendar.startOfDay(for: start)
        let total = totalDays(start: start, goal: goal, calendar: calendar)
        let elapsed = calendar.dateComponents(
            [.day],
            from: startDay,
            to: calendar.startOfDay(for: now)
        ).day ?? 0
        return min(total, max(0, elapsed))
    }
}

struct ProgressCardContent: View {
    @Bindable var card: Card
    @Environment(\.locale) private var locale

    var body: some View {
        GeometryReader { proxy in
            let metrics = ProgressCardMetrics(size: proxy.size)
            let calendar = currentCalendar
            let total = ProgressCardLogic.totalDays(
                start: card.progressStartDateValue,
                goal: card.progressGoalDateValue,
                calendar: calendar
            )
            let completed = ProgressCardLogic.completedDays(
                start: card.progressStartDateValue,
                goal: card.progressGoalDateValue,
                calendar: calendar
            )

            VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                ProgressCardHeader(
                    title: card.progressTitleValue,
                    goalDate: card.progressGoalDateValue,
                    metrics: metrics
                )

                Spacer(minLength: metrics.sectionSpacing)

                ProgressDotGrid(
                    totalDots: total,
                    completedDots: completed,
                    columns: metrics.columns,
                    dotSize: metrics.dotSize(totalDots: total),
                    spacing: metrics.dotSpacing,
                    dotColor: Color(hex: card.progressDotColorHexValue)
                )

                HStack(spacing: metrics.sectionSpacing) {
                    Text("\(completed) of \(total) days")
                        .font(.system(size: metrics.footerFont, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary.opacity(0.56))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                }
            }
            .padding(metrics.inset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background {
            RoundedRectangle(cornerRadius: card.cardSize.cornerRadius, style: .continuous)
                .fill(Color(hex: card.progressBackgroundColorHexValue))
        }
        .clipShape(.rect(cornerRadius: card.cardSize.cornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Progress"))
        .accessibilityValue(Text(accessibilityValue))
    }

    private var currentCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.timeZone = .current
        return calendar
    }

    private var accessibilityValue: String {
        let total = ProgressCardLogic.totalDays(
            start: card.progressStartDateValue,
            goal: card.progressGoalDateValue,
            calendar: currentCalendar
        )
        let completed = ProgressCardLogic.completedDays(
            start: card.progressStartDateValue,
            goal: card.progressGoalDateValue,
            calendar: currentCalendar
        )
        return "\(card.progressTitleValue), \(completed) of \(total) days"
    }
}

private struct ProgressCardMetrics {
    let size: CGSize

    var scale: CGFloat {
        max(0.75, min(size.width / CanvasMetrics.cell, size.height / CanvasMetrics.cell))
    }

    var inset: CGFloat { CanvasMetrics.cardContentInset }
    var sectionSpacing: CGFloat { max(6, 8 * scale) }
    var titleFont: CGFloat { max(13, 16 * scale) }
    var goalFont: CGFloat { max(9, 11 * scale) }
    var footerFont: CGFloat { max(8, 10 * scale) }
    var dotSpacing: CGFloat { max(4, min(10, 6 * scale)) }
    var columns: Int { size.width >= CanvasMetrics.footprintSize(columns: 2, rows: 1).width ? 10 : 6 }

    func dotSize(totalDots: Int) -> CGFloat {
        let rowCount = max(1, Int(ceil(Double(totalDots) / Double(columns))))
        let availableHeight = max(
            18,
            size.height - inset * 2 - titleFont - goalFont - footerFont - sectionSpacing * 3
        )
        let candidate = (availableHeight - CGFloat(max(0, rowCount - 1)) * dotSpacing)
            / CGFloat(rowCount)
        return max(4, min(12 * scale, candidate))
    }
}

private struct ProgressCardHeader: View {
    let title: String
    let goalDate: Date
    let metrics: ProgressCardMetrics

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: metrics.sectionSpacing) {
            Text(verbatim: title)
                .font(.system(size: metrics.titleFont, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: metrics.sectionSpacing)

            Text(goalDate, format: .dateTime.month(.abbreviated).day())
                .font(.system(size: metrics.goalFont, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.56))
                .lineLimit(1)
        }
    }
}

private struct ProgressDotGrid: View {
    let totalDots: Int
    let completedDots: Int
    let columns: Int
    let dotSize: CGFloat
    let spacing: CGFloat
    let dotColor: Color

    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: spacing),
                count: columns
            ),
            spacing: spacing
        ) {
            ForEach(0..<totalDots, id: \.self) { index in
                Circle()
                    .fill(index < completedDots ? dotColor : dotColor.opacity(0.18))
                    .frame(width: dotSize, height: dotSize)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
        }
    }
}
