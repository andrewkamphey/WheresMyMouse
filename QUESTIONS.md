# Questions from adding source tracking

Things I decided without asking, or left for you. The pick I went with is noted on each one.

1. **Google Analytics is still on every page.** The new tracking uses no cookies and no third parties, but GA4 (`G-M5TJXXCL2K`) is a third-party tracker that sets cookies, and it was already on every page except /stats. I left it alone. Do you want it removed now that /stats shows sources?

2. **The visitor hash has no secret salt.** `wrangler secret list` is empty, so the hash falls back to `'wmm'`, which is public in this repo. Anyone with a copy of the database and someone's IP and browser could check whether they visited that day. I didn't change production secrets. To fix it, run `npx wrangler secret put SALT` with a long random value. Visitors already counted that day get counted once more.

3. **/stats is public.** It was already public (`noindex`, but anyone with the URL can see it). Now it also shows your campaign names, email names and which channels work. Should it go behind Cloudflare Access or a password?

4. **Nothing is deployed.** The PR needs `worker/add-sources.sql` run on the live database, then `npx wrangler deploy`. Either order is safe: until the SQL runs, counting works as before and /stats says source stats aren't available. Steps are in SUMMARY.md.

5. **Who gets credit: the first visit of the day.** A visitor counts under the source of their first visit that UTC day, and their downloads that day go to the same source. If someone finds you on TikTok and comes back the next day by typing the URL, day two counts as `direct`. Without cookies there's no way to connect the two days. Is first-visit-of-the-day OK?

6. **Download rate uses all visitors.** As you asked, rate is downloads ÷ visitors. Phone visitors can't download, so I also added an "On a Mac" column and a "download rate for Mac visitors" number in the Mac card. Should the Sources table use Mac visitors as the denominator instead?

7. **Source tables always cover the last 30 days.** They don't follow the 30 days / 90 days / By month switch at the top. Want them to?

8. **The app's "Browse recipes" menu item isn't tagged.** It opens wheresmymouse.com/recipes with no referrer, so existing users show up as `direct`. Tagging it (`?utm_source=app&utm_medium=recipes-menu`, in `Sources/RecipeMenu.swift`) would separate them from new visitors, but it only takes effect in the next app release. I didn't change the app. Do you want it?

9. **`scripts/build_recipes.py` is out of date with `site/recipes.html`.** Running it would undo hand edits to recipes.html (the `·` title separator, the 192px favicon, the Guides nav link, the footer guide links) and, before this PR, the visit beacon. I added the beacon to the generator but didn't fix the rest. Fix it in a separate change?

10. **Anyone can send made-up sources.** `/api/hit` accepts whatever the page sends, like any cookieless analytics, so someone could add fake rows ("referrer spam"). Values are cut to 64 characters, and /stats escapes them and shows only the top 10 to 15 per table. Want an allowlist of utm_source values instead?

11. **UTM tags stay in the address bar.** If someone copies a tagged link and shares it, the next visitors count under the same tag. Stripping tags after the page reads them would stop that, but GA reads them later, so I left them. Strip them if GA goes?
