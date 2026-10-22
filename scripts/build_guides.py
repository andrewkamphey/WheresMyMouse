#!/usr/bin/env python3
"""Generates the how-to guides in site/guides/ from the data below.

Each guide answers one question people search for (see research/seo/REPORT.md),
with a screenshot per step. Screenshots live in site/assets/guides/; until a file
exists, its slot shows what to capture (see docs/guide-screenshots.md).

Run: python3 scripts/build_guides.py
"""
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "site" / "guides"
SITE = "https://wheresmymouse.com"
UPDATED = "2026-10-22"

SETTINGS_PATH = "System Settings → Accessibility → Display → Pointer"


def shot(name, alt, todo):
    """A screenshot slot. Shows `todo` until site/assets/guides/<name>.png exists."""
    return f'''<figure class="shot">
  <img src="/assets/guides/{name}.png" alt="{html.escape(alt)}" loading="lazy" onerror="this.parentNode.classList.add('missing')">
  <div class="todo"><b>Screenshot: {name}.png</b>{html.escape(todo)}</div>
</figure>'''


def steps(items):
    out = []
    for title, body, shot_html in items:
        out.append(f"<li><h3>{title}</h3>{body}{shot_html}</li>")
    return '<ol class="steps">' + "".join(out) + "</ol>"


# The first three steps are the same on every guide: getting to the Pointer settings.
OPEN_STEPS = [
    ("Open System Settings",
     "<p>Click the Apple menu in the top-left corner of the screen and choose <b>System Settings</b>.</p>",
     shot("open-settings", "Apple menu open with System Settings highlighted",
          "The Apple menu open, with System Settings… highlighted.")),
    ("Go to Accessibility, then Display",
     "<p>Click <b>Accessibility</b> in the sidebar (you may need to scroll down), then click <b>Display</b>.</p>",
     shot("accessibility-display", "System Settings with Accessibility selected and Display highlighted",
          "System Settings with Accessibility selected in the sidebar and the Display row visible.")),
    ("Scroll down to Pointer",
     "<p>Scroll to the <b>Pointer</b> section. Everything about the pointer is here: "
     "<b>Shake mouse pointer to locate</b>, <b>Pointer size</b>, <b>Pointer outline color</b>, "
     "<b>Pointer fill color</b> and <b>Reset Colors</b>.</p>",
     shot("pointer-section", "The Pointer section of Accessibility Display settings",
          "The Display pane scrolled to the Pointer section, showing all five controls.")),
]

OLDER_MACOS = f"""<h2 id="older-macos">On older versions of macOS</h2>
<ul>
<li><b>macOS 13 Ventura and later</b> (Sonoma, Sequoia, Tahoe): {SETTINGS_PATH}, as above.</li>
<li><b>macOS 12 Monterey:</b> Apple menu → System Preferences → Accessibility → Display → Pointer.
<a href="https://support.apple.com/guide/mac-help/make-the-pointer-easier-to-see-mchlp2920/12.0/mac/12.0">Apple's guide for Monterey</a>.</li>
<li><b>macOS 11 Big Sur and earlier:</b> size only. Pointer colors arrived in Monterey.</li>
</ul>"""

GUIDES = [
    {
        "slug": "change-cursor-size-mac",
        "title": "How to Change Cursor Size on Mac (and Go Bigger Than 4×)",
        "nav": "Change cursor size",
        "description": "Make the mouse pointer bigger or smaller on a Mac in System Settings, step by step with screenshots. Plus how to go past the 4× limit.",
        "answer": f"Open <b>{SETTINGS_PATH}</b> and drag the <b>Pointer size</b> slider. The pointer changes as you drag, with no restart. The slider stops at 4× the normal size.",
        "steps": OPEN_STEPS + [
            ("Drag the Pointer size slider",
             "<p>Drag right to make the pointer bigger, left to go back to normal. It changes live, so stop when you can find it easily.</p>",
             shot("size-slider", "Pointer size slider dragged toward Large",
                  "Close-up of the Pointer size slider dragged about halfway toward Large.")),
            ("Check it",
             "<p>Move the mouse around a busy window. If it still gets lost, try a brighter fill color too: see <a href=\"/guides/change-cursor-color-mac\">how to change cursor color</a>.</p>",
             shot("size-after", "A large Mac pointer over a busy window",
                  "The enlarged pointer over a busy window. Take it as a frame from a screen recording: still screenshots draw the pointer at normal size.")),
        ],
        "body": OLDER_MACOS + """
<h2 id="biggest">How big can the cursor get?</h2>
<p>In System Settings, 4× the normal size: that's the far right of the slider. On a big or high-resolution display, or when your screen is shrunk down in a video call or recording, even 4× can be hard to follow.</p>

<h2 id="suddenly-big">Why did my cursor suddenly get big?</h2>
<p>Usually it's <b>Shake mouse pointer to locate</b>: moving the mouse fast makes the pointer grow for a moment, then it shrinks back. That's on purpose. If it stays big, someone moved the Pointer size slider; drag it back to the left. See <a href="/guides/shake-to-find-cursor-mac">shake to find your cursor</a> and <a href="/guides/reset-cursor-mac">getting your cursor back to normal</a>.</p>

<h2 id="screenshots">Why is my cursor small in screenshots?</h2>
<p>macOS draws the pointer at its normal size in still screenshots, whatever size you set. Video recordings show the size you chose.</p>
""",
        "pitch": "Need the cursor bigger than 4×, or only bigger while you record or present? <b>Where's My Mouse?</b> goes up to 15× with the real pointer (30× while you shake it), and switches size on its own when an app like OBS, Zoom or Keynote is open.",
        "faq": [
            ("How do I make my cursor bigger on a Mac?",
             f"Open {SETTINGS_PATH} and drag the Pointer size slider to the right."),
            ("What is the maximum cursor size on a Mac?",
             "System Settings goes up to 4× the normal size. Apps like Where's My Mouse? can go further."),
            ("Why did my Mac cursor get big by itself?",
             "Shake mouse pointer to locate makes the pointer grow briefly when you move the mouse quickly. Turn it off in the same Pointer settings if you don't want it."),
            ("Do I need to restart after changing the cursor size?",
             "No. The pointer changes as soon as you move the slider."),
        ],
    },
    {
        "slug": "change-cursor-color-mac",
        "title": "How to Change Cursor Color on Mac: Fill, Outline, or Both",
        "nav": "Change cursor color",
        "description": "Change the Mac mouse pointer's fill color, outline color, or both in System Settings, with screenshots. Plus color pairs that stay visible on any background.",
        "answer": f"Open <b>{SETTINGS_PATH}</b>. Click the <b>Pointer fill color</b> well to change the inside of the arrow, or <b>Pointer outline color</b> to change its edge, and pick a color. Needs macOS 12 Monterey or later.",
        "steps": None,
        "body": f"""
<p>The Mac pointer has two colors: the <b>fill</b> (the inside, black by default) and the <b>outline</b> (the edge, white by default). You can change either one, or both. First get to the Pointer settings:</p>
{steps(OPEN_STEPS)}

<h2 id="fill">How to change the cursor fill color</h2>
<ol class="steps">
<li><h3>Click the Pointer fill color well</h3><p>It's the color swatch next to <b>Pointer fill color</b>.</p>{shot("fill-well", "Pointer fill color well clicked, showing color choices", "The Pointer fill color well clicked, with the color choices showing.")}</li>
<li><h3>Pick a color</h3><p>Choose a swatch, or open the full Colors window to choose any color. The pointer updates right away.</p>{shot("fill-after", "Mac pointer with a custom fill color", "The pointer with a bright fill (for example yellow) over a window. Take it as a frame from a screen recording.")}</li>
</ol>

<h2 id="outline">How to change the cursor outline color</h2>
<ol class="steps">
<li><h3>Click the Pointer outline color well</h3><p>It's the swatch next to <b>Pointer outline color</b>.</p>{shot("outline-well", "Pointer outline color well clicked, showing color choices", "The Pointer outline color well clicked, with the color choices showing.")}</li>
<li><h3>Pick a color</h3><p>A dark outline helps on light backgrounds; a light outline helps on dark ones.</p></li>
</ol>

<h2 id="both">How to change both fill and outline</h2>
<p>Set the fill first, then the outline, using the steps above. Pick two colors that contrast with each other, so the pointer stands out on both light and dark backgrounds. Some pairs to try:</p>
<table class="pairs">
<tr><th>Fill</th><th>Outline</th><th>Good for</th></tr>
<tr><td><i class="sw" style="background:#ffd60a"></i>Yellow</td><td><i class="sw" style="background:#000"></i>Black</td><td>Seeing it on anything, light or dark</td></tr>
<tr><td><i class="sw" style="background:#fff"></i>White</td><td><i class="sw" style="background:#000"></i>Black</td><td>Dark mode and dark apps</td></tr>
<tr><td><i class="sw" style="background:#ff3b30"></i>Red</td><td><i class="sw" style="background:#fff"></i>White</td><td>Presenting and projectors</td></tr>
<tr><td><i class="sw" style="background:#0a84ff"></i>Blue</td><td><i class="sw" style="background:#fff"></i>White</td><td>Screen recordings and tutorials</td></tr>
</table>
{shot("both-after", "Mac pointer with a yellow fill and black outline", "The pointer with both colors changed (yellow fill, black outline) over a light window. Frame from a screen recording.")}

<h2 id="exact-color">How to pick an exact color</h2>
<p>In the full Colors window, choose the sliders tab and set it to RGB. There you can type a hex code such as <code>#FF3B30</code>, handy for matching a brand color in product videos.</p>

<h2 id="reset">How to change the colors back</h2>
<p>Click <b>Reset Colors</b> in the same section. It restores the white outline and black fill. More in <a href="/guides/reset-cursor-mac">how to get your cursor back to normal</a>.</p>

{OLDER_MACOS}

<h2 id="not-changing">Why didn't the color change in some apps?</h2>
<p>Some apps, often games and some design tools, draw their own cursor and ignore the system pointer settings. The color comes back when you switch to another app.</p>
""",
        "pitch": "Tired of opening System Settings every time? <b>Where's My Mouse?</b> saves fill and outline pairs as presets, switches between them in one click from the menu bar, and can give each app its own look: big and blue in OBS, red in Keynote, normal everywhere else. There are 32 ready-made <a href=\"/recipes\">Cursor Recipes</a> to start from.",
        "faq": [
            ("How do I change my cursor color on a Mac?",
             f"Open {SETTINGS_PATH}, click the Pointer fill color or Pointer outline color well, and pick a color."),
            ("What is the cursor fill color?",
             "The color inside the arrow. It's black by default."),
            ("What is the cursor outline color?",
             "The color of the arrow's edge. It's white by default."),
            ("Can I change the cursor color on macOS Big Sur?",
             "No. Pointer colors were added in macOS 12 Monterey."),
            ("How do I reset the cursor color?",
             "Click Reset Colors in the Pointer section of Accessibility → Display."),
        ],
    },
    {
        "slug": "reset-cursor-mac",
        "title": "How to Get Your Mac Cursor Back to Normal",
        "nav": "Reset your cursor",
        "description": "Cursor too big, the wrong color, or gone? How to reset the Mac mouse pointer to its normal size and colors, with screenshots.",
        "answer": f"Open <b>{SETTINGS_PATH}</b>. Drag <b>Pointer size</b> all the way left to Normal, then click <b>Reset Colors</b> to get the white outline and black fill back.",
        "steps": OPEN_STEPS + [
            ("Drag Pointer size all the way left",
             "<p>Far left is the normal size.</p>",
             shot("size-normal", "Pointer size slider at Normal", "Close-up of the Pointer size slider at the far left (Normal).")),
            ("Click Reset Colors",
             "<p>This puts back the white outline and black fill.</p>",
             shot("reset-colors", "Reset Colors button in the Pointer settings", "The Reset Colors button in the Pointer section, highlighted.")),
        ],
        "body": """
<h2 id="grows">If the cursor grows for a second when you move it</h2>
<p>That's <b>Shake mouse pointer to locate</b>, which is on by default. Turn it off in the same section if it bothers you. See <a href="/guides/shake-to-find-cursor-mac">shake to find your cursor</a>.</p>

<h2 id="gone">If the cursor has disappeared</h2>
<ul>
<li>Shake the mouse or move your finger quickly on the trackpad: the pointer grows so you can spot it.</li>
<li>If you have more than one display, it may be on the other screen. Keep moving it toward the edge you think it went past.</li>
<li>Move the pointer onto the Dock, or press Command-Tab to switch apps. Some people report this brings a vanished pointer back.</li>
</ul>
""",
        "pitch": "If you use <b>Where's My Mouse?</b>, choose <b>Default</b> in its menu to go back to the normal pointer in one click. Your recording and presenting looks stay saved as presets for next time.",
        "faq": [
            ("How do I get my cursor back to normal on a Mac?",
             f"Open {SETTINGS_PATH}, drag Pointer size to the far left, and click Reset Colors."),
            ("How do I make my cursor smaller on a Mac?",
             "Drag the Pointer size slider to the left in Accessibility → Display."),
            ("Why is my cursor so big on my Mac?",
             "Either the Pointer size slider was moved, or Shake mouse pointer to locate is enlarging it while you move the mouse quickly."),
        ],
    },
    {
        "slug": "shake-to-find-cursor-mac",
        "title": "Shake to Find Your Cursor on Mac: Turn It On or Off",
        "nav": "Shake to find your cursor",
        "description": "What Shake mouse pointer to locate does on a Mac, how to turn it on or off with screenshots, and why your cursor gets bigger when you shake it.",
        "answer": f"Open <b>{SETTINGS_PATH}</b> and switch <b>Shake mouse pointer to locate</b> on or off. When it's on, moving the mouse quickly makes the pointer grow for a moment so you can spot it.",
        "steps": OPEN_STEPS + [
            ("Switch Shake mouse pointer to locate on or off",
             "<p>On: shake the mouse, or move a finger quickly back and forth on the trackpad, and the pointer grows for a moment. Off: it never grows.</p>",
             shot("shake-toggle", "Shake mouse pointer to locate switch", "Close-up of the Shake mouse pointer to locate switch.")),
        ],
        "body": """
<h2 id="why-bigger">Why does my cursor get bigger when I shake it?</h2>
<p>That's this feature doing its job: it's how a Mac helps you find a lost pointer. It's on by default, so many people only notice it by accident.</p>

<h2 id="not-enough">When shaking isn't enough</h2>
<p>The shake only makes the pointer briefly larger, and only for a second or two. On a large display, or across several, people still lose it:</p>
<blockquote>“No matter how much I shake it, the cursor is not visible.” <cite><a href="https://forums.macrumors.com/threads/cursor-highlight-on-large-screens.2356682/">MacRumors forum, user with two 43-inch screens</a></cite></blockquote>
<blockquote>“Currently it is as brief as 1-2 seconds, I need it for more like 10-15 seconds.” <cite><a href="https://www.mac-forums.com/threads/mouse-shake-duration.374598/">Mac-Forums</a></cite></blockquote>
<p>macOS has no setting for how big or how long the shake makes it. A permanently bigger pointer, or a brighter fill color, helps: see <a href="/guides/change-cursor-size-mac">change cursor size</a> and <a href="/guides/change-cursor-color-mac">change cursor color</a>.</p>
""",
        "pitch": "<b>Where's My Mouse?</b> adds <b>Super shake</b>: shake the mouse and the pointer grows to 3× its current size, at least 10× and up to 30×, then shrinks back. It works at any pointer size.",
        "faq": [
            ("How do I turn off shake to locate on a Mac?",
             f"Open {SETTINGS_PATH} and switch off Shake mouse pointer to locate."),
            ("Why does my Mac cursor get bigger when I shake it?",
             "Shake mouse pointer to locate is on. It briefly enlarges the pointer when you move the mouse quickly, to help you find it."),
            ("Can I make the shake cursor bigger?",
             "Not in macOS settings. Where's My Mouse? has a Super shake that grows the pointer up to 30×."),
        ],
    },
]

CSS_HREF = "/assets/guides.css"

HEAD = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-M5TJXXCL2K"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){{dataLayer.push(arguments);}}
  gtag('js', new Date());

  gtag('config', 'G-M5TJXXCL2K');
</script>

<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{description}">
<link rel="icon" type="image/png" href="/assets/favicon.png">
<link rel="apple-touch-icon" href="/assets/icon.png">
<meta property="og:title" content="{title}">
<meta property="og:description" content="{description}">
<meta property="og:image" content="https://wheresmymouse.com/assets/og.png">
<meta property="og:url" content="{url}">
<meta name="twitter:card" content="summary_large_image">
<link rel="canonical" href="{url}">
<link rel="stylesheet" href="{css}">
<script type="application/ld+json">{jsonld}</script>
</head>
<body>
<div class="wrap">
  <nav>
    <a class="brand" href="/"><img src="/assets/icon.png" alt="">Where's My Mouse?</a>
    <div class="links">
      <a class="hide-sm" href="/guides/">Guides</a>
      <a class="hide-sm" href="/recipes">Recipes</a>
      <a class="hide-sm" href="https://github.com/andrewkamphey/WheresMyMouse">GitHub</a>
      <a class="dl btn-dl" href="https://wheresmymouse.com/download"><span class="dl-label">Download free</span></a>
    </div>
  </nav>
"""

FOOT = """</div>
<footer>
  <div class="wrap">
    <span>Made by <a href="https://github.com/andrewkamphey">Andrew Kamphey</a>, who kept losing his mouse.</span>
    <span>MIT License · Not affiliated with Apple.</span>
  </div>
</footer>
<script src="/assets/get-app.js"></script>
<script>
  document.addEventListener('click', function (e) {
    var a = e.target.closest && e.target.closest('a[href*="/download"]');
    if (a && window.gtag) gtag('event', 'download', { file_name: 'WheresMyMouse.dmg', link_url: a.href, transport_type: 'beacon' });
  });
</script>
</body>
</html>
"""


def plain(s):
    """HTML fragment → text, for structured data."""
    import re
    return html.unescape(re.sub(r"<[^>]+>", "", s))


def page(g):
    url = f"{SITE}/guides/{g['slug']}"
    graph = [
        {"@type": "BreadcrumbList", "itemListElement": [
            {"@type": "ListItem", "position": 1, "name": "Guides", "item": f"{SITE}/guides/"},
            {"@type": "ListItem", "position": 2, "name": g["nav"], "item": url}]},
        {"@type": "FAQPage", "mainEntity": [
            {"@type": "Question", "name": q, "acceptedAnswer": {"@type": "Answer", "text": a}}
            for q, a in g["faq"]]},
    ]
    if g["steps"]:
        graph.append({"@type": "HowTo", "name": g["title"], "step": [
            {"@type": "HowToStep", "position": i + 1, "name": t, "text": plain(b)}
            for i, (t, b, _) in enumerate(g["steps"])]})
    jsonld = json.dumps({"@context": "https://schema.org", "@graph": graph}, ensure_ascii=False)
    others = "".join(
        f'<li><a href="/guides/{o["slug"]}">{o["nav"]}</a></li>' for o in GUIDES if o is not g)
    faq = "".join(
        f"<details><summary>{html.escape(q)}</summary><p>{html.escape(a)}</p></details>" for q, a in g["faq"])
    return (HEAD.format(title=html.escape(g["title"]), description=html.escape(g["description"]),
                        url=url, css=CSS_HREF, jsonld=jsonld)
            + f"""  <main class="guide">
    <p class="crumbs"><a href="/guides/">Guides</a> › {g["nav"]}</p>
    <h1>{g["title"]}</h1>
    <p class="updated">Updated {UPDATED} · macOS 12 Monterey to macOS 26 Tahoe</p>
    <div class="answer"><b>Quick answer:</b> {g["answer"]}</div>
    {steps(g["steps"]) if g["steps"] else ""}
    {g["body"]}
    <aside class="pitch">
      <img src="/assets/icon.png" alt="" width="56" height="56">
      <div>
        <p>{g["pitch"]}</p>
        <p class="acts"><a class="dl btn-dl" href="https://wheresmymouse.com/download"><span class="dl-label">Download free</span></a> <a href="/">See how it works</a></p>
        <p class="fine">Free and open source · macOS 11 and later · signed and notarized by Apple</p>
      </div>
    </aside>
    <h2 id="faq">Questions</h2>
    <div class="faq">{faq}</div>
    <h2>More guides</h2>
    <ul class="more">{others}</ul>
  </main>
""" + FOOT)


def index():
    url = f"{SITE}/guides/"
    cards = "".join(
        f'<a class="card" href="/guides/{g["slug"]}"><h2>{g["title"]}</h2><p>{g["description"]}</p></a>'
        for g in GUIDES)
    jsonld = json.dumps({"@context": "https://schema.org", "@type": "CollectionPage", "name": "Mac pointer guides",
                         "url": url}, ensure_ascii=False)
    return (HEAD.format(title="Mac Cursor Guides: Size, Color, Reset and Shake to Find",
                        description="Step-by-step guides with screenshots for changing the Mac mouse pointer: size, fill and outline color, resetting it, and shake to locate.",
                        url=url, css=CSS_HREF, jsonld=jsonld)
            + f"""  <main class="guide">
    <h1>Mac cursor guides</h1>
    <p class="lede">Everything macOS lets you change about the mouse pointer, step by step with screenshots.</p>
    <div class="cards">{cards}</div>
  </main>
""" + FOOT)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    (ROOT / "site" / "assets" / "guides").mkdir(parents=True, exist_ok=True)
    for g in GUIDES:
        (OUT / f"{g['slug']}.html").write_text(page(g))
    (OUT / "index.html").write_text(index())
    print(f"wrote {len(GUIDES) + 1} pages to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
