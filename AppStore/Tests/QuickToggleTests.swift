// Checks the App Store quick toggle (QuickToggle.swift) against the shared PointerStore.
// Run with AppStore/test.sh. Briefly draws the pointer on screen while it runs.
import AppKit

@main
enum QuickToggleTests {
    static func main() {
        let d = UserDefaults.standard
        for k in ["highlightSize", "highlightFill", "highlightOutline", "lastLook", "size", "customPresets", "appRules"] { d.removeObject(forKey: k) }
        d.set(1.0, forKey: "highlightSize") // start off
        _ = NSApplication.shared
        var failures = 0
        func check(_ ok: Bool, _ what: String) { print(ok ? "✓" : "✗", what); if !ok { failures += 1 } }

        CursorController.restore()
        let store = PointerStore()
        check(!store.isHighlightOn && !PointerHighlight.shared.isVisible, "starts off at 1×, nothing drawn")

        store.setHighlight(true)
        check(store.size == CursorController.firstLaunchSize && PointerHighlight.shared.isVisible, "on with no saved look → 3×, drawn")

        store.setSize(5); store.setFill(.red)
        store.setHighlight(false)
        check(store.size == 1 && store.fill == .black && store.activePresetID == PointerStore.defaultPresetID, "off → Default preset (1×, black/white)")
        check(!PointerHighlight.shared.isVisible, "off → nothing drawn")

        store.toggleHighlight()
        check(store.size == 5 && store.fill == .red && store.isHighlightOn, "toggle on → last look (5×, red)")

        store.toggleHighlight()
        let blue = RGBA(red: 0, green: 0.45, blue: 1)
        store.setFill(blue)
        check(store.size == 5 && store.fill == blue && PointerHighlight.shared.isVisible, "picking a color while off brings the size back")

        store.saveNewPreset(named: "Blue")
        store.toggleHighlight(); store.toggleHighlight()
        check(store.activePresetID == store.customPresets.first?.id, "turning on selects the preset that matches the last look")

        store.toggleHighlight()
        store.setHighlightStyle(.halo)
        check(store.isHighlightOn && CursorController.style == .halo, "changing style while off turns it on")
        CursorController.style = .arrow

        store.setHighlight(false)
        print(failures == 0 ? "all passed" : "\(failures) failed")
        exit(failures == 0 ? 0 : 1)
    }
}
