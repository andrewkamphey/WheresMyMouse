# Feasibility: a Mac App Store version of Where's My Mouse?

Checked 2026-10-22, against the App Review Guidelines last updated 2026-10-16.

## Verdict

**It's feasible, with one visible compromise.** The App Store version can't touch the real pointer. Instead it draws its own pointer (a bigger arrow, or a halo) in small click-through windows that follow the mouse. That uses public APIs, works in the App Sandbox, and asks for no permissions. It keeps the core experience: a quick on/off toggle, sizes from 1× to 30×, fill and outline colors, presets, Cursor Recipes, app rules and Super shake.

The compromise: **the real pointer stays visible on top of the drawn one.** macOS has no public way to resize, recolor or hide the pointer while another app is in front. So the drawn arrow sits under the real one, tips lined up, and the small system arrow shows at its tip. The halo style avoids the look by drawing a ring around the pointer instead. The menu links to Accessibility → Pointer, where people can give the real pointer the same colors so it blends in.

Nine cursor-highlight apps are on the Mac App Store today, and all of them use this overlay approach. None claims to change the system pointer.

## What Apple's rules require

| Rule | What it says (short) | What it means for this app |
|---|---|---|
| 2.5.1 | Public APIs only | The direct build's size and color calls are private (`CGSSetCursorScale`, `_AXInterfaceSetCursorColorFill/Outline`, `AXFCursorRegisterAll`), and so is its way of hiding the pointer for 16–30× (`SetsCursorInBackground`). None of them can ship. |
| 2.4.5(i) | Must be sandboxed | A sandboxed app can't write `com.apple.universalaccess` (pointer size and colors) or the global preference behind macOS "Shake to locate". The macOS shake switch goes; Super shake stays. |
| 2.4.5(iii) | No launch at login without consent | Launch at login stays opt-in (off by default), through `SMAppService`. |
| 2.4.5(vii) | Updates only through the Mac App Store | Nothing to change: the direct build has no updater either. |
| 2.4.5(viii) | Must run on the current macOS, with no deprecated technologies | The global shortcut uses Carbon `RegisterEventHotKey`. The SDK doesn't mark it deprecated (no warnings at a macOS 13 target), and Mac App Store apps use it: [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) calls it "fully sandboxed and Mac App Store compatible", and rcmd ships with it. |
| 2.5.9 | Apps that alter native UI or behaviors are rejected | Don't describe the app as changing the system pointer. It draws its own; the metadata says so. |
| 2.5.19 (clarified 2026-10-16) | The reviewed app must be the app that ships | Nothing hidden: the review build is the release build. |
| 2.3.10 | Metadata focused on the app; no other platforms or marketplaces | The listing doesn't mention the direct download. |

**Mentioning or linking to the version outside the App Store.** No guideline forbids naming a free version distributed outside the store. The anti-steering rules in 3.1.1 and 3.1.3 are about directing people to *purchase* elsewhere, and outside the United States storefront they still apply. That doesn't fit a free app with nothing to buy, but reviewers have rejected Mac apps over website links: Tumult Hype in 2024, and a 2012 report of rejections for mentioning non-App-Store versions. So it isn't confirmed as allowed. **The App Store build has no links or prompts that point to the direct version.** It also drops the menu's "Browse recipes on wheresmymouse.com…" item, because those pages offer the direct download. Listing wheresmymouse.com as the Support URL in App Store Connect is normal and fine; Presentify's site sells a DMG, for example. (QUESTIONS.md, Q5.)

## Approaches considered

| Approach | Public API? | Works sandboxed? | Permissions | Verdict |
|---|---|---|---|---|
| Resize/recolor the system pointer (what the direct build does) | No | Writes blocked | Full Disk Access | ✗ Not allowed |
| Write the Accessibility pointer preferences | `CFPreferences` is public, but writing another app's domain isn't allowed | No | Full Disk Access | ✗ |
| `NSCursor` with a big image | Yes | Yes | None | ✗ Only applies over your own windows |
| Hide the real pointer and draw a replacement (the direct build's 16–30×) | Hiding from the background needs the private `SetsCursorInBackground` | n/a | None | ✗ |
| **Click-through overlay window that follows the mouse** | **Yes** (AppKit, Core Animation) | **Yes** | **None** | **✓ Chosen** |
| Magnify or capture the real cursor (ScreenCaptureKit) | Yes | Yes | Screen Recording | ✗ Heavy and asks for a scary permission. `NSCursor.currentSystem` is deprecated in macOS 27. |
| Open Accessibility → Pointer for the user | Yes (`x-apple.systempreferences:` URL) | Yes | None | ✓ As a hint only ("Match its colors…"), not the feature |

How the pieces of the overlay get what they need, all without prompts:

- **Following the mouse:** `NSEvent` global and local monitors for mouse-moved and drag events. Apple's docs say only *key* events need Accessibility trust, and sandboxed apps can't get Accessibility anyway, so key monitors weren't an option.
- **Global shortcut:** `RegisterEventHotKey`, with no permission needed. The alternatives would have needed Accessibility (a keyDown monitor) or Input Monitoring (a `CGEventTap`).
- **Launch at login:** `SMAppService.mainApp` (macOS 13+). This is why the App Store build needs macOS 13. The direct build's fallback for macOS 11–12, a plist in `~/Library/LaunchAgents`, can't be written from the sandbox.
- **App rules:** `NSWorkspace` app-activation notifications, plus an Open panel to pick the app. The panel needs the `com.apple.security.files.user-selected.read-only` entitlement.

## Spike: what was verified on this Mac

macOS 14.6.1, two displays. `spike/sandbox_overlay.swift` was ad-hoc signed with only the `com.apple.security.app-sandbox` entitlement:

| Check | Result |
|---|---|
| Runs sandboxed | ✓ Container at `~/Library/Containers/com.wheresmymouse.SandboxSpike` |
| Overlay window per display, at the screen-saver level | ✓ Two windows at layer 1000 |
| Global + local mouse monitors, no prompt | ✓ 179 global and 168 local mouse events in ~10 s, no dialog |
| `RegisterEventHotKey` (⌃⌥⌘M) | ✓ Returned `noErr` |
| Reading `com.apple.universalaccess` | Works, but not used (the key is undocumented) |

Then the real App Store build (`AppStore/build.sh`) was run sandboxed. The window server showed its pointer window at layer 1000. That window followed the mouse on both displays, and its origin sat 5.6 pt up and left of the mouse, exactly where the drawn shape's padding puts it. Captures of the windows show the arrow, the halo and a 10× arrow drawn correctly. `AppStore/check-public-api.sh` confirms the binary has no private symbols, private framework paths or `dlopen`/`dlsym`.

## How Mac App Store competitors do it

From their current listings (October 2026):

| App | What it draws | Claims to change the system pointer? | Permissions listed |
|---|---|---|---|
| [Presentify](https://apps.apple.com/app/id1507246666) ($14.99) | Ring, click pulse, spotlight, zoom, drawing | No | None |
| [Cursor Pro](https://apps.apple.com/app/cursor-pro/id1447043133) ($14.99) | Shape and glow around the pointer, click effects, magnifier | No | Screen Recording (magnifier only) |
| [Cursor Highlighter](https://apps.apple.com/us/app/cursor-highlighter/id1576720712?mt=12) ($2.99) | Glow or disc, click animation | No | None |
| [Hyper Cursor](https://apps.apple.com/us/app/hyper-cursor/id1634220679?mt=12) (free) | Circle or ring, click pulse | No | None |
| [Highlight my cursor](https://apps.apple.com/us/app/highlight-my-cursor/id6738329029?mt=12) (free) | Highlight, click effects, trails | No | States "No Accessibility or Input Monitoring permission is needed" |
| [FocusCursor](https://apps.apple.com/app/6743495172) (free + IAP) | Ring, click effect, dimming mask | No | None |
| [Mouse Pro: Cursor Spotlight](https://apps.apple.com/app/id6670465634) ($9.99) | Spotlight, magnifier | No | None |
| [Screen Cursor](https://apps.apple.com/us/app/id1577211880) (free + IAP) | Halo, per-button click colors | No | None |
| [Giant Cursor](https://apps.apple.com/us/app/giant-cursor-large-pointer/id6738851315) (free + IAP) | A "giant" cursor for a few seconds on a shortcut | Unclear | None |

All of them draw their own overlay. Giant Cursor is the closest to Where's My Mouse. Presentify also sells a direct DMG and through Setapp, and its App Store listing doesn't mention either. Every privacy label above says no data is collected.

## The chosen design

- **Drawn pointer, two styles.**
  - *Arrow*: the classic arrow at the chosen size, outline under fill (the same drawing the direct build uses for 16–30×), with its tip on the real pointer's tip.
  - *Halo*: a 30%-opacity disc in the fill color with a ring in the outline color, centered on the pointer.
- **Small windows, one per display.** Each window is sized to the part of the shape on its display, so a pointer straddling two screens isn't cut off. They sit at the screen-saver level on every Space (including full-screen apps), ignore the mouse, and move with each mouse event.
- **1× means nothing drawn.** That's the built-in Default preset, so presets, recipes and app rules work exactly as in the direct build: an app rule switching back to Default turns the drawn pointer off.
- **Quick toggle.** A switch in the menu header, a right-click on the menu bar icon, or ⌃⌥⌘M from any app. Turning it on brings back the last look; turning it off applies Default.
- **Pauses while the App Store app is in front.** Since macOS 15.3.2, the App Store hides its install-confirm button when another app's window is on top of it. Developers have reported this ([forum thread](https://developer.apple.com/forums/thread/781317), FB17235505), and Apple DTS says it may be caused by a window above the installer. Small windows already keep the overlap to the pointer's area, and the pause makes sure the button can be clicked.
- **Entitlements:** `app-sandbox`, `files.user-selected.read-only`. No network, no Accessibility, no Screen Recording, no Input Monitoring. Privacy label: Data Not Collected.

## Compared with the direct download

| | Direct download | App Store |
|---|---|---|
| Size | Real pointer up to 15×, drawn 16–30× | Drawn at every size, 1–30× (real pointer stays at the System Settings size) |
| Colors | Real pointer recolored, needs Full Disk Access | Drawn, no permission |
| Real pointer | Becomes the big one | Stays visible on top of the drawn one |
| Pointer shape | Real hand, I-beam, etc. | Drawn arrow or halo; the real shape shows on top |
| When an app hides the pointer (typing, video) | Hidden | Drawn pointer stays |
| Screenshots | Pointer not included | Drawn pointer included (as it is in screen recordings, which is the point) |
| Fast moves | No lag up to 15× | May trail slightly (like the direct build's 16–30×) |
| macOS shake to find switch | Yes | No (can't write the global setting); Super shake works |
| Presets, recipes, app rules, launch at login, wheresmymouse:// links | Yes | Yes |
| Quick toggle | Presets, ⌘1–⌘9 in the menu | Same, plus header switch, right-click on the icon, ⌃⌥⌘M |
| macOS | 11+ | 13+ |

## Risks

- **Apple tightens overlay protection.** The App Store button case shows macOS can hide sensitive UI under other apps' windows. If more system UI starts doing that, the pause list in `PointerHighlight` may need more apps.
- **Shortcut conflicts.** If another app already holds ⌃⌥⌘M, registration fails (logged), and the menu switch and right-click still work. There's no shortcut recorder yet (QUESTIONS.md, Q4).
- **Tooling.** There's no minimum macOS SDK for Mac uploads today. Apple's Xcode 26 requirement covers iOS, iPadOS, tvOS, visionOS and watchOS only. Xcode 26 needs macOS 15.6+, so it won't run on this Mac (macOS 14.6.1), but [Xcode 16.2 runs on macOS 14.5+](https://developer.apple.com/xcode/system-requirements/) and can archive and upload. Transporter is already installed. See `AppStore/SUBMISSION_CHECKLIST.md`.
