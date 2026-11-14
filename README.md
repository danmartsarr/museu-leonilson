# Museu Leonilson

**Live site:** https://danmartsarr.github.io/museu-leonilson/

A digital museum for the work of Brazilian artist **José Leonilson**
(Fortaleza, 1957 – São Paulo, 1993): the collection by decade, a biography
with a timeline and family photographs, and an interactive canvas. Content is
in Portuguese.

Built with Flutter (web), go_router and Google Fonts.

## Image rights and the watermark

All artworks and photographs belong to **Projeto Leonilson** and are shown
with its watermark. The watermark is **burned into the image files** by
[`tools/marca_dagua.py`](tools/marca_dagua.py), not just painted on screen:
on the web every asset can be downloaded by URL, so an on-screen overlay alone
would leave the clean files exposed.

- the Projeto Leonilson logo in the bottom-right corner, plus
  "© Projeto Leonilson" tiled diagonally across the whole image, so the mark
  survives any crop the layout applies;
- images converted from CMYK to RGB and reduced to at most 2000 px.

`python3 tools/marca_dagua.py --conferir` checks every published photo against
its original and fails if any file is identical to the original, has less than
3 % of its pixels changed by the mark, lacks the corner seal, or is missing.
The unwatermarked originals are kept locally in `originais/` and are excluded
from git.

## Run

```bash
python3 tools/marca_dagua.py            # regenerate watermarked assets from originais/
python3 tools/marca_dagua.py --conferir # verify all 48 photos
flutter test
flutter build web --base-href /museu-leonilson/
```

© Projeto Leonilson — all rights reserved for the artworks and photographs.
The code is the author's.
