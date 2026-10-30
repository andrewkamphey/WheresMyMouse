# Source tracking: summary

/stats now shows where visitors and downloads come from, in a **Sources** table below the existing charts. The charts, tiles and table at the top didn't change, and the download redirect is as fast as before.

## How to read the Sources table

It covers the **last 30 days**, one row per source:

- **Source**: the site that sent the visitor (`google`, `tiktok`, `github`, `reddit`, or the site's domain for anything else), or `direct` when the browser didn't say. Visits from TikTok's and Instagram's in-app browsers count as `tiktok` and `instagram`. A link with `?utm_source=name` shows as that name (see LINKS.md).
- **Visitors**: once per visitor per UTC day, as in the charts above.
- **Downloads**: a download from a Download button on the site is credited to where that visitor came from that day.
- **Download rate**: downloads ÷ visitors. It can go over 100% for `github`, because the README links straight to /download, so those downloads come without a page visit.

Visits and downloads from before source tracking started have no source. They stay in the charts above, and the table says when tracking started.

## What changed

| File | Change |
|---|---|
| `worker/index.js` | Records each visitor's and download's source in the background, after the existing counts. Adds `GET /api/sources`. The download redirect is unchanged. |
| `worker/schema.sql`, `worker/add-sources.sql` | The new `breakdown` table and `seen.src` column. The migration has been run on the live database. |
| `site/index.html`, `site/recipes.html`, `site/guides/*.html`, `scripts/build_*.py` | The visit beacon also sends the referring domain (not the full URL), the page path and any `utm_*` tags. |
| `site/stats.html` | The new Sources table under the existing charts. The existing code is untouched. |
| `README.md` | Its site and download links are tagged `github`. Downloads go through wheresmymouse.com/download, so they're counted now. |
| `TRACKING.md`, `LINKS.md` | How counting worked before, and how to name a link's source. |

**Recorded but not shown.** The worker also records country, Mac vs other systems, browser, landing page and downloaded version as daily totals, so any of these can be added to /stats later without waiting for new data.

**Privacy.** No cookies, no IP addresses, no full referrer URLs. Only daily totals are stored. Each visitor's source is kept next to the existing daily visitor hash until the end of that UTC day, so a download can be credited to it, and then deleted.
