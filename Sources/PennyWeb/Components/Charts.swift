import PennyCore

extension SiteRenderer {
    func donut(fraction: Double, size: Double = 96, stroke: Double = 11, color: String = Palette.violet.css, track: String = Palette.track.css) -> HTML {
        let ring = DonutGeometry(size: size, stroke: stroke, fraction: fraction)
        return svg(
            .class("donut"), Attribute("viewBox", "0 0 \(SVGNumber.format(size)) \(SVGNumber.format(size))"),
            .width(size), .height(size), .ariaHidden()
        ) {
            svgCircle(
                num("cx", ring.center), num("cy", ring.center), num("r", ring.radius), Attribute("fill", "none"),
                Attribute("stroke", track), num("stroke-width", stroke)
            )
            svgCircle(
                num("cx", ring.center), num("cy", ring.center), num("r", ring.radius), Attribute("fill", "none"),
                Attribute("stroke", color), num("stroke-width", stroke), Attribute("stroke-linecap", "round"),
                Attribute("stroke-dasharray", "\(SVGNumber.format(ring.dash)) \(SVGNumber.format(ring.circumference))"),
                Attribute("transform", "rotate(-90 \(SVGNumber.format(ring.center)) \(SVGNumber.format(ring.center)))")
            )
        }
    }

    /// The end-of-line marker, positioned in percent so it stays round when the SVG stretches.
    func chartDot(_ marker: Point, dark: Bool = false) -> HTML {
        span(.class("chart-dot", dark ? "dk" : nil), .style([
            "left": MoneyFormat.fixed(marker.x * 100, decimals: 2) + "%",
            "top": MoneyFormat.fixed(marker.y * 100, decimals: 2) + "%",
        ]))
    }

    private func chartFrame(width: Double, height: Double, @HTMLBuilder content: () -> HTML) -> HTML {
        svg(
            .class("chart"), Attribute("viewBox", "0 0 \(SVGNumber.format(width)) \(SVGNumber.format(height))"),
            Attribute("preserveAspectRatio", "none"), .ariaHidden(), content: content
        )
    }

    private func stroke(_ path: VectorPath, color: String, width: Double, dash: String? = nil, roundCaps: Bool = false) -> HTML {
        svgPath(
            Attribute("d", path.svgData), Attribute("stroke", color), num("stroke-width", width),
            dash.map { Attribute("stroke-dasharray", $0) } ?? .class(),
            Attribute("fill", "none"), roundCaps ? Attribute("stroke-linecap", "round") : .class(),
            Attribute("vector-effect", "non-scaling-stroke")
        )
    }

    func netWorthChart(width: Double, height: Double, dark: Bool = false) -> HTML {
        let chart = NetWorthChartGeometry(history: household.netWorthHistory, width: width, height: height)
        let gradient = RenderScope.nextID("nw")
        let color = dark ? Palette.lavender.css : Palette.violet.css
        return chartFrame(width: width, height: height) {
            svgDefs {
                linearGradient(id: gradient, x2: 0, y2: 1, stops: [(0, color, 0.32), (1, color, 0)])
            }
            svgPath(Attribute("d", chart.area.svgData), Attribute("fill", "url(#\(gradient))"))
            stroke(chart.line, color: color, width: 2.4)
        } + chartDot(chart.endMarker, dark: dark)
    }

    func sparkline(_ values: [Double], color: String = Palette.violet.css) -> HTML {
        svg(.class("spark"), Attribute("viewBox", "0 0 80 26"), Attribute("preserveAspectRatio", "none"), .ariaHidden()) {
            stroke(ChartGeometry.sparkline(values), color: color, width: 1.8)
        }
    }

    enum SpendChartTheme {
        case light, dark

        var current: String { self == .light ? "#5B3FD9" : "#FFFFFF" }
        var last: String { self == .light ? "#C9C3D9" : "rgba(255,255,255,.38)" }
        var pace: String { self == .light ? "#E4A06E" : "rgba(255,255,255,.28)" }
        var fill: String { self == .light ? "#5B3FD9" : "#FFFFFF" }
    }

    /// Cumulative spend this month vs. last month, with the straight budget-pace line.
    func spendChart(width: Double, height: Double, theme: SpendChartTheme = .light, axis: Bool = false) -> HTML {
        let chart = SpendChartGeometry(household: household, width: width, height: height)
        let gradient = RenderScope.nextID("spend")
        return chartFrame(width: width, height: height) {
            svgDefs {
                linearGradient(id: gradient, x2: 0, y2: 1, stops: [(0, theme.fill, 0.28), (1, theme.fill, 0)])
            }
            if axis {
                for value in SpendChartGeometry.gridValues {
                    let y = chart.gridY(for: value)
                    svgLine(
                        Attribute("x1", "0"), num("x2", width), num("y1", y), num("y2", y), Attribute("stroke", "#EEEAF3"),
                        Attribute("stroke-width", "1")
                    )
                }
            }
            stroke(chart.paceLine, color: theme.pace, width: 1.4, dash: "2 4")
            stroke(chart.lastMonthLine, color: theme.last, width: 1.6, dash: "4 4")
            svgPath(Attribute("d", chart.thisMonthArea.svgData), Attribute("fill", "url(#\(gradient))"))
            stroke(chart.thisMonthLine, color: theme.current, width: 2.4, roundCaps: true)
        } + chartDot(chart.endMarker)
    }
}
