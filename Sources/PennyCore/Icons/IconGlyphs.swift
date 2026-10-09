/// Geometry for every icon in ``IconName``. Both the SVG renderer and the SwiftUI `Shape` read from
/// here, so an icon tweak lands on the phone and the site at once.
enum IconGlyphs {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    static func shapes(for name: IconName) -> [IconShape] {
        switch name {
        case .cart:
            [
                .path("M3 4h2l2.2 10.2a1.5 1.5 0 0 0 1.5 1.2h8.6a1.5 1.5 0 0 0 1.5-1.1L20.5 8H6.2"),
                .circle(cx: 9.5, cy: 19.5, r: 1.3),
                .circle(cx: 17, cy: 19.5, r: 1.3),
            ]
        case .cup:
            [
                .path("M5 8h11v5a5 5 0 0 1-5 5h-1a5 5 0 0 1-5-5V8z"),
                .path("M16 9.5h1.5a2.5 2.5 0 0 1 0 5H16"),
                .path("M8.5 3.5c0 1 1 1.2 1 2.2M12.5 3.5c0 1 1 1.2 1 2.2"),
            ]
        case .fork:
            [
                .path("M7 3v7a2 2 0 0 0 2 2v9M11 3v7a2 2 0 0 1-2 2M9 3v6"),
                .path("M17 21V3c-2 1.5-3 4-3 7v3h3"),
            ]
        case .car:
            [
                .path("M4 16v-4l2-5a2 2 0 0 1 1.9-1.4h8.2A2 2 0 0 1 18 7l2 5v4"),
                .path("M3 16h18v2.5a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1V18H7v.5a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V16z"),
                .path("M5 12h14"),
            ]
        case .bag:
            [
                .path("M5 8h14l-1 12H6L5 8z"),
                .path("M9 8V6.5a3 3 0 0 1 6 0V8"),
            ]
        case .ticket:
            [
                .path("M4 7h16v3a2 2 0 0 0 0 4v3H4v-3a2 2 0 0 0 0-4V7z"),
                .path("M14.5 7.5v9", dash: [1.5, 2.2]),
            ]
        case .heart:
            [.path("M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10z")]
        case .home:
            [
                .path("M4 11l8-7 8 7"),
                .path("M6 9.5V20h12V9.5"),
                .path("M10 20v-5h4v5"),
            ]
        case .paw:
            [
                .circle(cx: 6.5, cy: 10.5, r: 1.7),
                .circle(cx: 10, cy: 6.5, r: 1.7),
                .circle(cx: 14.5, cy: 6.5, r: 1.7),
                .circle(cx: 18, cy: 10.5, r: 1.7),
                .path(
                    "M12 12c-2.5 0-5 3.5-5 5.5 0 1.5 1.2 2.5 2.6 2.1l1.6-.5a3 3 0 0 1 1.6 0l1.6.5c1.4.4 2.6-.6 2.6-2.1 0-2-2.5-5.5-5-5.5z"
                ),
            ]
        case .bolt:
            [.path("M13 3L5 13h6l-1 8 8-10h-6l1-8z")]
        case .wifi:
            [
                .path("M3 9a13 13 0 0 1 18 0M6 12.5a8.5 8.5 0 0 1 12 0M9 16a4 4 0 0 1 6 0"),
                .circle(cx: 12, cy: 19, r: 0.6),
            ]
        case .shield:
            [.path("M12 3l7 3v5c0 5-3.2 8.3-7 10-3.8-1.7-7-5-7-10V6l7-3z")]
        case .shieldck:
            [
                .path("M12 3l7 3v5c0 5-3.2 8.3-7 10-3.8-1.7-7-5-7-10V6l7-3z"),
                .path("M9 12l2.2 2.2L15.5 10"),
            ]
        case .phone:
            [
                .rect(x: 7, y: 3, width: 10, height: 18, cornerRadius: 2.5),
                .path("M11 18h2"),
            ]
        case .play:
            [
                .rect(x: 3, y: 5, width: 18, height: 13, cornerRadius: 2.5),
                .path("M10.5 9v5l4-2.5-4-2.5z"),
                .path("M8 21h8"),
            ]
        case .dumbbell:
            [.path("M6.5 7v10M17.5 7v10M3.5 9.5v5M20.5 9.5v5M6.5 12h11")]
        case .music:
            [
                .path("M9 18V6l10-2v12"),
                .circle(cx: 6.5, cy: 18, r: 2.5),
                .circle(cx: 16.5, cy: 16, r: 2.5),
            ]
        case .bank:
            [
                .path("M3 9.5L12 4l9 5.5"),
                .path("M5 10v8M9.5 10v8M14.5 10v8M19 10v8M3 20h18"),
            ]
        case .trend:
            [
                .path("M3 17l6-6 4 4 8-8"),
                .path("M15 7h6v6"),
            ]
        case .users:
            [
                .circle(cx: 9, cy: 8, r: 3.2),
                .path("M3 20a6 6 0 0 1 12 0"),
                .path("M16 5.2a3 3 0 0 1 0 5.6M18 14.5a6 6 0 0 1 3 5.5"),
            ]
        case .calendar:
            [
                .rect(x: 4, y: 5, width: 16, height: 15, cornerRadius: 2.5),
                .path("M4 10h16M8.5 3v4M15.5 3v4"),
            ]
        case .grid:
            [
                .rect(x: 4, y: 4, width: 7, height: 7, cornerRadius: 1.8),
                .rect(x: 13, y: 4, width: 7, height: 7, cornerRadius: 1.8),
                .rect(x: 4, y: 13, width: 7, height: 7, cornerRadius: 1.8),
                .rect(x: 13, y: 13, width: 7, height: 7, cornerRadius: 1.8),
            ]
        case .list:
            [
                .path("M9 6h11M9 12h11M9 18h11"),
                .circle(cx: 4.5, cy: 6, r: 0.6),
                .circle(cx: 4.5, cy: 12, r: 0.6),
                .circle(cx: 4.5, cy: 18, r: 0.6),
            ]
        case .pie:
            [
                .path("M12 3.5v8.5h8.5A8.5 8.5 0 1 1 12 3.5z"),
                .path("M15 3.8A8.6 8.6 0 0 1 20.2 9H15V3.8z"),
            ]
        case .lock:
            [
                .rect(x: 5, y: 10.5, width: 14, height: 10, cornerRadius: 2.5),
                .path("M8 10.5V8a4 4 0 0 1 8 0v2.5"),
            ]
        case .eye:
            [
                .path("M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"),
                .circle(cx: 12, cy: 12, r: 2.8),
            ]
        case .eyeoff:
            [
                .path("M4 4l16 16"),
                .path(
                    "M10 5.7A9.8 9.8 0 0 1 12 5.5c6 0 9.5 6.5 9.5 6.5a17 17 0 0 1-2.6 3.4M6.3 7.4A16 16 0 0 0 2.5 12S6 18.5 12 18.5a9.3 9.3 0 0 0 4-.9"
                ),
            ]
        case .check:
            [.path("M5 12.5l4.5 4.5L19 7.5")]
        case .arrow:
            [.path("M5 12h14M13 6l6 6-6 6")]
        case .bell:
            [
                .path("M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15L6 16z"),
                .path("M10 20.5a2 2 0 0 0 4 0"),
            ]
        case .split:
            [
                .path("M6 3.5v4l6 6v7M18 3.5v4l-6 6"),
                .path("M4 5.5l2-2 2 2M16 5.5l2-2 2 2"),
            ]
        case .sparkle:
            [
                .path("M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8L12 3z"),
                .path("M18.5 15.5l.7 1.8 1.8.7-1.8.7-.7 1.8-.7-1.8-1.8-.7 1.8-.7.7-1.8z"),
            ]
        case .repeat:
            [.path("M4 11V9a3 3 0 0 1 3-3h12l-3-3M20 13v2a3 3 0 0 1-3 3H5l3 3")]
        case .plus:
            [.path("M12 5v14M5 12h14")]
        case .search:
            [
                .circle(cx: 11, cy: 11, r: 6.5),
                .path("M16 16l4.5 4.5"),
            ]
        case .sliders:
            [
                .path("M4 7h10M18 7h2M4 17h4M12 17h8"),
                .circle(cx: 16, cy: 7, r: 2),
                .circle(cx: 10, cy: 17, r: 2),
            ]
        case .chev:
            [.path("M9 6l6 6-6 6")]
        case .chevl:
            [.path("M15 6l-6 6 6 6")]
        case .chevd:
            [.path("M6 9l6 6 6-6")]
        case .up:
            [.path("M7 14l5-5 5 5")]
        case .down:
            [.path("M7 10l5 5 5-5")]
        case .wallet:
            [
                .path("M4 7.5A2.5 2.5 0 0 1 6.5 5H18v3"),
                .rect(x: 4, y: 8, width: 16, height: 11, cornerRadius: 2.5),
                .circle(cx: 16, cy: 13.5, r: 1.1),
            ]
        case .card:
            [
                .rect(x: 3, y: 6, width: 18, height: 12, cornerRadius: 2.5),
                .path("M3 10h18M7 15h3"),
            ]
        case .face:
            [
                .path("M4 8V6a2 2 0 0 1 2-2h2M16 4h2a2 2 0 0 1 2 2v2M20 16v2a2 2 0 0 1-2 2h-2M8 20H6a2 2 0 0 1-2-2v-2"),
                .path("M9 9.5v1M15 9.5v1M12 9.5v3.5h-1M9.5 15.5a3.5 3.5 0 0 0 5 0"),
            ]
        case .download:
            [.path("M12 4v11M7 10l5 5 5-5M5 20h14")]
        case .ban:
            [
                .circle(cx: 12, cy: 12, r: 8.5),
                .path("M6 6l12 12"),
            ]
        case .target:
            [
                .circle(cx: 12, cy: 12, r: 8.5),
                .circle(cx: 12, cy: 12, r: 4.5),
                .circle(cx: 12, cy: 12, r: 0.8),
            ]
        case .tag:
            [
                .path("M3.5 12.5V4.5a1 1 0 0 1 1-1h8l8 8-9 9-8-8z"),
                .circle(cx: 8, cy: 8, r: 1.4),
            ]
        case .inbox:
            [
                .path("M4 13l2.5-8h11L20 13v5a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-5z"),
                .path("M4 13h4.5l1 2h5l1-2H20"),
            ]
        case .monitor:
            [
                .rect(x: 3, y: 4, width: 18, height: 12.5, cornerRadius: 2),
                .path("M9 20.5h6M12 16.5v4"),
            ]
        case .mail:
            [
                .rect(x: 3, y: 5.5, width: 18, height: 13, cornerRadius: 2.5),
                .path("M4 7.5l8 6 8-6"),
            ]
        }
    }
}
