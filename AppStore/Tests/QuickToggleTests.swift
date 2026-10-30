// Checks the App Store quick toggle (QuickToggle.swift) against the shared PointerStore.
// Run with AppStore/test.sh. Briefly draws the pointer on screen while it runs.
import AppKit

@main
enum QuickToggleTests {
    static func main() {
        let d = UserDefaults.standard
        for k in ["highlightSize", "highlightFill", "highlightOutline", "lastLook", "size", "customPresets", "appRules", "unlocked", "highlightStyle", "extendedSizes"] { d.removeObject(forKey: k) }
        d.set(1.0, forKey: "highlightSize") // start off
        _ = NSApplication.shared
        var failures = 0
        func check(_ ok: Bool, _ what: String) { print(ok ? "✓" : "✗", what); if !ok { failures += 1 } }

        var offers = 0
        Unlock.shared.onLocked = { offers += 1 }
        Unlock.shared.isUnlocked = true

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

        // Before unlocking
        Unlock.shared.isUnlocked = false
        store.setHighlight(true)
        store.setSize(8)
        check(store.size == Unlock.freeMaxSize && store.maxSize == Unlock.freeMaxSize, "locked: sizes stop at 5×")
        offers = 0
        store.setExtendedSizes(true)
        check(!store.extendedSizes && offers == 1, "locked: Extra large sizes offers the unlock")
        store.setHighlightStyle(.halo)
        check(CursorController.style == .arrow && offers == 2, "locked: Halo offers the unlock, stays Arrow")
        let presetCount = store.customPresets.count
        store.saveNewPreset(named: "Nope")
        store.addRecipe(name: "Klein Blue", size: 6, fill: blue, outline: .white)
        check(store.customPresets.count == presetCount && offers == 4, "locked: new presets and recipes offer the unlock")
        store.toggleHighlight(); store.toggleHighlight()
        check(store.isHighlightOn && store.size <= Unlock.freeMaxSize, "locked: the quick toggle still works")

        Unlock.shared.isUnlocked = true
        store.setSize(8)
        check(store.size == 8 && offers == 4, "unlocked: 6–10× without an offer")
        store.setExtendedSizes(true); store.setSize(20)
        check(store.size == 20, "unlocked: Extra large sizes to 30×")
        store.setExtendedSizes(false)

        store.setHighlight(false)
        print(failures == 0 ? "all passed" : "\(failures) failed")
        exit(failures == 0 ? 0 : 1)
    }
}
