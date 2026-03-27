#!/usr/bin/env python3
import os
import shutil
import tensorflow as tf
from ultralytics import YOLO

# --- 1. MODEL PATHS ---
# RELATIVE PATH: Reaches out to the generic 'models_weights' folder
DETECT_NANO_PT = "../models_weights/best_nano.pt"
POSE_MEDIUM_PT = "../models_weights/best_medium.pt"
OUTPUT_DIR = "../models_weights"

# --- 2. EXPORT PARAMETERS ---
IMG_SIZE = 640
EXPORT_NMS = False # Key requirement: No Non-Maximum Suppression (NMS)

def convert_model_robust(pt_path, output_name_base, half=False, nms=False):
    """
    Converts a .pt model to .tflite using a robust 2-step method:
    .pt -> saved_model (always FP32) -> .tflite (FP32 or FP16)
    """
    
    output_filename = os.path.join(OUTPUT_DIR, f"{output_name_base}_{'fp16' if half else 'fp32'}.tflite")
    print(f"\n--- 🚀 Starting conversion: {output_filename} ---")
    
    yolo_model = YOLO(pt_path)
    
    # --- STEP 1: Export to TensorFlow SavedModel ---
    print(f"  Step 1/2: Exporting to 'saved_model' (Always FP32, NMS={nms})...")
    try:
        # Export 'saved_model' always as FP32.
        # Ultralytics does not support 'half=True' for this format directly.
        saved_model_dir = yolo_model.export(
            format='saved_model',
            imgsz=IMG_SIZE,
            nms=nms,
            half=False 
        )
        print(f"  Intermediate model saved at: {saved_model_dir}")
    except Exception as e:
        print(f"  ❌ ERROR in Ultralytics export(): {e}")
        return

    # --- STEP 2: Convert SavedModel to TFLite ---
    print(f"  Step 2/2: Converting to TFLite (FP16={half})...")
    try:
        converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
        
        # Apply FP16 quantization if requested
        if half:
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_types = [tf.float16]
            
        tflite_model = converter.convert()
        
        # --- STEP 3: Save final .tflite file ---
        with open(output_filename, 'wb') as f:
            f.write(tflite_model)
            
        print(f"  ✅ Success! Model saved at: {output_filename}")
        
        # Clean up the saved_model folder (frees up disk space)
        if os.path.exists(saved_model_dir):
            shutil.rmtree(saved_model_dir)
        
    except Exception as e:
        print(f"  ❌ ERROR in TFLiteConverter: {e}")
        # Attempt cleanup even on failure
        if os.path.exists(saved_model_dir):
            shutil.rmtree(saved_model_dir)

if __name__ == '__main__':
    print("Starting conversions... (This may take several minutes)")
    
    # Ensure output directory exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # --- Detector (Nano) WITHOUT NMS ---
    convert_model_robust(DETECT_NANO_PT, "detector_nano", 
                         half=False, nms=EXPORT_NMS)
                         
    convert_model_robust(DETECT_NANO_PT, "detector_nano", 
                         half=True, nms=EXPORT_NMS)

    # --- Pose (Medium) WITHOUT NMS ---
    convert_model_robust(POSE_MEDIUM_PT, "pose_medium", 
                         half=False, nms=EXPORT_NMS)
                         
    convert_model_robust(POSE_MEDIUM_PT, "pose_medium", 
                         half=True, nms=EXPORT_NMS)

    print("\n[INFO] === PROCESS COMPLETED ===")
    print(f"Generated files in '{OUTPUT_DIR}':")
    print(" - detector_nano_fp32.tflite")
    print(" - detector_nano_fp16.tflite")
    print(" - pose_medium_fp32.tflite")
    print(" - pose_medium_fp16.tflite")