#!/usr/bin/env python3
"""
Stage 1 — Train the dual-stage YOLOv8 models and evaluate on the held-out test set.

Consumes the datasets prepared by 00_data_split.py and trains, in order:

  det_baseline    YOLOv8-Nano detector (Stage 1)                          -> box mAP on test
  pose_baseline   YOLOv8-Medium-Pose (Stage 2), long budget + early stop  -> convergence + test mAP
  pose_lowaug     ablation: reduced data augmentation (canonical model)   -> test mAP
  pose_halfdata   ablation: 50% of the training crops                     -> test mAP

Early stopping (patience) lets the pose model run to convergence rather than a
fixed epoch count; the validation-loss/mAP plateau documents that convergence.
The reduced-augmentation model (pose_lowaug) is the canonical model reported in
the manuscript. Every model is evaluated on the held-out TEST split and the
metrics are written to results_summary.json.

Training was run on a single NVIDIA GeForce RTX 5080 (16 GB); peak VRAM ~7.7 GB
at batch 16. Lower --batch if you hit out-of-memory.

Usage:
  python 01_train.py --work ./theia_runs/work --device 0
  # quick end-to-end sanity check:
  python 01_train.py --work ./theia_runs/work --skip-ablations --pose-epochs 20 --det-epochs 20

Next stage: 02_export_tflite.py (converts the trained weights to TFLite for the app).
"""
import argparse
import json
from pathlib import Path

import numpy as np


def main():
    ap = argparse.ArgumentParser(description="Train + test-evaluate the Theia YOLO models.")
    ap.add_argument("--work", required=True, help="work/ directory produced by 00_data_split.py")
    ap.add_argument("--out", default=None, help="output dir for runs/ and results_summary.json (default: --work parent)")
    ap.add_argument("--device", default="0", help="CUDA device index, or 'cpu'")
    ap.add_argument("--imgsz", type=int, default=640)
    ap.add_argument("--batch", type=int, default=16)
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--det-epochs", type=int, default=150)
    ap.add_argument("--pose-epochs", type=int, default=300, help="upper bound; early stopping via --patience")
    ap.add_argument("--patience", type=int, default=50, help="early-stopping patience (documents convergence)")
    ap.add_argument("--skip-ablations", action="store_true")
    args = ap.parse_args()

    WORK = Path(args.work).resolve()
    OUT = Path(args.out).resolve() if args.out else WORK.parent
    det_yaml = WORK / "det" / "data_det.yaml"
    pose_yaml = WORK / "pose" / "data_pose.yaml"
    pose_yaml_half = WORK / "pose" / "data_pose_half.yaml"
    for y in (det_yaml, pose_yaml):
        assert y.exists(), f"missing {y}; run 00_data_split.py first"

    from ultralytics import YOLO
    import torch
    gpu = torch.cuda.get_device_name(0) if torch.cuda.is_available() else "CPU"
    print(f"[env] torch {torch.__version__}  cuda={torch.cuda.is_available()}  device={gpu}")

    common = dict(imgsz=args.imgsz, batch=args.batch, workers=args.workers, device=args.device,
                  project=str(OUT / "runs"), exist_ok=True, verbose=True)
    summary = {"gpu": gpu, "batch": args.batch, "runs": {}}

    def evaluate(model, data_yaml, tag):
        m = model.val(data=str(data_yaml), split="test",
                      project=str(OUT / "runs"), name=f"{tag}_test", exist_ok=True)
        summary["runs"][tag] = {k: (float(v) if isinstance(v, (int, float, np.floating)) else str(v))
                                for k, v in m.results_dict.items()}
        print(f"[test:{tag}] {json.dumps(summary['runs'][tag])}")

    # Reduced-augmentation scheme for the canonical pose model: light geometric/color
    # jitter only, with mosaic and mixup disabled.
    lowaug = dict(mosaic=0.0, mixup=0.0, hsv_h=0.0, hsv_s=0.2, hsv_v=0.2,
                  degrees=0.0, translate=0.05, scale=0.1, fliplr=0.5)

    stages = [
        dict(tag="det_baseline", model="yolov8n.pt", task="detect", data=det_yaml,
             epochs=args.det_epochs, extra={}),
        dict(tag="pose_baseline", model="yolov8m-pose.pt", task="pose", data=pose_yaml,
             epochs=args.pose_epochs, extra={}),
    ]
    if not args.skip_ablations:
        stages += [
            dict(tag="pose_lowaug", model="yolov8m-pose.pt", task="pose", data=pose_yaml,
                 epochs=args.pose_epochs, extra=lowaug),
            dict(tag="pose_halfdata", model="yolov8m-pose.pt", task="pose", data=pose_yaml_half,
                 epochs=args.pose_epochs, extra={}),
        ]

    for i, st in enumerate(stages, 1):
        print(f"\n[{i}/{len(stages)}] training {st['tag']} "
              f"({st['epochs']} epochs max, patience {args.patience}) ...")
        model = YOLO(st["model"])
        model.train(task=st["task"], data=str(st["data"]), epochs=st["epochs"],
                    patience=args.patience, name=st["tag"], **{**common, **st["extra"]})
        evaluate(model, st["data"], st["tag"])
        (OUT / "results_summary.json").write_text(json.dumps(summary, indent=2))  # incremental save

    print(f"\n[done] {len(stages)} models trained. Metrics -> {OUT / 'results_summary.json'}")
    print(f"       convergence curves -> {OUT / 'runs' / 'pose_baseline' / 'results.png'}")


if __name__ == "__main__":
    main()
