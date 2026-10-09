#if os(iOS)
import PennyCore
import SwiftUI

extension Path {
    /// A SwiftUI path from PennyCore's platform-neutral commands.
    init(_ vector: VectorPath) {
        self.init()
        for command in vector.commands {
            switch command {
            case let .move(point):
                move(to: CGPoint(x: point.x, y: point.y))
            case let .line(point):
                addLine(to: CGPoint(x: point.x, y: point.y))
            case let .quadCurve(point, control):
                addQuadCurve(to: CGPoint(x: point.x, y: point.y), control: CGPoint(x: control.x, y: control.y))
            case let .curve(point, control1, control2):
                addCurve(
                    to: CGPoint(x: point.x, y: point.y),
                    control1: CGPoint(x: control1.x, y: control1.y),
                    control2: CGPoint(x: control2.x, y: control2.y)
                )
            case .close:
                closeSubpath()
            }
        }
    }
}

/// Parsed icon geometry. Parsing happens once per icon, the first time it is drawn.
private enum IconGeometry {
    struct Stroke: Sendable {
        let path: VectorPath
        let dash: [Double]
        /// Circles and rounded rects are drawn natively rather than as path data.
        let primitive: IconShape?
    }

    static let all: [IconName: [Stroke]] = Dictionary(uniqueKeysWithValues: IconName.allCases.map { name in
        (name, name.glyph.map(stroke(for:)))
    })

    private static func stroke(for shape: IconShape) -> Stroke {
        switch shape {
        case let .path(data, dash):
            // Glyph data is static and covered by the PennyCore tests, so a parse failure is a bug.
            let parsed = (try? VectorPath(svg: data)) ?? VectorPath()
            return Stroke(path: parsed, dash: dash ?? [], primitive: nil)
        case .circle, .rect:
            return Stroke(path: VectorPath(), dash: [], primitive: shape)
        }
    }
}

/// One of Penny's 24×24 line icons, stroked at any size.
struct PennyIcon: View {
    let name: IconName
    var color: Color = Theme.ink
    var size: CGFloat = 20
    var lineWidth: CGFloat = IconStyle.strokeWidth

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / IconStyle.viewBox
            context.scaleBy(x: scale, y: scale)
            for stroke in IconGeometry.all[name] ?? [] {
                let path: Path
                switch stroke.primitive {
                case let .circle(cx, cy, r)?:
                    path = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                case let .rect(x, y, width, height, cornerRadius)?:
                    path = Path(roundedRect: CGRect(x: x, y: y, width: width, height: height), cornerRadius: cornerRadius)
                default:
                    path = Path(stroke.path)
                }
                context.stroke(
                    path, with: .color(color),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, dash: stroke.dash.map { CGFloat($0) })
                )
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
#endif
