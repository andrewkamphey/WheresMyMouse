import AppKit
import QuartzCore

/// What the App Store build draws at the pointer.
enum HighlightStyle: String, CaseIterable, Identifiable {
    /// A bigger arrow behind the real pointer, tips lined up.
    case arrow
    /// A disc and ring centered on the pointer.
    case halo

    var id: String { rawValue }
    var label: String { self == .arrow ? "Arrow" : "Halo" }
}

/// Draws the App Store build's pointer in small click-through windows that follow the mouse.
/// Public APIs only, and no permissions: mouse moves arrive through NSEvent monitors, which
/// don't need Accessibility access.
///
/// The real pointer stays visible on top. Hiding it while another app is active takes a
/// private API, so the arrow is drawn with its tip on the real pointer's tip.
///
/// There's one window per screen, each showing the part of the shape on its screen, so the
/// shape isn't cut off where displays meet. The windows only cover the shape: since macOS
/// 15.3.2 the App Store hides its install button under other apps' windows, so the drawing
/// also pauses while the App Store is the active app.
final class PointerHighlight {
    static let shared = PointerHighlight()

    var size: Double = 1 { didSet { if size != oldValue { update() } } }
    var style: HighlightStyle = .arrow { didSet { if style != oldValue { update() } } }
    private var fill: RGBA = .black
    private var outline: RGBA = .white

    /// Nothing is drawn at 1×: that's your own pointer.
    var isVisible: Bool { size > 1.01 }

    /// Apps that get no drawn pointer while they're active.
    private static let pausedApps: Set<String> = ["com.apple.AppStore"]
    private var isPaused = false

    private var overlays: [Overlay] = []
    /// The shape's extent around the pointer's tip, in points.
    private var shapeBounds: CGRect = .zero
    private var monitors: [Any] = []
    private var screenObserver: NSObjectProtocol?

    private init() {
        isPaused = Self.pausedApps.contains(NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "")
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
        ) { [weak self] note in
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            self?.isPaused = Self.pausedApps.contains(app?.bundleIdentifier ?? "")
            self?.update()
        }
    }

    func setColors(fill: RGBA, outline: RGBA) {
        self.fill = fill
        self.outline = outline
        update()
    }

    private func update() {
        guard isVisible, !isPaused else { hide(); return }
        if overlays.isEmpty { show() }
        let parts = shapeParts()
        shapeBounds = parts.reduce(CGRect.null) { $0.union($1.path.boundingBoxOfPath.insetBy(dx: -$1.lineWidth, dy: -$1.lineWidth)) }
            .insetBy(dx: -2, dy: -2)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for overlay in overlays { overlay.draw(parts) }
        CATransaction.commit()
        follow()
    }

    private func show() {
        overlays = NSScreen.screens.map(Overlay.init)
        let moves: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        // Global: moves over other apps. Local: moves over this app's own menu.
        monitors = [
            NSEvent.addGlobalMonitorForEvents(matching: moves) { [weak self] _ in self?.follow() },
            NSEvent.addLocalMonitorForEvents(matching: moves) { [weak self] event in self?.follow(); return event },
        ].compactMap { $0 }
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.rebuild() }
    }

    private func hide() {
        guard !overlays.isEmpty else { return }
        overlays.forEach { $0.close() }
        overlays = []
        monitors.forEach(NSEvent.removeMonitor)
        monitors = []
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
        screenObserver = nil
    }

    /// Displays were added, removed or rearranged: one window per screen again.
    private func rebuild() {
        hide()
        update()
    }

    /// Moves the shape to the mouse on every screen it touches.
    private func follow() {
        let mouse = NSEvent.mouseLocation
        let rect = shapeBounds.offsetBy(dx: mouse.x, dy: mouse.y)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for overlay in overlays { overlay.place(rect, mouse: mouse) }
        CATransaction.commit()
    }

    // MARK: Shapes

    /// One layer of the drawing, in points relative to the pointer's tip, y up.
    struct Part {
        var path: CGPath
        var fill: CGColor?
        var stroke: CGColor?
        var lineWidth: CGFloat = 0
    }

    /// The 1× arrow is ~16pt tall, like the system pointer.
    static func arrowHeight(for size: Double) -> CGFloat { 16 * CGFloat(size) }

    func shapeParts() -> [Part] {
        let height = Self.arrowHeight(for: size)
        switch style {
        case .arrow:
            // The outline is stroked under the fill, so only its outer half shows.
            let path = NSBezierPath.pointerArrow(height: height, origin: .zero).flippedCGPath
            return [
                Part(path: path, fill: nil, stroke: outline.cgColor, lineWidth: height * 0.075),
                Part(path: path, fill: fill.cgColor, stroke: nil),
            ]
        case .halo:
            // A see-through disc so whatever is under the pointer stays readable.
            let radius = height * 0.75
            let path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
            return [
                Part(path: path, fill: fill.nsColor.withAlphaComponent(0.3).cgColor, stroke: nil),
                Part(path: path, fill: nil, stroke: outline.cgColor, lineWidth: max(2, radius * 0.08)),
            ]
        }
    }
}

/// A click-through window on one screen, sized to the part of the shape on that screen.
private final class Overlay {
    private let window: NSWindow
    private let screenFrame: NSRect
    private let scale: CGFloat
    private let container = CALayer()
    private var isShown = false

    init(screen: NSScreen) {
        screenFrame = screen.frame
        scale = screen.backingScaleFactor
        window = NSWindow(contentRect: NSRect(origin: screenFrame.origin, size: NSSize(width: 1, height: 1)),
                          styleMask: .borderless, backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.animationBehavior = .none
        window.isExcludedFromWindowsMenu = true
        // Above menus, the Dock and full-screen apps, on every Space.
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]

        // A layer-hosting view: the layer tree is ours, not AppKit's.
        let view = NSView(frame: NSRect(origin: .zero, size: window.frame.size))
        view.autoresizingMask = [.width, .height]
        view.layer = CALayer()
        view.wantsLayer = true
        view.layer?.addSublayer(container)
        window.contentView = view
    }

    func draw(_ parts: [PointerHighlight.Part]) {
        while (container.sublayers?.count ?? 0) < parts.count { container.addSublayer(CAShapeLayer()) }
        for (layer, part) in zip(container.sublayers as? [CAShapeLayer] ?? [], parts) {
            layer.path = part.path
            layer.fillColor = part.fill
            layer.strokeColor = part.stroke
            layer.lineWidth = part.lineWidth
            layer.lineJoin = .round
            layer.contentsScale = scale
        }
    }

    /// Shows the part of `rect` (the shape around `mouse`, in global coordinates) on this screen.
    func place(_ rect: NSRect, mouse: NSPoint) {
        let visible = rect.intersection(screenFrame)
        guard !visible.isEmpty else {
            if isShown { window.orderOut(nil) }
            isShown = false
            return
        }
        if window.frame != visible { window.setFrame(visible, display: false) }
        container.position = CGPoint(x: mouse.x - visible.minX, y: mouse.y - visible.minY)
        if !isShown { window.orderFrontRegardless() }
        isShown = true
    }

    func close() {
        window.orderOut(nil)
        window.close()
    }
}

private extension NSBezierPath {
    /// The path as a CGPath with y pointing up, for a straight-edged path drawn in flipped
    /// coordinates (`NSBezierPath.cgPath` needs macOS 14).
    var flippedCGPath: CGPath {
        let path = CGMutablePath()
        var points = [NSPoint](repeating: .zero, count: 3)
        for i in 0..<elementCount {
            switch element(at: i, associatedPoints: &points) {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: -points[0].y))
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: -points[0].y))
            case .closePath: path.closeSubpath()
            default: break // the arrow has no curves
            }
        }
        return path
    }
}
