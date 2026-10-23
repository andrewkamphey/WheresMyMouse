# Decisions needed

Each item says what I assumed so the research could keep going.

## Q1. Does the big pointer really show in recordings and screen shares? (blocks the main claim)

The strongest positioning, "the real pointer, not an overlay, so viewers see it", depends on this. Several people report the opposite with macOS's own enlarged pointer:

- "I enlarged the cursor to capture the screen. In the recording, however, the cursor is as small as before." ([OBS forum, 2023](https://obsproject.com/forum/threads/screencast-and-cursor.164575/post-603888))
- "when you do a screen recording or a screenshot, the cursor appears small so this will not enhance your screencasts" ([alicekeeler.com, 2014](https://alicekeeler.com/2014/05/23/mac-tip-a-really-big-cursor/))
- Pointer size resets to default in Screen Sharing and Jump Desktop ([Ask Different](https://apple.stackexchange.com/questions/443757))

The site FAQ says "Yes. We tested it in OBS." Some of these reports are old, and newer macOS may behave differently.

**Decision:** test at 4×, 10× and 30× in QuickTime, the macOS screenshot toolbar recorder, OBS (display and window capture), Loom, Zoom (full screen and window share), Google Meet, Teams, and Screen Sharing. Then decide what the site may claim. I assumed it works only in OBS until tested.

**Update 2026-10-22:** confirmed again in OBS while capturing the guide screenshots: a recording shows the enlarged pointer, while still screenshots draw it at normal size. QuickTime, `Shift-Command-5`, Loom, Zoom, Meet, Teams and Screen Sharing are still untested.

## Q2. What goes in the paid version?

The research suggests features people ask for that no competitor has: different pointer sizes per monitor, a hotkey toggle, a longer or bigger shake-to-locate, click highlights that are guaranteed to show in shares. **Decision:** which stay free and which are paid. I assumed the core (size, color, presets, app rules) stays free, since "free and open source" is the main trust signal against $8–15 single-feature apps.

## Q3. Where do the new pages live?

The site has 2 URLs (home, recipes). The plan needs 4 new pages (cursor size how-to, cursor color how-to, highlighter comparison, presenting page). **Decision:** subfolder (`/guides/...`) or blog, and whether you write them or want drafts. I assumed `/guides/` subfolder pages on wheresmymouse.com, not a separate blog domain.

## Q4. Name competitors on a comparison page?

The comparison page names Mouseposé, Presentify, Cursor Pro and others, with prices and published complaints. **Decision:** comfortable naming them? If so, prices need re-checking before publishing. Mouseposé's price couldn't be confirmed (boinx.com shows prices by region). I assumed yes, with neutral wording and a "checked on" date.

## Q5. Mac App Store and Setapp

Most competitors sell through the Mac App Store; Presentify and CleanShot are also on Setapp. The App Store build in [andrewkamphey/WheresMyMouse#1](https://github.com/andrewkamphey/WheresMyMouse/pull/1) draws the pointer in overlay windows, because the private cursor APIs can't ship there. That puts it in the same overlay category as every competitor. The "real pointer, not an overlay" argument would apply only to the direct download, and the App Store build needs its own capture test (Q1). **Decision:** does the enhanced version go to the Mac App Store, Setapp, direct, or several? And should marketing describe the two builds differently? This also changes which search surface matters: Mac App Store search is separate from Google.

## Q6. How to approach low-vision users

AppleVis wants maker-written, non-AI posts and doesn't let developers list their own apps. **Decision:** will you write and post the AppleVis forum post yourself? I assumed yes and drafted nothing.

## Q7. Spam backlinks to wheresmymouse.com

DataForSEO lists 29 referring domains, nearly all `.shop`/`.online` spam (spam score 63), first seen 2026-09-19. Usually harmless, but you might want to check Google Search Console. **Decision:** disavow or ignore. I assumed ignore unless Search Console shows a manual action.

## Q8. Markets beyond the US

All volumes are US only. UK users write "colour" and "partially sighted". **Decision:** pull UK, Canada and Australia volumes too? That's a few cents of DataForSEO calls. I assumed US is enough for now.

## Q9. Reddit

Reddit was blocked to every automated method, so r/macapps, r/MacOS and r/obs threads appear only as URLs. Many of them rank on page one for target keywords. **Decision:** check them by hand in a browser, or have me drive your Chrome to read them. Your reddit-posting skill could then plan posts. I assumed no Reddit quotes rather than using third-party archives.
