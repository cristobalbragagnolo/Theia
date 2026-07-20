#!/usr/bin/env python3
"""
Theia on-device inference pipeline, reproduced in Python from the app's Kotlin code
(MainActivity.kt). Runs the SAME TFLite models the app ships, with the SAME letterbox
(black padding), the SAME raw-output decode, and the SAME crop/pose two-stage flow — so
the predictions match what Theia produces on-device.

This is used to generate landmark CSVs for the biological validation with the canonical
retrained model, matching the app rather than a PyTorch replica.
"""
import numpy as np
from PIL import Image

try:
    import tensorflow as tf
    _Interp = tf.lite.Interpreter
except Exception:  # fall back to the standalone LiteRT runtime
    from ai_edge_litert.interpreter import Interpreter as _Interp

INPUT = 640
CONF_IDX = 4           # channel holding the object confidence
KPT_START = 5          # first keypoint channel
KPT_N = 32
CROP_PAD = 0.15
MIN_DETECT_CONF = 0.4  # MainActivity.kt MIN_DETECT_CONFIDENCE
MIN_POSE_CONF = 0.25   # MainActivity.kt MIN_POSE_CONFIDENCE


def load(path):
    it = _Interp(model_path=path)
    it.allocate_tensors()
    return it


def _letterbox(img):
    """Match letterboxBitmap(): scale to fit 640, center on a BLACK 640x640 canvas."""
    w, h = img.size
    scale = min(INPUT / w, INPUT / h)
    sw, sh = max(1, round(w * scale)), max(1, round(h * scale))
    dx, dy = (INPUT - sw) / 2.0, (INPUT - sh) / 2.0
    canvas = Image.new("RGB", (INPUT, INPUT), (0, 0, 0))
    canvas.paste(img.resize((sw, sh), Image.BILINEAR), (int(dx), int(dy)))
    arr = (np.asarray(canvas, dtype=np.float32) / 255.0)[None]  # NHWC, RGB, [0,1]
    return arr, scale, dx, dy


def _best(interp, arr, min_conf):
    """runModel(): transpose to [8400, C], pick the highest-confidence detection > min_conf."""
    inp, out = interp.get_input_details()[0], interp.get_output_details()[0]
    interp.set_tensor(inp["index"], arr)
    interp.invoke()
    raw = interp.get_tensor(out["index"])[0]        # [C, 8400]
    conf = raw[CONF_IDX]
    i = int(conf.argmax())
    return raw[:, i] if conf[i] > min_conf else None  # [C]


def _lb_to_orig(v, pad, scale, limit):
    return min(max((v - pad) / scale, 0.0), float(limit))


def predict(image_path, det, pose):
    """Full two-stage pipeline. Returns 32x2 normalized [0,1] landmarks in the full image, or None."""
    img = Image.open(image_path).convert("RGB")
    W, H = img.size

    # Stage 1: detector on the whole (letterboxed) image.
    arr, scale, dx, dy = _letterbox(img)
    d = _best(det, arr, MIN_DETECT_CONF)
    if d is None:
        return None, 0.0
    cx, cy, w, h = d[0], d[1], d[2], d[3]
    if w <= 0 or h <= 0:
        return None, float(d[CONF_IDX])
    x1 = _lb_to_orig(cx - w / 2, dx, scale, W); x2 = _lb_to_orig(cx + w / 2, dx, scale, W)
    y1 = _lb_to_orig(cy - h / 2, dy, scale, H); y2 = _lb_to_orig(cy + h / 2, dy, scale, H)
    left, right = min(x1, x2), max(x1, x2)
    top, bottom = min(y1, y2), max(y1, y2)
    if right - left <= 1 or bottom - top <= 1:
        return None, float(d[CONF_IDX])

    # expandCropBounds(): pad the box by CROP_PAD, floor/ceil to integer pixels.
    import math
    pw, ph = (right - left) * CROP_PAD, (bottom - top) * CROP_PAD
    cl = max(0, math.floor(left - pw)); ct = max(0, math.floor(top - ph))
    cr = min(W, math.ceil(right + pw)); cb = min(H, math.ceil(bottom + ph))
    cl = min(cl, W - 1); ct = min(ct, H - 1)
    cr = max(cr, cl + 1); cb = max(cb, ct + 1)
    crop = img.crop((cl, ct, cr, cb))
    cw, ch = cr - cl, cb - ct

    # Stage 2: pose on the (letterboxed) crop.
    parr, pscale, pdx, pdy = _letterbox(crop)
    p = _best(pose, parr, MIN_POSE_CONF)
    if p is None:
        return None, float(d[CONF_IDX])
    kp = np.empty((KPT_N, 2), dtype=np.float64)
    for i in range(KPT_N):
        rx, ry = p[KPT_START + i * 3], p[KPT_START + i * 3 + 1]
        crop_x = _lb_to_orig(rx, pdx, pscale, cw)
        crop_y = _lb_to_orig(ry, pdy, pscale, ch)
        kp[i, 0] = min(max(crop_x + cl, 0.0), float(W)) / W
        kp[i, 1] = min(max(crop_y + ct, 0.0), float(H)) / H
    return kp, float(d[CONF_IDX])
