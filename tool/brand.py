"""Renders the brand directions: a 1024 icon master per direction, and a
preview sheet with the icon at home-screen sizes plus the launch screen.

    python brand.py <repo> <outdir>
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageChops

REPO = Path(sys.argv[1])
OUT = Path(sys.argv[2])
OUT.mkdir(parents=True, exist_ok=True)
FONTS = REPO / 'assets' / 'fonts'

BG = (11, 12, 14)
RAISED = (22, 23, 25)
LINE = (29, 31, 34)
LINE_STRONG = (42, 45, 48)
INK = (242, 243, 245)
INK2 = (180, 184, 188)
INK3 = (136, 141, 146)
INK_FAINT = (82, 86, 91)
UP = (88, 206, 150)


def font(name, size, **axes):
    f = ImageFont.truetype(str(FONTS / f'{name}.ttf'), size)
    order = {
        'Inter-Variable': ['opsz', 'wght'],
        'JetBrainsMono-Variable': ['wght'],
        'Newsreader-Variable': ['wght', 'opsz'],
    }[name]
    defaults = {'opsz': 14 if name.startswith('Inter') else 72, 'wght': 400}
    f.set_variation_by_axes([axes.get(a, defaults[a]) for a in order])
    return f


def text_center(d, cx, cy, s, f, fill, tracking=0):
    """Draws s centred on its ink box, with tracking in px between letters."""
    if tracking == 0:
        l, t, r, b = d.textbbox((0, 0), s, font=f)
        d.text((cx - (l + r) / 2, cy - (t + b) / 2), s, font=f, fill=fill)
        return
    widths = [d.textlength(c, font=f) for c in s]
    total = sum(widths) + tracking * (len(s) - 1)
    _, t, _, b = d.textbbox((0, 0), s, font=f)
    x = cx - total / 2
    for c, w in zip(s, widths):
        d.text((x, cy - (t + b) / 2), c, font=f, fill=fill)
        x += w + tracking


# ---------------------------------------------------------------- icons (1024)

def icon_masthead():
    """A: one serif capital, the way a broadsheet or an old bank signs."""
    im = Image.new('RGB', (1024, 1024), BG)
    d = ImageDraw.Draw(im)
    text_center(d, 512, 492, 'A', font('Newsreader-Variable', 700, wght=400, opsz=72), INK)
    d.rectangle((512 - 150, 790, 512 + 150, 790 + 10), fill=INK3)
    return im


def icon_ticker():
    """B: the ticker. The tape is the brand's signature, so the icon is a
    quote on it: the symbol, and which way it went."""
    im = Image.new('RGB', (1024, 1024), BG)
    d = ImageDraw.Draw(im)
    mono = font('JetBrainsMono-Variable', 330, wght=500)
    text_center(d, 512, 470, 'AUR', mono, INK)
    small = font('JetBrainsMono-Variable', 112, wght=500)
    # The tape line under it: an up arrow and a change, in up.
    text_center(d, 512, 720, '↑ +7.79%', small, UP)
    return im


def chart_points(x0, y0, w, h):
    # A session's line: a dip, a run, a pause, a finish near the high.
    ys = [0.62, 0.70, 0.58, 0.66, 0.48, 0.52, 0.34, 0.40, 0.22, 0.18]
    return [(x0 + w * i / (len(ys) - 1), y0 + h * y) for i, y in enumerate(ys)]


def draw_line(d, pts, width, dot, baseline_y=None, x0=None, x1=None, dash=None):
    if baseline_y is not None:
        step, gap = dash
        x = x0
        while x < x1:
            d.line((x, baseline_y, min(x + step, x1), baseline_y), fill=INK_FAINT, width=max(2, width // 5))
            x += step + gap
    d.line(pts, fill=INK, width=width, joint='curve')
    for p in pts[1:-1]:
        r = width / 2
        d.ellipse((p[0] - r, p[1] - r, p[0] + r, p[1] + r), fill=INK)
    x, y = pts[-1]
    d.ellipse((x - dot, y - dot, x + dot, y + dot), fill=UP)


def icon_line():
    """C: the chart line. No letters: a session's price, finishing up."""
    s = 4  # supersample
    im = Image.new('RGB', (1024 * s, 1024 * s), BG)
    d = ImageDraw.Draw(im)
    pts = chart_points(200 * s, 250 * s, 600 * s, 600 * s)
    draw_line(d, pts, 40 * s, 46 * s, baseline_y=640 * s, x0=180 * s, x1=844 * s, dash=(26 * s, 22 * s))
    return im.resize((1024, 1024), Image.LANCZOS)


# ------------------------------------------------------------- launch (390×844)

def launch(kind, scale=2):
    W, H = 390 * scale, 844 * scale
    im = Image.new('RGB', (W, H), BG)
    d = ImageDraw.Draw(im)
    cx, cy = W / 2, H / 2
    k = scale
    word = font('Inter-Variable', 17 * k, wght=600, opsz=17)
    if kind == 'masthead':
        text_center(d, cx, cy - 22 * k, 'A', font('Newsreader-Variable', 72 * k, opsz=72), INK)
        d.rectangle((cx - 15 * k, cy + 12 * k, cx + 15 * k, cy + 13 * k), fill=INK3)
        text_center(d, cx, cy + 40 * k, 'AURA EXCHANGE', font('Inter-Variable', 12 * k, wght=600), INK2, tracking=3.2 * k)
    elif kind == 'ticker':
        text_center(d, cx, cy - 8 * k, 'Aura Exchange', word, INK)
        mono = font('JetBrainsMono-Variable', 12 * k, wght=500)
        text_center(d, cx, cy + 18 * k, '$AURA  1,000.00  ↑ +7.79%', mono, INK3)
    else:
        ss = 4
        big = Image.new('RGB', (W * ss, H * ss), BG)
        bd = ImageDraw.Draw(big)
        pts = chart_points((cx - 24 * k) * ss, (cy - 64 * k) * ss, 48 * k * ss, 48 * k * ss)
        draw_line(bd, pts, int(3.4 * k * ss), int(4 * k * ss))
        im = big.resize((W, H), Image.LANCZOS)
        d = ImageDraw.Draw(im)
        text_center(d, cx, cy + 4 * k, 'Aura Exchange', word, INK)
    return im


# ------------------------------------------------------------------ the sheets

def squircle(size):
    """iOS's icon mask, close enough for a preview: a superellipse."""
    ss = 4
    n = 5.0
    big = Image.new('L', (size * ss, size * ss), 0)
    px = big.load()
    R = size * ss / 2
    for y in range(size * ss):
        dy = abs((y + 0.5 - R) / R) ** n
        if dy > 1:
            continue
        dx = (1 - dy) ** (1 / n) * R
        for x in range(int(R - dx), int(R + dx)):
            px[x, y] = 255
    return big.resize((size, size), Image.LANCZOS)


def masked(icon, size):
    i = icon.resize((size, size), Image.LANCZOS).convert('RGBA')
    i.putalpha(squircle(size))
    return i


def sheet(name, title, icon, launch_im, label):
    W, H = 1500, 1000
    im = Image.new('RGB', (W, H), (28, 29, 32))
    d = ImageDraw.Draw(im)
    hf = font('Inter-Variable', 30, wght=600)
    sf = font('Inter-Variable', 20, wght=400)
    d.text((48, 40), title, font=hf, fill=INK)
    # A home screen strip: wallpaper-ish grey so a dark icon's edge shows.
    strip = Image.new('RGB', (760, 300), (54, 58, 66))
    sd = ImageDraw.Draw(strip)
    lf = font('Inter-Variable', 24, wght=500)
    x = 40
    for other in ['Wallet', 'Stocks']:
        g = (90, 96, 106)
        oi = Image.new('RGBA', (120, 120), g + (255,))
        oi.putalpha(squircle(120))
        strip.paste(oi, (x, 50), oi)
        text_center(sd, x + 60, 205, other, lf, (235, 235, 240))
        x += 180
    ic = masked(icon, 120)
    strip.paste(ic, (x, 50), ic)
    text_center(sd, x + 60, 205, label, lf, (235, 235, 240))
    im.paste(strip, (48, 110))
    d.text((48, 420), 'Home screen (60 pt @2x)', font=sf, fill=INK3)
    # Sizes: the 1024 master, Settings and Spotlight.
    big = masked(icon, 320)
    im.paste(big, (48, 470), big)
    x = 400
    for s, cap in [(180, '60 pt @3x'), (120, '40 pt @3x'), (58, '29 pt @2x'), (40, '20 pt @2x')]:
        i = masked(icon, s)
        im.paste(i, (x, 790 - s), i)
        d.text((x, 805), cap, font=font('Inter-Variable', 16), fill=INK3)
        x += s + 40
    d.text((48, 805), '1024 master', font=font('Inter-Variable', 16), fill=INK3)
    # Launch screen at 390×844, shown at half size.
    lw, lh = 390, 844
    lim = launch_im.resize((lw, lh), Image.LANCZOS)
    lx, ly = W - lw - 60, 110
    im.paste(lim, (lx, ly))
    d.rectangle((lx - 1, ly - 1, lx + lw, ly + lh), outline=LINE_STRONG)
    d.text((lx, ly - 34), 'Launch screen', font=sf, fill=INK3)
    im.save(OUT / f'{name}.png')


directions = [
    ('A-masthead', 'A · Masthead: one serif capital, like an old bank', icon_masthead(), launch('masthead'), 'Aura'),
    ('B-ticker', 'B · Ticker: the symbol and its move, off the tape', icon_ticker(), launch('ticker'), 'Aura'),
    ('C-line', 'C · Session line: a day’s price, closing up', icon_line(), launch('line'), 'Aura'),
]
for name, title, icon, li, label in directions:
    icon.save(OUT / f'{name}-icon-1024.png')
    li.save(OUT / f'{name}-launch.png')
    sheet(name, title, icon, li, label)
print('ok')
