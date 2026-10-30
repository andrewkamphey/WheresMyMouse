import AppKit
import StoreKit

/// The App Store build's one in-app purchase: a one-time Unlock. Free: the big pointer
/// (Arrow, 1–5×), colors, the quick toggle, the shortcut and Super shake. Unlocked: sizes up
/// to 30×, Halo, presets and Cursor Recipes, and app rules.
/// Used from the main thread only.
final class Unlock: ObservableObject {
    static let shared = Unlock()
    static let productID = "com.wheresmymouse.appstore.unlock"
    /// The largest size before unlocking.
    static let freeMaxSize: Double = 5

    /// Cached so the menu doesn't flash locked at launch; `refresh()` checks it with StoreKit.
    @Published var isUnlocked = UserDefaults.standard.bool(forKey: Unlock.unlockedKey) {
        didSet { UserDefaults.standard.set(isUnlocked, forKey: Self.unlockedKey) }
    }
    @Published private(set) var product: Product?
    @Published private(set) var isBusy = false
    /// What a locked feature does when used. Tests replace the alert.
    var onLocked: () -> Void = { Unlock.shared.showOffer() }

    private static let unlockedKey = "unlocked"
    private var updates: Task<Void, Never>?

    /// Starts listening for purchases (including ones made on another Mac, or approved later
    /// by Ask to Buy) and checks the current entitlement.
    func start() {
        updates = Task { @MainActor [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.refresh()
            }
        }
        Task { @MainActor in await refresh(); await loadProduct() }
    }

    /// True if unlocked. Otherwise offers the unlock and returns false.
    func check() -> Bool {
        if isUnlocked { return true }
        onLocked()
        return false
    }

    @MainActor
    func refresh() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID, transaction.revocationDate == nil {
                owned = true
            }
        }
        if owned != isUnlocked { isUnlocked = owned }
    }

    @MainActor
    private func loadProduct() async {
        guard product == nil else { return }
        product = try? await Product.products(for: [Self.productID]).first
    }

    // MARK: Buying

    @MainActor
    func buy() async {
        await loadProduct()
        guard let product else {
            alert("The App Store can't be reached right now", "Check your internet connection and try again.")
            return
        }
        isBusy = true
        defer { isBusy = false }
        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                isUnlocked = true
            case .success(.unverified):
                alert("The purchase couldn't be verified", "Try Restore Purchase, or try again later.")
            case .pending:
                alert("Waiting for approval", "Where's My Mouse? unlocks as soon as the purchase is approved.")
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            alert("The purchase didn't go through", error.localizedDescription)
        }
    }

    @MainActor
    func restore() async {
        isBusy = true
        defer { isBusy = false }
        try? await AppStore.sync() // asks to sign in if needed; cancelling just checks what's there
        await refresh()
        if !isUnlocked {
            alert("No purchase to restore", "This Apple Account hasn't bought the unlock. If you bought it with another one, sign in with that account in the App Store app.")
        }
    }

    var priceText: String { product?.displayPrice ?? "" }

    /// The offer shown when a locked feature is used.
    func showOffer() {
        Task { @MainActor in
            await loadProduct()
            let alert = NSAlert()
            alert.messageText = "Unlock everything"
            alert.informativeText = """
                One purchase\(priceText.isEmpty ? "" : " of \(priceText)"), yours to keep:
                • Sizes up to 30×
                • The Halo style
                • Presets and Cursor Recipes
                • App rules

                The big pointer, colors, the keyboard shortcut and Super shake stay free.
                """
            alert.icon = NSApp.applicationIconImage
            alert.addButton(withTitle: priceText.isEmpty ? "Unlock" : "Unlock for \(priceText)")
            alert.addButton(withTitle: "Not Now")
            alert.addButton(withTitle: "Restore Purchase")
            NSApp.activate(ignoringOtherApps: true)
            switch alert.runModal() {
            case .alertFirstButtonReturn: await buy()
            case .alertThirdButtonReturn: await restore()
            default: break
            }
        }
    }

    private func alert(_ title: String, _ detail: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = detail
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
