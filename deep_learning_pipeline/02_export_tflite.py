#!/usr/bin/env python3
"""
Stage 2 — Export the trained YOLO weights to TensorFlow Lite for on-device inference.

Converts the detector and pose weights (.pt) into FP32 TFLite models that the
Theia mobile app loads at runtime. Conversion is done via a robust two-step path
(.pt -> TensorFlow SavedModel -> .tflite) and NMS is disabled, because the app
applies its own confidence gating and single-object selection.

By default this produces the two models the app ships:
  detector_nano_fp32.tflite          (Stage 1, from the retrained YOLOv8-Nano detector)
  pose_medium_lowaug_fp32.tflite     (Stage 2, from the canonical reduced-augmentation pose model)

Usage:
  python 02_export_tflite.py \
      --detector-pt path/to/det_baseline_best.pt \
      --pose-pt     path/to/pose_lowaug_best.pt \
      --out-dir     ../models_weights

Requires: ultralytics, tensorflow.
"""
import argparse
import os
import shutil

import tensorflow as tf
from ultralytics import YOLO

IMG_SIZE = 640


def convert(pt_path, out_dir, out_name, half=False, nms=False):
    """Convert a .pt model to TFLite via a SavedModel intermediate. Returns the output path."""
    out_path = os.path.join(out_dir, f"{out_name}_{'fp16' if half else 'fp32'}.tflite")
    print(f"\n[convert] {pt_path} -> {out_path}")

    # Step 1: export to a TensorFlow SavedModel (always FP32; Ultralytics does not
    # support half precision for this format directly).
    saved_model_dir = YOLO(pt_path).export(format="saved_model", imgsz=IMG_SIZE, nms=nms, half=False)
    print(f"  saved_model: {saved_model_dir}")

    # Step 2: convert the SavedModel to TFLite (optionally FP16-quantized).
    try:
        converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
        if half:
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_types = [tf.float16]
        tflite_model = converter.convert()
        with open(out_path, "wb") as f:
            f.write(tflite_model)
        print(f"  OK -> {out_path}")
        return out_path
    finally:
        shutil.rmtree(saved_model_dir, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser(description="Export trained YOLO weights to TFLite for the Theia app.")
    ap.add_argument("--detector-pt", required=True, help="detector .pt weights (retrained YOLOv8-Nano)")
    ap.add_argument("--pose-pt", required=True, help="pose .pt weights (canonical pose_lowaug)")
    ap.add_argument("--out-dir", default="../models_weights", help="output directory for the .tflite files")
    ap.add_argument("--detector-name", default="detector_nano")
    ap.add_argument("--pose-name", default="pose_medium_lowaug")
    ap.add_argument("--fp16", action="store_true", help="also export FP16 variants")
    args = ap.parse_args()

    os.makedirs(args.out_dir, exist_ok=True)
    convert(args.detector_pt, args.out_dir, args.detector_name, half=False)
    convert(args.pose_pt, args.out_dir, args.pose_name, half=False)
    if args.fp16:
        convert(args.detector_pt, args.out_dir, args.detector_name, half=True)
        convert(args.pose_pt, args.out_dir, args.pose_name, half=True)
    print("\n[done] TFLite export complete.")


if __name__ == "__main__":
    main()
