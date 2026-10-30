# Summary: Mac App Store version

## What was built

A Mac App Store version of Where's My Mouse in `AppStore/`, next to the direct download, which is unchanged. It's sandboxed, uses public APIs only, and asks for no permissions.

**How it works.** The real pointer can't be resized or recolored from the App Store (FEASIBILITY.md). Instead, the app draws a bigger pointer in small click-through windows that follow the mouse, one per display. There are two styles: **Arrow** (a big arrow with its tip on the real pointer's tip) and **Halo** (a translucent disc and ring). 1× means nothing is drawn, which is the Default preset. Because of that, presets, Cursor Recipes, app rules and Super shake from the direct build all work unchanged.

**Core experience kept:**
- **Quick toggle:** a switch in the menu header, a right-click on the menu bar icon, or ⌃⌥⌘M from any app. Turning it on brings back the last look.
- **Size:** 1–10×, or 1–30× with Extra large sizes.
- **Fill and outline colors:** swatches or any color.
- **Also kept:** presets (⌘1–⌘9), Recipes, app rules, Super shake (now also works while off), launch at login and `wheresmymouse://` recipe links.

**Free with a $9.99 Unlock** (added 2026-10-30, `AppStore/Sources/Unlock.swift`, StoreKit 2): free is Arrow at 1–5×, colors, the quick toggle, the shortcut and Super shake. The one-time Unlock adds 6–30×, Halo, presets, Recipes and app rules. Locked features show an "Unlock everything" offer with Restore Purchase; the menu has an Unlock row until bought. `AppStore/WheresMyMouse.storekit` lets you test the purchase from Xcode.

**Dropped from the App Store build:**
- Full Disk Access, which isn't needed.
- The macOS "shake to find" switch: the sandbox can't write that setting.
- The "Browse recipes on wheresmymouse.com" link (QUESTIONS.md Q5).

**Files**

| Path | What |
|---|---|
| `AppStore/FEASIBILITY.md` | Rules, approaches, spike results, competitors, chosen design |
| `AppStore/QUESTIONS.md` | 13 decisions for you, each with the default that's built |
| `AppStore/Sources/` | App Store-only code: entry point, `CursorController` stand-in, `PointerHighlight` (the drawing), `GlobalShortcut`, `QuickToggle`, menu additions |
| `Sources/PointerStore.swift`, `MenuView.swift`, `RecipeMenu.swift` | Shared; App Store differences behind `#if APP_STORE` (+68 lines, nothing removed) |
| `AppStore/AppStore.xcconfig`, `Info.plist`, `WheresMyMouse.entitlements`, `PrivacyInfo.xcprivacy` | Bundle ID `com.wheresmymouse.appstore`, v1.0.0, macOS 13+, sandbox + user-selected read-only files, privacy manifest |
| `AppStore/project.yml` | XcodeGen spec for the Xcode project you archive and upload |
| `AppStore/build.sh` | Command Line Tools build for local testing (sandboxed, ad-hoc signed); `--run` opens it |
| `AppStore/check-public-api.sh` | Fails if a build has private symbols, private framework or function names, or no sandbox |
| `AppStore/test.sh`, `AppStore/Tests/` | Quick toggle checks |
| `AppStore/snapshot-menu.sh`, `menu.png`, `menu-dark.png` | Renders the App Store menu |
| `AppStore/METADATA.md` | Name, subtitle, description, keywords, privacy, review notes, screenshot plan |
| `AppStore/SUBMISSION_CHECKLIST.md` | What you do by hand: App ID, certificates, App Store Connect, the in-app purchase, archive, upload, TestFlight, screenshots |
| `.github/workflows/appstore.yml` | On PRs and main: both builds, the API check and the tests. Nothing is uploaded. |
| `spike/sandbox_overlay.swift` | The sandbox experiment behind FEASIBILITY.md |

## What works (verified)

- **The direct build is unchanged.**
  - With the `#if` blocks resolved the way the direct build compiles them, the three shared files are line-for-line identical to `main`.
  - The direct menu renders pixel-identical to `main`.
  - `./build.sh` still builds.
  - `release.yml` is untouched.
- **The App Store build compiles** with the Command Line Tools: arm64 locally, universal in CI.
- **The public-API check passes.** As a control, it fails the direct build, listing all of its private calls.
- **It runs sandboxed on this Mac** (macOS 14.6.1, two displays):
  - The window server shows the pointer window at the screen-saver level, following the mouse on both displays, with the tip within rounding of the mouse position.
  - Captures of its windows show the arrow, the halo and a 10× arrow drawn correctly.
- **In the sandbox spike, no permission prompt appeared:** mouse monitors received events, and the ⌃⌥⌘M hot key registered.
- **The toggle logic passes 8 checks:** starts off, on → 3×, off → Default, last look restored, a color picked while off brings it back, a matching preset gets selected, a style change turns it on.
- **The menu renders correctly** in light and dark, on and off (`AppStore/menu*.png`).

## Not verified yet

- **The Xcode build in CI** (XcodeGen → `xcodebuild`): see the PR checks. The Command Line Tools build, the API check and the tests are the same in both.
- **Clicked through by hand:**
  - pressing ⌃⌥⌘M (registration was checked, a key press wasn't)
  - right-clicking the icon
  - the Open panel for app rules inside the sandbox
  - launch at login
  - full-screen apps, Spaces and Mission Control
  - the pause while the App Store app is in front

  These need someone at the keyboard. They're listed in `SUBMISSION_CHECKLIST.md` §5. I didn't take over your screen while you were using it.
- **Other macOS versions:** only tested on 14.6.1, not on macOS 13, 15 or 26.
- **Signing with Apple Distribution, uploading, TestFlight, App Review:** not done, as asked.

## What doesn't match the direct build

- The real pointer stays visible on top. With Arrow, the small system pointer shows at the big one's tip. "Match its colors…" opens Accessibility → Pointer so people can make it blend in.
- The drawn pointer is always an arrow or halo; the real hand or I-beam shows on top.
- It stays visible when an app hides the pointer (typing, full-screen video).
- It appears in screenshots, as it does in recordings.
- It may trail slightly on very fast moves.
- macOS 13+ instead of 11+.

## What's left

1. Answer QUESTIONS.md, especially Q1 (price) and Q2 (bundle ID).
2. Check the PR's CI result. If the Xcode step fails, it's most likely a build-setting precedence issue in `project.yml`; the step's log names it.
3. Hand-test the items above (`AppStore/build.sh --run` with the direct app quit, or TestFlight).
4. Follow `AppStore/SUBMISSION_CHECKLIST.md`: App ID, App Store Connect record, the Unlock purchase, screenshots, archive with Xcode 27, upload, submit.
5. Optional follow-ups:
   - a shortcut recorder (Q4)
   - hide while idle (Q10)
   - mention the App Store version on the site and README (Q13)
