import Carbon.HIToolbox
import Foundation

/// ⌃⌥⌘M from any app turns the drawn pointer on or off. Uses Carbon's RegisterEventHotKey,
/// which works in the App Sandbox without Accessibility or Input Monitoring access
/// (watching key presses with NSEvent monitors would need both).
final class GlobalShortcut {
    static let shared = GlobalShortcut()

    /// How the shortcut is shown in the menu.
    static let label = "⌃⌥⌘M"
    private static let enabledKey = "shortcutEnabled"

    var onPress: (() -> Void)?

    private(set) var isEnabled = UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?

    func setEnabled(_ on: Bool) {
        isEnabled = on
        UserDefaults.standard.set(on, forKey: Self.enabledKey)
        on ? register() : unregister()
    }

    /// Registers the shortcut if it's turned on. Call once at launch.
    func start() {
        if isEnabled { register() }
    }

    private func register() {
        guard hotKey == nil else { return }
        if handler == nil {
            var pressed = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
                DispatchQueue.main.async { GlobalShortcut.shared.onPress?() }
                return noErr
            }, 1, &pressed, nil, &handler)
        }
        let id = EventHotKeyID(signature: OSType(0x574D_4D53), id: 1) // "WMMS"
        let status = RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(controlKey | optionKey | cmdKey), id,
                                         GetApplicationEventTarget(), 0, &hotKey)
        if status != noErr { NSLog("WheresMyMouse: couldn't register \(Self.label) (\(status)); another app may use it") }
    }

    private func unregister() {
        if let hotKey { UnregisterEventHotKey(hotKey) }
        hotKey = nil
    }
}
