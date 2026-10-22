# Guide screenshots

The pages in `site/guides/` show a dashed box for each screenshot until its file exists. Save each one as a PNG in `site/assets/guides/` with the exact name below, and the page picks it up on its own.

**Before you start**
- Light or dark mode, but use the same for every shot.
- Use `Shift-Command-4`, then `Space`, then click the window: a whole-window shot with its shadow. For close-ups, drag a box instead.
- Keep each file under about 1,600 px wide. Retina is fine.
- **The "after" shots need a screen recording, not a screenshot.** macOS draws the pointer at normal size, or leaves it out, in still screenshots. Record a few seconds with `Shift-Command-5` → Record, open the video in QuickTime, pause on a good frame, and press `Command-C`. Then in Preview choose File → New from Clipboard and save it as a PNG.

| # | File | Used on | What to capture |
|---|---|---|---|
| 1 | `open-settings.png` | all four guides | The Apple menu open, with **System Settings…** highlighted |
| 2 | `accessibility-display.png` | all four | System Settings with **Accessibility** selected in the sidebar and the **Display** row visible |
| 3 | `pointer-section.png` | all four | Display scrolled to **Pointer**, with all five controls showing (shake, size, outline, fill, Reset Colors) |
| 4 | `size-slider.png` | size | Close-up of **Pointer size** dragged about halfway |
| 5 | `size-after.png` | size | **Recording frame:** the big pointer over a busy window |
| 6 | `fill-well.png` | color | The **Pointer fill color** well clicked, with the color choices open |
| 7 | `fill-after.png` | color | **Recording frame:** the pointer with a bright fill (for example yellow) |
| 8 | `outline-well.png` | color | The **Pointer outline color** well clicked, with the color choices open |
| 9 | `both-after.png` | color | **Recording frame:** yellow fill and black outline over a light window |
| 10 | `size-normal.png` | reset | Close-up of **Pointer size** at the far left (Normal) |
| 11 | `reset-colors.png` | reset | The **Reset Colors** button |
| 12 | `shake-toggle.png` | shake | Close-up of the **Shake mouse pointer to locate** switch |

Shots 1–3 are shared, so 12 captures cover all four pages. When you're done, put your pointer back to how you like it, or click Reset Colors.

The page text lives in `scripts/build_guides.py`. Run `python3 scripts/build_guides.py` after editing it.
