# Links for sharing Where's My Mouse?

Plain `https://wheresmymouse.com` links work fine. The Sources table on [/stats](https://wheresmymouse.com/stats) shows the site that sent each visitor (google, github, reddit...). Visits from TikTok's and Instagram's in-app browsers count as tiktok and instagram, even though those apps don't say where the visitor came from.

A visit shows up as `direct` when the browser doesn't say where it came from: typed URLs, some apps, some email clients. To name a link's source anyway, add `?utm_source=` with a name, and that name shows in the Source column:

| Where | Link |
|---|---|
| TikTok bio | `https://wheresmymouse.com/?utm_source=tiktok` |
| YouTube description | `https://wheresmymouse.com/?utm_source=youtube` |
| GitHub README (already set) | `https://wheresmymouse.com/?utm_source=github&utm_medium=readme` |

Use lowercase, one word, and keep using the same name for the same place.
