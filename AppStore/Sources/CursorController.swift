import AppKit

/// The App Store build's stand-in for the direct build's `CursorController`, with the same
/// interface the shared code calls. Nothing here touches the system pointer: the App Store
/// only allows public APIs, and macOS has no public way to resize or recolor the pointer
/// for other apps. Size and colors drive `PointerHighlight` instead, a pointer drawn in
/// click-through windows that follow the mouse. 1× is your own pointer, with nothing drawn.
enum CursorController {
    /// The slider's normal range, and the "extra large" range behind a switch.
    static let standardMaxSize: Double = 10
    static let extendedMaxSize: Double = 30
    static let sizeRange: ClosedRange<Double> = 1...extendedMaxSize
    /// Shown on first launch, so the app visibly does something right away.
    static let firstLaunchSize: Double = 3

    /// Pointer colors are drawn by the app, so they work on every supported macOS.
    static let colorsSupported = true

    private static let sizeKey = "highlightSize"
    private static let fillKey = "highlightFill"
    private static let outlineKey = "highlightOutline"
    private static let styleKey = "highlightStyle"

    // MARK: Size

    static var size: Double { PointerHighlight.shared.size }

    private static var savedSize: Double {
        UserDefaults.standard.object(forKey: sizeKey) as? Double ?? firstLaunchSize
    }

    /// Applies the size live. `persist` also saves it for the next launch.
    static func setSize(_ size: Double, persist: Bool) {
        let clamped = min(max(size, sizeRange.lowerBound), sizeRange.upperBound)
        PointerHighlight.shared.size = clamped
        if persist { UserDefaults.standard.set(clamped, forKey: sizeKey) }
    }

    // MARK: Colors

    static var fill: RGBA? { load(fillKey) }
    static var outline: RGBA? { load(outlineKey) }

    static func setColors(fill: RGBA, outline: RGBA) {
        PointerHighlight.shared.setColors(fill: fill, outline: outline)
        save(fill, fillKey)
        save(outline, outlineKey)
    }

    // MARK: Style

    static var style: HighlightStyle {
        get { UserDefaults.standard.string(forKey: styleKey).flatMap(HighlightStyle.init) ?? .arrow }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: styleKey)
            PointerHighlight.shared.style = newValue
        }
    }

    /// Shows the saved look at launch.
    static func restore() {
        let highlight = PointerHighlight.shared
        highlight.style = style
        highlight.setColors(fill: fill ?? .black, outline: outline ?? .white)
        highlight.size = savedSize
    }

    /// The Pointer section of Accessibility settings, where people can recolor the real
    /// pointer themselves (e.g. to match the drawn one).
    static func openPointerSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Accessibility-Settings.extension?Display")!)
    }

    private static func load(_ key: String) -> RGBA? {
        UserDefaults.standard.data(forKey: key).flatMap { try? JSONDecoder().decode(RGBA.self, from: $0) }
    }

    private static func save(_ color: RGBA, _ key: String) {
        UserDefaults.standard.set(try? JSONEncoder().encode(color), forKey: key)
    }
}
