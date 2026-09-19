#!/usr/bin/env python3
"""Create a gray placeholder PNG for every image referenced in the markdown that doesn't exist yet.
Replace them with your real screenshots (same file name) as you finish each step.
Usage: python3 scripts/make_placeholders.py   (needs: pip install pillow)
"""
import re, pathlib
from PIL import Image, ImageDraw

root = pathlib.Path(__file__).resolve().parent.parent
pat = re.compile(r'!\[[^\]]*\]\((\.\./images/[^)]+)\)')
made = 0
for md in list(root.glob('labs/*.md')) + list(root.glob('concepts/*.md')):
    for rel in pat.findall(md.read_text(encoding='utf-8')):
        target = (md.parent / rel).resolve()
        if target.exists():
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        img = Image.new('RGB', (1000, 320), (235, 238, 242))
        d = ImageDraw.Draw(img)
        d.rectangle([4, 4, 995, 315], outline=(150, 160, 175), width=3)
        d.text((30, 120), 'TODO: replace with your screenshot', fill=(60, 70, 85))
        d.text((30, 160), target.name, fill=(90, 100, 115))
        img.save(target)
        made += 1
print(f'Created {made} placeholder images')
