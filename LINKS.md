# Tagged links for sharing Where's My Mouse?

Use these instead of the bare wheresmymouse.com, so the **Sources** table on [/stats](https://wheresmymouse.com/stats) can tell where visitors and downloads came from. Untagged links still work, and the stats fall back to the referring site, but many apps (TikTok, Instagram, email) send no referrer at all and show up as `direct`.

## Ready-to-use links

| Where you share it | Link |
|---|---|
| TikTok bio | `https://wheresmymouse.com/?utm_source=tiktok&utm_medium=bio` |
| TikTok video (comment or caption) | `https://wheresmymouse.com/?utm_source=tiktok&utm_medium=video&utm_campaign=VIDEO-NAME` |
| YouTube description | `https://wheresmymouse.com/?utm_source=youtube&utm_medium=description` |
| YouTube pinned comment | `https://wheresmymouse.com/?utm_source=youtube&utm_medium=comment` |
| YouTube Shorts | `https://wheresmymouse.com/?utm_source=youtube&utm_medium=shorts` |
| Better Sheets emails (Kit) | `https://wheresmymouse.com/?utm_source=kit&utm_medium=email&utm_campaign=EMAIL-NAME` |
| Better Sheets website | `https://wheresmymouse.com/?utm_source=bettersheets&utm_medium=site` |
| GitHub README (site link) | `https://wheresmymouse.com/?utm_source=github&utm_medium=readme` |
| GitHub README (download) | `https://wheresmymouse.com/download?utm_source=github&utm_medium=readme` |
| GitHub release notes | `https://wheresmymouse.com/?utm_source=github&utm_medium=release` |
| Reddit post | `https://wheresmymouse.com/?utm_source=reddit&utm_medium=post&utm_campaign=SUBREDDIT` |
| Reddit comment | `https://wheresmymouse.com/?utm_source=reddit&utm_medium=comment&utm_campaign=SUBREDDIT` |
| X / Twitter | `https://wheresmymouse.com/?utm_source=x&utm_medium=post` |
| LinkedIn | `https://wheresmymouse.com/?utm_source=linkedin&utm_medium=post` |
| Instagram bio | `https://wheresmymouse.com/?utm_source=instagram&utm_medium=bio` |
| Product Hunt | `https://wheresmymouse.com/?utm_source=producthunt&utm_medium=launch` |
| The app's "Browse recipes" menu item (not changed yet, see QUESTIONS.md) | `https://wheresmymouse.com/recipes?utm_source=app&utm_medium=recipes-menu` |

The README already uses its two links. Every other row is ready to paste.

## Deep links

The tags work on any page, not just the home page:

- A guide: `https://wheresmymouse.com/guides/cursor-too-small-in-screen-recording-mac?utm_source=youtube&utm_medium=description`
- Recipes: `https://wheresmymouse.com/recipes?utm_source=tiktok&utm_medium=video&utm_campaign=halloween`
- Straight to the download, skipping the page: `https://wheresmymouse.com/download?utm_source=kit&utm_medium=email` (or `/download.zip`). Use this only where people already know what the app is: it starts a .dmg download on any device, including phones, and those downloads count with no visit, so that source's download rate can go over 100%.

## The convention

- **utm_source**: where the link lives, as one lowercase word: `tiktok`, `youtube`, `kit`, `github`, `reddit`. This is the **Source** column on /stats, and it matches the name /stats gives untagged visits from the same site (a visit from tiktok.com with no tag is also `tiktok`), so the two add up in one row.
- **utm_medium**: what kind of spot on that site: `bio`, `video`, `description`, `comment`, `email`, `readme`, `post`. Source and medium together are the **Tagged links** table.
- **utm_campaign** (optional): the specific post, video or email, so you can compare them: `halloween-recipes`, `oct-newsletter`, `r-macapps`. This is the **UTM campaigns** table.
- Lowercase, with hyphens instead of spaces. The stats lowercase everything and turn spaces into hyphens anyway, so `Halloween Recipes` and `halloween-recipes` land in the same row.
- Keep using the same values. `yt` one week and `youtube` the next splits one source into two rows.
- Tags are only read on the first page of a visit, and each visitor is counted once a day, so tagging internal links between your own pages does nothing.
