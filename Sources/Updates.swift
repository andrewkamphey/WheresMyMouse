import AppKit
import Sparkle

/// Automatic updates with Sparkle. Amore hosts the appcast (SUFeedURL in Info.plist) and signs
/// each update with the key whose public half is SUPublicEDKey. Sparkle checks daily and asks
/// before installing.
enum Updates {
    private static var controller: SPUStandardUpdaterController?

    /// Stays off until Amore's values replace the placeholders in Info.plist.
    static func start() {
        guard Bundle.main.configuredValue("SUFeedURL") != nil, Bundle.main.configuredValue("SUPublicEDKey") != nil else { return }
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    static var isAvailable: Bool { controller != nil }

    static func check() {
        NSApp.activate(ignoringOtherApps: true)
        controller?.checkForUpdates(nil)
    }
}

extension Bundle {
    /// An Info.plist value, or nil while it's still a REPLACE_WITH_… placeholder (build.sh won't
    /// make a release until they're filled in).
    func configuredValue(_ key: String) -> String? {
        guard let value = object(forInfoDictionaryKey: key) as? String, !value.isEmpty, !value.contains("REPLACE_WITH") else { return nil }
        return value
    }
}
