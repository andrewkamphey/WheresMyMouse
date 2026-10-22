# Guide screenshots

The pages in `site/guides/` show a dashed box for each screenshot until its file exists. Save each one as a PNG in `site/assets/guides/` with the exact name below, and the page picks it up on its own.

**Before you start**
- Light or dark mode, but use the same for every shot.
- Use `Shift-Command-4`, then `Space`, then click the window: a whole-window shot with its shadow. For close-ups, drag a box instead.
- Keep each file under about 1,600 px wide. Retina is fine.
- **The "after" shots need the pointer in the picture.** Screen recordings (`Shift-Command-5` recording, or OBS with Capture Cursor on) include it by default. Regular screenshots leave it out; for a still with the pointer, run `screencapture -C -T 5 ~/Desktop/pointer-shot.png` in Terminal (`-C` includes the pointer, `-T 5` gives you 5 seconds to position it), then crop it in Preview.
- **Big pointer (`size-after.png`): record with OBS.** OBS is the setup the site says was tested. macOS draws the pointer at normal size in still screenshots, and it isn't confirmed that the built-in recorder keeps the enlarged size. Try a `Shift-Command-5` recording too: if the pointer comes out big, that also settles Q1 in `research/seo/QUESTIONS.md`. To grab a frame: open the video in QuickTime, pause on a good frame, press `Command-C`, then in Preview choose File → New from Clipboard and save as PNG.
- **Colored pointer (`fill-after`, `both-after`):** a still from `screencapture -C` should show the colors at normal size. Check the first one; if the colors don't show, use a recording frame instead.

| # | File | Used on | What to capture |
|---|---|---|---|
| 1 | `open-settings.png` | all four guides | The Apple menu open, with **System Settings…** highlighted |
| 2 | `accessibility-display.png` | all four | System Settings with **Accessibility** selected in the sidebar and the **Display** row visible |
| 3 | `pointer-section.png` | all four | Display scrolled to **Pointer**, with all five controls showing (shake, size, outline, fill, Reset Colors) |
| 4 | `size-slider.png` | size | Close-up of **Pointer size** dragged about halfway |
| 5 | `size-after.png` | size | **OBS recording frame:** the big pointer over a busy window |
| 6 | `fill-well.png` | color | The **Pointer fill color** well clicked, with the color choices open |
| 7 | `fill-after.png` | color | **Recording frame:** the pointer with a bright fill (for example yellow) |
| 8 | `outline-well.png` | color | The **Pointer outline color** well clicked, with the color choices open |
| 9 | `both-after.png` | color | **Recording frame:** yellow fill and black outline over a light window |
| 10 | `size-normal.png` | reset | Close-up of **Pointer size** at the far left (Normal) |
| 11 | `reset-colors.png` | reset | The **Reset Colors** button |
| 12 | `shake-toggle.png` | shake | Close-up of the **Shake mouse pointer to locate** switch |

Shots 1–3 are shared, so 12 captures cover all four pages. When you're done, put your pointer back to how you like it, or click Reset Colors.

The page text lives in `scripts/build_guides.py`. Run `python3 scripts/build_guides.py` after editing it.
