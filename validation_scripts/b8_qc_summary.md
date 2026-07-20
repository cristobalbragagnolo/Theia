# B8 - Detector quality-control: confidence vs. synthetic degradation

**Detector:** retrained Stage-1 `det_baseline_best.pt` (single class: flower/calyx).  
**Base images:** 30 clean top-down specimens, first 6 (sorted) per population across En11-07, Ene05-09, Ewi02-06, Ewi03-07, H01-07 (Em17-07 excluded).  
**Inference:** imgsz=640, top-1 confidence for class 0; 0.0 = no detection.

## Clean-image baseline

- Mean clean confidence (level 0, pooled): **0.956**
- Clean detection rate: **100.0%** (90/90 clean evaluations)
- **Clean-image false-negative rate: 0.0%**

## Perspective

| level | mean conf | std | min | max | detect rate |
|---|---|---|---|---|---|
| 0.0 (clean) | 0.956 | 0.007 | 0.927 | 0.967 | 100% |
| 0.1 | 0.953 | 0.009 | 0.923 | 0.971 | 100% |
| 0.2 | 0.950 | 0.009 | 0.927 | 0.968 | 100% |
| 0.3 | 0.939 | 0.015 | 0.889 | 0.965 | 100% |
| 0.4 | 0.846 | 0.157 | 0.308 | 0.943 | 100% |

- Trend: **monotonically non-increasing**. Step-to-step mean deltas: -0.003, -0.003, -0.012, -0.093.
- Accept threshold: mean confidence never drops below 0.40 within the tested range.

## Blur

| level | mean conf | std | min | max | detect rate |
|---|---|---|---|---|---|
| 0 (clean) | 0.956 | 0.007 | 0.927 | 0.967 | 100% |
| 3 | 0.953 | 0.009 | 0.921 | 0.971 | 100% |
| 6 | 0.932 | 0.043 | 0.768 | 0.962 | 100% |
| 9 | 0.741 | 0.350 | 0.000 | 0.962 | 93% |
| 12 | 0.556 | 0.418 | 0.000 | 0.955 | 83% |

- Trend: **monotonically non-increasing**. Step-to-step mean deltas: -0.003, -0.021, -0.191, -0.185.
- Accept threshold: mean confidence never drops below 0.40 within the tested range.

## Occlusion

| level | mean conf | std | min | max | detect rate |
|---|---|---|---|---|---|
| 0.0 (clean) | 0.956 | 0.007 | 0.927 | 0.967 | 100% |
| 0.15 | 0.411 | 0.328 | 0.000 | 0.945 | 87% |
| 0.3 | 0.036 | 0.082 | 0.000 | 0.426 | 57% |
| 0.45 | 0.047 | 0.093 | 0.000 | 0.386 | 67% |

- Trend: **NOT strictly monotonic** (an increase occurs between adjacent levels). Step-to-step mean deltas: -0.545, -0.375, +0.011.
- Accept threshold: mean confidence first drops below 0.40 at level **0.3**.

## Interpretation (honest framing)

- The detector's confidence **falls as image quality degrades** under all three synthetic degradation families, and the clean-image false-negative rate is 0.0%. This demonstrates **sensitivity to gross image-quality violations** (extreme tilt, heavy defocus, large occlusion).
- This is a **screening signal for gross violations only**. Because the degradations are synthetic and applied to images the detector was trained to handle clean, a confidence drop on grossly degraded inputs is **partly expected by construction**.
- These results **do not** validate fitness-for-geometric-morphometrics, and they do **not** establish that the detector catches subtle or borderline quality problems. The claim supported is narrow: the detector screens out grossly degraded imaging.
