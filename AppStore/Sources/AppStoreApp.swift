import AppKit
import Combine
import SwiftUI

/// App Store build entry point: the same menu as the direct build, around a drawn pointer
/// (`PointerHighlight`) instead of the system one. Sandboxed, public APIs only.
@main
enum WheresMyMouseMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) { app.run() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var store: PointerStore?
    private var hosting: NSHostingController<AnyView>?
    private var changes: AnyCancellable?
    private var unlockChanges: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        CursorController.restore()
        let store = PointerStore()
        let hosting = NSHostingController(rootView: AnyView(MenuView().environmentObject(store)))
        popover.contentViewController = hosting
        popover.behavior = .transient
        self.store = store
        self.hosting = hosting

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.target = self
        item.button?.action = #selector(statusItemClicked(_:))
        // Right-click (or Control-click) is the quick toggle; a plain click opens the menu.
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItem = item

        // Unlocking (or a refund) changes the size range, the style and app rules.
        unlockChanges = Unlock.shared.$isUnlocked.dropFirst().removeDuplicates().sink { [weak store] unlocked in
            DispatchQueue.main.async {
                guard let store else { return }
                PointerHighlight.shared.style = CursorController.style
                if !unlocked, store.size > Unlock.freeMaxSize { store.setSize(Unlock.freeMaxSize) }
                store.setAppRulesEnabled(store.appRulesEnabled)
                store.objectWillChange.send()
            }
        }
        Unlock.shared.start()

        GlobalShortcut.shared.onPress = { [weak store] in store?.toggleHighlight() }
        GlobalShortcut.shared.start()

        // Keep the popover sized to its SwiftUI content, and the icon showing on or off.
        changes = store.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.fitPopover(); self?.updateIcon() }
        }
        updateIcon()
    }

    /// wheresmymouse://recipe links from the website's Cursor Recipes.
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let store = store else { return }
        for url in urls { RecipeMenu.handle(url, store: store) { [weak self] in self?.showPopover() } }
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            popover.performClose(sender)
            store?.toggleHighlight()
            return
        }
        if popover.isShown {
            popover.performClose(sender)
            return
        }
        showPopover()
    }

    private func showPopover() {
        guard let sender = statusItem?.button, !popover.isShown else { return }
        store?.refresh()
        fitPopover()
        NSApp.activate(ignoringOtherApps: true) // so text fields take typing
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func updateIcon() {
        guard let button = statusItem?.button else { return }
        let on = store?.isHighlightOn ?? false
        button.image = on ? Self.onIcon : Self.offIcon
        button.toolTip = "Where's My Mouse? (\(on ? "on" : "off"))\nRight-click or \(GlobalShortcut.label) to turn it \(on ? "off" : "on")"
        button.setAccessibilityLabel("Where's My Mouse, \(on ? "on" : "off")")
    }

    private func fitPopover() {
        guard let view = hosting?.view else { return }
        let size = view.fittingSize
        if size.width > 0, size.height > 0, size != popover.contentSize { popover.contentSize = size }
    }

    /// The app icon's rainbow pointer while on: full color, so it isn't mistaken for the
    /// real pointer sitting in the menu bar.
    private static let onIcon: NSImage = {
        NSImage(size: NSSize(width: 12, height: 18), flipped: true) { _ in
            let path = NSBezierPath.pointerArrow(height: 16, origin: NSPoint(x: 1.5, y: 1))
            let rainbow = [(1.0, 0.23, 0.19), (1.0, 0.58, 0.0), (1.0, 0.84, 0.0), (0.2, 0.82, 0.35), (0.0, 0.55, 1.0), (0.69, 0.32, 0.87)]
                .map { NSColor(srgbRed: $0.0, green: $0.1, blue: $0.2, alpha: 1) }
            NSColor(white: 0.1, alpha: 0.9).setStroke()
            path.lineWidth = 1.2
            path.stroke()
            NSGradient(colors: rainbow)!.draw(in: path, angle: 60)
            return true
        }
    }()

    /// While off: just the outline, in the menu bar's own color.
    private static let offIcon: NSImage = {
        let image = NSImage(size: NSSize(width: 12, height: 18), flipped: true) { _ in
            let path = NSBezierPath.pointerArrow(height: 16, origin: NSPoint(x: 1.5, y: 1))
            NSColor.black.setStroke()
            path.lineWidth = 1.2
            path.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }()
}
