#!/usr/bin/env python3
"""
Stage 0 — Dataset split and preparation for the Theia dual-stage YOLO pipeline.

Builds the train/validation/test datasets used to train the detector (Stage 1)
and the pose/landmark model (Stage 2) from the annotated Erysimum image pool.

This script implements the split protocol described in the Methods:

  * One image per specimen (no specimen appears in more than one image), so an
    image-level split is a specimen-level split and carries no train/test leakage.
  * The full annotated pool is re-split 70 / 15 / 15 into train / val / test.
  * The split is deterministic: images are sorted before a seeded shuffle, so the
    same seed reproduces the same split on any machine. A manifest of the split
    (split_manifest.csv) is written for auditability.
  * The exact 179-image held-out test set behind the released weights and the
    reported test metrics is recorded in heldout_test_manifest.txt. (That run
    predates this deterministic ordering, so use the manifest to reproduce the
    published test evaluation; use this script's deterministic split to re-train
    from scratch.)

For Stage 2, each detection box is cropped with a fixed padding ratio (0.15) and
the 32 landmarks are re-expressed in crop-relative coordinates, matching the
on-device inference pipeline. A 50%-of-training ablation set is also prepared.

Output layout (under --out):
  work/det/{images,labels}/{train,val,test}     + data_det.yaml
  work/pose/{images,labels}/{train,val,test}    + data_pose.yaml
  work/pose/{images,labels}/train_half          + data_pose_half.yaml
  split_manifest.csv

Usage:
  python 00_data_split.py --zip ./yolo_dataset.zip --out ./theia_runs --seed 42

Next stage: 01_train.py (reads the YAML files produced here).
"""
import argparse
import csv
import glob
import os
import random
import shutil
import zipfile
from pathlib import Path

import numpy as np
from PIL import Image

IMG_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".JPG", ".JPEG", ".PNG"}
PADDING_RATIO = 0.15  # bounding-box padding for Stage-2 crops; matches on-device inference
N_KPTS = 32


def list_images(folder):
    """Return image paths in `folder`, sorted for deterministic ordering."""
    return sorted(
        p for p in glob.glob(os.path.join(folder, "*"))
        if os.path.splitext(p)[1] in IMG_EXTS
    )


def clamp01(v):
    return max(0.0, min(1.0, float(v)))


def parse_pose_label_line(line):
    """Parse one YOLO pose label line: class, box (cx,cy,w,h), then 32*(x,y) kpts."""
    vals = [float(x) for x in line.strip().split()]
    cls = int(vals[0])
    cx, cy, w, h = vals[1:5]
    kpts = vals[5:]
    if len(kpts) != 2 * N_KPTS:
        raise ValueError(f"Expected {2 * N_KPTS} keypoint values, got {len(kpts)}")
    return cls, cx, cy, w, h, kpts


def crop_and_relabel(img_path, label_path, out_img_dir, out_lbl_dir, pad=PADDING_RATIO):
    """Crop each detection box (with padding) and re-express landmarks in crop coordinates."""
    im = Image.open(img_path).convert("RGB")
    W, H = im.size
    lines = [ln.strip() for ln in open(label_path) if ln.strip()]
    kept = 0
    for idx, ln in enumerate(lines):
        _, cx, cy, w, h, kpts = parse_pose_label_line(ln)
        bw, bh = w * W, h * H
        bx, by = cx * W, cy * H
        x1 = max(0, int(bx - bw / 2 - bw * pad))
        y1 = max(0, int(by - bh / 2 - bh * pad))
        x2 = min(W, int(bx + bw / 2 + bw * pad))
        y2 = min(H, int(by + bh / 2 + bh * pad))
        cw = max(1, x2 - x1)
        ch = max(1, y2 - y1)
        name = f"{Path(img_path).stem}_obj{idx}.jpg"
        im.crop((x1, y1, x2, y2)).save(os.path.join(out_img_dir, name), quality=95)

        kxy = np.array(kpts, dtype=np.float32).reshape(-1, 2)
        kx = (kxy[:, 0] * W - x1) / cw
        ky = (kxy[:, 1] * H - y1) / ch
        out_k = []
        for x_, y_ in zip(kx, ky):
            out_k += [clamp01(x_), clamp01(y_), 2]  # visibility flag = 2 (visible)
        cxn, cyn = clamp01((bx - x1) / cw), clamp01((by - y1) / ch)
        wn, hn = clamp01(bw / cw), clamp01(bh / ch)
        with open(os.path.join(out_lbl_dir, f"{Path(name).stem}.txt"), "w") as f:
            f.write("0 " + " ".join(
                [f"{cxn:.6f}", f"{cyn:.6f}", f"{wn:.6f}", f"{hn:.6f}",
                 *[f"{v:.6f}" if isinstance(v, float) else str(v) for v in out_k]]
            ))
        kept += 1
    return kept


def main():
    ap = argparse.ArgumentParser(description="Split and prepare the Theia YOLO datasets (70/15/15).")
    ap.add_argument("--zip", required=True, help="path to yolo_dataset.zip (the annotated image pool)")
    ap.add_argument("--out", default="./theia_runs", help="output directory")
    ap.add_argument("--seed", type=int, default=42, help="split seed (reproducible)")
    ap.add_argument("--pad", type=float, default=PADDING_RATIO, help="crop padding ratio for Stage-2")
    args = ap.parse_args()

    random.seed(args.seed)
    np.random.seed(args.seed)
    OUT = Path(args.out).resolve()
    WORK = OUT / "work"
    WORK.mkdir(parents=True, exist_ok=True)

    # 1) Extract the dataset zip.
    RAW = WORK / "yolo_dataset"
    if not RAW.exists():
        print(f"[1] extracting {args.zip} ...")
        with zipfile.ZipFile(args.zip) as z:
            z.extractall(WORK)
        if not RAW.exists():
            cand = [Path(p).parents[1] for p in glob.glob(str(WORK / "**/images"), recursive=True)
                    if Path(p).name == "images" and (Path(p).parent / "labels").exists()]
            if cand:
                shutil.move(str(cand[0]), str(RAW))
    assert (RAW / "images").exists(), f"images/ not found under {RAW}"

    # 2) Pool every existing split, drop macOS junk, then re-split 70/15/15 by image
    #    (= by specimen, since there is one image per specimen). Sorted before the
    #    seeded shuffle so the split is reproducible independently of filesystem order.
    print("[2] pooling + deterministic 70/15/15 re-split ...")
    pool = []
    for sp in ["train", "val", "test"]:
        idir, ldir = RAW / "images" / sp, RAW / "labels" / sp
        if not idir.exists():
            continue
        for ip in list_images(str(idir)):
            if "__MACOSX" in ip or os.path.basename(ip).startswith("._"):
                continue
            lp = ldir / f"{Path(ip).stem}.txt"
            if lp.exists():
                pool.append((ip, str(lp)))
    pool.sort()
    random.shuffle(pool)
    n = len(pool)
    n_tr, n_va = int(0.70 * n), int(0.15 * n)
    splits = {"train": pool[:n_tr], "val": pool[n_tr:n_tr + n_va], "test": pool[n_tr + n_va:]}
    print(f"    pooled={n}  ->  train={len(splits['train'])} "
          f"val={len(splits['val'])} test={len(splits['test'])}")

    # Write an auditable manifest of which image went to which split.
    with open(OUT / "split_manifest.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["image", "split"])
        for sp, items in splits.items():
            for ip, _ in items:
                w.writerow([os.path.basename(ip), sp])

    # 3) Build the detection and pose-crop datasets for the three splits.
    DET, POSE = WORK / "det", WORK / "pose"
    for base in (DET, POSE):
        for sp in ["train", "val", "test"]:
            (base / "images" / sp).mkdir(parents=True, exist_ok=True)
            (base / "labels" / sp).mkdir(parents=True, exist_ok=True)
    pose_counts = {}
    for sp, items in splits.items():
        pc = 0
        for ip, lp in items:
            shutil.copy2(ip, DET / "images" / sp / os.path.basename(ip))
            det_lines = []
            for ln in [x.strip() for x in open(lp) if x.strip()]:
                cls, cx, cy, w, h, _ = parse_pose_label_line(ln)
                det_lines.append(f"{cls} {cx} {cy} {w} {h}")
            open(DET / "labels" / sp / f"{Path(ip).stem}.txt", "w").write("\n".join(det_lines))
            pc += crop_and_relabel(ip, lp, str(POSE / "images" / sp),
                                   str(POSE / "labels" / sp), pad=args.pad)
        pose_counts[sp] = pc
    print(f"    pose crops: {pose_counts}")

    (DET / "data_det.yaml").write_text(
        f"path: {DET}\ntrain: images/train\nval: images/val\ntest: images/test\nnames: ['flower']\n")

    def write_pose_yaml(path, train_rel="images/train"):
        Path(path).write_text(
            f"path: {POSE}\ntrain: {train_rel}\nval: images/val\ntest: images/test\n"
            f"kpt_shape: [{N_KPTS}, 3]\nnames: ['flower']\n")

    write_pose_yaml(POSE / "data_pose.yaml")

    # 3b) Smaller-training-set ablation: 50% of the pose TRAIN crops (val/test unchanged).
    half_img, half_lbl = POSE / "images" / "train_half", POSE / "labels" / "train_half"
    half_img.mkdir(parents=True, exist_ok=True)
    half_lbl.mkdir(parents=True, exist_ok=True)
    tr_crops = sorted(glob.glob(str(POSE / "images" / "train" / "*.jpg")))
    random.shuffle(tr_crops)
    for ip in tr_crops[:len(tr_crops) // 2]:
        shutil.copy2(ip, half_img / os.path.basename(ip))
        lp = POSE / "labels" / "train" / f"{Path(ip).stem}.txt"
        if lp.exists():
            shutil.copy2(lp, half_lbl / f"{Path(ip).stem}.txt")
    write_pose_yaml(POSE / "data_pose_half.yaml", train_rel="images/train_half")
    print(f"    half-data pose train crops: {len(tr_crops) // 2}")

    print(f"[done] datasets under {WORK}; manifest at {OUT / 'split_manifest.csv'}")
    print("       next: python 01_train.py --work", WORK)


if __name__ == "__main__":
    main()
