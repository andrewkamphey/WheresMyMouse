import Foundation

/// The App Store build's on/off switch. "Off" is the Default preset at 1×, where nothing is
/// drawn, so presets and app rules work exactly as in the direct build. "On" brings back the
/// last look that was on.
extension PointerStore {
    private static let lastLookKey = "lastLook"

    private struct Look: Codable {
        var size: Double
        var fill: RGBA
        var outline: RGBA
    }

    var isHighlightOn: Bool { size > 1.01 }

    func toggleHighlight() { setHighlight(!isHighlightOn) }

    func setHighlight(_ on: Bool) {
        guard on != isHighlightOn else { return }
        guard let defaultPreset = allPresets.first(where: { $0.id == Self.defaultPresetID }) else { return }
        if on {
            let look = lastLook
            let preset = allPresets.first { $0.matches(size: look.size, fill: look.fill, outline: look.outline) }
                ?? Preset(name: "", size: look.size, fill: look.fill, outline: look.outline)
            apply(preset)
        } else {
            lastLook = Look(size: size, fill: fill, outline: outline)
            apply(defaultPreset)
        }
    }

    /// Picking a color at 1× would show nothing, so bring the size back first.
    func revealIfOff() {
        guard !isHighlightOn else { return }
        setSize(lastLook.size)
    }

    private var lastLook: Look {
        get {
            UserDefaults.standard.data(forKey: Self.lastLookKey).flatMap { try? JSONDecoder().decode(Look.self, from: $0) }
                ?? Look(size: CursorController.firstLaunchSize, fill: fill, outline: outline)
        }
        set { UserDefaults.standard.set(try? JSONEncoder().encode(newValue), forKey: Self.lastLookKey) }
    }

    // MARK: Style and shortcut

    var highlightStyle: HighlightStyle { CursorController.style }

    func setHighlightStyle(_ style: HighlightStyle) {
        objectWillChange.send()
        if style != .arrow, !Unlock.shared.check() { return }
        CursorController.style = style
        revealIfOff()
    }

    var shortcutEnabled: Bool { GlobalShortcut.shared.isEnabled }

    func setShortcutEnabled(_ on: Bool) {
        objectWillChange.send()
        GlobalShortcut.shared.setEnabled(on)
    }
}
