// App Store screenshots: the demo slide with the app's own arrow, menu and Unlock alert drawn on it.
import AppKit
import SwiftUI

let dir = CommandLine.arguments[1]
let slide = NSImage(contentsOfFile: dir + "/Q3-Review.png")!
let W = 2880, H = 1800
let s: CGFloat = 2 // pixels per point

func canvas(_ draw: () -> Void) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    let flipped = NSGraphicsContext(cgContext: ctx.cgContext, flipped: true)
    ctx.cgContext.translateBy(x: 0, y: CGFloat(H)); ctx.cgContext.scaleBy(x: 1, y: -1)
    NSGraphicsContext.current = flipped
    slide.draw(in: NSRect(x: 0, y: 0, width: W, height: H), from: .zero, operation: .copy, fraction: 1, respectFlipped: true, hints: nil)
    draw()
    NSGraphicsContext.current = nil
    return rep
}

/// The app's arrow (PointerHighlight .arrow), with the real 1x pointer on top, tips lined up.
func arrow(at tip: NSPoint, size: CGFloat, fill: NSColor) {
    let h = 16 * size * s
    let path = NSBezierPath.pointerArrow(height: h, origin: tip)
    path.lineJoinStyle = .round
    path.lineWidth = h * 0.075
    NSColor.white.setStroke(); path.stroke()
    fill.setFill(); path.fill()
    let real = NSBezierPath.pointerArrow(height: 16 * s * 1.1, origin: tip)
    real.lineJoinStyle = .round
    real.lineWidth = 1.5 * s
    NSColor.white.setStroke(); real.stroke()
    NSColor.black.setFill(); real.fill()
}

func panel(_ image: NSImage, at origin: NSPoint, radius: CGFloat) {
    let rect = NSRect(origin: origin, size: NSSize(width: image.size.width, height: image.size.height))
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(white: 0, alpha: 0.28)
    shadow.shadowBlurRadius = 40
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.set()
    NSColor.windowBackgroundColor.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
    NSGraphicsContext.restoreGraphicsState()
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).addClip()
    image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
    NSGraphicsContext.restoreGraphicsState()
    NSColor(white: 0, alpha: 0.12).setStroke()
    let border = NSBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), xRadius: radius, yRadius: radius)
    border.lineWidth = 1
    border.stroke()
}

/// Renders a view offscreen at 2x into an NSImage sized in pixels.
@MainActor func render(_ view: NSView) -> NSImage {
    let window = NSWindow(contentRect: view.frame, styleMask: .borderless, backing: .buffered, defer: false)
    window.contentView = view
    window.setFrameOrigin(NSPoint(x: -10_000, y: -10_000))
    window.orderFrontRegardless()
    view.layoutSubtreeIfNeeded()
    RunLoop.main.run(until: Date().addingTimeInterval(0.5))
    let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
    view.cacheDisplay(in: view.bounds, to: rep)
    let image = NSImage(size: NSSize(width: rep.pixelsWide, height: rep.pixelsHigh))
    image.addRepresentation(rep)
    return image
}

func save(_ rep: NSBitmapImageRep, _ name: String) {
    // Store screenshots can't have alpha.
    let jpg = rep.representation(using: .png, properties: [:])!
    try! jpg.write(to: URL(fileURLWithPath: dir + "/" + name))
    print("Wrote \(name)")
}

/// A plain macOS-style menu bar with the app's icon lit.
func menuBar(iconX: CGFloat) {
    let bar = NSRect(x: 0, y: 0, width: W, height: Int(24 * s))
    NSColor(white: 0.96, alpha: 0.92).setFill(); bar.fill()
    let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 13 * s, weight: .medium), .foregroundColor: NSColor.black]
    ("Fri Oct 30  9:41 AM" as NSString).draw(at: NSPoint(x: CGFloat(W) - 175 * s, y: 4 * s), withAttributes: attrs)
    let bold: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 13 * s, weight: .bold), .foregroundColor: NSColor.black]
    ("Preview" as NSString).draw(at: NSPoint(x: 44 * s, y: 4 * s), withAttributes: bold)
    let apple = NSImage(systemSymbolName: "applelogo", accessibilityDescription: nil)!
        .withSymbolConfiguration(.init(pointSize: 14 * s, weight: .regular))!
    apple.draw(in: NSRect(x: 16 * s, y: 4 * s, width: apple.size.width, height: apple.size.height))
    // The app's "on" icon: the rainbow pointer.
    let path = NSBezierPath.pointerArrow(height: 16 * s, origin: NSPoint(x: iconX, y: 4 * s))
    let rainbow = [(1.0, 0.23, 0.19), (1.0, 0.58, 0.0), (1.0, 0.84, 0.0), (0.2, 0.82, 0.35), (0.0, 0.55, 1.0), (0.69, 0.32, 0.87)]
        .map { NSColor(srgbRed: $0.0, green: $0.1, blue: $0.2, alpha: 1) }
    NSColor(white: 0.1, alpha: 0.9).setStroke(); path.lineWidth = 1.2 * s; path.stroke()
    NSGradient(colors: rainbow)!.draw(in: path, angle: 60)
}

@main
enum StoreShots {
    @MainActor static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        UserDefaults.standard.set(true, forKey: "unlocked")
        UserDefaults.standard.set(true, forKey: "showAppRules")
        UserDefaults.standard.set(false, forKey: "extendedSizes")

        // 1. The big arrow on the slide (free tier, 5x).
        save(canvas { arrow(at: NSPoint(x: 2290, y: 500), size: 5, fill: NSColor(srgbRed: 1, green: 0.15, blue: 0.1, alpha: 1)) },
             "store-1-arrow.png")
        save(canvas { arrow(at: NSPoint(x: 1210, y: 640), size: 15, fill: NSColor(srgbRed: 0.2, green: 0.8, blue: 0.3, alpha: 1)) },
             "store-4-xl.png")

        // 2. The menu open from the menu bar.
        let presenting = Preset(name: "Presenting", size: 5, fill: .red, outline: .white)
        let recording = Preset(name: "Recording", size: 4, fill: RGBA(red: 0, green: 0.45, blue: 1), outline: .white)
        let huge = Preset(name: "Huge Green", size: 12, fill: RGBA(red: 0.2, green: 0.8, blue: 0.3), outline: .black)
        let rules = [
            AppRule(bundleID: "com.apple.Keynote", appName: "Keynote", presetID: presenting.id),
            AppRule(bundleID: "com.apple.FaceTime", appName: "FaceTime", presetID: presenting.id),
            AppRule(bundleID: "com.obsproject.obs-studio", appName: "OBS", presetID: recording.id),
        ]
        let store = PointerStore(snapshotOf: presenting, presets: [presenting, recording, huge], rules: rules)
        let host = NSHostingView(rootView: MenuView().environmentObject(store)
            .background(Color(nsColor: .windowBackgroundColor)).environment(\.colorScheme, .light))
        host.appearance = NSAppearance(named: .aqua)
        host.frame.size = host.fittingSize
        let menu = render(host)
        menu.size = NSSize(width: menu.size.width, height: menu.size.height) // already pixels at 2x
        let iconX = CGFloat(W) - 240 * s
        let menuX = min(iconX - menu.size.width / 2, CGFloat(W) - menu.size.width - 16 * s)
        save(canvas {
            arrow(at: NSPoint(x: 1300, y: 900), size: 5, fill: NSColor(srgbRed: 1, green: 0.15, blue: 0.1, alpha: 1))
            menuBar(iconX: iconX)
            panel(menu, at: NSPoint(x: menuX, y: 30 * s), radius: 12 * s)
        }, "store-2-menu.png")

        // 3. The Unlock offer, as Unlock.showOffer shows it (for the IAP review screenshot).
        let alert = NSAlert()
        alert.messageText = "Unlock everything"
        alert.informativeText = """
            One purchase of $9.99, yours to keep:
            • Sizes up to 30×
            • The Halo style
            • Presets and Cursor Recipes
            • App rules

            The big pointer, colors, the keyboard shortcut and Super shake stay free.
            """
        alert.icon = NSImage(contentsOfFile: dir + "/icon.png")
        alert.addButton(withTitle: "Unlock for $9.99")
        alert.addButton(withTitle: "Not Now")
        alert.addButton(withTitle: "Restore Purchase")
        alert.window.appearance = NSAppearance(named: .aqua)
        alert.layout()
        let content = alert.window.contentView!
        let offer = render(content)
        save(canvas {
            NSColor(white: 0, alpha: 0.18).setFill()
            NSRect(x: 0, y: 0, width: W, height: H).fill(using: .sourceOver)
            panel(offer, at: NSPoint(x: (CGFloat(W) - offer.size.width) / 2, y: (CGFloat(H) - offer.size.height) / 2 - 60), radius: 14 * s)
        }, "store-3-unlock.png")
        exit(0)
    }
}
