# App Store metadata (draft)

Paste-ready text for App Store Connect. Character limits are Apple's. Nothing here mentions the direct download, other platforms or other stores (FEASIBILITY.md).

## Name (30 max)

> Where's My Mouse?

17 characters. If the name is taken, try "Where's My Mouse? Pointer" (25).

## Subtitle (30 max)

> Bigger, bolder mouse pointer

28 characters. Alternatives: "Find your pointer instantly" (27), "Big pointer for demos & calls" (29).

## Promotional text (170 max, can change anytime without review)

> Lost the pointer on a big screen, a call or a recording? Turn on a big, bright pointer with one shortcut and it follows your mouse everywhere.

## Description (4,000 max)

> Never lose sight of your mouse. Where's My Mouse? draws a big, bright pointer that follows your mouse across every app, every display and every Space, so you and everyone watching can see exactly where you're pointing.
>
> Perfect for screen recordings, live demos, presentations, screen sharing on calls, teaching, and big or busy screens.
>
> TURN IT ON IN A SECOND
> • Press ⌃⌥⌘M from any app, right-click the menu bar icon, or use the switch in the menu.
> • Shake the mouse to show a big pointer for a moment, even when it's off.
>
> MAKE IT YOURS
> • Size from 2× to 10×, or up to 30× for the back of the room.
> • Pick any fill and outline color.
> • Two styles: a big arrow, or a halo around your pointer.
>
> PRESETS AND RECIPES
> • Save looks as presets, like a big blue one for recording, and switch with ⌘1–⌘9 in the menu.
> • 32 ready-made Cursor Recipes: seasonal, pop culture and colors from around the world.
>
> APP RULES
> • Add apps to a preset. While one of them is in use, your pointer switches to that preset automatically. With none in use, it goes back to normal.
>
> PRIVATE AND LIGHTWEIGHT
> • Lives in the menu bar. No account, no tracking, no data collected.
> • Needs no special permissions.
>
> Where's My Mouse? draws its own pointer on top of your screen; it doesn't change your Mac's pointer settings. Your own pointer stays visible at the tip of the big one. To make it blend in, give it the same colors in System Settings → Accessibility → Display → Pointer.

About 1,450 characters.

## Keywords (100 max, comma-separated, no spaces needed)

> cursor,pointer,highlight,big,large,presentation,screen recording,demo,zoom,teaching,halo,find,locate

100 characters (the limit). Apple already indexes the name and subtitle, so words in those ("mouse", "bigger") are left out here.

## Category

- Primary: **Utilities**
- Secondary: **Productivity**

## URLs

- Support URL (required): `https://wheresmymouse.com` (or a support or contact page there; QUESTIONS.md Q5)
- Marketing URL (optional): `https://wheresmymouse.com`
- Privacy Policy URL (required for all apps): a page saying the app collects no data. The site doesn't have one yet (QUESTIONS.md Q6). Suggested text:

  > Where's My Mouse? doesn't collect, store or share any personal data. Your settings and presets stay on your Mac. The app makes no network connections.

## Age rating

Answer "None" to every content question, giving **4+**. No web access, no user-generated content, no gambling.

## App Privacy ("nutrition label")

- **Data Not Collected.** The app has no network code, analytics or crash reporting. The privacy manifest (`AppStore/PrivacyInfo.xcprivacy`) declares no tracking and no collected data, plus the two "required reason" APIs it uses:
  - UserDefaults, reason CA92.1: the app's own settings.
  - System boot time, reason 35F9.1: `systemUptime` to time the shake detection.

## Export compliance

The app uses no encryption. `ITSAppUsesNonExemptEncryption` is `NO` in Info.plist, so App Store Connect won't ask.

## Price

Free, or paid (QUESTIONS.md Q1). Both are allowed. No in-app purchases are set up.

## Copyright

> 2026 Andrew Kamphey

## App Review information

**Sign-in required:** No.

**Notes for the reviewer:**

> Where's My Mouse? is a menu bar app (no Dock icon) that makes the mouse pointer easier to see during screen recordings, presentations and screen sharing. It draws a bigger pointer (an arrow, or a halo) in small transparent, click-through windows that follow the mouse. It does not change the system pointer or any system settings, and it uses only public APIs.
>
> HOW TO TRY IT
> 1. Launch the app. A 3× pointer appears right away and follows the mouse; the system pointer stays visible at its tip.
> 2. Click the pointer icon in the menu bar to open the menu: change Size, Fill and Outline, or switch the Style to Halo.
> 3. Quick toggle: press Control-Option-Command-M, right-click the menu bar icon, or use the switch at the top of the menu.
> 4. Presets: click "Default" to turn the drawn pointer off (1×), or "Recipes" to add a ready-made look.
> 5. Shake the mouse quickly side to side: the pointer grows for a moment (Super shake), even when it's off.
> 6. App rules (optional): hover a preset, click its "+" button, and pick any app in /Applications. While that app is frontmost, the pointer switches to that preset.
>
> PERMISSIONS AND ENTITLEMENTS
> • App Sandbox.
> • com.apple.security.files.user-selected.read-only: only to read the app the user picks in the Open panel for an app rule (its name, bundle ID and icon).
> • No Accessibility, Input Monitoring, Screen Recording or network access is requested. Mouse movement comes from NSEvent mouse-moved monitors, which need no permission. The keyboard shortcut is a registered hot key (RegisterEventHotKey), not a key logger.
> • "Launch at login" is off by default and uses SMAppService only when the user turns it on.
>
> The drawn pointer pauses while the App Store app is in front, because macOS hides the App Store's install button under other apps' windows.

## Screenshots

Mac screenshots must be 16:10: 1280×800, 1440×900, 2560×1600 or 2880×1800. Up to 10 are allowed. Suggested set (see SUBMISSION_CHECKLIST.md):

1. A slide or demo with a big red arrow pointing at something. Caption: "Never lose sight of your mouse"
2. The menu open over a desktop, with presets and colors. Caption: "Size, colors and presets in one menu"
3. Halo style over a busy app (maps, code). Caption: "Arrow or halo, any color"
4. A screen recording frame (e.g. QuickTime) with the pointer obvious. Caption: "Made for recordings and calls"
5. The Recipes menu open. Caption: "32 ready-made Cursor Recipes"
6. App rules with OBS or Zoom. Caption: "Switches automatically for the apps you choose"
