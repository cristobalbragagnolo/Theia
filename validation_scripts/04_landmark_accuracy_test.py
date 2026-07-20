#!/usr/bin/env python3
"""
Per-landmark pixel RMSE accuracy test on the 179 image-registered held-out crops.

This is the landmark-by-landmark accuracy test on the 179 image-registered
held-out test specimens (the held-out test slice of the 1,190-image training
pool). It directly answers Reviewer 2's suggestion that "a per-landmark RMSE in
pixel distances would be a better metric" than the aggregate correlation
("Global R"): for each landmark it reports the root-mean-square error between the
predicted and ground-truth keypoints, in both normalized crop units and crop
pixels.

The N here (179) is image-registered: the ground truth is a YOLO-pose keypoint
label tied to the pixels of each crop, so a point-by-point, pixel-level
comparison is valid. This is distinct from the shape-only N=268 biological
validation, where only landmark configurations (not pixel positions) are
comparable and analysis is Procrustes/GM-based. Detector localization is
evaluated separately (detector test mAP50-95(B)=0.964); this script isolates the
pose stage by running it on the ground-truth-box crops.

The evaluation uses the retrained pose_lowaug weights and the published dataset's
held-out test split.

Outputs (under --out):
  lm179_per_landmark.csv   RMSE per landmark (normalized + crop px)
  lm179_per_specimen.csv   per-crop mean error, crop dims, detection confidence
  lm179_results.md         Markdown summary
  fig_lm179_per_landmark_rmse.png   per-landmark RMSE bar chart

Usage:
  python 04_landmark_accuracy_test.py \
      --weights ../models_weights/pose_lowaug_best.pt \
      --crops ../data/pose/images/test \
      --labels ../data/pose/labels/test \
      --out .
"""
import argparse
import csv
import glob
import math
import os
from pathlib import Path

import numpy as np
from PIL import Image
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from ultralytics import YOLO

K = 32  # landmarks
# Worst-5 landmarks (1-indexed) from the 268 GM Procrustes analysis, for cross-check.
GM_WORST5 = [32, 16, 26, 31, 10]


def parse_gt(label_path):
    """Return GT keypoints as (K,2) normalized-to-crop [0,1]."""
    vals = [float(x) for x in open(label_path).read().split()]
    # layout: class, cx, cy, w, h, then K*(x,y,vis)
    kpts = vals[5:]
    assert len(kpts) == K * 3, f"{label_path}: expected {K * 3} kpt values, got {len(kpts)}"
    arr = np.array(kpts, dtype=np.float64).reshape(K, 3)
    return arr[:, :2]  # x,y normalized


def main():
    ap = argparse.ArgumentParser(
        description="Per-landmark pixel RMSE on the 179 image-registered held-out test crops.")
    ap.add_argument("--weights", default="../models_weights/pose_lowaug_best.pt",
                    help="pose model weights (.pt)")
    ap.add_argument("--crops", default="../data/pose/images/test",
                    help="directory of held-out test crops (*.jpg)")
    ap.add_argument("--labels", default="../data/pose/labels/test",
                    help="directory of YOLO-pose ground-truth labels (*.txt)")
    ap.add_argument("--out", default=".", help="output directory for the result artifacts")
    args = ap.parse_args()

    OUT = Path(args.out)
    OUT.mkdir(parents=True, exist_ok=True)

    model = YOLO(args.weights)
    crops = sorted(glob.glob(os.path.join(args.crops, "*.jpg")))
    assert crops, f"no crops in {args.crops}"

    # Per-landmark accumulators of squared error.
    sq_norm = [[] for _ in range(K)]   # normalized euclidean^2
    sq_px = [[] for _ in range(K)]     # crop-pixel euclidean^2
    per_spec = []
    n_fail = 0
    n_multi = 0

    for cp in crops:
        stem = os.path.splitext(os.path.basename(cp))[0]
        lp = os.path.join(args.labels, stem + ".txt")
        if not os.path.exists(lp):
            print(f"[warn] no label for {stem}"); continue
        gt = parse_gt(lp)  # (K,2) normalized
        W, H = Image.open(cp).size

        res = model.predict(cp, imgsz=640, conf=0.001, verbose=False, device="cpu")[0]
        if res.keypoints is None or res.boxes is None or len(res.boxes) == 0:
            n_fail += 1
            per_spec.append((stem, W, H, 0, 0.0, float("nan"), float("nan")))
            continue
        confs = res.boxes.conf.cpu().numpy()
        if len(confs) > 1:
            n_multi += 1
        bi = int(np.argmax(confs))                  # highest-confidence box
        pred = res.keypoints.xyn.cpu().numpy()[bi]  # (K,2) normalized

        dx = (pred[:, 0] - gt[:, 0])
        dy = (pred[:, 1] - gt[:, 1])
        d_norm = np.sqrt(dx * dx + dy * dy)                       # per-landmark, normalized
        d_px = np.sqrt((dx * W) ** 2 + (dy * H) ** 2)             # per-landmark, crop pixels
        for k in range(K):
            sq_norm[k].append(d_norm[k] ** 2)
            sq_px[k].append(d_px[k] ** 2)
        per_spec.append((stem, W, H, len(confs), float(confs[bi]),
                         float(d_norm.mean()), float(d_px.mean())))

    n_ok = sum(1 for s in per_spec if s[3] > 0)

    # Per-landmark RMSE.
    rmse_norm = np.array([math.sqrt(np.mean(sq_norm[k])) for k in range(K)])
    rmse_px = np.array([math.sqrt(np.mean(sq_px[k])) for k in range(K)])

    # Overall metrics.
    pooled_norm = math.sqrt(np.mean([v for k in range(K) for v in sq_norm[k]]))
    pooled_px = math.sqrt(np.mean([v for k in range(K) for v in sq_px[k]]))
    mean_lm_norm = float(rmse_norm.mean())
    mean_lm_px = float(rmse_px.mean())

    order = np.argsort(rmse_norm)[::-1]
    worst5 = [(int(i) + 1, round(float(rmse_norm[i]), 4), round(float(rmse_px[i]), 2)) for i in order[:5]]
    best5 = [(int(i) + 1, round(float(rmse_norm[i]), 4), round(float(rmse_px[i]), 2)) for i in order[::-1][:5]]

    # ---- per-landmark csv
    with open(OUT / "lm179_per_landmark.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["landmark_1idx", "rmse_norm", "rmse_crop_px", "n"])
        for k in range(K):
            w.writerow([k + 1, round(float(rmse_norm[k]), 6), round(float(rmse_px[k]), 4), len(sq_norm[k])])
    # ---- per-specimen csv
    with open(OUT / "lm179_per_specimen.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["stem", "crop_w", "crop_h", "n_det", "conf", "mean_err_norm", "mean_err_px"])
        for row in per_spec:
            w.writerow([row[0], row[1], row[2], row[3], round(row[4], 4),
                        ("" if math.isnan(row[5]) else round(row[5], 6)),
                        ("" if math.isnan(row[6]) else round(row[6], 4))])

    # ---- figure
    fig, ax = plt.subplots(figsize=(11, 4.2))
    colors = ["#c0392b" if (k + 1) in [wl[0] for wl in worst5] else "#2c7fb8" for k in range(K)]
    ax.bar(np.arange(1, K + 1), rmse_norm, color=colors)
    ax.axhline(mean_lm_norm, color="#555", ls="--", lw=1, label=f"mean = {mean_lm_norm:.4f}")
    ax.set_xlabel("Landmark"); ax.set_ylabel("Per-landmark RMSE (normalized crop units)")
    ax.set_title(f"Theia pose_lowaug vs GT — per-landmark RMSE on 179 held-out test crops (n_ok={n_ok})")
    ax.set_xticks(np.arange(1, K + 1)); ax.tick_params(axis="x", labelsize=7)
    ax.legend(); fig.tight_layout()
    fig.savefig(OUT / "fig_lm179_per_landmark_rmse.png", dpi=140)

    # Crop dimension summary.
    ws = [s[1] for s in per_spec]; hs = [s[2] for s in per_spec]

    # ---- markdown summary
    md = []
    md.append("# 179 held-out test — per-landmark pixel RMSE (Reviewer 2)\n")
    md.append(f"- **Model:** pose_lowaug (canonical) · **crops:** {len(crops)} · "
              f"**usable:** {n_ok} · **detection failures:** {n_fail} · **multi-detection crops:** {n_multi}\n")
    md.append(f"- **Crop size (px):** W {min(ws)}–{max(ws)} (med {int(np.median(ws))}), "
              f"H {min(hs)}–{max(hs)} (med {int(np.median(hs))}).\n")
    md.append("\n## Overall agreement (predicted vs image-registered GT)\n")
    md.append(f"- **Mean per-landmark RMSE:** {mean_lm_norm:.4f} normalized crop units "
              f"(≈ {mean_lm_px:.2f} crop px).\n")
    md.append(f"- **Pooled RMSE (all 32×{n_ok} landmark instances):** {pooled_norm:.4f} normalized "
              f"(≈ {pooled_px:.2f} crop px).\n")
    md.append("\n## Worst / best landmarks (by normalized RMSE)\n")
    md.append("| rank | worst landmark | RMSE_norm | RMSE_px |  | best landmark | RMSE_norm | RMSE_px |\n")
    md.append("|---|---|---|---|---|---|---|---|\n")
    for i in range(5):
        wl = worst5[i]; bl = best5[i]
        md.append(f"| {i+1} | {wl[0]} | {wl[1]} | {wl[2]} |  | {bl[0]} | {bl[1]} | {bl[2]} |\n")
    md.append(f"\n- **Worst-5 (179 lm×lm):** {[wl[0] for wl in worst5]}\n")
    md.append(f"- **Worst-5 (268 GM Procrustes, for cross-check):** {GM_WORST5}\n")
    overlap = sorted(set([wl[0] for wl in worst5]) & set(GM_WORST5))
    md.append(f"- **Overlap:** {overlap if overlap else 'none'}\n")
    md.append("\n## Files\n")
    md.append("- `lm179_per_landmark.csv` — RMSE per landmark (normalized + crop px)\n")
    md.append("- `lm179_per_specimen.csv` — per-crop mean error, crop dims, detection conf\n")
    md.append("- `fig_lm179_per_landmark_rmse.png` — per-landmark RMSE bar chart\n")
    md.append("\n_Note: this isolates the pose stage on GT-box crops; detector localization is "
              "reported separately (detector test mAP50-95(B)=0.964). The 179 GT is image-registered, "
              "so pixel/landmark comparison is valid here — unlike the shape-only 268 (GM/Procrustes only)._\n")
    (OUT / "lm179_results.md").write_text("".join(md))

    # Console summary.
    print(f"[done] crops={len(crops)} ok={n_ok} fail={n_fail} multi={n_multi}")
    print(f"  mean per-landmark RMSE: {mean_lm_norm:.4f} norm  ({mean_lm_px:.2f} crop px)")
    print(f"  pooled RMSE:            {pooled_norm:.4f} norm  ({pooled_px:.2f} crop px)")
    print(f"  worst-5 landmarks:      {[wl[0] for wl in worst5]}  (268 GM worst-5: {GM_WORST5})")


if __name__ == "__main__":
    main()
