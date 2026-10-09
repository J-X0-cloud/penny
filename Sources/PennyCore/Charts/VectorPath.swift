/// A point in a chart's or icon's own coordinate space.
public struct Point: Hashable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public init(_ x: Double, _ y: Double) {
        self.init(x: x, y: y)
    }

    public static let zero = Point(0, 0)
}

/// Absolute drawing commands. Every SVG command, including elliptical arcs and the shorthand
/// curves, reduces to these, which map one-to-one onto `CGPath`/SwiftUI `Path` and back to SVG.
public enum PathCommand: Hashable, Sendable {
    case move(to: Point)
    case line(to: Point)
    case quadCurve(to: Point, control: Point)
    case curve(to: Point, control1: Point, control2: Point)
    case close
}

/// A resolution-independent path: built by the chart geometry, or parsed from SVG path data for the
/// icon set. `svgData` serialises it back for the web renderer.
public struct VectorPath: Hashable, Sendable {
    public var commands: [PathCommand]

    public init(commands: [PathCommand] = []) {
        self.commands = commands
    }

    /// Parses SVG path data (`d` attribute). Supports every command in SVG 1.1 (`M L H V C S Q T A Z`,
    /// absolute and relative). Arcs are converted to cubic Béziers.
    public init(svg data: String) throws {
        var parser = SVGPathParser(data)
        self.commands = try parser.parse()
    }

    public var isEmpty: Bool { commands.isEmpty }

    /// The path's final point, if it draws anything.
    public var currentPoint: Point? {
        var start: Point?
        var current: Point?
        for command in commands {
            switch command {
            case let .move(point):
                start = point
                current = point
            case let .line(point), let .quadCurve(point, _), let .curve(point, _, _):
                current = point
            case .close:
                current = start
            }
        }
        return current
    }

    public mutating func move(to point: Point) { commands.append(.move(to: point)) }
    public mutating func line(to point: Point) { commands.append(.line(to: point)) }
    public mutating func curve(to point: Point, control1: Point, control2: Point) {
        commands.append(.curve(to: point, control1: control1, control2: control2))
    }
    public mutating func close() { commands.append(.close) }

    /// SVG path data with compact numbers: `"M0,62.3 C10,62.3 10,60 20,60"`.
    public var svgData: String {
        commands.map { command in
            switch command {
            case let .move(p): "M\(SVGNumber.format(p.x)),\(SVGNumber.format(p.y))"
            case let .line(p): "L\(SVGNumber.format(p.x)),\(SVGNumber.format(p.y))"
            case let .quadCurve(p, c):
                "Q\(SVGNumber.format(c.x)),\(SVGNumber.format(c.y)) \(SVGNumber.format(p.x)),\(SVGNumber.format(p.y))"
            case let .curve(p, c1, c2):
                "C\(SVGNumber.format(c1.x)),\(SVGNumber.format(c1.y)) \(SVGNumber.format(c2.x)),\(SVGNumber.format(c2.y)) \(SVGNumber.format(p.x)),\(SVGNumber.format(p.y))"
            case .close: "Z"
            }
        }.joined(separator: " ")
    }
}

/// Number formatting for SVG attributes: up to two decimals, trailing zeros dropped, never `-0`.
public enum SVGNumber {
    public static func format(_ value: Double) -> String {
        let hundredths = Int((value * 100).rounded(.toNearestOrAwayFromZero))
        if hundredths == 0 { return "0" }
        let sign = hundredths < 0 ? "-" : ""
        let magnitude = abs(hundredths)
        let whole = magnitude / 100
        let fraction = magnitude % 100
        if fraction == 0 { return sign + String(whole) }
        if fraction % 10 == 0 { return sign + "\(whole).\(fraction / 10)" }
        return sign + "\(whole)." + (fraction < 10 ? "0" : "") + String(fraction)
    }
}

public struct SVGPathError: Error, Hashable, CustomStringConvertible {
    public let message: String
    public let offset: Int
    public var description: String { "Invalid SVG path data at offset \(offset): \(message)" }
}

/// A small recursive-descent parser for SVG path data.
struct SVGPathParser {
    private let scalars: [Unicode.Scalar]
    private var index = 0

    init(_ data: String) {
        self.scalars = Array(data.unicodeScalars)
    }

    mutating func parse() throws -> [PathCommand] {
        var commands: [PathCommand] = []
        var current = Point.zero
        var subpathStart = Point.zero
        var lastCubicControl: Point?
        var lastQuadControl: Point?
        var command: Unicode.Scalar?

        skipSeparators()
        while index < scalars.count {
            if let letter = peekCommand() {
                command = letter
                index += 1
            } else if command == nil {
                throw SVGPathError(message: "path must start with a command", offset: index)
            }
            guard let active = command else { break }
            let relative = active.properties.isLowercase
            let origin = relative ? current : .zero

            switch active.uppercased {
            case "M":
                let point = try readPoint(relativeTo: origin)
                commands.append(.move(to: point))
                current = point
                subpathStart = point
                // Further coordinate pairs after a moveto are implicit linetos.
                command = relative ? "l" : "L"
                lastCubicControl = nil
                lastQuadControl = nil
            case "L":
                let point = try readPoint(relativeTo: origin)
                commands.append(.line(to: point))
                current = point
                lastCubicControl = nil
                lastQuadControl = nil
            case "H":
                let x = try readNumber() + (relative ? current.x : 0)
                current = Point(x, current.y)
                commands.append(.line(to: current))
                lastCubicControl = nil
                lastQuadControl = nil
            case "V":
                let y = try readNumber() + (relative ? current.y : 0)
                current = Point(current.x, y)
                commands.append(.line(to: current))
                lastCubicControl = nil
                lastQuadControl = nil
            case "C":
                let c1 = try readPoint(relativeTo: origin)
                let c2 = try readPoint(relativeTo: origin)
                let end = try readPoint(relativeTo: origin)
                commands.append(.curve(to: end, control1: c1, control2: c2))
                current = end
                lastCubicControl = c2
                lastQuadControl = nil
            case "S":
                let c1 = lastCubicControl.map { reflect($0, about: current) } ?? current
                let c2 = try readPoint(relativeTo: origin)
                let end = try readPoint(relativeTo: origin)
                commands.append(.curve(to: end, control1: c1, control2: c2))
                current = end
                lastCubicControl = c2
                lastQuadControl = nil
            case "Q":
                let control = try readPoint(relativeTo: origin)
                let end = try readPoint(relativeTo: origin)
                commands.append(.quadCurve(to: end, control: control))
                current = end
                lastQuadControl = control
                lastCubicControl = nil
            case "T":
                let control = lastQuadControl.map { reflect($0, about: current) } ?? current
                let end = try readPoint(relativeTo: origin)
                commands.append(.quadCurve(to: end, control: control))
                current = end
                lastQuadControl = control
                lastCubicControl = nil
            case "A":
                let rx = try readNumber()
                let ry = try readNumber()
                let rotation = try readNumber()
                let largeArc = try readFlag()
                let sweep = try readFlag()
                let end = try readPoint(relativeTo: origin)
                commands += ArcConverter.cubics(
                    from: current, to: end, rx: rx, ry: ry, rotationDegrees: rotation,
                    largeArc: largeArc, sweep: sweep
                )
                current = end
                lastCubicControl = nil
                lastQuadControl = nil
            case "Z":
                commands.append(.close)
                current = subpathStart
                lastCubicControl = nil
                lastQuadControl = nil
                command = nil
            default:
                throw SVGPathError(message: "unsupported command '\(active)'", offset: index - 1)
            }
            skipSeparators()
        }
        return commands
    }

    // MARK: - Lexing

    private func reflect(_ point: Point, about center: Point) -> Point {
        Point(2 * center.x - point.x, 2 * center.y - point.y)
    }

    private func peekCommand() -> Unicode.Scalar? {
        guard index < scalars.count else { return nil }
        let scalar = scalars[index]
        return "MmLlHhVvCcSsQqTtAaZz".unicodeScalars.contains(scalar) ? scalar : nil
    }

    private mutating func skipSeparators() {
        while index < scalars.count, scalars[index] == "," || scalars[index].properties.isWhitespace {
            index += 1
        }
    }

    private mutating func readPoint(relativeTo origin: Point) throws -> Point {
        let x = try readNumber()
        let y = try readNumber()
        return Point(origin.x + x, origin.y + y)
    }

    /// Arc flags are single digits and may be packed without separators (`a1 1 0 011 1`).
    private mutating func readFlag() throws -> Bool {
        skipSeparators()
        guard index < scalars.count else { throw SVGPathError(message: "expected arc flag", offset: index) }
        defer { index += 1 }
        switch scalars[index] {
        case "0": return false
        case "1": return true
        default: throw SVGPathError(message: "arc flag must be 0 or 1", offset: index)
        }
    }

    private mutating func readNumber() throws -> Double {
        skipSeparators()
        let start = index
        if index < scalars.count, scalars[index] == "-" || scalars[index] == "+" { index += 1 }
        var sawDigit = false
        var sawDot = false
        while index < scalars.count {
            let scalar = scalars[index]
            if scalar.properties.numericType != nil, ("0"..."9").contains(scalar) {
                sawDigit = true
            } else if scalar == ".", !sawDot {
                sawDot = true
            } else {
                break
            }
            index += 1
        }
        if sawDigit, index < scalars.count, scalars[index] == "e" || scalars[index] == "E" {
            var lookahead = index + 1
            if lookahead < scalars.count, scalars[lookahead] == "-" || scalars[lookahead] == "+" { lookahead += 1 }
            if lookahead < scalars.count, ("0"..."9").contains(scalars[lookahead]) {
                index = lookahead
                while index < scalars.count, ("0"..."9").contains(scalars[index]) { index += 1 }
            }
        }
        guard sawDigit else { throw SVGPathError(message: "expected a number", offset: start) }
        var text = ""
        text.unicodeScalars.append(contentsOf: scalars[start..<index])
        guard let value = Double(text) else { throw SVGPathError(message: "malformed number '\(text)'", offset: start) }
        return value
    }
}

private extension Unicode.Scalar {
    var uppercased: Unicode.Scalar {
        properties.uppercaseMapping.unicodeScalars.first ?? self
    }
}
