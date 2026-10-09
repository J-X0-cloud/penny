import Foundation
import Testing
@testable import PennyCore

@Suite("Chart geometry")
struct ChartGeometryTests {
    @Test func pointsScaleIntoThePaddedBox() {
        let points = ChartGeometry.points([0, 50, 100], width: 200, height: 108, max: 100)
        #expect(points == [Point(0, 104), Point(100, 54), Point(200, 4)])
    }

    @Test func slotsPlaceAPartialSeriesOnAFullAxis() {
        let points = ChartGeometry.points([0, 0], width: 290, height: 100, max: 10, slots: 30)
        #expect(points[1].x == 10)
    }

    @Test func coordinatesRoundToTenths() {
        let points = ChartGeometry.points([1, 2, 3], width: 100, height: 100, max: 3.3, min: 0.7)
        for point in points {
            #expect((point.x * 10).rounded() == point.x * 10)
            #expect((point.y * 10).rounded() == point.y * 10)
        }
    }

    @Test func smoothPathUsesHorizontalTangents() {
        let path = ChartGeometry.smoothPath([Point(0, 10), Point(20, 30)])
        #expect(path.svgData == "M0,10 C10,10 10,30 20,30")
        #expect(ChartGeometry.smoothPath([]).isEmpty)
    }

    @Test func areaPathClosesToTheBaseline() {
        let path = ChartGeometry.areaPath([Point(0, 10), Point(20, 30)], height: 50, closeAtX: 40)
        #expect(path.svgData == "M0,10 C10,10 10,30 20,30 L40,50 L0,50 Z")
    }

    @Test func endMarkerIsAFractionOfTheBox() {
        let marker = ChartGeometry.endMarker([Point(0, 0), Point(130, 35)], width: 260, height: 70)
        #expect(marker == Point(0.5, 0.5))
    }

    @Test func donut() {
        let ring = DonutGeometry(size: 92, stroke: 10, fraction: 1708.42 / 2250)
        #expect(ring.radius == 41)
        #expect(ring.center == 46)
        #expect(ring.circumference == 257.6)
        #expect(ring.dash == 195.6)
        #expect(DonutGeometry(size: 10, stroke: 2, fraction: 3).fraction == 1)
    }

    @Test func spendChartEndsOnTodayAndPaceHitsTheBudget() {
        let chart = SpendChartGeometry(household: .sample, width: 290, height: 108)
        #expect(chart.thisMonth.count == 24)
        #expect(chart.lastMonth.count == 30)
        // Day 24 of 30 sits 23/29 of the way across.
        #expect(chart.thisMonth.last?.x == ChartGeometry.tenths(290.0 * 23 / 29))
        #expect(chart.paceStart == Point(0, 104))
        // $2,250 of a $2,400 scale.
        #expect(chart.paceEnd == Point(290, ChartGeometry.tenths(4 + 100 * (1 - 2250.0 / 2400))))
        #expect(chart.gridY(for: 2400) == 4)
        #expect(chart.gridY(for: 0) == 104)
        #expect(chart.thisMonthArea.commands.last == .close)
    }

    @Test func netWorthChartFillsToTheRightEdge() {
        let chart = NetWorthChartGeometry(history: Household.sample.netWorthHistory, width: 520, height: 150)
        #expect(chart.points.count == 12)
        #expect(chart.points.last?.x == 520)
        #expect(chart.area.svgData.hasSuffix("L520,150 L0,150 Z"))
        #expect(chart.endMarker.x == 1)
    }

    @Test func sparklineHandlesAFlatSeries() {
        let path = ChartGeometry.sparkline([5, 5, 5])
        #expect(path.commands.count == 3)
        #expect(ChartGeometry.sparkline([]).isEmpty)
    }

    @Test func svgNumbers() {
        #expect(SVGNumber.format(12) == "12")
        #expect(SVGNumber.format(12.5) == "12.5")
        #expect(SVGNumber.format(12.05) == "12.05")
        #expect(SVGNumber.format(-0.001) == "0")
        #expect(SVGNumber.format(-3.4) == "-3.4")
    }
}

@Suite("SVG path parsing")
struct VectorPathTests {
    @Test func absoluteAndRelativeLines() throws {
        let path = try VectorPath(svg: "M5 12h14M13 6l6 6-6 6")
        #expect(path.commands == [
            .move(to: Point(5, 12)), .line(to: Point(19, 12)),
            .move(to: Point(13, 6)), .line(to: Point(19, 12)), .line(to: Point(13, 18)),
        ])
    }

    @Test func compactNumbersAndImplicitLineTos() throws {
        let path = try VectorPath(svg: "M18.5 15.5l.7 1.8 1.8.7-1.8.7z")
        #expect(path.commands.count == 5)
        if case let .line(point) = path.commands[2] {
            #expect(abs(point.x - 21) < 1e-9)
            #expect(abs(point.y - 18) < 1e-9)
        } else {
            Issue.record("expected an implicit lineto")
        }
        #expect(path.commands.last == .close)
        #expect(path.currentPoint == Point(18.5, 15.5))
    }

    @Test func verticalAndCubicCommands() throws {
        let path = try VectorPath(svg: "M17 21V3c-2 1.5-3 4-3 7v3h3")
        #expect(path.commands[1] == .line(to: Point(17, 3)))
        #expect(path.commands[2] == .curve(to: Point(14, 10), control1: Point(15, 4.5), control2: Point(14, 7)))
        #expect(path.currentPoint == Point(17, 13))
    }

    @Test func smoothCurvesReflectTheirControlPoints() throws {
        let path = try VectorPath(svg: "M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12")
        // First S has no previous cubic, so its first control point is the current point.
        #expect(path.commands[1] == .curve(to: Point(12, 5.5), control1: Point(2.5, 12), control2: Point(6, 5.5)))
        #expect(path.commands[2] == .curve(to: Point(21.5, 12), control1: Point(18, 5.5), control2: Point(21.5, 12)))
    }

    @Test func quadraticCurves() throws {
        let path = try VectorPath(svg: "M0 0Q5 10 10 0T20 0")
        #expect(path.commands[2] == .quadCurve(to: Point(20, 0), control: Point(15, -10)))
    }

    @Test func arcsBecomeCubicsThatLandOnTheEndpoint() throws {
        // Semicircle from (0,0) to (10,0) with radius 5.
        let path = try VectorPath(svg: "M0 0A5 5 0 0 1 10 0")
        let curves = path.commands.dropFirst()
        #expect(curves.count == 2)
        #expect(path.currentPoint == Point(10, 0))
        // The midpoint of the arc is the top of the circle (sweep flag 1 runs clockwise in SVG's y-down space).
        if case let .curve(mid, _, _) = curves.first {
            #expect(abs(mid.x - 5) < 1e-9)
            #expect(abs(mid.y + 5) < 1e-9)
        } else {
            Issue.record("expected a cubic")
        }
    }

    @Test func packedArcFlags() throws {
        let packed = try VectorPath(svg: "M0 0a5 5 0 0110 0")
        let spaced = try VectorPath(svg: "M0 0a5 5 0 0 1 10 0")
        #expect(packed == spaced)
    }

    @Test func undersizedArcRadiiAreScaledUp() throws {
        let path = try VectorPath(svg: "M0 0A1 1 0 0 1 10 0")
        #expect(path.currentPoint == Point(10, 0))
    }

    @Test func zeroRadiusArcIsALine() throws {
        let path = try VectorPath(svg: "M0 0A0 5 0 0 1 10 0")
        #expect(path.commands == [.move(to: .zero), .line(to: Point(10, 0))])
    }

    @Test func exponentNotation() throws {
        let path = try VectorPath(svg: "M1e1 2E-1L-1.5e+1,0")
        #expect(path.commands == [.move(to: Point(10, 0.2)), .line(to: Point(-15, 0))])
    }

    @Test(arguments: ["12 4", "M1", "M1 2 X3 4", "M0 0A5 5 0 2 1 10 0"])
    func malformedDataThrows(data: String) {
        #expect(throws: SVGPathError.self) { try VectorPath(svg: data) }
    }

    @Test func everyIconParsesAndStaysInsideItsViewBox() throws {
        for icon in IconName.allCases {
            #expect(!icon.glyph.isEmpty, "\(icon) has no shapes")
            for shape in icon.glyph {
                guard case let .path(data, _) = shape else { continue }
                let path = try VectorPath(svg: data)
                #expect(!path.isEmpty)
                for command in path.commands {
                    let end: Point? = switch command {
                    case let .move(p), let .line(p), let .quadCurve(p, _), let .curve(p, _, _): p
                    case .close: nil
                    }
                    if let end {
                        #expect((0...24).contains(end.x) && (0...24).contains(end.y), "\(icon) leaves the 24×24 box")
                    }
                }
            }
        }
    }
}
