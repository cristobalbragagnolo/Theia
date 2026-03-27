#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
THEIA - Focused Visual Comparative (Modified for Accuracy Analysis)

Generates 10 visual panels (4 columns) for validation images:
  1) GT: Ground Truth landmarks from .txt overlaid on GT crop (with padding)
  2) Model C: Pose-only TFLite (app baseline) with STRETCH preprocessing (640x640)
  3) Model A: Detector Nano TFLite + NMS + Padding + Pose Medium TFLite (LETTERBOX per model)
  4) Overlay: (GT vs C vs A) on the same GT crop

Generates panels for the first 10 images to avoid memory overload.
Analyzes ALL images in the directory and saves a CSV with inference times,
flags, and NORMALIZED ERROR per image.
Prints an accuracy summary (mean error) at the end.
"""

# ============================== Imports ==============================

import argparse
import csv
import sys
import time
from pathlib import Path
from typing import List, Tuple

import numpy as np
import cv2
import pandas as pd

try:
    import tensorflow as tf
except Exception as e:
    print("TensorFlow (tflite) is missing. Install tensorflow or ai_edge_litert. Error:", e)
    sys.exit(1)


# ============================== Utilities ==============================

def ts() -> str:
    return time.strftime("%H:%M:%S")


def log(s: str):
    print(f"[{ts()}] {s}", flush=True)


def letterbox(img: np.ndarray, new_size: int):
    """Resize + pad to a square of new_size maintaining aspect ratio."""
    h, w = img.shape[:2]
    scale = min(new_size / h, new_size / w)
    nh, nw = int(round(h * scale)), int(round(w * scale))
    resized = cv2.resize(img, (nw, nh), interpolation=cv2.INTER_LINEAR)
    canvas = np.zeros((new_size, new_size, 3), dtype=img.dtype)
    pad_w = (new_size - nw) // 2
    pad_h = (new_size - nh) // 2
    canvas[pad_h:pad_h + nh, pad_w:pad_w + nw] = resized
    return canvas, scale, (pad_w, pad_h)


def unletterbox_xy(xy: np.ndarray, scale: float, pad: Tuple[int, int]):
    out = xy.copy()
    out[:, 0] = (out[:, 0] - pad[0]) / scale
    out[:, 1] = (out[:, 1] - pad[1]) / scale
    return out


def unletterbox_box(cx, cy, w, h, scale, pad):
    x1 = (cx - w/2 - pad[0]) / scale
    y1 = (cy - h/2 - pad[1]) / scale
    x2 = (cx + w/2 - pad[0]) / scale
    y2 = (cy + h/2 - pad[1]) / scale
    cx2 = (x1 + x2) / 2
    cy2 = (y1 + y2) / 2
    w2 = (x2 - x1)
    h2 = (y2 - y1)
    return cx2, cy2, w2, h2


def iou_xyxy(a, b):
    ax1, ay1, ax2, ay2, _ = a
    bx1, by1, bx2, by2, _ = b
    ix1, iy1 = max(ax1, bx1), max(ay1, by1)
    ix2, iy2 = min(ax2, bx2), min(ay2, by2)
    iw = max(0.0, ix2 - ix1)
    ih = max(0.0, iy2 - iy1)
    inter = iw * ih
    ua = max(0.0, ax2 - ax1) * max(0.0, ay2 - ay1)
    ub = max(0.0, bx2 - bx1) * max(0.0, by2 - by1) 
    return inter / (ua + ub - inter + 1e-9)


def nms_xyxy(boxes: List[Tuple[float, float, float, float, float]], iou_thres=0.5, max_det=3):
    """Non-Maximum Suppression (NMS) on xyxy boxes using confidence scores."""
    if not boxes:
        return []
    boxes = sorted(boxes, key=lambda b: b[4], reverse=True)
    keep = []
    while boxes and len(keep) < max_det:
        b0 = boxes.pop(0)
        keep.append(b0)
        boxes = [b for b in boxes if iou_xyxy(b0, b) < iou_thres]
    return keep


def clamp(x, lo, hi):
    return max(lo, min(hi, x))


def expand_box(x1, y1, x2, y2, pad_ratio, W, H):
    """Expands bounding box with relative padding and clamps to image dimensions."""
    w = x2 - x1
    h = y2 - y1
    x1p = clamp(x1 - w * pad_ratio, 0, W - 1)
    y1p = clamp(y1 - h * pad_ratio, 0, W - 1)
    x2p = clamp(x2 + w * pad_ratio, 0, W - 1)
    y2p = clamp(y2 + h * pad_ratio, 0, W - 1)
    return int(x1p), int(y1p), int(x2p), int(y2p)


def parse_yolo_label(txt_path: Path, K=32):
    """Reads the first object from a .txt file (YOLO pose format: cls cx cy w h kpts...)."""
    lines = [ln.strip() for ln in txt_path.read_text().splitlines() if ln.strip()]
    if not lines:
        raise ValueError(f"Empty label file: {txt_path}")
    parts = lines[0].split()
    vals = list(map(float, parts[1:]))
    cx, cy, w, h = vals[0:4]
    k = np.array(vals[4:], dtype=np.float32)
    if len(k) >= 3*K:
        k = k[:3*K].reshape(K, 3)[:, :2]  # Discard visibility flag
    else:
        k = k[:2*K].reshape(K, 2)
    return cx, cy, w, h, k  # Normalized to image dimensions [0..1]


def to_px_from_norm_img(pts01, W, H):
    pts = np.zeros_like(pts01, dtype=np.float32)
    pts[:, 0] = pts01[:, 0] * W
    pts[:, 1] = pts01[:, 1] * H
    return pts


def crop_from_box(img, box_xyxy):
    x1, y1, x2, y2 = [int(v) for v in box_xyxy]
    x1 = max(0, x1)
    y1 = max(0, y1)
    x2 = min(img.shape[1]-1, x2)
    y2 = min(img.shape[0]-1, y2)
    if x2 <= x1 or y2 <= y1:
        return img.copy(), (0, 0, 0, 0)
    return img[y1:y2, x1:x2], (x1, y1, x2, y2)


def to_crop_px(pts_img_px, crop_xyxy):
    x1, y1, x2, y2 = crop_xyxy
    out = pts_img_px.copy()
    out[:, 0] -= x1
    out[:, 1] -= y1
    return out


def to_NC(arr: np.ndarray) -> np.ndarray:
    """Robustly converts TFLite output to shape (N,C)."""
    a = arr
    if a.ndim == 3 and a.shape[0] == 1:
        a = a[0]
    if a.ndim == 2:
        C, N = a.shape
        if C in (5, 69, 101) and C < N:
            a = a.T  # -> (N,C)
        return a
    return a.reshape(-1, a.shape[-1])


def sigmoid(x):
    return 1.0 / (1.0 + np.exp(-x))


def draw_points_numbered(canvas, pts, color, label):
    out = canvas.copy()
    for i, (x, y) in enumerate(pts):
        cv2.circle(out, (int(x), int(y)), 3, color, -1)
        cv2.putText(out, str(i + 1), (int(x) + 4, int(y) - 4),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255),
                    1, cv2.LINE_AA)
    # Title bar
    H, W = out.shape[:2]
    cv2.rectangle(out, (0, 0), (W, 22), (0, 0, 0), -1)
    cv2.putText(out, label, (6, 16), cv2.FONT_HERSHEY_SIMPLEX,
                0.5, (255, 255, 255), 1, cv2.LINE_AA)
    return out


def hstack4(a, b, c, d, gap=6):
    H = max(a.shape[0], b.shape[0], c.shape[0], d.shape[0])
    def resize(img):
        return cv2.resize(img, (int(img.shape[1]*H/img.shape[0]), H))
    A, B, C, D = map(resize, [a, b, c, d])
    sep = 255 * np.ones((H, gap, 3), dtype=np.uint8)
    return np.concatenate([A, sep, B, sep, C, sep, D], axis=1)


def calculate_normalized_error(k_gt: np.ndarray, k_pred: np.ndarray, scale: float) -> float:
    """Calculates the mean L2 error normalized by scale (GT bbox diagonal)."""
    if scale < 1e-6:
        return np.nan  # Prevent division by zero if GT bbox is invalid
    
    # Take the minimum number of points (e.g. GT=32, Model=17)
    k_min = min(len(k_gt), len(k_pred))
    if k_min == 0:
        return np.nan
    
    k_gt = k_gt[:k_min]
    k_pred = k_pred[:k_min]
    
    distances = np.sqrt(np.sum((k_gt - k_pred)**2, axis=1))
    normalized_distances = distances / scale
    return float(np.mean(normalized_distances))


# ============================== TFLite Runners ==============================

class TFLiteRunner:
    def __init__(self, model_path: Path):
        self.path = Path(model_path)
        self.interp = tf.lite.Interpreter(model_path=str(self.path))
        self.interp.allocate_tensors()
        self.in_det = self.interp.get_input_details()[0]
        self.out_det = self.interp.get_output_details()[0]
        shp = self.in_det["shape"]
        self.in_h = int(shp[1])
        self.in_w = int(shp[2])
        self.in_dtype = self.in_det["dtype"]

    def infer(self, x: np.ndarray) -> np.ndarray:
        self.interp.set_tensor(self.in_det["index"], x)
        self.interp.invoke()
        return self.interp.get_tensor(self.out_det["index"])


# ============================== Inference (Models C & A) ==============================

def run_pose_app_stretch(img_rgb: np.ndarray,
                         tfl_pose: TFLiteRunner,
                         conf_thres=0.25):
    """Model C: Baseline Pose-Only with STRETCH 640x640 preprocessing."""
    INPUT = 640
    H, W = img_rgb.shape[:2]
    proc = cv2.resize(img_rgb, (INPUT, INPUT), interpolation=cv2.INTER_LINEAR)
    x = proc.astype(np.float32) / 255.0
    x = np.expand_dims(x, 0)

    t0 = time.time()
    out = tfl_pose.infer(x)
    dt = time.time() - t0

    arr = to_NC(out)  # (N,C)
    if arr.shape[1] < 5:
        return None, dt

    scores = arr[:, 4]
    if np.nanmax(scores) > 1.2 or np.nanmin(scores) < 0.0:
        scores = sigmoid(scores)
    if not np.any(scores) or float(np.max(scores)) < conf_thres:
        return None, dt

    i = int(np.argmax(scores))
    row = arr[i]
    cx, cy, w, h = row[:4]

    # Robust parsing block for keypoints (x,y) or (x,y,c)
    rest = row[5:]
    if rest.size % 3 == 0:
        K = rest.size // 3
        kxy = rest.reshape(K, 3)[:, :2]
    elif rest.size % 2 == 0:
        K = rest.size // 2
        kxy = rest.reshape(K, 2)
    else:
        K = 32
        kxy = rest[:2*K].reshape(K, 2)

    # Map back via stretch transformation
    sx = W / INPUT
    sy = H / INPUT
    cx_img = cx * sx
    cy_img = cy * sy
    w_img = w * sx
    h_img = h * sy
    k_img = kxy.copy()
    k_img[:, 0] *= sx
    k_img[:, 1] *= sy

    x1 = int(cx_img - w_img/2)
    y1 = int(cy_img - h_img/2)
    x2 = int(cx_img + w_img/2)
    y2 = int(cy_img + h_img/2)

    return ((x1, y1, x2, y2), k_img), dt


def run_pipeline_A(img_rgb: np.ndarray,
                   tfl_det: TFLiteRunner,
                   tfl_pose: TFLiteRunner,
                   conf_det=0.25, conf_pose=0.25,
                   iou_thres=0.5, max_det=3,
                   pad_ratio=0.15):
    """Model A: Detector (Letterbox) -> NMS -> Padding Expansion -> Pose (Letterbox) on Crop."""
    H, W = img_rgb.shape[:2]

    # Detector (Letterbox preprocessing)
    det_inp, s_d, pad_d = letterbox(img_rgb, tfl_det.in_w)
    x = det_inp.astype(np.float32) / 255.0
    x = np.expand_dims(x, 0)

    t0 = time.time()
    out_det = tfl_det.infer(x)
    t_det = time.time() - t0

    arr = to_NC(out_det)  # (N,C) where C ~ 5
    if arr.shape[1] < 5:
        return None, t_det

    coords = arr[:, :4]  # cx, cy, w, h
    confs = arr[:, 4]
    if np.nanmax(confs) > 1.2 or np.nanmin(confs) < 0.0:
        confs = sigmoid(confs)

    # Unletterbox -> Standard xyxy
    boxes = []
    for (cx, cy, w, h), sc in zip(coords, confs):
        if float(sc) < conf_det:
            continue
        cx_i, cy_i, w_i, h_i = unletterbox_box(cx, cy, w, h, s_d, pad_d)
        x1 = cx_i - w_i/2
        y1 = cy_i - h_i/2
        x2 = cx_i + w_i/2
        y2 = cy_i + h_i/2
        boxes.append((x1, y1, x2, y2, float(sc)))

    boxes_n = nms_xyxy(boxes, iou_thres=iou_thres, max_det=max_det)
    if not boxes_n:
        return None, t_det

    # Select Top-1 Det + apply empirical padding
    x1, y1, x2, y2, _ = boxes_n[0]
    x1, y1, x2, y2 = expand_box(x1, y1, x2, y2, pad_ratio, W, H)
    if x2 <= x1 or y2 <= y1:
        return None, t_det

    crop = img_rgb[y1:y2, x1:x2]

    # Pose Network on the dynamically generated crop (Letterbox preprocessing)
    pose_inp, s_p, pad_p = letterbox(crop, tfl_pose.in_w)
    xp = pose_inp.astype(np.float32) / 255.0
    xp = np.expand_dims(xp, 0)

    t1 = time.time()
    out_pose = tfl_pose.infer(xp)
    t_pose = time.time() - t1

    arrp = to_NC(out_pose)  # (N,C) where C ~ 5+2K or 5+3K
    if arrp.shape[1] < 7:
        return None, t_det + t_pose

    confs_p = arrp[:, 4]
    if np.nanmax(confs_p) > 1.2 or np.nanmin(confs_p) < 0.0:
        confs_p = sigmoid(confs_p)
    if not np.any(confs_p) or float(np.max(confs_p)) < conf_pose:
        return None, t_det + t_pose

    j = int(np.argmax(confs_p))
    rowp = arrp[j]
    
    # Robust parsing block for keypoints (x,y) or (x,y,c)
    rest = rowp[5:]
    if rest.size % 3 == 0:
        K = rest.size // 3
        kxy = rest.reshape(K, 3)[:, :2]
    elif rest.size % 2 == 0:
        K = rest.size // 2
        kxy = rest.reshape(K, 2)
    else:
        K = 32
        kxy = rest[:2*K].reshape(K, 2)

    # Unletterbox to crop pixels, then map to absolute image pixels
    kxy_crop = unletterbox_xy(kxy, s_p, pad_p)
    kxy_img = kxy_crop.copy()
    kxy_img[:, 0] += x1
    kxy_img[:, 1] += y1

    return ((x1, y1, x2, y2), kxy_img), (t_det + t_pose)


# ============================== Main Pipeline Engine ==============================

def run(args):
    img_dir = Path(args.images_dir)
    lbl_dir = Path(args.labels_dir)
    out_dir = Path(args.output_dir)
    (out_dir / "panels").mkdir(parents=True, exist_ok=True)

    # Scan ALL images, but only generate visual panels for the first 10
    all_imgs = sorted([p for p in img_dir.glob("*")
                   if p.suffix.lower() in (".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff")])
    
    panel_indices = set(range(min(10, len(all_imgs)))) 
    
    log(f"Total images targeted: {len(all_imgs)}; Visual panels to be generated: {len(panel_indices)}")

    # Load TFLite models
    tfl_pose_C = TFLiteRunner(Path(args.pose_tfl_nms))
    tfl_det_A = TFLiteRunner(Path(args.det_tfl32))
    tfl_pose_A = TFLiteRunner(Path(args.pose_tfl32))

    # Array to store numerical evaluations
    results = []

    for i, p in enumerate(all_imgs):
        make_panel = (i in panel_indices)
        log(f"[{i+1}/{len(all_imgs)}] {p.name}" + (" (rendering panel)" if make_panel else ""))
        
        img_bgr = cv2.imread(str(p))
        if img_bgr is None:
            log("  [!] ERROR: Could not read image matrix")
            continue

        img = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        H, W = img.shape[:2]

        lbl = lbl_dir / (p.stem + ".txt")
        if not lbl.exists():
            log("  [!] WARNING: Missing Ground Truth .txt label")
            continue

        # Extract Ground Truth bbox + apply equivalent padding
        cx01, cy01, w01, h01, k01_img01 = parse_yolo_label(lbl, K=args.kpts)
        cx, cy, w, h = cx01 * W, cy01 * H, w01 * W, h01 * H
        gt_scale = np.sqrt(w**2 + h**2) # GT BBox diagonal (unpadded) as normalizing scalar
        
        x1 = int(cx - w/2)
        y1 = int(cy - h/2)
        x2 = int(cx + w/2)
        y2 = int(cy + h/2)
        x1g, y1g, x2g, y2g = expand_box(x1, y1, x2, y2, args.pad_ratio, W, H)
        
        # Translate GT normalized coordinates to absolute image pixels
        k_gt_img = to_px_from_norm_img(k01_img01, W, H)

        # Metric tracking variables
        notes = ""
        error_C = np.nan
        error_A = np.nan
        kC_img = None
        kA_img = None
        det_box_str = ""

        # --- Evaluate Model C (Stretch Pose-Only Baseline) ---
        resC, dtC = run_pose_app_stretch(img, tfl_pose_C, conf_thres=args.pose_conf_thres)
        if resC is None:
            notes += "C:no_inference;"
        else:
            boxC, kC_img = resC
            error_C = calculate_normalized_error(k_gt_img, kC_img, gt_scale)

        # --- Evaluate Model A (Letterbox Det+Pose Two-Stage Pipeline) ---
        resA, dtA = run_pipeline_A(img, tfl_det_A, tfl_pose_A,
                                   conf_det=args.det_conf_thres,
                                   conf_pose=args.pose_conf_thres,
                                   iou_thres=args.iou_thres,
                                   max_det=args.max_det,
                                   pad_ratio=args.pad_ratio)
        if resA is None:
            notes += "A:no_inference;"
        else:
            boxA, kA_img = resA
            error_A = calculate_normalized_error(k_gt_img, kA_img, gt_scale)
            det_box_str = f"{tuple(int(v) for v in boxA)}"

        # Save quantitative results for current frame
        results.append({
            "image": p.name,
            "C_time_ms": int(dtC * 1000) if resC else -1,
            "A_time_ms": int(dtA * 1000) if resA else -1,
            "C_norm_error": error_C,
            "A_norm_error": error_A,
            "A_det_box": det_box_str,
            "GT_box": f"({x1g},{y1g},{x2g},{y2g})",
            "notes": notes
        })

        # --- Generate Visual Panels (For qualitative inspection) ---
        if make_panel:
            crop_gt, xyxy_gt = crop_from_box(img, (x1g, y1g, x2g, y2g))
            k_gt_crop = to_crop_px(k_gt_img, (x1g, y1g, x2g, y2g))

            # Render Panel C
            if kC_img is not None:
                kC_crop = to_crop_px(kC_img, (x1g, y1g, x2g, y2g))
                img_C = draw_points_numbered(crop_gt, kC_crop, (0, 165, 255),
                                             "C: Baseline Pose-Only (Stretch)")
            else:
                img_C = draw_points_numbered(crop_gt, np.empty((0, 2)), (0, 165, 255),
                                             "C: Baseline Pose-Only - Failed")

            # Render Panel A
            if kA_img is not None:
                kA_crop = to_crop_px(kA_img, (x1g, y1g, x2g, y2g))
                img_A = draw_points_numbered(crop_gt, kA_crop, (0, 0, 255),
                                             "A: Two-Stage Pipeline (Letterbox)")
            else:
                img_A = draw_points_numbered(crop_gt, np.empty((0, 2)), (0, 0, 255),
                                             "A: Two-Stage Pipeline - Failed")
            
            # Render GT Panel
            img_GT = draw_points_numbered(crop_gt, k_gt_crop, (0, 0, 0), "Ground Truth (Manual Labels)")

            # Render Overlay Panel (GT Black, C Orange, A Red)
            overlay = crop_gt.copy()
            for i2, (x, y) in enumerate(k_gt_crop):
                cv2.circle(overlay, (int(x), int(y)), 3, (0, 0, 0), -1)
                cv2.putText(overlay, str(i2 + 1), (int(x) + 4, int(y) - 4),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.45, (200, 200, 200), 1, cv2.LINE_AA)
            if kC_img is not None:
                for x, y in to_crop_px(kC_img, (x1g, y1g, x2g, y2g)):
                    cv2.circle(overlay, (int(x), int(y)), 3, (0, 165, 255), -1)
            if kA_img is not None:
                for x, y in to_crop_px(kA_img, (x1g, y1g, x2g, y2g)):
                    cv2.circle(overlay, (int(x), int(y)), 3, (0, 0, 255), -1)

            Hc, Wc = overlay.shape[:2]
            cv2.rectangle(overlay, (0, 0), (Wc, 22), (0, 0, 0), -1)
            cv2.putText(overlay, "Overlay Diagnostics (GT: Black, C: Orange, A: Red)",
                        (6, 16), cv2.FONT_HERSHEY_SIMPLEX, 0.5,
                        (255, 255, 255), 1, cv2.LINE_AA)

            panel = hstack4(img_GT, img_C, img_A, overlay, gap=8)
            outp = out_dir / "panels" / f"panel_{p.stem}.jpg"
            cv2.imwrite(str(outp), cv2.cvtColor(panel, cv2.COLOR_RGB2BGR))
            
    # --- END OF INFERENCE LOOP ---

    if not results:
        log("[!] No images were processed. Check input directories.")
        return

    # Aggregate results and export CSV log
    df = pd.DataFrame(results)
    csv_path = out_dir / "summary_geometric_accuracy.csv"
    df.to_csv(csv_path, index=False, float_format="%.6f")
    log(f"Quantitative evaluation matrix saved to: {csv_path}")

    # Calculate final GEOMETRIC ACCURACY metrics (ignoring NaNs)
    mean_err_C = df['C_norm_error'].mean()
    std_err_C = df['C_norm_error'].std()
    count_C = df['C_norm_error'].count()
    
    mean_err_A = df['A_norm_error'].mean()
    std_err_A = df['A_norm_error'].std()
    count_A = df['A_norm_error'].count()
    
    total_imgs = len(df)

    log("\n" + "="*80)
    log(" [GEOMETRIC FIDELITY AUDIT] THEIA Normalized Mean Error vs Ground Truth")
    log("="*80)
    log(f" Total Image Frames Analyzed : {total_imgs}")
    log("-" * 80)
    log(f" MODEL C (Stretch Baseline)  : Mean Error = {mean_err_C:.6f} (Std: {std_err_C:.6f})")
    log(f"                               [Calculated across {count_C} valid inferences]")
    log(f" MODEL A (Letterbox Pipeline): Mean Error = {mean_err_A:.6f} (Std: {std_err_A:.6f})")
    log(f"                               [Calculated across {count_A} valid inferences]")
    log("-" * 80)
    log(" INTERPRETATION:")
    log(" 'Mean Error' is the L2 distance between predicted and GT coordinates,")
    log(" normalized by the GT bounding box diagonal. LOWER VALUES INDICATE HIGHER ACCURACY.")
    log("="*80 + "\n")
    log(f"[OK] Visual diagnostic panels stored in: {out_dir/'panels'}")


# ============================== CLI Interface ==============================

def main():
    ap = argparse.ArgumentParser(description="THEIA Geometric Fidelity Evaluator (Stretch vs Letterbox)")
    # Defaulting to relative repository structure to ensure zero-friction reproducibility for reviewers
    ap.add_argument("--images_dir", default="../data/yolo_dataset/images/val", help="Path to validation images")
    ap.add_argument("--labels_dir", default="../data/yolo_dataset/labels/val", help="Path to ground truth labels")
    ap.add_argument("--pose_tfl_nms", default="../models_weights/pose_medium_fp32.tflite", help="Baseline Pose Model (Model C)")
    ap.add_argument("--det_tfl32", default="../models_weights/detector_nano_fp32.tflite", help="Detector Model for Pipeline (Model A)")
    ap.add_argument("--pose_tfl32", default="../models_weights/pose_medium_fp32.tflite", help="Pose Model for Pipeline (Model A)")
    ap.add_argument("--output_dir", default="../data/morph_analysis_data", help="Directory to save logs and visual panels")
    
    # Mathematical and topological parameters (do not alter unless experimenting)
    ap.add_argument("--kpts", type=int, default=32, help="Number of anatomical landmarks")
    ap.add_argument("--pad_ratio", type=float, default=0.15, help="Relative padding around detected bounding box")
    ap.add_argument("--det_conf_thres", type=float, default=0.25, help="Detector confidence threshold")
    ap.add_argument("--pose_conf_thres", type=float, default=0.25, help="Pose estimation confidence threshold")
    ap.add_argument("--iou_thres", type=float, default=0.5, help="Intersection Over Union threshold for NMS")
    ap.add_argument("--max_det", type=int, default=3, help="Maximum detections allowed per frame")
    
    args = ap.parse_args()
    
    try:
        run(args)
    except Exception as e:
        log(f"[!] FATAL ERROR: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()