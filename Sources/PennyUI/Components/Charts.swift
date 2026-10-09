#if os(iOS)
import PennyCore
import SwiftUI

/// September to date (white) against August (dashed) and the budget-pace line, on the Home hero.
/// Uses PennyCore's geometry at the view's real size, so the curve matches the web chart exactly.
struct SpendChartView: View {
    let household: Household
    var height: CGFloat = 80

    var body: some View {
        Canvas { context, size in
            let chart = SpendChartGeometry(household: household, width: size.width, height: size.height)
            context.stroke(
                Path(chart.paceLine), with: .color(.white.opacity(0.28)),
                style: StrokeStyle(lineWidth: 1.4, dash: [2, 4])
            )
            context.stroke(
                Path(chart.lastMonthLine), with: .color(.white.opacity(0.38)),
                style: StrokeStyle(lineWidth: 1.6, dash: [4, 4])
            )
            context.fill(
                Path(chart.thisMonthArea),
                with: .linearGradient(
                    Gradient(colors: [.white.opacity(0.28), .white.opacity(0)]),
                    startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)
                )
            )
            context.stroke(Path(chart.thisMonthLine), with: .color(.white), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
            if let end = chart.thisMonth.last {
                let dot = Path(ellipseIn: CGRect(x: end.x - 4.5, y: end.y - 4.5, width: 9, height: 9))
                context.fill(dot, with: .color(.white))
                context.stroke(dot, with: .color(Theme.violet), lineWidth: 2)
            }
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityLabel("Spending this month compared with last month and the budget pace")
    }
}

/// Net worth history as a filled violet line with an end marker.
struct NetWorthChartView: View {
    let history: [Money]
    var height: CGFloat = 120

    var body: some View {
        Canvas { context, size in
            let chart = NetWorthChartGeometry(history: history, width: size.width, height: size.height)
            context.fill(
                Path(chart.area),
                with: .linearGradient(
                    Gradient(colors: [Theme.violet.opacity(0.32), Theme.violet.opacity(0)]),
                    startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)
                )
            )
            context.stroke(Path(chart.line), with: .color(Theme.violet), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
            if let end = chart.points.last {
                let dot = Path(ellipseIn: CGRect(x: end.x - 4.5, y: end.y - 4.5, width: 9, height: 9))
                context.fill(dot, with: .color(Theme.violet))
                context.stroke(dot, with: .color(.white), lineWidth: 2)
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.25), value: history)
        .accessibilityElement()
        .accessibilityLabel("Net worth over time")
        .accessibilityValue(history.last.map { MoneyFormat.money($0, decimals: 0) } ?? "")
    }
}
#endif
