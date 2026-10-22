# SEO research: Where's My Mouse?

Research run 2026-10-22. Volumes are US Google Ads monthly averages to Sep 2026, pulled through DataForSEO. "Who ranks" comes from DataForSEO live Google results (US, desktop) on the same day. Every number below is in [keywords.csv](keywords.csv) with its source. Nothing here is estimated unless it says so.

## Summary

1. **People search for settings, not for apps.** The biggest Mac-specific demand is how-to searches about pointer size and color: "how to change cursor size mac" (390/mo), "change cursor size mac" (260), "how to change cursor color on mac" (260). Apple Support, Apple Community threads, TikTok and YouTube Shorts own page one. No app ranks for them. A how-to page that answers the question in its first paragraph, then shows how to go past macOS's 4× limit, can rank.
2. **App-intent searches are tiny but winnable.** "cursor highlighter mac" (40/mo), "mac cursor highlight" (40), "mousepose alternative" (10), "presentify alternative" (10). Small indie apps hold the top spots, so a new page can get there.
3. **The screen-recording pain is real but mostly not searched for.** Phrases taken straight from posts, such as "mouse cursor too small in recording", "viewers can't see my mouse" and "cursor disappears when sharing screen mac", all return under 10 searches a month. That audience is reached through forums, YouTube and the tools they already use (OBS, Zoom, Loom), not through Google. Use those phrases for video hooks and community posts, not as SEO targets.
4. **The biggest competitive gap: almost every competitor is an overlay.** The category's #1 complaint is that the highlight doesn't show up for viewers on Zoom, Teams or in recordings. The direct download of Where's My Mouse? changes the real pointer. If that holds up in testing (see QUESTIONS.md Q1), it is the main differentiator. The App Store build in PR #1 draws an overlay, so the claim wouldn't apply to it (Q5).
5. **The site starts from zero.** wheresmymouse.com has no ranked keywords and 29 referring domains, nearly all spam. The repo was created 2026-10-13 and has 2 stars.

Google buckets close variants into one shared figure. "change cursor size mac", "mac change cursor size" and "change mouse pointer size mac" each show 260, but that's one pool of searches, not three. Don't add variants together.

## The 10 keywords to target first

Picked for Mac-specific intent, real volume, and a page one that a new site can break into (forums, social video, thin articles, no strong product pages).

| # | Keyword | US vol/mo | Intent | Who ranks now (top 3) | Why it's winnable | Page |
|---|---|---|---|---|---|---|
| 1 | how to change cursor size mac | 390 | use | Apple Community thread, Apple Support, TikTok | Forum and social results in the top 3; no app or full guide | Cursor size how-to |
| 2 | change cursor size mac | 260 | use | Apple Support, Reddit, YouTube | Same page as #1 | Cursor size how-to |
| 3 | how to change cursor color on mac | 260 | use | TikTok, Apple Community (2014 thread), Apple Support AU | #1 is a TikTok, #2 is a 10-year-old thread | Cursor color how-to |
| 4 | how to make cursor bigger on mac | 170 | use | YouTube, Apple Support, YouTube | Video-led SERP: one page plus one short video | Cursor size how-to + video |
| 5 | make mouse pointer bigger mac | 110 | use | TikTok, YouTube Short, Apple Support | Social video owns #1 and #2 | Cursor size how-to + video |
| 6 | mac cursor size | 110 | use | MacMost, YouTube, Ask Different | Thin editorial competition | Cursor size how-to |
| 7 | cursor highlighter mac | 40 | purchase | MAS "Cursor Highlighter", Facebook group post, Reddit | Indie MAS app at #1, social posts below it | Highlighter comparison |
| 8 | keynote laser pointer | 70 | use | Logitech Spotlight review blog, Reddit, MAS "Presentation Pointer" | Indie app at #3; no Mac-native guide | Presenting page |
| 9 | powertoys for mac | 70 | purchase | Softonic, Reddit (2020), YouTube | Weak page one; no Mac version of Find My Mouse exists | Windows switcher section |
| 10 | mousecape (alternative) | 2,400 brand / 50 "mousecape mac" | purchase | GitHub repo, mousecape.com, YouTube | Mousecape is unmaintained since 2020; issues report breakage and malicious download mirrors | Highlighter comparison, alternative section |

Second wave, for after the first pages are indexed: "mac cursor highlight" (40), "highlight cursor mac" (40), "keynote pointer" (40), "zoomit for mac" (90, but Microsoft now owns it), "why does mac cursor get bigger when you shake it" (20, a natural Super Shake explainer), "screen studio alternative" (260, only if you write the honest "big cursor in any recorder" angle, since Where's My Mouse? isn't a recorder).

**Leave alone:** "custom cursor" (90,500), "custom cursor download" (2,400) and "cursor pro" (3,600) are web cursors, Windows themes or the Cursor AI editor. Windows "can't find my cursor" searches (1,000/mo) are owned by Microsoft Learn and don't fit a Mac app.

## The 5 pages to build

### 1. Home page sections (wheresmymouse.com)
The current H1 ("Never lose sight of your mouse") contains no searchable term. Keep the line, but add the words people use:
- **Title/H1 support line:** "Make your Mac cursor bigger and change its color, past the 4× limit in System Settings." This covers size, color and Mac in one line.
- **Section: "Bigger than System Settings allows."** Built-in max vs 10×/15×/30×, side by side.
- **Section: "The real pointer, not an overlay."** Highlight rings often don't reach viewers on Zoom or Teams; a bigger real pointer does. *Only publish once Q1 is tested across apps.*
- **Section: "For screen recordings, presentations and calls."** Use the exact problem phrases from the hooks list below.
- **FAQ taken from People Also Ask** (see [supporting/people-also-ask.txt](supporting/people-also-ask.txt)): "How do I make my pointer bigger on my MacBook?", "Can I change the color of my cursor on a Mac?", "How do I get my cursor back to normal?"
- Add `SoftwareApplication` structured data (price 0, macOS). The site currently has 2 URLs in its sitemap.

### 2. How-to: "How to change cursor size on Mac (and go bigger than 4×)"
Targets keywords 1, 2, 4, 5 and 6. Answer in the first 2 sentences with the built-in path (System Settings > Accessibility > Display > Pointer size), with screenshots for Sonoma, Sequoia and Tahoe. Then cover: the 4× cap, why the pointer may record small, and different sizes per monitor (a real request on [Ask Different](https://apple.stackexchange.com/questions/421699)). Then a short section on Where's My Mouse?. Pair it with a 30-second vertical video: page one for these terms is full of TikToks and Shorts.

### 3. How-to: "How to change cursor color on Mac"
Targets keyword 3 and its color variants (70 each). Cover outline vs fill, Reset, colors that stay visible in dark mode, the 2021 Monterey memory-leak report ([TidBITS](https://talk.tidbits.com/t/17174)), and the Cursor Recipes as ready-made combinations.

### 4. Comparison: "Best cursor highlighters for Mac in 2026: overlays vs the real pointer"
Targets keywords 7 and 10, plus the "alternative" and brand searches. Honest table: macOS built-in, Mouseposé, Presentify, Cursor Pro, Pro Mouse, Mouzz, Cluxo, Mousecape, Where's My Mouse?, with price, approach, and whether each shows in screen shares. Add sub-sections titled "Mouseposé alternative", "Presentify alternative" and "Mousecape alternative". This is also the page to pitch to roundup authors.

### 5. Presenting page: "Show your pointer when presenting on a Mac (Keynote, projector, Zoom)"
Targets keyword 8 plus the presenting and screen-share pain. It also holds a "PowerToys Find My Mouse for Mac" section for keyword 9. Cover Keynote's pointer behavior, projectors, Zoom's window-share cursor problem ([Zoom Community](https://community.zoom.com/meetings-2/cursor-not-visible-to-attendees-when-sharing-application-window-17018)), and per-app rules (big pointer whenever Keynote or Zoom is in front).

The accessibility audience gets a section on page 2 and a dedicated forum post, not its own SEO page: accessibility-worded queries ("cursor for low vision", "mac cursor for visually impaired") show no measurable volume. See "Accessibility" below.

## Strongest problem phrases for video hooks

All verbatim. ✓ = re-checked against the source page.

| Hook | Situation | Source |
|---|---|---|
| "I enlarged the cursor to capture the screen. In the recording, however, the cursor is as small as before." ✓ | Screen recording | [OBS forum](https://obsproject.com/forum/threads/screencast-and-cursor.164575/post-603888) |
| "I've had complaints from attendees that they can't see my mouse when sharing my screen." ✓ | Video calls | [Zoom Community](https://community.zoom.com/meetings-2/cursor-not-visible-to-attendees-when-sharing-application-window-17018) |
| "it's impossible to find my mouse on the screen." ✓ | Teaching on Zoom | [Zoom Community](https://community.zoom.com/meetings-2/cursor-disappears-while-using-annotate-41396) |
| "No matter how much I shake it, the cursor is not visible." ✓ | Big monitors (two 43-inch) | [MacRumors](https://forums.macrumors.com/threads/cursor-highlight-on-large-screens.2356682/) |
| "my learners pointed out ... they almost could not see where my cursor was moving to" ✓ | Tutorials | [Adobe Community](https://community.adobe.com/questions-567/how-do-i-make-my-cursor-more-visible-or-bigger-for-an-online-presentation-194266) |
| "wiggling around your tiny mouse cursor in hopes that the students can see what you are pointing at" ✓ | Teaching | [alicekeeler.com](https://alicekeeler.com/2014/05/23/mac-tip-a-really-big-cursor/) |
| "I spent my entire day thinking that students were able to see the effects on my screen just to find out that they could not see any effects." ✓ | The overlay trap (competitor review) | [Pro Mouse, App Store](https://itunes.apple.com/us/rss/customerreviews/id=1505869474/sortby=mostrecent/json) |
| "the cursor grew slightly ... but it didn't grow nearly big enough." ✓ | Shake to locate | [Hacker News](https://news.ycombinator.com/item?id=46279468) |
| "This sort of thing is very hard to find for the mac." ✓ | Screen recording | [OBS forum](https://obsproject.com/forum/threads/option-to-highlight-mouse-cursor-and-mouse-clicks.81966/post-426381) |
| "He says the cursor is too small for his 80 year old eyeballs." ✓ | Caregiver | [Mac-Forums](https://www.mac-forums.com/threads/can-i-enlarge-cursor-size.39828/) |
| "I keep losing the cursor!" (Apple's site blocks automated checks; not re-verified) | Multi-monitor | [Apple Community](https://discussions.apple.com/thread/8601868) |

Suggested hook formats: (a) split screen, "what you see / what your Zoom audience sees"; (b) "Your Mac's cursor maxes out at 4×. Here's 30×."; (c) read a real quote on screen, then show the fix in 5 seconds.

## Gaps competitors leave open

1. **Overlays that viewers can't see.** 11 of 107 collected complaints say the highlight didn't show up in a screen share or recording, the single largest theme. One open-source competitor (Cluxo) hides its overlay from capture by default. A real-pointer approach sidesteps this, pending Q1.
2. **Nobody goes past the 4× cap with the real pointer, persistently.** CursorProMax grows the real pointer only while shaking, and only on macOS 26+. Giant Cursor is momentary. Mousecape changes cursor art but is unmaintained since 2020.
3. **No per-app automation.** No competitor found switches pointer size or color by app. Where's My Mouse?'s app rules (big pointer while OBS, Loom or Keynote is open) answer an Apple Community request for a hotkey toggle ([thread](https://discussions.apple.com/thread/256229037)).
4. **Per-monitor size.** Users ask for different pointer sizes per display ([Ask Different](https://apple.stackexchange.com/questions/421699)); nobody offers it. This is a possible paid-version feature (Q4).
5. **Price and trust.** The category is full of $8–15 single-feature apps, paywalled colors, review nags and an annual subscription (Mouseposé). A free, open-source, signed and notarized app is the clean option. Low-vision users specifically worry about memory leaks and permissions.
6. **No Mac version of PowerToys Find My Mouse.** Mac users ask for it by name ("powertoys for mac", 70/mo), and page one is Softonic and a 2020 Reddit thread.
7. **The how-to SERPs have no good long-form answer.** Page one is TikTok, Shorts, Facebook groups and old forum threads.

## Accessibility (separate audience)

- **Language:** they say "mouse pointer" and use "cursor" for the text caret: "not the mouse, which Mac insists is the cursor. No!" ([AppleVis](https://www.applevis.com/forum/low-vision-accessibility-apple-products/alternative-zoomtext-mac)). Write "mouse pointer (the arrow)". Use "low vision" first, then "partially sighted" / "visually impaired"; avoid "suffering from".
- **Search demand:** accessibility-worded queries show no measurable volume. The audience uses the same generic searches ("change cursor size mac", 260) and finds help through AppleVis, Mac-Forums, TidBITS Talk, AbilityNet and Perkins.
- **What they need:** a pointer that doesn't blend in, longer or bigger shake-to-locate ("Currently it is as brief as 1-2 seconds, I need it for more like 10-15 seconds", [Mac-Forums](https://www.mac-forums.com/threads/mouse-shake-duration.374598/)), honesty that very big pointers are less precise, plain statements on permissions and memory.
- **Outreach:** one honest, maker-written post in the AppleVis Low Vision forum (AppleVis doesn't allow developers to submit their own apps to its directory, and asks for original, non-AI writing). Then AbilityNet My Computer My Way (cited in Google's AI Overviews for pointer queries), Perkins, AFB AccessWorld and Veronica With Four Eyes. Details are in [backlink-targets.csv](backlink-targets.csv).

## Outreach: first moves

From [backlink-targets.csv](backlink-targets.csv) (115 rows):
1. Pull requests to awesome-mac (jaywcjlove), open-source-mac-os-apps and awesome-swift-macos-apps. They list Presentify, KeyCastr and Cluxo, and accept PRs.
2. AlternativeTo: add Where's My Mouse? as an alternative on the Mouseposé, Presentify and Cursor Pro pages, and in the "mouse highlight" feature list.
3. MacUpdate: its Hyper Cursor page ranks #1 for "best cursor highlighter mac". Use its Add App form.
4. Directory submit forms: macmenubar.com, menubarlist.com, indieappcatalog.com, opentosh.com, theodorehq.com, payonceapps/onetimepay (free apps fit), discovermacapps.com.
5. Pitch the authors of the roundups that list competitors: MacMost (an article plus a 60.7K-view video on Mouseposé and Presentify), capnot.app, screencharm.com, Setapp's "customize and highlight cursor" how-to, techyorker.
6. Product Hunt launch. Presentify got 224 points there; Cluxo got 3–4 with no audience.
7. Answer existing threads where the question is still open (OBS forum, MacRumors, TidBITS Talk, MPU Talk), as the maker, disclosing it.

## Method and data quality

- **Datasets:** 157 quotes (97 general, 60 accessibility), 989 keywords (447 with real volume), 110 competitors, 107 complaints, 115 outreach targets.
- **Gathering:** five Sonnet agents collected the data. Haiku agents then spot-checked a sample of each dataset against the sources, and I re-checked what they couldn't reach. Results are in [supporting/verification.csv](supporting/verification.csv):
  - Quotes: 18 of 22 matched, 1 minor difference, 3 unreachable (Haiku). I re-checked 15 accessibility quotes plus 6 hook quotes: all matched.
  - Keyword volumes: 7 of 7 returned matched. My own re-check of 10 accessibility volumes matched too. Rankings: 3 of 4 matched, 1 partly.
  - Competitor facts: 11 of 18 matched, 6 minor differences, 1 unconfirmed (Mouseposé's price). Complaints: 74 of 107 found verbatim in saved source downloads, 12 more matched in a live re-check, and 1 couldn't be found and was removed.
  - Outreach pages: 7 of 18 matched, 6 minor, 1 not found, 4 unreachable.
  - Competitor ranking positions (stored DataForSEO data): 3 of 3 live re-checks didn't match, so they're marked stale.
- **Blocked sources:** Reddit (all access methods), X, YouTube comments, G2/Capterra, and partly Apple Community, MacRumors and AppleVis (bot checks, not bypassed). Reddit threads appear only as URLs in rankings and outreach rows, never as quotes.
- **Intent tags:** the first pass mislabeled 14 of a sample of 25, so I replaced them with a fixed rule (why/what/is → info; how → use; app, tool, best, alternative, download, free, brand → purchase; else use).
- **Market:** US only. Other English-speaking markets were not pulled.
