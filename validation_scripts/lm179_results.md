# 179 held-out test — per-landmark pixel RMSE (Reviewer 2)
- **Model:** pose_lowaug (canonical) · **crops:** 179 · **usable:** 179 · **detection failures:** 0 · **multi-detection crops:** 0
- **Crop size (px):** W 226–1051 (med 468), H 282–1332 (med 567).

## Overall agreement (predicted vs image-registered GT)
- **Mean per-landmark RMSE:** 0.0322 normalized crop units (≈ 18.60 crop px).
- **Pooled RMSE (all 32×179 landmark instances):** 0.0333 normalized (≈ 19.53 crop px).

## Worst / best landmarks (by normalized RMSE)
| rank | worst landmark | RMSE_norm | RMSE_px |  | best landmark | RMSE_norm | RMSE_px |
|---|---|---|---|---|---|---|---|
| 1 | 19 | 0.0453 | 29.97 |  | 21 | 0.0172 | 9.62 |
| 2 | 3 | 0.0444 | 28.55 |  | 5 | 0.0179 | 9.85 |
| 3 | 7 | 0.0441 | 28.83 |  | 29 | 0.0191 | 10.58 |
| 4 | 15 | 0.0437 | 26.92 |  | 13 | 0.0214 | 10.78 |
| 5 | 23 | 0.0432 | 27.75 |  | 4 | 0.0239 | 14.29 |

- **Worst-5 (179 lm×lm):** [19, 3, 7, 15, 23]
- **Worst-5 (268 GM Procrustes, for cross-check):** [32, 16, 26, 31, 10]
- **Overlap:** none

## Files
- `lm179_per_landmark.csv` — RMSE per landmark (normalized + crop px)
- `lm179_per_specimen.csv` — per-crop mean error, crop dims, detection conf
- `fig_lm179_per_landmark_rmse.png` — per-landmark RMSE bar chart

_Note: this isolates the pose stage on GT-box crops; detector localization is reported separately (detector test mAP50-95(B)=0.964). The 179 GT is image-registered, so pixel/landmark comparison is valid here — unlike the shape-only 268 (GM/Procrustes only)._
