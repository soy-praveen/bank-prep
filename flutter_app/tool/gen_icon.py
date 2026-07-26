#!/usr/bin/env python3
"""Generate BankPrep launcher icons: legacy full icon + adaptive foreground."""
from PIL import Image, ImageDraw
import os

SIZE = 1024
BG = (14, 19, 26, 255)        # 0E131A
BARS = [(20, 184, 166, 255),  # 14B8A6
        (45, 212, 191, 255),  # 2DD4BF
        (94, 234, 212, 255)]  # 5EEAD4

def draw_bars(d, cx, cy, scale=1.0):
    """Three ascending rounded bars centered at (cx, cy)."""
    bw = int(150 * scale)          # bar width
    gap = int(52 * scale)
    heights = [int(300 * scale), int(440 * scale), int(580 * scale)]
    radius = int(44 * scale)
    total_w = bw * 3 + gap * 2
    x0 = cx - total_w // 2
    baseline = cy + int(290 * scale)
    for i, h in enumerate(heights):
        x = x0 + i * (bw + gap)
        d.rounded_rectangle([x, baseline - h, x + bw, baseline],
                            radius=radius, fill=BARS[i])

os.makedirs('assets/icon', exist_ok=True)

# legacy / full icon: dark bg + bars
img = Image.new('RGBA', (SIZE, SIZE), BG)
d = ImageDraw.Draw(img)
draw_bars(d, SIZE // 2, SIZE // 2, scale=1.0)
img.save('assets/icon/icon.png')

# adaptive foreground: transparent, content inside the ~66% safe zone
fg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
d = ImageDraw.Draw(fg)
draw_bars(d, SIZE // 2, SIZE // 2, scale=0.62)
fg.save('assets/icon/icon_fg.png')

print('icons written:', os.listdir('assets/icon'))
