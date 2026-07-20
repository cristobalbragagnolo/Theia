#!/usr/bin/env python3
"""
Companion helper for 05_detector_quality_control.py — visual contact sheet of the
synthetic image-quality degradations.

Takes one clean top-down flower image (first sorted image of population H01-07) and
renders controlled "bad" versions (perspective tilt, yaw, occlusion, defocus blur) into
a single labelled contact sheet, so a reviewer can see the degradation families that the
quality-control experiment feeds to the Stage-1 detector.

This script only GENERATES the illustrative sheet; measuring detector confidence vs.
degradation is done by 05_detector_quality_control.py.

Output (written next to this script):
  degradation_demo.png

Usage:
  python generate_degradations.py
"""
import glob, os, numpy as np
from PIL import Image, ImageFilter, ImageDraw, ImageFont

DATA = "../data/validation_datates"
OUT_DIR = os.path.dirname(os.path.abspath(__file__))

def find_coeffs(src, dst):
    m = []
    for (sx, sy), (dx, dy) in zip(src, dst):
        m.append([dx, dy, 1, 0, 0, 0, -sx*dx, -sx*dy])
        m.append([0, 0, 0, dx, dy, 1, -sy*dx, -sy*dy])
    A = np.array(m, dtype=float); B = np.array(src, dtype=float).reshape(8)
    return np.linalg.solve(A, B)

def tilt(im, delta, axis='x'):
    w, h = im.size
    src = [(0, 0), (w, 0), (w, h), (0, h)]
    if axis == 'x':   # pitch: top edge recedes
        dst = [(w*delta, 0), (w*(1-delta), 0), (w, h), (0, h)]
    else:             # yaw: left edge recedes
        dst = [(0, 0), (w, h*delta), (w, h*(1-delta)), (0, h)]
    c = find_coeffs(src, dst)
    return im.transform((w, h), Image.PERSPECTIVE, c, resample=Image.BICUBIC, fillcolor=(120, 120, 120))

def occlude(im, frac=0.28):
    im = im.copy(); d = ImageDraw.Draw(im); w, h = im.size
    bw, bh = int(w*frac), int(h*frac*1.4); x = int(w*0.5-bw*0.5); y = int(h*0.45)
    d.rectangle([x, y, x+bw, y+bh], fill=(70, 55, 45)); return im

def _font(s, b=False):
    for p in (["/System/Library/Fonts/Supplemental/Arial Bold.ttf"] if b else ["/System/Library/Fonts/Supplemental/Arial.ttf"]):
        if os.path.exists(p):
            try: return ImageFont.truetype(p, s)
            except: pass
    return ImageFont.load_default()

def main():
    base_path = sorted(glob.glob(f"{DATA}/H01-07/*.jpg") + glob.glob(f"{DATA}/H01-07/*.JPG"))[0]
    img = Image.open(base_path).convert("RGB"); img.thumbnail((900, 900))
    W, H = img.size
    variants = [
        ("original (top-down)", img),
        ("perspective ~15deg",  tilt(img, 0.12, 'x')),
        ("perspective ~30deg",  tilt(img, 0.25, 'x')),
        ("perspective ~45deg",  tilt(img, 0.38, 'x')),
        ("yaw ~30deg",          tilt(img, 0.25, 'y')),
        ("occlusion 28%",       occlude(img)),
        ("blur (defocus)",      img.filter(ImageFilter.GaussianBlur(6))),
    ]
    ft, fttl = _font(20, True), _font(26, True)
    cols, rows, pad, lab = 4, 2, 16, 30
    cw, ch = int(W*0.5), int(H*0.5)
    sheetW = cols*cw + (cols+1)*pad; sheetH = 60 + rows*(ch+lab+pad) + pad
    sheet = Image.new("RGB", (sheetW, sheetH), (245, 246, 248)); dd = ImageDraw.Draw(sheet)
    dd.text((pad, 16), "B8 - synthetic image-quality degradations (detector-QC test)", font=fttl, fill=(20, 22, 28))
    for i, (name, v) in enumerate(variants):
        r, c = divmod(i, cols); x = pad + c*(cw+pad); y = 60 + r*(ch+lab+pad)
        dd.text((x+2, y), name, font=ft, fill=(30, 30, 30))
        sheet.paste(v.resize((cw, ch)), (x, y+lab))
        col = (5, 150, 105) if i == 0 else (200, 60, 60)
        dd.rectangle([x, y+lab, x+cw, y+lab+ch], outline=col, width=3)
    out = os.path.join(OUT_DIR, "degradation_demo.png")
    sheet.save(out, quality=92)
    print("base image:", os.path.basename(base_path))
    print("saved:", out, sheet.size)

if __name__ == "__main__":
    main()
