# THEIA: Edge AI for Geometric Morphometrics in Ecology

This repository contains the official codebase, deep learning pipeline, and biological validation scripts for the manuscript submitted to ***Methods in Ecology and Evolution* (MEE)**. 

Theia is a sovereign, open-source Edge AI mobile application designed to democratize high-throughput geometric morphometrics in the field, eliminating the need for internet connectivity, cloud computing, or manual landmark digitization.

---

## Repository Structure

To ensure frictionless reproducibility, the project is strictly modularized into four domains:

* **`data/`**: Contains the validation datasets (`.tps` and `.csv` files) and morphological analysis arrays required to reproduce the Procrustes ANOVA and Algorithmic Fidelity tests. *(Note: The raw image dataset for YOLO training is provided via GitHub Releases/Zenodo due to size constraints).*
* **`deep_learning_pipeline/`**: The complete AI training workflow. Includes the cloud training notebook for YOLOv8 (Nano detector + Medium pose estimator), the robust export pipeline to TFLite (FP32/FP16), and the geometrical fidelity test comparing Letterbox padding vs. affine stretching.
* **`validation_scripts/`**: Jupyter notebooks containing the mathematical and biological validation of the Theia engine against the *geomorph* (R) Gold Standard.
* **`theia_app/`**: The complete Flutter/Dart source code for the Android application.

---

## Reproducibility Guide

### Phase 1: Deep Learning Pipeline
1. Download the raw image dataset from the [Releases](#) tab and upload it to your Google Drive.
2. Open `deep_learning_pipeline/00_yolo_cloud_training.ipynb` in Google Colab to train the object detection and pose estimation models. 
   > *Note: If Colab GPU time limits are exceeded, use the `resume=True` parameter as instructed inside the notebook.*
3. Execute `01_export_tflite_edge.py` locally to quantize and export the PyTorch weights to TensorFlow Lite formats suitable for mobile Edge deployment.
4. Run `02_compare_padding_vs_stretch.py` to evaluate the topological preservation of the Letterbox preprocessing approach.

### Phase 2: Biological & Algorithmic Validation
Dependencies: `Python 3.10+`, `R 4.0+`, `geomorph`, `rpy2`.
1. Run `validation_scripts/01_algorithmic_fidelity.ipynb` to verify that Theia's native Python/Dart Procrustes engine perfectly correlates ($|r| > 0.999$) with the R *geomorph* standard.
2. Run `validation_scripts/02_model_biological_validation.ipynb` to reproduce the Procrustes ANOVA, extracting the systematic bias and the biological morphospace fidelity between AI-generated landmarks and manual human digitization.

### Phase 3: Theia Edge Application (Mobile Deployment)
Theia is built using the Flutter cross-platform framework, natively integrating TensorFlow Lite (C++ API).
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Navigate to the `theia_app/` directory.
3. Place the compiled `.tflite` models into the designated `assets/` folder.
4. Run `flutter pub get` to resolve dependencies.
5. Connect an Android device (API Level 24+) and execute `flutter run --release`. 
   > *Note: While the codebase is inherently cross-platform, this study formally validates the analytical engine exclusively on Android architectures.*

---

## Data and Weights Availability

To comply with repository size limits, the heavy binary files are hosted in the **Releases** section of this repository:
* `yolo_dataset.zip` (Raw training images and YOLO-formatted labels).
* Compiled Model Weights (`best_nano.pt`, `best_medium.pt`, and their `.tflite` equivalents).
* `Theia_Release_v1.0.apk` (Ready-to-install Android application).

---
*Developed for the advancement of Biology.*