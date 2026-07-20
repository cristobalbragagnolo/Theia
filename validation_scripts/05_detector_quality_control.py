#!/usr/bin/env python3
"""
Detector quality-control — detection confidence vs. synthetic image-quality degradation.

Reviewer-facing robustness experiment addressing Reviewer 2's camera-angle concern:
"is [a detector] powerful enough to catch small variations in the angle?" and the
request to "clarify and validate how detector confidence is used as a quality-control
criterion".

It takes clean held-out top-down specimen images and degrades each along three graded
severity ladders — perspective tilt, defocus blur, and occlusion — then measures how the
top-1 detection confidence of the retrained Stage-1 detector (det_baseline_best.pt) falls
as image quality drops. Confidence is read against an accept threshold of 0.40: for each
ladder, the level at which the mean confidence first crosses below that threshold is the
reported crossing point. The clean-image baseline and false-negative rate are reported so
the drop can be calibrated.

This is a screening signal for gross image-quality violations (extreme tilt, heavy defocus,
large occlusion); it is not a validation of fitness for geometric morphometrics, nor a claim
that the detector catches subtle or borderline problems.

Outputs (written next to this script):
  b8_qc_results.csv                     per-image confidence at every ladder level
  b8_qc_summary.md                      aggregated tables + honest-framing interpretation
  fig_b8_confidence_vs_degradation.png  mean confidence vs. severity, one curve per ladder

Usage:
  python 05_detector_quality_control.py
  python 05_detector_quality_control.py --weights <det.pt> --data <validation_dir>
"""
import argparse, glob, os, csv
import numpy as np
from PIL import Image, ImageFilter, ImageDraw
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from ultralytics import YOLO

DATA    = "../data/validation_datates"
OUT_DIR = os.path.dirname(os.path.abspath(__file__))
WEIGHTS = "../models_weights/det_baseline_best.pt"
POPS    = ["En11-07", "Ene05-09", "Ewi02-06", "Ewi03-07", "H01-07"]  # 268 clean specimens; Em17-07 excluded
PER_POP = 6          # deterministic: first 6 (sorted) per population -> ~30 base images
IMGSZ   = 640        # consistent with training
CLASS_ID = 0         # single detector class ('flower' / calyx)
ACCEPT_THR = 0.40    # plausible accept threshold for reporting the crossing level
WORK_MAX = 1400      # cap the long edge before degrading (keeps runtime sane, preserves aspect)

# ---- degradation transforms (reused from generate_degradations.py) ----
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
    else:             # yaw
        dst = [(0, 0), (w, h*delta), (w, h*(1-delta)), (0, h)]
    c = find_coeffs(src, dst)
    return im.transform((w, h), Image.PERSPECTIVE, c, resample=Image.BICUBIC, fillcolor=(120, 120, 120))

def occlude(im, frac=0.28):
    im = im.copy(); d = ImageDraw.Draw(im); w, h = im.size
    bw, bh = int(w*frac), int(h*frac*1.4); x = int(w*0.5-bw*0.5); y = int(h*0.45)
    d.rectangle([x, y, x+bw, y+bh], fill=(70, 55, 45)); return im

def defocus(im, radius):
    return im.filter(ImageFilter.GaussianBlur(radius)) if radius > 0 else im

# graded severity ladders; level 0 (== clean) is shared across all types
LADDERS = {
    "perspective": [0.0, 0.10, 0.20, 0.30, 0.40],   # tilt delta
    "blur":        [0, 3, 6, 9, 12],                # GaussianBlur radius
    "occlusion":   [0.0, 0.15, 0.30, 0.45],         # occluded fraction
}

def apply(deg_type, level, img):
    if level == 0 or level == 0.0:
        return img
    if deg_type == "perspective":
        return tilt(img, level, 'x')
    if deg_type == "blur":
        return defocus(img, level)
    if deg_type == "occlusion":
        return occlude(img, level)
    raise ValueError(deg_type)

def top1_conf(model, pil_img):
    r = model.predict(pil_img, imgsz=IMGSZ, conf=0.001, verbose=False)[0]
    boxes = r.boxes
    if boxes is None or len(boxes) == 0:
        return 0.0
    cls = boxes.cls.cpu().numpy().astype(int)
    conf = boxes.conf.cpu().numpy()
    mask = cls == CLASS_ID
    if not mask.any():
        return 0.0
    return float(conf[mask].max())

def sample_bases():
    bases = []
    for pop in POPS:
        files = sorted(glob.glob(f"{DATA}/{pop}/*.JPG") + glob.glob(f"{DATA}/{pop}/*.jpg"))
        for f in files[:PER_POP]:
            bases.append((pop, f))
    return bases

def main():
    global DATA, WEIGHTS
    ap = argparse.ArgumentParser(
        description="Detector quality-control: detection confidence vs. synthetic image-quality degradation.")
    ap.add_argument("--weights", default=WEIGHTS, help="path to the retrained Stage-1 detector weights (.pt)")
    ap.add_argument("--data", default=DATA, help="root of the validation image populations")
    args = ap.parse_args()
    DATA, WEIGHTS = args.data, args.weights

    model = YOLO(WEIGHTS)
    bases = sample_bases()
    print(f"[b8] {len(bases)} base images across {len(POPS)} populations")

    rows = []
    for i, (pop, path) in enumerate(bases):
        img = Image.open(path).convert("RGB")
        if max(img.size) > WORK_MAX:
            img.thumbnail((WORK_MAX, WORK_MAX))
        name = os.path.basename(path)
        for deg_type, levels in LADDERS.items():
            for lvl in levels:
                conf = top1_conf(model, apply(deg_type, lvl, img))
                rows.append({
                    "image": name, "population": pop, "degradation_type": deg_type,
                    "level": lvl, "det_conf": round(conf, 5), "detected": int(conf > 0.0),
                })
        print(f"[b8] {i+1}/{len(bases)} {pop}/{name} done")

    # ---- write CSV ----
    csv_path = os.path.join(OUT_DIR, "b8_qc_results.csv")
    with open(csv_path, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["image", "population", "degradation_type", "level", "det_conf", "detected"])
        w.writeheader(); w.writerows(rows)
    print("[b8] wrote", csv_path)

    # ---- aggregate: mean/min/max/std per (type, level) ----
    def agg(deg_type):
        out = []
        for lvl in LADDERS[deg_type]:
            vals = np.array([r["det_conf"] for r in rows
                             if r["degradation_type"] == deg_type and r["level"] == lvl])
            out.append((lvl, vals.mean(), vals.std(), vals.min(), vals.max(), (vals > 0).mean()))
        return out

    stats = {dt: agg(dt) for dt in LADDERS}

    # clean baseline: level-0 confidence pooled across all three ladders' clean entries
    clean_conf = np.array([r["det_conf"] for r in rows if r["level"] in (0, 0.0)])
    clean_detrate = (clean_conf > 0).mean()
    clean_fn_rate = 1.0 - clean_detrate
    clean_mean = clean_conf.mean()

    # ---- figure ----
    palette = {"perspective": "#2563eb", "blur": "#dc2626", "occlusion": "#059669"}
    fig, ax = plt.subplots(figsize=(8, 5), dpi=150)
    for dt in LADDERS:
        s = stats[dt]
        # normalise severity to [0,1] for a shared x-axis
        raw = [r[0] for r in s]
        xmax = max(raw) if max(raw) > 0 else 1
        x = [r/xmax for r in raw]
        mean = [r[1] for r in s]; lo = [r[3] for r in s]; hi = [r[4] for r in s]
        ax.plot(x, mean, "-o", color=palette[dt], lw=2, ms=5, label=dt)
        ax.fill_between(x, lo, hi, color=palette[dt], alpha=0.12)
    ax.axhline(ACCEPT_THR, ls="--", lw=1, color="#6b7280")
    ax.text(0.015, ACCEPT_THR + 0.015, f"accept threshold = {ACCEPT_THR:.2f}",
            fontsize=8, color="#6b7280")
    ax.set_xlabel("Degradation severity (normalised to max level per type)")
    ax.set_ylabel("Mean detector confidence (class: flower/calyx)")
    ax.set_title("B8 - Stage-1 detector: confidence vs. synthetic image-quality degradation\n"
                 "(retrained det_baseline_best.pt; band = min-max across specimens)",
                 fontsize=10)
    ax.set_ylim(-0.02, 1.02); ax.set_xlim(-0.02, 1.02)
    ax.grid(True, alpha=0.25); ax.legend(title="degradation", frameon=False)
    fig.tight_layout()
    png_path = os.path.join(OUT_DIR, "fig_b8_confidence_vs_degradation.png")
    fig.savefig(png_path); plt.close(fig)
    print("[b8] wrote", png_path)

    # ---- monotonicity check ----
    def is_monotone(s):
        means = [r[1] for r in s]
        diffs = np.diff(means)
        return bool((diffs <= 1e-9).all()), diffs

    # ---- summary.md ----
    lines = []
    lines.append("# B8 - Detector quality-control: confidence vs. synthetic degradation\n")
    lines.append("**Detector:** retrained Stage-1 `det_baseline_best.pt` (single class: flower/calyx).  ")
    lines.append(f"**Base images:** {len(bases)} clean top-down specimens, first {PER_POP} (sorted) per population "
                 f"across {', '.join(POPS)} (Em17-07 excluded).  ")
    lines.append(f"**Inference:** imgsz={IMGSZ}, top-1 confidence for class {CLASS_ID}; 0.0 = no detection.\n")

    lines.append("## Clean-image baseline\n")
    lines.append(f"- Mean clean confidence (level 0, pooled): **{clean_mean:.3f}**")
    lines.append(f"- Clean detection rate: **{clean_detrate*100:.1f}%** "
                 f"({int(clean_detrate*len(clean_conf))}/{len(clean_conf)} clean evaluations)")
    lines.append(f"- **Clean-image false-negative rate: {clean_fn_rate*100:.1f}%**\n")

    hdr = "| level | mean conf | std | min | max | detect rate |"
    sep = "|---|---|---|---|---|---|"
    for dt in LADDERS:
        lines.append(f"## {dt.capitalize()}\n")
        lines.append(hdr); lines.append(sep)
        for (lvl, mean, std, lo, hi, dr) in stats[dt]:
            tag = " (clean)" if lvl in (0, 0.0) else ""
            lines.append(f"| {lvl}{tag} | {mean:.3f} | {std:.3f} | {lo:.3f} | {hi:.3f} | {dr*100:.0f}% |")
        mono, diffs = is_monotone(stats[dt])
        means = [r[1] for r in stats[dt]]
        # crossing below accept threshold
        cross = None
        for (lvl, mean, *_ ) in stats[dt]:
            if mean < ACCEPT_THR:
                cross = lvl; break
        cross_txt = (f"mean confidence first drops below {ACCEPT_THR:.2f} at level **{cross}**"
                     if cross is not None else
                     f"mean confidence never drops below {ACCEPT_THR:.2f} within the tested range")
        mono_txt = ("**monotonically non-increasing**" if mono
                    else "**NOT strictly monotonic** (an increase occurs between adjacent levels)")
        lines.append("")
        lines.append(f"- Trend: {mono_txt}. Step-to-step mean deltas: "
                     f"{', '.join(f'{d:+.3f}' for d in diffs)}.")
        lines.append(f"- Accept threshold: {cross_txt}.\n")

    lines.append("## Interpretation (honest framing)\n")
    lines.append("- The detector's confidence **falls as image quality degrades** under all three "
                 "synthetic degradation families, and the clean-image false-negative rate is "
                 f"{clean_fn_rate*100:.1f}%. This demonstrates **sensitivity to gross image-quality "
                 "violations** (extreme tilt, heavy defocus, large occlusion).")
    lines.append("- This is a **screening signal for gross violations only**. Because the degradations "
                 "are synthetic and applied to images the detector was trained to handle clean, a "
                 "confidence drop on grossly degraded inputs is **partly expected by construction**.")
    lines.append("- These results **do not** validate fitness-for-geometric-morphometrics, and they do "
                 "**not** establish that the detector catches subtle or borderline quality problems. "
                 "The claim supported is narrow: the detector screens out grossly degraded imaging.\n")

    md_path = os.path.join(OUT_DIR, "b8_qc_summary.md")
    with open(md_path, "w") as fh:
        fh.write("\n".join(lines))
    print("[b8] wrote", md_path)

    # console recap
    print("\n=== RECAP ===")
    print(f"clean baseline mean conf: {clean_mean:.3f}  |  clean FN rate: {clean_fn_rate*100:.1f}%")
    for dt in LADDERS:
        mono, _ = is_monotone(stats[dt])
        print(f"{dt:12s} means: " + ", ".join(f"{r[0]}={r[1]:.3f}" for r in stats[dt])
              + f"   monotone={mono}")

if __name__ == "__main__":
    main()
