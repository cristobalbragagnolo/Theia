#!/usr/bin/env python3
"""
On-device TFLite inference over the held-out specimens (biological validation).

Runs the SAME TFLite models the Theia app ships (detector + pose) through the app's
exact on-device decode (theia_tflite_engine, a Python transcription of the Kotlin
pipeline) over the 268 independent held-out specimens. It writes one Theia __LM.csv
per population containing the RAW model predictions, with NO human correction.

This directly answers Reviewer 2: the validated landmarks are the model's raw
predictions, not human-corrected digitizations. The per-population CSVs (image_name
plus kpt1_x..kpt32_y) feed 03_biological_validation.ipynb.

Requires a TFLite runtime: tensorflow or ai_edge_litert.

Usage:
  python 02_infer_tflite.py
"""
import argparse
import csv
import glob
import os

import theia_tflite_engine as E

POPS = ["En11-07", "Ene05-09", "Ewi02-06", "Ewi03-07", "H01-07"]


def main():
    ap = argparse.ArgumentParser(
        description="Run the app's TFLite models over the held-out specimens (raw predictions).")
    ap.add_argument("--det", default="../models_weights/detector_nano_fp32.tflite",
                    help="detector TFLite model (Stage 1)")
    ap.add_argument("--pose", default="../models_weights/pose_medium_lowaug_fp32.tflite",
                    help="pose/landmark TFLite model (Stage 2)")
    ap.add_argument("--val-dir", default="../data/validation_datates",
                    help="validation images, one folder per population")
    ap.add_argument("--out", default="predictions/pose_lowaug_tflite",
                    help="output directory for the per-population LM CSVs")
    args = ap.parse_args()

    det, pose = E.load(args.det), E.load(args.pose)
    os.makedirs(args.out, exist_ok=True)
    header = ["image_name"] + [f"kpt{i}_{ax}" for i in range(1, 33) for ax in ("x", "y")]
    total_ok = total = 0
    for pop in POPS:
        imgs = sorted(glob.glob(f"{args.val_dir}/{pop}/*.JPG"))
        rows = []
        for ip in imgs:
            total += 1
            kp, _ = E.predict(ip, det, pose)  # raw prediction, no human correction
            if kp is None:
                continue
            row = [os.path.basename(ip)]
            for x, y in kp:
                row += [f"{x:.6f}", f"{y:.6f}"]
            rows.append(row)
            total_ok += 1
        with open(f"{args.out}/{pop}__lowaug_tflite__LM.csv", "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(header)
            w.writerows(rows)
        print(f"{pop}: {len(rows)}/{len(imgs)} -> {pop}__lowaug_tflite__LM.csv", flush=True)
    print(f"TOTAL OK: {total_ok}/{total}", flush=True)


if __name__ == "__main__":
    main()
