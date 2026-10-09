import Foundation

/// Converts SVG elliptical arcs to cubic Béziers, following the endpoint-to-centre conversion in
/// SVG 1.1 appendix F.6.5. Each output segment spans at most 90°, which keeps the approximation
/// error far below a pixel at icon sizes.
enum ArcConverter {
    static func cubics(
        from start: Point, to end: Point, rx: Double, ry: Double, rotationDegrees: Double,
        largeArc: Bool, sweep: Bool
    ) -> [PathCommand] {
        // F.6.2: a zero-length arc draws nothing; a zero radius is a straight line.
        if start == end { return [] }
        var rx = abs(rx)
        var ry = abs(ry)
        if rx == 0 || ry == 0 { return [.line(to: end)] }

        let phi = rotationDegrees * .pi / 180
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)

        // F.6.5.1: move to a frame centred between the endpoints and aligned with the ellipse axes.
        let dx = (start.x - end.x) / 2
        let dy = (start.y - end.y) / 2
        let x1p = cosPhi * dx + sinPhi * dy
        let y1p = -sinPhi * dx + cosPhi * dy

        // F.6.6: scale radii up if they cannot reach between the endpoints.
        let lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
        if lambda > 1 {
            let scale = lambda.squareRoot()
            rx *= scale
            ry *= scale
        }

        // F.6.5.2: centre in the rotated frame.
        let numerator = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
        let denominator = rx * rx * y1p * y1p + ry * ry * x1p * x1p
        var coefficient = (max(numerator, 0) / denominator).squareRoot()
        if largeArc == sweep { coefficient = -coefficient }
        let cxp = coefficient * (rx * y1p / ry)
        let cyp = coefficient * -(ry * x1p / rx)

        // F.6.5.3: centre in user space.
        let cx = cosPhi * cxp - sinPhi * cyp + (start.x + end.x) / 2
        let cy = sinPhi * cxp + cosPhi * cyp + (start.y + end.y) / 2

        // F.6.5.5-6: start angle and sweep.
        let theta1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
        var delta = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
        if !sweep && delta > 0 { delta -= 2 * .pi }
        if sweep && delta < 0 { delta += 2 * .pi }

        let segments = max(1, Int((abs(delta) / (.pi / 2)).rounded(.up)))
        let step = delta / Double(segments)
        // Control-point distance for a circular arc of `step` radians.
        let k = 4.0 / 3.0 * tan(step / 4)

        func pointOnEllipse(_ t: Double) -> Point {
            let x = rx * cos(t)
            let y = ry * sin(t)
            return Point(cx + cosPhi * x - sinPhi * y, cy + sinPhi * x + cosPhi * y)
        }

        func derivative(_ t: Double) -> Point {
            let x = -rx * sin(t)
            let y = ry * cos(t)
            return Point(cosPhi * x - sinPhi * y, sinPhi * x + cosPhi * y)
        }

        var commands: [PathCommand] = []
        var t = theta1
        var from = start
        for segment in 0..<segments {
            let next = t + step
            let to = segment == segments - 1 ? end : pointOnEllipse(next)
            let d1 = derivative(t)
            let d2 = derivative(next)
            let c1 = Point(from.x + k * d1.x, from.y + k * d1.y)
            let c2 = Point(to.x - k * d2.x, to.y - k * d2.y)
            commands.append(.curve(to: to, control1: c1, control2: c2))
            from = to
            t = next
        }
        return commands
    }

    /// Signed angle between two vectors.
    private static func angle(_ ux: Double, _ uy: Double, _ vx: Double, _ vy: Double) -> Double {
        atan2(ux * vy - uy * vx, ux * vx + uy * vy)
    }
}
