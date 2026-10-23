# Competitors

Checked 2026-10-22. Prices are US storefront prices on that date. The full list of 110 tools, with every source URL, is in [supporting/competitors-all.csv](supporting/competitors-all.csv). Verbatim review complaints are in [supporting/competitor-complaints.csv](supporting/competitor-complaints.csv).

## The one thing that matters most

Nearly every competitor is an **overlay**: a ring, halo or spotlight drawn on top of the pointer in its own window. Only three tools change the **real** macOS pointer: macOS itself (Accessibility > Display > Pointer), Mousecape (cursor themes, unmaintained since 2020) and CursorProMax (shake-to-grow, released 2026-10-14, macOS 26+ only).

That split explains the top complaint in the category. Overlays often don't show up for the other people on a Zoom or Teams call, or in some recorders:

- "Considering how expensive this tool is, it's quite disappointing that it doesn't work while screen sharing." Cursor Pro, App Store review, 2021 ([source](https://itunes.apple.com/us/rss/customerreviews/id=1447043133/sortby=mostrecent/json))
- "I spent my entire day thinking that students were able to see the effects on my screen just to find out that they could not see any effects." Pro Mouse, App Store review, 2020 ([source](https://itunes.apple.com/us/rss/customerreviews/id=1505869474/sortby=mostrecent/json))
- Cluxo hides its own overlay from screen capture by default (`sharingType = .none`) and needs a "Screenshot Mode" toggle to appear ([source](https://github.com/kykim79/Cluxo)).

The direct download of Where's My Mouse? changes the real pointer (the App Store build in PR #1 is an overlay), so it inherits the same capture behavior as the macOS setting. See QUESTIONS.md Q1: that behavior has to be tested before it goes in marketing copy, because several users report the enlarged system pointer recording at normal size.

## Most direct competitors

| Tool | Approach | Price (US, 2026-10-22) | Where sold | Cursor features | Last update | Source |
|---|---|---|---|---|---|---|
| macOS built-in pointer settings | Real pointer | Free | Built in | Size slider (Apple documents no numeric max; capped around 4×), outline/fill color (Monterey+), shake to locate | n/a | [Apple](https://support.apple.com/guide/mac-help/make-the-pointer-easier-to-see-mchlp2920/mac) |
| Mouseposé (Boinx) | Overlay | $9.99/yr in a Google result snippet; **unconfirmed** on boinx.com (geo-priced) | Direct, Homebrew | Spotlight, click circles, keystrokes | v4.5.1, 2026-06-05 | [boinx.com](https://boinx.com/mousepose/) |
| Presentify (Softal) | Overlay | $14.99 MAS; $14 direct; Setapp | MAS, direct, Setapp | Highlight ring, click animations, spotlight, zoom lens, full screen annotation | v8.1.2, 2026-07-12 | [MAS](https://apps.apple.com/us/app/presentify-screen-annotation/id1507246666) |
| Cursor Pro (App ahead) | Overlay | $14.99 | MAS | Ring (shape, color, glow), click animations, magnifier | v2.16, 2026-08-18 | [MAS](https://apps.apple.com/us/app/cursor-pro/id1447043133) |
| Pro Mouse | Overlay | $7.99 | MAS | Halo, click ripples, zoom glass, drawing, spotlight, keystrokes | v2.4, 2026-09-15 | [MAS](https://apps.apple.com/us/app/pro-mouse-cursor-highlighter/id1505869474) |
| Mouzz | Overlay | Free on MAS; Pro $14.99 one-time (direct) | MAS, direct | Spotlight, ring, trails, click effects, shake to locate | v2.3.3, 2026-09-30 | [MAS](https://apps.apple.com/us/app/mouzz-cursor-highlighter/id6760307235) |
| Where Is My Cursor | Overlay | Free, no IAP | MAS | Halo, spotlight, draw | 2026-09-19 | [MAS](https://apps.apple.com/us/app/where-is-my-cursor/id6770836427) |
| Giant Cursor | Momentary giant cursor | Free; IAP $2.49 / $4.99 | MAS | Shortcut turns pointer giant for a few seconds | v1.3, 2025-01-12 | [MAS](https://apps.apple.com/us/app/giant-cursor-large-pointer/id6738851315) |
| Simple Mouse Locator | Overlay | $2.99 | MAS | Momentary or permanent locator ring | v1.13, 2024-02-13 | [MAS](https://apps.apple.com/us/app/simple-mouse-locator/id946676425) |
| Cursorly (Presentify's maker) | Overlay | Free; Pro $4.99 | MAS | Halo, click animations, spotlight, cursor zoom | v1.1.2, 2026-07-17 | [MAS](https://apps.apple.com/us/app/cursorly-cursor-effects/id6776335075) |
| Mousecape | Real pointer (themes) | Free, open source | GitHub | Replaces system cursor art, multiple scales | Release 1813, 2020-06-13 | [GitHub](https://github.com/alexzielenski/Mousecape) |
| CursorProMax | Real pointer | Free, GPL-3.0 | GitHub | Shake to grow the real pointer | v1.1.0, 2026-10-14 | [GitHub](https://github.com/castdrian/CursorProMax) |
| Cluxo | Overlay | Free, MIT | GitHub | Ring, click effects, magnifier, spotlight, keystrokes | v1.5.1, 2026-07-26 | [GitHub](https://github.com/kykim79/Cluxo) |
| ZoomIt for Mac (Microsoft) | Zoom/draw, no pointer ring | Free, MIT | GitHub, Homebrew, MAS | Zoom, draw, record | 12.3.1, 2026-10-15 | [GitHub](https://github.com/microsoft/ZoomitForMac) |

### Screen recorders with cursor effects (adjacent: they own "cursor in recordings")

| Tool | Price | What it does to the cursor | Source |
|---|---|---|---|
| Screen Studio | $9/mo billed yearly ($108/yr) or $29/mo | Records without the cursor and redraws it in post: bigger, smoother, auto-zoom. Exported video only, never live | [screen.studio](https://screen.studio) |
| CleanShot X | $35 one-time (1 yr updates) or Pro $10/user/mo | "Highlight every click", keystrokes, smart zoom baked into recordings | [pricing](https://cleanshot.com/pricing) |
| Camtasia | Annual plans; US prices only from a third party (trainn.co) | Cursor effects and smoothing in the editor | [store](https://www.techsmith.com/store/camtasia) |
| Cap | Free app; $29/yr or $58 lifetime license | Open-source Loom alternative | [pricing](https://cap.so/pricing) |
| Limelight | Spotlight free; Pro $2.99/mo or $34 lifetime | Live spotlight overlay plus recorder | [limelightmac.com](https://limelightmac.com) |

### Windows tools Mac users ask for

PowerToys Mouse Utilities (Find My Mouse, Mouse Highlighter, Crosshairs) and ZoomIt are free from Microsoft ([docs](https://learn.microsoft.com/en-us/windows/powertoys/mouse-utilities)). Mac users benchmark against them: "powertoys for mac" gets 70 searches a month and "zoomit for mac" 90 (keywords.csv). Microsoft now ships ZoomIt for Mac, but nothing ships PowerToys Find My Mouse for Mac.

## Complaint themes (107 verbatim complaints)

| Theme | Count | Example |
|---|---|---|
| Not visible in screen share or recording | 11 | Cursor Pro and Pro Mouse quotes above |
| Bugs | 11 | |
| Breaks on new macOS | 8 | Mousecape open issues ([#309](https://github.com/alexzielenski/Mousecape/issues/309), [#305](https://github.com/alexzielenski/Mousecape/issues/305)) |
| Laggy or heavy CPU | 7 | "Pro Mouse will singlehandedly cause the fans to come on" ([source](https://itunes.apple.com/us/rss/customerreviews/id=1505869474/sortby=mostrecent/json)) |
| Missing feature | 7 | |
| Subscription or price | 6 | "$10 it's not worth having a colored ring or magnifier for your cursor" (Cursor Pro) |
| Paywalled free tier | 6 | "you have to pay for more colors" (CursorFlow) |
| Can't quit or turn off | 6 | |
| Multi-monitor problems | 4 | |

Counts are as tagged by the gathering agent (one theme per complaint).

## What competitors rank for

Brand searches (US Google Ads, monthly): Screen Studio 8,100; CleanShot X 3,600; Mousecape 2,400; ZoomIt 2,400; Presentify 480; KeyCastr 390; Mouseposé 70. Non-brand rankings are thin. The Mac App Store app "Cursor Highlighter" is #1 for "cursor highlighter mac" and "mac cursor highlight" (40/mo each), and Mouseposé and Cursor Pro rank on page one for small highlighter queries. Rankings per domain are in [supporting/competitor-rankings.csv](supporting/competitor-rankings.csv). Treat those positions as stale: they come from DataForSEO's stored index, and all 3 that were re-checked live didn't match.

## Link profiles (DataForSEO referring domains)

| Competitor | Dofollow referring domains | Notes |
|---|---|---|
| Presentify | 2,252 | Inflated by footer and network links; real editorial links include Product Hunt (224 points), AlternativeTo, OBS forum, MPU Talk |
| Screen Studio | 1,431 | Mostly AI and Mac app directories |
| ScreenFlow page | 804 | Old reviews, teacher blogs |
| KeyCastr (GitHub) | 350 | How-to blogs in 15+ languages |
| Mouseposé page | 39 (54 total) | Apple blogs, forums, podcasts |
| Cursor Pro page | 8 | |
| wheresmymouse.com | 29 total, spam score 63 | Almost all `.shop`/`.online` spam; no ranked keywords yet |
