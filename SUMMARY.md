# Source tracking: summary

/stats now shows where visitors and downloads come from, below the existing charts. The charts, tiles and table at the top didn't change, and the download redirect is as fast as before.

## What changed

| File | Change |
|---|---|
| `worker/index.js` | Records where each visitor and download came from, after the existing counts and in the background. Adds `GET /api/sources`. The download redirect is unchanged. |
| `worker/schema.sql` | Full schema for a new database: `seen.src` and the new `breakdown` table. |
| `worker/add-sources.sql` | One-time migration for the live database. |
| `site/index.html`, `site/recipes.html`, `site/guides/*.html` | The visit beacon now also sends the referring domain, the `utm_*` tags, the page path and whether the device has touch. |
| `scripts/build_guides.py`, `scripts/build_recipes.py` | Same beacon in the page generators, so regenerating keeps it. The recipes generator had lost the beacon entirely. |
| `site/stats.html` | New "Where they come from" section under the existing charts. The existing code is untouched: the diff only adds lines. |
| `README.md` | Site, recipes and download links use `?utm_source=github&utm_medium=readme`. Downloads now go through wheresmymouse.com/download (same file, now counted) instead of straight to GitHub Releases. |
| `TRACKING.md` | How counting worked before this change. |
| `LINKS.md` | Tagged links for each place you share the app, and the naming convention. |
| `QUESTIONS.md` | Decisions to check and things left for you. |

## What's tracked now

For each **visitor** (once per UTC day, as before):

- **Source**: the link's `utm_source` if it had one, otherwise a short name for the referring site (`google`, `tiktok`, `github`...), otherwise the in-app browser it opened in (TikTok, Instagram, Facebook, LinkedIn), otherwise `direct`.
- **Referring site**: the domain only, cleaned up (`www.google.co.uk` → `google.com`, `old.reddit.com` → `reddit.com`, `youtu.be` → `youtube.com`), or `direct`.
- **UTM tags**: `utm_source / utm_medium` together, and `utm_campaign`, lowercased.
- **Landing page**: the path of the first page.
- **Country**: from Cloudflare (`request.cf.country`).
- **System** (macOS, iOS, Android, Windows, Linux, ChromeOS) and **browser** (Safari, Chrome, Firefox, Edge, the TikTok and Instagram in-app browsers...), from the user agent. iPads pretend to be Macs, so the page's touch flag counts them as iOS.

For each **download**, the same fields plus the **file**: the release version that `/releases/latest` pointed to at that moment, and `dmg` or `zip`. A download from a Download button on the site gets the source of that visitor's first visit today. A download from a link straight to `/download` (like the README's) gets the link's own tags or referrer.

**Privacy.** No cookies, no new third parties, no IP addresses, no full referrer URLs (the page sends only the domain). Only daily totals per value are stored. The one per-visitor item is the source of today's first visit, stored next to the existing daily salted hash so a download can be credited to it. The worker now deletes earlier days' hashes every time it counts a new visitor; before, deletion was random and hadn't happened yet. See QUESTIONS.md for the missing `SALT` secret and the existing Google Analytics.

**Old data.** Visits and downloads from before the migration have no source and can't get one. They stay in the charts and tiles, and the new section says when source tracking started.

## How to read the new section

Everything covers the **last 30 days**.

- **Sources**: one row per source. **On a Mac** is the share of that source's visitors who could actually install the app. **Rate** is downloads ÷ visitors. Compare sources with Rate and On a Mac together: TikTok might bring lots of visitors, mostly on phones, so a low rate there means "wrong device", not "not interested". Rates over 100% happen when downloads come from a link straight to /download with no visit (the README).
- **Mac vs non-Mac**: the share of visitors on a Mac, the download rate among just those Mac visitors (the real conversion rate), and the share of downloads from a Mac. Below that, visitors and downloads by system.
- **Countries**: top 10, with the rest folded into one row.
- **UTM campaigns** and **Tagged links**: only visits from links tagged per LINKS.md. Use these to compare one TikTok video, email or subreddit with another.
- **Landing pages**: which first page converts. A guide with a high rate is worth linking to directly.
- **Referring sites**: the actual domain, including untagged links. Useful for finding places that link to you that you didn't know about.
- **Browsers** and **Files downloaded**: which browsers, and which version and file people got.

## To ship it (not done: no merge, no deploy)

```bash
npx wrangler d1 execute wheresmymouse-stats --remote --file worker/add-sources.sql
npx wrangler deploy
```

Either order works. If the worker goes out first, counting carries on as before and /stats says source stats aren't available until the SQL runs. After deploying, update your TikTok bio, YouTube descriptions and Kit email links using LINKS.md.

## How it was tested

Locally with `wrangler dev` against a separate copy of the database in the old schema, seeded with 39 days of counts:

- **Before the migration**: visits and downloads still counted, the download redirect answered in 5 ms, and the source errors were caught and logged. `/api/sources` returned an error, which /stats handles.
- **After the migration**: 39 simulated visitors and 18 downloads from TikTok's in-app browser, tagged TikTok, Kit and YouTube links, Google (including google.co.uk), GitHub, Reddit, Windows, Android, an iPad, direct visits, README-style direct downloads and a bot. Every count landed where expected. The bot wasn't counted, and the version resolved to `v1.4.3`.
- **In a real browser**: the page beacon sent the right fields with no console errors. /stats rendered the new section at desktop and phone width (375px) with no horizontal scrolling. A `<img onerror>` campaign name showed up as plain text.

Not tested: real Cloudflare country headers (local dev reports one fixed country), and real TikTok or Instagram traffic.
