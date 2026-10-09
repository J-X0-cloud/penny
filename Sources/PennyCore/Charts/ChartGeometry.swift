/// Geometry for Penny's hand-drawn charts. Pure functions, shared by the SVG renderer on the web and
/// the SwiftUI charts on iPhone, so both draw exactly the same curve.
public enum ChartGeometry {
    /// Maps values onto a `width` × `height` box with `max` at the top.
    ///
    /// - Parameters:
    ///   - slots: Number of x positions; defaults to `values.count`. Lets a partial month sit on a
    ///     full-month axis.
    ///   - min: Value at the bottom of the box.
    ///   - padTop, padBottom: Vertical breathing room so strokes are not clipped.
    ///   - roundToTenths: Rounds coordinates to 0.1, which keeps SVG output compact.
    public static func points(
        _ values: [Double], width: Double, height: Double, max: Double, slots: Int? = nil,
        min: Double = 0, padTop: Double = 4, padBottom: Double = 4, roundToTenths: Bool = true
    ) -> [Point] {
        let slotCount = slots ?? values.count
        guard slotCount > 1, max != min else {
            return values.map { _ in Point(0, height / 2) }
        }
        let step = width / Double(slotCount - 1)
        let usable = height - padTop - padBottom
        return values.enumerated().map { index, value in
            let x = Double(index) * step
            let y = padTop + usable * (1 - (value - min) / (max - min))
            return roundToTenths ? Point(tenths(x), tenths(y)) : Point(x, y)
        }
    }

    /// Horizontal-tangent cubic smoothing: reads as a calm line without overshooting the data.
    public static func smoothPath(_ points: [Point], roundToTenths: Bool = true) -> VectorPath {
        guard let first = points.first else { return VectorPath() }
        var path = VectorPath()
        path.move(to: first)
        var previous = first
        for point in points.dropFirst() {
            let midX = (previous.x + point.x) / 2
            let controlX = roundToTenths ? tenths(midX) : midX
            path.curve(to: point, control1: Point(controlX, previous.y), control2: Point(controlX, point.y))
            previous = point
        }
        return path
    }

    /// The smoothed line closed down to the baseline, for gradient fills. `closeAtX` extends the fill
    /// to a fixed right edge (used when the line spans the full width).
    public static func areaPath(_ points: [Point], height: Double, closeAtX: Double? = nil, roundToTenths: Bool = true) -> VectorPath {
        guard let last = points.last else { return VectorPath() }
        var path = smoothPath(points, roundToTenths: roundToTenths)
        path.line(to: Point(closeAtX ?? last.x, height))
        path.line(to: Point(0, height))
        path.close()
        return path
    }

    /// Straight two-point segment, for the budget-pace line.
    public static func straightPath(from start: Point, to end: Point) -> VectorPath {
        VectorPath(commands: [.move(to: start), .line(to: end)])
    }

    /// Position of the end-of-line marker as fractions of the box (0...1 on each axis), for an
    /// absolutely-positioned dot that stays round when the chart stretches.
    public static func endMarker(_ points: [Point], width: Double, height: Double) -> Point {
        let last = points.last ?? .zero
        return Point(last.x / width, last.y / height)
    }

    /// Small trend line used in the dashboard KPIs, scaled to its own range with 10% headroom.
    public static func sparkline(_ values: [Double], width: Double = 80, height: Double = 26) -> VectorPath {
        guard let low = values.min(), let high = values.max() else { return VectorPath() }
        let pad = (high - low) * 0.1
        return smoothPath(points(values, width: width, height: height, max: high + pad + 0.01, min: low - pad))
    }

    static func tenths(_ value: Double) -> Double {
        (value * 10).rounded(.toNearestOrAwayFromZero) / 10
    }
}

/// A progress ring drawn as a stroked circle with a dash covering `fraction` of its length.
public struct DonutGeometry: Hashable, Sendable {
    public let size: Double
    public let stroke: Double
    public let fraction: Double

    public init(size: Double, stroke: Double, fraction: Double) {
        self.size = size
        self.stroke = stroke
        self.fraction = min(max(fraction, 0), 1)
    }

    public var radius: Double { (size - stroke) / 2 }
    public var center: Double { size / 2 }
    public var circumference: Double { ChartGeometry.tenths(2 * .pi * radius) }
    /// Length of the filled dash along the circumference.
    public var dash: Double { ChartGeometry.tenths(2 * .pi * radius * fraction) }
}

/// The Home and dashboard spending chart: cumulative spend this month against last month, with the
/// straight budget-pace line from zero to the full budget.
public struct SpendChartGeometry: Sendable {
    public static let defaultMax = 2400.0
    public static let gridValues: [Double] = [0, 600, 1200, 1800, 2400]

    public let width: Double
    public let height: Double
    public let max: Double
    public let lastMonth: [Point]
    public let thisMonth: [Point]
    public let paceStart: Point
    public let paceEnd: Point

    public init(household: Household, width: Double, height: Double, max: Double = SpendChartGeometry.defaultMax) {
        self.width = width
        self.height = height
        self.max = max
        lastMonth = ChartGeometry.points(household.spendLastMonth.map(\.dollars), width: width, height: height, max: max)
        thisMonth = ChartGeometry.points(
            household.spendThisMonth.map(\.dollars), width: width, height: height, max: max,
            slots: household.period.days
        )
        let pace = ChartGeometry.points([0, household.totalBudget.dollars], width: width, height: height, max: max)
        paceStart = pace[0]
        paceEnd = pace[1]
    }

    public var lastMonthLine: VectorPath { ChartGeometry.smoothPath(lastMonth) }
    public var thisMonthLine: VectorPath { ChartGeometry.smoothPath(thisMonth) }
    public var thisMonthArea: VectorPath { ChartGeometry.areaPath(thisMonth, height: height) }
    public var paceLine: VectorPath { ChartGeometry.straightPath(from: paceStart, to: paceEnd) }
    public var endMarker: Point { ChartGeometry.endMarker(thisMonth, width: width, height: height) }

    /// Y position of a horizontal grid line for `value`.
    public func gridY(for value: Double) -> Double {
        ChartGeometry.tenths(4 + (height - 8) * (1 - value / max))
    }
}

/// Net worth history as a filled line, scaled so the curve sits in the middle of the box.
public struct NetWorthChartGeometry: Sendable {
    public let width: Double
    public let height: Double
    public let points: [Point]

    public init(history: [Money], width: Double, height: Double) {
        self.width = width
        self.height = height
        let values = history.map(\.dollars)
        let low = (values.min() ?? 0) - 4000
        let high = (values.max() ?? 0) + 2500
        points = ChartGeometry.points(values, width: width, height: height, max: high, min: low)
    }

    public var line: VectorPath { ChartGeometry.smoothPath(points) }
    public var area: VectorPath { ChartGeometry.areaPath(points, height: height, closeAtX: width) }
    public var endMarker: Point { ChartGeometry.endMarker(points, width: width, height: height) }
}
