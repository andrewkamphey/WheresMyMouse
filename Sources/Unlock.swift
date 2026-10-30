import AmoreCheckout
import AmoreLicensing
import AppKit
import Combine
import Observation
import struct AmoreStore.AmoreStore
import struct AmoreStore.Product

/// The direct download's one purchase: a one-time Unlock, sold through Amore. Checkout opens in
/// the browser (Stripe, Apple Pay); once paid, the license activates on this Mac by itself. The
/// license key (emailed, and shown after paying) unlocks another Mac. Same free tier as the
/// App Store build (AppStore/Sources/Unlock.swift): sizes up to 5×, colors, Super shake and
/// macOS shake to find. Unlocked: sizes up to 30×, presets and Cursor Recipes, and app rules.
/// Used from the main thread only.
final class Unlock: ObservableObject {
    static let shared = Unlock()
    /// The largest size before unlocking.
    static let freeMaxSize: Double = 5

    @Published private(set) var isUnlocked = false
    /// The email the license belongs to, when unlocked.
    @Published private(set) var licensedTo: String?
    @Published private(set) var product: Product?
    /// True while a checkout waits for payment in the browser.
    @Published private(set) var isBusy = false
    /// What a locked feature does when used.
    var onLocked: () -> Void = { Unlock.shared.showOffer() }

    /// nil until Amore's public key replaces the placeholder in Info.plist: everything stays locked.
    private let licensing: AmoreLicensing?
    @MainActor private var checkout: AmoreCheckout?

    // AmoreLicensing is main-actor isolated, and Unlock is only used on the main thread.
    private init() {
        licensing = MainActor.assumeIsolated {
            Bundle.main.configuredValue("AmoreLicensingPublicKey").flatMap { try? AmoreLicensing(publicKey: $0) }
        }
        sync() // a license already verified on this Mac is known right away, offline too
    }

    /// Keeps `isUnlocked` in step with the license, loads the price, and finishes a purchase that
    /// was interrupted (the app quit after paying).
    @MainActor
    func start() {
        guard let licensing else { return }
        let checkout = AmoreCheckout(licensing: licensing)
        self.checkout = checkout
        observe()
        Task { @MainActor in
            _ = await checkout.recoverPendingPurchase()
            await loadProduct()
        }
    }

    /// Re-checks the license. Cheap: it's verified on this Mac and only asks Amore now and then.
    func refresh() {
        guard let licensing else { return }
        Task { @MainActor in _ = try? await licensing.validate() }
    }

    /// True if unlocked. Otherwise offers the unlock and returns false.
    func check() -> Bool {
        if isUnlocked { return true }
        onLocked()
        return false
    }

    private func observe() {
        guard let licensing else { return }
        withObservationTracking { _ = MainActor.assumeIsolated { licensing.status } } onChange: { [weak self] in
            DispatchQueue.main.async { self?.sync(); self?.observe() }
        }
    }

    private func sync() {
        switch MainActor.assumeIsolated({ licensing?.status }) {
        case .valid(let license), .gracePeriod(let license):
            if !isUnlocked { isUnlocked = true }
            if licensedTo != license.customer?.email { licensedTo = license.customer?.email }
        default:
            if isUnlocked { isUnlocked = false }
            if licensedTo != nil { licensedTo = nil }
        }
    }

    @MainActor
    private func loadProduct() async {
        guard product == nil, licensing != nil else { return }
        product = try? await AmoreStore().products().first
    }

    var priceText: String { product?.displayPrice ?? "" }

    // MARK: Buying

    @MainActor
    func buy() async {
        guard let checkout else { return notAvailable() }
        await loadProduct()
        guard let product else {
            alert("The store can't be reached right now", "Check your internet connection and try again.")
            return
        }
        isBusy = true
        defer { isBusy = false }
        openWhenReady(checkout)
        switch await checkout.start(product) {
        case .completed:
            alert("Thank you!", "Everything is unlocked on this Mac. Your license key is in your email: enter it on your other Macs.")
        case .cancelled:
            break
        case .failed(.activationFailed(let licenseKey, _)):
            alert("Paid, but this Mac didn't unlock", "Your license key is \(licenseKey) (it's in your email too). Choose Enter License Key… to try again.")
        case .failed(let error):
            alert("The purchase didn't go through", error.localizedDescription)
        }
    }

    /// Opens the checkout page in the browser as soon as Amore has created it.
    @MainActor
    private func openWhenReady(_ checkout: AmoreCheckout) {
        withObservationTracking { _ = checkout.state } onChange: { [weak self] in
            Task { @MainActor in
                switch checkout.state {
                case .awaitingPayment(let url): NSWorkspace.shared.open(url)
                case .idle, .preparing: self?.openWhenReady(checkout)
                default: break
                }
            }
        }
    }

    /// Stops waiting for a payment that was abandoned in the browser.
    @MainActor
    func cancelPurchase() {
        checkout?.cancel()
    }

    // MARK: License key

    @MainActor
    func enterLicenseKey() async {
        guard let licensing else { return notAvailable() }
        let prompt = NSAlert()
        prompt.messageText = "Enter your license key"
        prompt.informativeText = "It's in the email you got after buying."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        field.placeholderString = "License key"
        prompt.accessoryView = field
        prompt.addButton(withTitle: "Unlock")
        prompt.addButton(withTitle: "Cancel")
        prompt.window.initialFirstResponder = field
        NSApp.activate(ignoringOtherApps: true)
        guard prompt.runModal() == .alertFirstButtonReturn else { return }
        let key = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        do {
            try await licensing.activate(licenseKey: key)
            alert("Unlocked", "Everything is unlocked on this Mac.")
        } catch {
            alert("That key didn't work", error.localizedDescription)
        }
    }

    /// Frees the license for another Mac.
    @MainActor
    func deactivate() async {
        guard let licensing else { return }
        let confirm = NSAlert()
        confirm.messageText = "Remove the license from this Mac?"
        confirm.informativeText = "That frees it up for another Mac. Your license key unlocks this one again anytime."
        confirm.addButton(withTitle: "Remove")
        confirm.addButton(withTitle: "Cancel")
        NSApp.activate(ignoringOtherApps: true)
        guard confirm.runModal() == .alertFirstButtonReturn else { return }
        do {
            try await licensing.deactivate()
        } catch {
            alert("The license couldn't be removed", error.localizedDescription)
        }
    }

    /// Amore's customer portal: look up a lost license key, see which Macs use it.
    @MainActor
    func openPortal() {
        guard let checkout else { return notAvailable() }
        NSWorkspace.shared.open(checkout.portalURL)
    }

    // MARK: Offer

    /// The offer shown when a locked feature is used.
    func showOffer() {
        Task { @MainActor in
            await loadProduct()
            let alert = NSAlert()
            alert.messageText = "Unlock everything"
            alert.informativeText = """
                One purchase\(priceText.isEmpty ? "" : " of \(priceText)"), yours to keep:
                • Sizes up to 30×
                • Presets and Cursor Recipes
                • App rules

                Sizes up to 5×, colors, Super shake and macOS shake to find stay free.
                """
            alert.icon = NSApp.applicationIconImage
            alert.addButton(withTitle: priceText.isEmpty ? "Unlock" : "Unlock for \(priceText)")
            alert.addButton(withTitle: "Not Now")
            alert.addButton(withTitle: "Enter License Key…")
            NSApp.activate(ignoringOtherApps: true)
            switch alert.runModal() {
            case .alertFirstButtonReturn: await buy()
            case .alertThirdButtonReturn: await enterLicenseKey()
            default: break
            }
        }
    }

    private func notAvailable() {
        alert("Unlocking isn't set up in this build", "Download Where's My Mouse? from wheresmymouse.com to unlock it.")
    }

    private func alert(_ title: String, _ detail: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = detail
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
