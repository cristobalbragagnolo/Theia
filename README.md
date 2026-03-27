# THEIA: Edge AI for Geometric Morphometrics in Ecology

This repository contains the official codebase, deep learning pipeline, and biological validation scripts for the manuscript submitted to ***Methods in Ecology and Evolution* (MEE)**. 

Theia is a sovereign, open-source Edge AI mobile application designed to allow high-throughput geometric morphometrics in the field, eliminating the need for internet connectivity, cloud computing, or manual landmark digitization.

---

## 📁 Repository Structure

To ensure frictionless reproducibility, the project is strictly modularized into four domains:

* **`data/`**: Contains validation datasets and morphological analysis arrays.
* **`deep_learning_pipeline/`**: The complete AI training and export workflow.
* **`validation_scripts/`**: Jupyter notebooks for mathematical and biological validation.
* **`theia_app/`**: The complete Flutter/Dart source code for the Android application.

---

## 🚀 Reproducibility Guide

### Phase 1: Deep Learning Pipeline
1. Download `yolo_dataset.zip` from the **Releases** tab and extract its content into `data/yolo_dataset/`.
2. If training on the cloud, upload the extracted folder to your Google Drive.
3. Open `deep_learning_pipeline/00_yolo_cloud_training.ipynb` in Google Colab to train the models.
4. Execute `01_export_tflite_edge.py` locally to generate the TFLite models.

### Phase 2: Biological & Algorithmic Validation
1. Run `validation_scripts/01_algorithmic_fidelity.ipynb` to verify engine correlation ($|r| > 0.999$).
2. Run `validation_scripts/02_model_biological_validation.ipynb` to reproduce the Procrustes ANOVA and morphospace fidelity tests.

### Phase 3: Theia Edge Application (Mobile Deployment)
Theia requires specific binary placement for both the analytical pipeline and the mobile build:
1. **Download Weights:** Get `pose_medium_fp32.tflite` from the **Releases** tab.
2. **File Placement:** To ensure the app and scripts function correctly, place the file in:
   * `models_weights/` (for local validation scripts)
   * `theia_app/assets/` (for Flutter framework access)
   * `theia_app/android/app/src/main/assets/` (for native Android TFLite initialization)
3. **Build:** Navigate to `theia_app/`, run `flutter pub get` and execute `flutter run --release`.

---

## 📥 Data and Weights Availability

Due to repository size limits, heavy binaries are hosted in the **Releases** section. After downloading, please follow this mapping:

| Downloadable File | Target Destination Path |
| :--- | :--- |
| **`yolo_dataset.zip`** | `data/yolo_dataset/` |
| **`pose_medium_fp32.tflite`** | `models_weights/` **&** `theia_app/assets/` **&** `theia_app/android/app/...` |
| **`Theia_Release_v1.0.apk`** | (Ready-to-install Android application) |

---
*Developed for the advancement of Biology.*