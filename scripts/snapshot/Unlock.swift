// Stands in for Sources/Unlock.swift and Sources/Updates.swift, which need AmoreKit and Sparkle
// (SwiftPM), so scripts/snapshot-menu.sh can render the menu with plain swiftc.
import Foundation

final class Unlock: ObservableObject {
    static let shared = Unlock()
    static let freeMaxSize: Double = 5
    /// LOCKED=1 renders the free menu, with its Unlock row.
    let isUnlocked = ProcessInfo.processInfo.environment["LOCKED"] == nil
    let licensedTo: String? = nil
    let isBusy = false
    let priceText = "$9.99"
    func check() -> Bool { isUnlocked }
    func buy() async {}
    func cancelPurchase() {}
    func enterLicenseKey() async {}
    func deactivate() async {}
    func openPortal() {}
}

enum Updates {
    static let isAvailable = true
    static func check() {}
}
