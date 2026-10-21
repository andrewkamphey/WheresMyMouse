// Spike: can a sandboxed app (public APIs only) draw a pointer highlight that follows the mouse?
// Checks: a click-through overlay window per screen, global + local mouse monitors, a
// Carbon global hotkey, and whether the real pointer can be hidden from the background.
// Results go to spike-results.txt in the container's Documents folder. Results on macOS 14.6
// (2026-10-22) are in FEASIBILITY.md. To run it, compile into an .app with LSUIElement, sign
// ad-hoc with only the com.apple.security.app-sandbox entitlement, and `open` it.
import AppKit
import Carbon.HIToolbox

var log: [String] = []
func note(_ s: String) {
    print(s)
    log.append(s)
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("spike-results.txt")
    try? log.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

note("home: \(NSHomeDirectory())")
note("sandboxed: \(ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil)")

// One borderless, click-through window per screen; the highlight is a layer moved inside it.
var layers: [(NSScreen, CAShapeLayer)] = []
var windows: [NSWindow] = []
for screen in NSScreen.screens {
    let window = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
    window.isOpaque = false
    window.backgroundColor = .clear
    window.hasShadow = false
    window.ignoresMouseEvents = true
    window.level = .screenSaver
    window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
    window.setFrame(screen.frame, display: false)
    let view = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
    view.wantsLayer = true
    let ring = CAShapeLayer()
    ring.path = CGPath(ellipseIn: CGRect(x: -40, y: -40, width: 80, height: 80), transform: nil)
    ring.fillColor = NSColor.systemYellow.withAlphaComponent(0.35).cgColor
    ring.strokeColor = NSColor.systemRed.cgColor
    ring.lineWidth = 4
    ring.contentsScale = screen.backingScaleFactor
    view.layer?.addSublayer(ring)
    window.contentView = view
    window.orderFrontRegardless()
    windows.append(window)
    layers.append((screen, ring))
}
note("overlay windows: \(windows.count), visible: \(windows.map(\.isVisible))")

func follow() {
    let mouse = NSEvent.mouseLocation
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    for (screen, layer) in layers {
        layer.position = CGPoint(x: mouse.x - screen.frame.minX, y: mouse.y - screen.frame.minY)
    }
    CATransaction.commit()
}
follow()

var globalEvents = 0
var localEvents = 0
let mask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { _ in globalEvents += 1; follow() }
let localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { event in localEvents += 1; follow(); return event }
note("global monitor installed: \(globalMonitor != nil), local: \(localMonitor != nil)")

// Carbon global hotkey: ⌃⌥⌘M.
var hotKeyRef: EventHotKeyRef?
var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
let handlerStatus = InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in note("hotkey pressed"); return noErr }, 1, &spec, nil, nil)
let hotKeyStatus = RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(cmdKey | optionKey | controlKey),
                                       EventHotKeyID(signature: 0x574D4D53, id: 1), GetApplicationEventTarget(), 0, &hotKeyRef)
note("hotkey handler: \(handlerStatus), register: \(hotKeyStatus) (0 = ok)")

// Can a background app hide the real pointer with public API? (The direct app needs a private call.)
let hideResult = CGDisplayHideCursor(CGMainDisplayID())
note("CGDisplayHideCursor from background: \(hideResult.rawValue) (0 = call accepted; visible effect must be checked by eye)")
CGDisplayShowCursor(CGMainDisplayID())

// Reading another app's preferences from the sandbox (System Settings' pointer size).
let uaSize = CFPreferencesCopyValue("mouseDriverCursorSize" as CFString, "com.apple.universalaccess" as CFString,
                                    kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
note("read com.apple.universalaccess mouseDriverCursorSize: \(String(describing: uaSize))")

let duration = Double(CommandLine.arguments.dropFirst().first ?? "") ?? 20
DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
    // Window list check from the window server's side: are our windows on screen, at what level?
    let info = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
    let ours = info.filter { ($0[kCGWindowOwnerPID as String] as? Int32) == ProcessInfo.processInfo.processIdentifier }
    note("on-screen windows owned by us: \(ours.count), layers: \(ours.compactMap { $0[kCGWindowLayer as String] as? Int })")
    note("mouse events seen: global \(globalEvents), local \(localEvents)")
    exit(0)
}
app.run()
