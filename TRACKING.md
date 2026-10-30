# How wheresmymouse.com counts visitors and downloads

Written before adding source tracking, to record how it worked up to then (v1.4.3, Oct 2026).

## Where it runs

- **Hosting:** Cloudflare Workers with static assets (`wrangler.jsonc`). `site/` is served as static files; `worker/index.js` only runs first for `/download`, `/download.zip` and `/api/*`.
- **Storage:** a Cloudflare D1 (SQLite) database, `wheresmymouse-stats`. Schema in `worker/schema.sql`.

## What gets recorded

**Page views and visitors.** Every public page (home, recipes, guides) ends with:

```html
<script>navigator.sendBeacon && navigator.sendBeacon('/api/hit');</script>
```

The worker handles `POST /api/hit` (`countView` in `worker/index.js`):

1. Adds 1 to `daily` for `(today, 'view')`.
2. Hashes `SALT | day | IP | user agent` with SHA-256 and inserts the hash into `seen`. If the hash is new today, adds 1 to `(today, 'visitor')`. So a visitor is one browser on one IP, once per UTC day, without cookies.
3. On about 2% of hits, deletes `seen` rows from earlier days.

The beacon has no body, so nothing about where the visitor came from reaches the worker.

**Downloads.** Every Download button links to `https://wheresmymouse.com/download` (or `/download.zip`). The worker adds 1 to `(today, 'download')` in the background (`ctx.waitUntil`) and immediately 302-redirects to `github.com/andrewkamphey/WheresMyMouse/releases/latest/download/WheresMyMouse.dmg` (or `.zip`). The README links straight to GitHub Releases, so those downloads were never counted here.

**Bots** are skipped by a user agent regex (`BOT` in `worker/index.js`).

## Tables

| Table | Holds |
|---|---|
| `daily (day, metric, n)` | One row per UTC day and metric: `view`, `visitor`, `download` |
| `seen (day, h)` | Salted visitor hashes, meant to be kept for the current day only |

## The stats page

`site/stats.html` (served at `/stats`) fetches `GET /api/stats`, which returns every `daily` row from the last 800 days. The page draws the tiles, the visitor and download bar charts (30 days, 90 days, by month) and the table in the browser. It also adds up `download_count` from the GitHub Releases API for the all-time total, which includes downloads from before site tracking began.

## Also on the site

Every page except `/stats` also loads Google Analytics 4 (`G-M5TJXXCL2K`) and sends a GA `download` event on Download clicks. That is separate from the D1 counts and not used by `/stats`.

## Gaps found while reading

- **No source data** of any kind: no referrer, UTM tags, landing page, country, device or file.
- **No `SALT` secret is set** on the worker (`wrangler secret list` is empty), so the hash uses the fallback salt `'wmm'`, which is in this public repo.
- **`seen` keeps old hashes.** The 2% prune hadn't run yet: on 30 Oct 2026 it still held all 72 hashes back to 21 Oct, the day tracking started.
- **`scripts/build_recipes.py` has drifted from `site/recipes.html`.** Regenerating would drop the `/api/hit` beacon (and other hand edits), so recipes visits would stop being counted.

Tracking started on **21 Oct 2026**. On 30 Oct it had 82 page views, 72 visitor-days and 62 downloads.
