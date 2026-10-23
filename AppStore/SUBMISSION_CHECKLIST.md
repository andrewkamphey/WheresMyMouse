# Submitting the App Store version: what to do by hand

Everything here needs your Apple account, your keychain or your judgment, so none of it was done for you. Answer QUESTIONS.md first: the bundle ID can't change after the first upload.

## 1. Decide

- [ ] Price, bundle ID, minimum macOS and the other defaults in QUESTIONS.md. If the bundle ID changes, edit `PRODUCT_BUNDLE_IDENTIFIER` in `AppStore/AppStore.xcconfig`.

## 2. Apple Developer portal (developer.apple.com → Certificates, IDs & Profiles)

- [ ] **Register the App ID.** Identifiers → **+** → App IDs → App:
  - Explicit Bundle ID `com.wheresmymouse.appstore`, description "Where's My Mouse App Store".
  - No capabilities to tick: the App Sandbox is an entitlement, not a portal capability.
- [ ] **Certificates.** Signing for the store needs two certificates:
  - **Apple Distribution**: your keychain already lists one for team T99P47AGU6.
  - **Mac Installer Distribution**: Xcode calls it "3rd Party Mac Developer Installer", and it signs the uploaded package.

  With automatic signing, Xcode creates whatever is missing the first time you distribute (Xcode → Settings → Accounts → Manage Certificates shows them). Your Developer ID certificate isn't used for the store.
- [ ] **Provisioning profile.** Automatic signing creates a Mac App Store profile for the App ID. TestFlight rejects uploads without one (ITMS-90889).

## 3. App Store Connect (appstoreconnect.apple.com)

- [ ] My Apps → **+** → New App:
  - Platform: macOS
  - Name: Where's My Mouse?
  - Primary language: English (U.S.)
  - Bundle ID: `com.wheresmymouse.appstore`
  - SKU: e.g. `WHERESMYMOUSE-MAS`
- [ ] **App Information:** subtitle, category Utilities (secondary: Productivity), content rights (no third-party content), age rating 4+. Use AppStore/METADATA.md.
- [ ] **Privacy Policy URL:** publish a privacy page first (METADATA.md has the text; QUESTIONS.md Q6).
- [ ] **App Privacy:** Get Started → "No, we do not collect data from this app" → Publish.
- [ ] **Pricing and Availability:** price (QUESTIONS.md Q1) and countries.
- [ ] **Version page (1.0.0):** promotional text, description, keywords, support and marketing URLs, copyright, screenshots, and App Review contact (name, phone, email). Sign-in: not required. Paste the review notes from METADATA.md.

## 4. Build and upload

This Mac runs macOS 14.6.1. Xcode 26 needs macOS 15.6, but Apple has no minimum SDK for Mac uploads, and **Xcode 16.2 runs on macOS 14.5+**.

- [ ] Install **Xcode 16.2**, or newer if you update macOS, from developer.apple.com/download/all. Then run `sudo xcode-select -s /Applications/Xcode.app`.
- [ ] Install XcodeGen and generate the project:
  ```bash
  brew install xcodegen
  ```
  ```bash
  xcodegen generate --spec AppStore/project.yml
  ```
- [ ] Open `AppStore/WheresMyMouse.xcodeproj`. In the WheresMyMouse target, under **Signing & Capabilities**, keep "Automatically manage signing" with team Andrew Kamphey (T99P47AGU6). It should show the App Sandbox and "User Selected File: Read Only" from `WheresMyMouse.entitlements`.
- [ ] Bump the build number for every upload: `CURRENT_PROJECT_VERSION` in `AppStore/AppStore.xcconfig`. Bump `MARKETING_VERSION` for each new App Store version.
- [ ] **Product → Archive**, with destination "Any Mac".
- [ ] In the Organizer: **Validate App**, then **Distribute App → App Store Connect → Upload**. Xcode signs with Apple Distribution and embeds the profile.
- [ ] Wait for the "processing complete" email (usually 5–30 minutes).

Alternative upload path: Distribute App → **Export** for App Store Connect gives a `.pkg`, which you then drag into **Transporter** (already installed). Since February 2025, files with a `com.apple.quarantine` attribute are rejected; an Xcode export doesn't have one.

## 5. Test before submitting

- [ ] **Quit the direct-download app first.** Both would draw or resize the pointer at once.
- [ ] Both builds are called "Where's My Mouse.app". Move the direct one out of /Applications while TestFlight or App Store installs the store one (QUESTIONS.md Q2).
- [ ] TestFlight (macOS): add yourself as an internal tester and install the build. Then check:
  - [ ] First launch shows a 3× arrow that follows the mouse on every display, over full-screen apps and in every Space.
  - [ ] The header switch, a right-click on the icon, and ⌃⌥⌘M all toggle it.
  - [ ] Size, fill, outline, Arrow/Halo and Extra large sizes work.
  - [ ] Super shake works with the pointer off and on.
  - [ ] Presets: new, rename, update, delete and undo, ⌘1–⌘9, and Recipes.
  - [ ] App rules: the Open panel picks an app, and the pointer switches while that app is in front.
  - [ ] Launch at login: turn it on, log out and in, and it starts. Turn it off again.
  - [ ] A `wheresmymouse://recipe?...` link from wheresmymouse.com/recipes opens the store build and asks before adding.
  - [ ] With the App Store app in front, the drawn pointer pauses and its install button works.
- [ ] Locally, without TestFlight: `AppStore/build.sh --run` builds the same app sandboxed and signed ad-hoc.

## 6. Screenshots

Mac screenshots are 16:10: 2880×1800 (Retina full screen), 2560×1600, 1440×900 or 1280×800. You need 1 to 10.

- [ ] Use a clean desktop with no personal files, notifications or other apps' private content.
- [ ] macOS screenshots (⌘⇧5) **include the drawn pointer**, because it's a window. Under ⌘⇧5 → Options, turn on "Show Mouse Pointer" to include the real one too.
- [ ] Suggested shots and captions are in METADATA.md. `AppStore/snapshot-menu.sh` renders the menu on its own (`AppStore/menu.png`, `menu-dark.png`), handy for a composed shot.

## 7. Submit

- [ ] On the version page, choose the processed build, then **Add for Review → Submit**. Pick manual or automatic release.
- [ ] If App Review asks about the pointer: it's drawn by the app in click-through windows, the system pointer and its settings aren't changed, and no permissions are requested. The review notes already say this.

## 8. After approval

- [ ] Optional, and out of this PR's scope: add an App Store badge on wheresmymouse.com.
- [ ] The direct download keeps shipping from `.github/workflows/release.yml`, unchanged.
