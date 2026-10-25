"""Compare a golden with its reference, and measure a reference.

Development only (Python 3 with Pillow and numpy); the app never runs it.

    python tool/golden_diff.py diff GOLDEN.png REFERENCE.png [OUT.png]
        Share of pixels that differ by more than 24 levels in any channel,
        and an image with the golden, the reference and the differences side
        by side (written next to the golden unless OUT is given).

    python tool/golden_diff.py bands REFERENCE.png [--x0 PT --x1 PT]
        The horizontal bands that hold content (anything that isn't the
        background colour of the top-left pixel), in points (pixels / 2),
        with each band's left and right edge. For measuring the drawn
        screens, which have no HTML source.
"""
import sys

import numpy as np
from PIL import Image

THRESHOLD = 24


def load(path):
    return np.asarray(Image.open(path).convert("RGB")).astype(np.int16)


def diff(golden_path, reference_path, out_path=None):
    golden = load(golden_path)
    reference = load(reference_path)
    if golden.shape != reference.shape:
        print(f"size differs: golden {golden.shape[1]}x{golden.shape[0]}, "
              f"reference {reference.shape[1]}x{reference.shape[0]}")
        h = min(golden.shape[0], reference.shape[0])
        w = min(golden.shape[1], reference.shape[1])
        golden, reference = golden[:h, :w], reference[:h, :w]
    delta = np.abs(golden - reference).max(axis=2)
    mask = delta > THRESHOLD
    print(f"{mask.mean() * 100:.2f}% of pixels differ by more than {THRESHOLD}")
    rows = np.where(mask.any(axis=1))[0]
    if rows.size:
        # Group differing rows into bands so it's clear where to look.
        bands, start, prev = [], rows[0], rows[0]
        for r in rows[1:]:
            if r > prev + 4:
                bands.append((start, prev))
                start = r
            prev = r
        bands.append((start, prev))
        for a, b in bands[:40]:
            share = mask[a:b + 1].mean() * 100
            print(f"  y {a / 2:6.1f}-{b / 2:6.1f} pt: {share:5.2f}% of that band")
    red = np.zeros_like(golden)
    red[..., 0] = np.where(mask, 255, golden.mean(axis=2) // 3)
    red[..., 1] = np.where(mask, 40, golden.mean(axis=2) // 3)
    red[..., 2] = np.where(mask, 40, golden.mean(axis=2) // 3)
    side = np.concatenate([golden, reference, red], axis=1).clip(0, 255)
    out = out_path or golden_path.replace(".png", ".diff.png")
    Image.fromarray(side.astype(np.uint8)).save(out)
    print(f"side by side: {out}")


def bands(path, x0=None, x1=None):
    image = load(path)
    if x0 is not None:
        image = image[:, int(x0 * 2):int(x1 * 2)]
    bg = image[0, 0]
    content = (np.abs(image - bg).max(axis=2) > 10)
    rows = content.any(axis=1)
    y = 0
    h = len(rows)
    offset = int(x0 * 2) if x0 is not None else 0
    while y < h:
        if not rows[y]:
            y += 1
            continue
        start = y
        while y < h and rows[y]:
            y += 1
        cols = np.where(content[start:y].any(axis=0))[0]
        print(f"y {start / 2:6.1f}-{y / 2:6.1f} pt (h {(y - start) / 2:5.1f})"
              f"  x {(cols[0] + offset) / 2:6.1f}-{(cols[-1] + 1 + offset) / 2:6.1f}")


if __name__ == "__main__":
    command, *args = sys.argv[1:]
    if command == "diff":
        diff(*args)
    elif command == "bands":
        x0 = x1 = None
        if "--x0" in args:
            x0 = float(args[args.index("--x0") + 1])
            x1 = float(args[args.index("--x1") + 1])
        bands(args[0], x0, x1)
