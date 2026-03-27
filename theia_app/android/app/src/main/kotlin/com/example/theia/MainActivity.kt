package com.example.theia

import android.Manifest
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.location.LocationManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.channels.FileChannel
import java.util.Locale
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.math.ceil
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

class MainActivity : FlutterActivity(), SensorEventListener {

    private var detectorInterpreter: Interpreter? = null
    private var poseInterpreter: Interpreter? = null
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val detectorInputBuffer = allocateInputBuffer()
    private val poseInputBuffer = allocateInputBuffer()

    private var pendingLocationPermissionResult: MethodChannel.Result? = null

    private lateinit var sensorManager: SensorManager
    private var accelerometerSensor: Sensor? = null
    private var magnetometerSensor: Sensor? = null
    private var accelerometerValues: FloatArray? = null
    private var magnetometerValues: FloatArray? = null
    private var lastHeadingDegrees: Double? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magnetometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "runTFLite" -> {
                    val imagePath = call.argument<String>("path")
                    if (imagePath.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "Image path is null", null)
                        return@setMethodCallHandler
                    }
                    executor.execute {
                        try {
                            val processedOutput = runDetectPosePipeline(imagePath)
                            runOnUiThread { result.success(processedOutput) }
                        } catch (ex: Exception) {
                            runOnUiThread {
                                result.error(
                                    "TFLITE_INFERENCE_ERROR",
                                    "Error during inference",
                                    ex.localizedMessage
                                )
                            }
                        }
                    }
                }
                "runLiveDetector" -> {
                    val frameBytes = call.argument<ByteArray>("bytes")
                    val width = call.argument<Int>("width") ?: 0
                    val height = call.argument<Int>("height") ?: 0
                    val rotation = call.argument<Int>("rotation") ?: 0
                    if (frameBytes == null || frameBytes.isEmpty() || width <= 0 || height <= 0) {
                        result.error("INVALID_ARGS", "Frame data is invalid", null)
                        return@setMethodCallHandler
                    }
                    executor.execute {
                        try {
                            val detection = runLiveDetector(frameBytes, width, height, rotation)
                            runOnUiThread { result.success(detection) }
                        } catch (ex: Exception) {
                            runOnUiThread {
                                result.error(
                                    "LIVE_DETECT_ERROR",
                                    "Error during live detection",
                                    ex.localizedMessage
                                )
                            }
                        }
                    }
                }
                "requestLocationPermission" -> {
                    requestLocationPermission(result)
                }
                "getEcoTelemetry" -> {
                    try {
                        result.success(buildEcoTelemetry())
                    } catch (ex: Exception) {
                        result.error("TELEMETRY_ERROR", "Unable to read telemetry", ex.localizedMessage)
                    }
                }
                "runEcoCrop" -> {
                    val imagePath = call.argument<String>("path")
                    val blurFilterEnabled = call.argument<Boolean>("blurFilterEnabled") ?: false
                    val blurThreshold = (call.argument<Double>("blurThreshold") ?: DEFAULT_BLUR_VARIANCE_THRESHOLD)
                    if (imagePath.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "Image path is null", null)
                        return@setMethodCallHandler
                    }
                    executor.execute {
                        try {
                            val output = runEcoCrop(
                                imagePath = imagePath,
                                blurFilterEnabled = blurFilterEnabled,
                                blurThreshold = blurThreshold
                            )
                            runOnUiThread { result.success(output) }
                        } catch (ex: Exception) {
                            runOnUiThread {
                                result.error(
                                    "ECO_CROP_ERROR",
                                    "Error creating Eco-Field crop",
                                    ex.localizedMessage
                                )
                            }
                        }
                    }
                }
                "saveImageToGallery" -> {
                    val sourcePath = call.argument<String>("sourcePath")
                    val sessionFolder = call.argument<String>("sessionFolder")
                    val displayName = call.argument<String>("displayName")
                    if (sourcePath.isNullOrBlank() || sessionFolder.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "sourcePath/sessionFolder is null", null)
                        return@setMethodCallHandler
                    }
                    executor.execute {
                        try {
                            val output = saveImageToGallery(sourcePath, sessionFolder, displayName)
                            runOnUiThread { result.success(output) }
                        } catch (ex: Exception) {
                            runOnUiThread {
                                result.error(
                                    "SAVE_GALLERY_ERROR",
                                    "Error saving image to gallery",
                                    ex.localizedMessage
                                )
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        registerCompassListeners()
    }

    override fun onPause() {
        unregisterCompassListeners()
        super.onPause()
    }

    override fun onDestroy() {
        unregisterCompassListeners()
        executor.shutdown()
        detectorInterpreter?.close()
        poseInterpreter?.close()
        super.onDestroy()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_LOCATION_PERMISSION) {
            val granted = grantResults.any { it == PackageManager.PERMISSION_GRANTED }
            pendingLocationPermissionResult?.success(granted)
            pendingLocationPermissionResult = null
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        event ?: return
        when (event.sensor.type) {
            Sensor.TYPE_ACCELEROMETER -> {
                accelerometerValues = event.values.clone()
            }
            Sensor.TYPE_MAGNETIC_FIELD -> {
                magnetometerValues = event.values.clone()
            }
        }

        val accel = accelerometerValues
        val magnet = magnetometerValues
        if (accel == null || magnet == null) return

        val rotation = FloatArray(9)
        val inclination = FloatArray(9)
        if (!SensorManager.getRotationMatrix(rotation, inclination, accel, magnet)) return

        val orientation = FloatArray(3)
        SensorManager.getOrientation(rotation, orientation)
        var azimuth = Math.toDegrees(orientation[0].toDouble())
        if (azimuth < 0) {
            azimuth += 360.0
        }
        lastHeadingDegrees = azimuth
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not used.
    }

    private fun registerCompassListeners() {
        accelerometerSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
        }
        magnetometerSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
        }
    }

    private fun unregisterCompassListeners() {
        sensorManager.unregisterListener(this)
    }

    private fun requestLocationPermission(result: MethodChannel.Result) {
        if (hasLocationPermission()) {
            result.success(true)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            result.success(false)
            return
        }

        if (pendingLocationPermissionResult != null) {
            result.error("PERMISSION_PENDING", "A location permission request is already running", null)
            return
        }

        pendingLocationPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
            ),
            REQUEST_LOCATION_PERMISSION,
        )
    }

    private fun hasLocationPermission(): Boolean {
        val fineGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        return fineGranted || coarseGranted
    }

    private fun buildEcoTelemetry(): Map<String, Any?> {
        val location = if (hasLocationPermission()) getBestLastKnownLocation() else null
        return mapOf(
            "latitude" to location?.latitude,
            "longitude" to location?.longitude,
            "altitude" to location?.takeIf { it.hasAltitude() }?.altitude,
            "accuracy" to location?.takeIf { it.hasAccuracy() }?.accuracy?.toDouble(),
            "heading" to lastHeadingDegrees,
        )
    }

    private fun getBestLastKnownLocation(): Location? {
        val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val providers = locationManager.getProviders(true)

        var bestLocation: Location? = null
        for (provider in providers) {
            val candidate = try {
                locationManager.getLastKnownLocation(provider)
            } catch (_: SecurityException) {
                null
            }

            candidate ?: continue
            if (bestLocation == null) {
                bestLocation = candidate
                continue
            }

            val isMoreAccurate = candidate.accuracy < bestLocation.accuracy
            val isNewer = candidate.time > bestLocation.time
            if (isMoreAccurate || (isNewer && candidate.accuracy <= bestLocation.accuracy + 10f)) {
                bestLocation = candidate
            }
        }
        return bestLocation
    }

    private fun saveImageToGallery(
        sourcePath: String,
        sessionFolder: String,
        displayName: String?
    ): Map<String, String> {
        val sourceFile = File(sourcePath)
        require(sourceFile.exists()) { "Source image does not exist" }

        val safeSessionFolder = sanitizePathSegment(sessionFolder)
        val requestedName = displayName?.trim().orEmpty()
        val baseName = if (requestedName.isEmpty()) {
            "THEIA_${System.currentTimeMillis()}"
        } else {
            requestedName
        }
        val safeName = ensureJpegExtension(sanitizeFileName(baseName))

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val relativePath = "${Environment.DIRECTORY_PICTURES}/THEIA/$safeSessionFolder"
            val resolver = contentResolver
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, safeName)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(MediaStore.Images.Media.RELATIVE_PATH, relativePath)
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }

            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Unable to create MediaStore entry")

            resolver.openOutputStream(uri)?.use { out ->
                sourceFile.inputStream().use { input ->
                    input.copyTo(out)
                }
            } ?: throw IllegalStateException("Unable to open MediaStore output stream")

            val publishValues = ContentValues().apply {
                put(MediaStore.Images.Media.IS_PENDING, 0)
            }
            resolver.update(uri, publishValues, null, null)

            mapOf(
                "displayName" to safeName,
                "uri" to uri.toString(),
            )
        } else {
            @Suppress("DEPRECATION")
            val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            val appDir = File(picturesDir, "THEIA")
            val sessionDir = File(appDir, safeSessionFolder)
            if (!sessionDir.exists()) {
                sessionDir.mkdirs()
            }

            val targetFile = File(sessionDir, safeName)
            sourceFile.inputStream().use { input ->
                FileOutputStream(targetFile).use { output ->
                    input.copyTo(output)
                }
            }

            MediaScannerConnection.scanFile(
                this,
                arrayOf(targetFile.absolutePath),
                arrayOf("image/jpeg"),
                null,
            )

            mapOf(
                "displayName" to targetFile.name,
                "uri" to targetFile.absolutePath,
            )
        }
    }

    private fun sanitizePathSegment(value: String): String {
        return value
            .replace(Regex("[^a-zA-Z0-9._-]"), "_")
            .trim('_')
            .ifEmpty { "session" }
    }

    private fun sanitizeFileName(value: String): String {
        return value
            .replace(Regex("[/\\\\:*?\"<>|]"), "_")
            .replace(Regex("\\s+"), "_")
            .take(120)
            .ifEmpty { "image_${System.currentTimeMillis()}" }
    }

    private fun ensureJpegExtension(value: String): String {
        val lower = value.lowercase(Locale.US)
        return if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            value
        } else {
            "$value.jpg"
        }
    }

    private fun runEcoCrop(
        imagePath: String,
        blurFilterEnabled: Boolean,
        blurThreshold: Double,
    ): Map<String, Any?> {
        val originalBitmap = BitmapFactory.decodeFile(imagePath)
            ?: return mapOf("ok" to false, "reason" to "DECODE_FAILED")

        val originalWidth = originalBitmap.width
        val originalHeight = originalBitmap.height

        try {
            val (detectorBitmap, detectorLetterbox) = letterboxBitmap(originalBitmap, MODEL_INPUT_PIXELS)
            convertBitmapToBuffer(detectorBitmap, detectorInputBuffer)
            detectorBitmap.recycle()

            val detectorOutput = runModel(
                interpreter = ensureDetectorInterpreter(),
                buffer = detectorInputBuffer,
                channelCount = DETECTOR_OUTPUT_CHANNELS,
                minConfidence = MIN_DETECT_CONFIDENCE,
            ) ?: return mapOf("ok" to false, "reason" to "NO_DETECTION")

            val detectionBox = convertToDetectionBox(
                detection = detectorOutput,
                letterbox = detectorLetterbox,
                imageWidth = originalWidth,
                imageHeight = originalHeight,
            ) ?: return mapOf("ok" to false, "reason" to "NO_DETECTION")

            val cropBounds = expandCropBounds(detectionBox, originalWidth, originalHeight)
                ?: return mapOf("ok" to false, "reason" to "CROP_INVALID")

            val cropBitmap = Bitmap.createBitmap(
                originalBitmap,
                cropBounds.left,
                cropBounds.top,
                cropBounds.width,
                cropBounds.height,
            )

            try {
                val blurVariance = calculateLaplacianVariance(cropBitmap)
                if (blurFilterEnabled && blurVariance < blurThreshold) {
                    return mapOf(
                        "ok" to false,
                        "reason" to "BLUR",
                        "confidence" to detectionBox.confidence.toDouble(),
                        "blurVariance" to blurVariance,
                    )
                }

                val (finalCrop, _) = letterboxBitmap(cropBitmap, MODEL_INPUT_PIXELS)
                val tempFile = File.createTempFile("theia_eco_crop_", ".jpg", cacheDir)
                FileOutputStream(tempFile).use { stream ->
                    finalCrop.compress(Bitmap.CompressFormat.JPEG, 95, stream)
                }
                finalCrop.recycle()

                return mapOf(
                    "ok" to true,
                    "reason" to "OK",
                    "confidence" to detectionBox.confidence.toDouble(),
                    "cropPath" to tempFile.absolutePath,
                    "blurVariance" to blurVariance,
                )
            } finally {
                cropBitmap.recycle()
            }
        } finally {
            originalBitmap.recycle()
        }
    }

    private fun calculateLaplacianVariance(bitmap: Bitmap): Double {
        val width = bitmap.width
        val height = bitmap.height
        if (width < 3 || height < 3) return 0.0

        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        val gray = IntArray(width * height)
        for (i in pixels.indices) {
            val p = pixels[i]
            val r = (p shr 16) and 0xFF
            val g = (p shr 8) and 0xFF
            val b = p and 0xFF
            gray[i] = ((0.299 * r) + (0.587 * g) + (0.114 * b)).roundToInt()
        }

        var sum = 0.0
        var sumSq = 0.0
        var count = 0

        for (y in 1 until height - 1) {
            for (x in 1 until width - 1) {
                val center = y * width + x
                val lap = gray[center - width] + gray[center - 1] -
                    (4 * gray[center]) +
                    gray[center + 1] + gray[center + width]

                val value = lap.toDouble()
                sum += value
                sumSq += value * value
                count++
            }
        }

        if (count == 0) return 0.0
        val mean = sum / count
        return (sumSq / count) - (mean * mean)
    }

    private fun allocateInputBuffer(): ByteBuffer =
        ByteBuffer.allocateDirect(IMAGE_BYTE_SIZE).apply { order(ByteOrder.nativeOrder()) }

    private fun loadModelFile(modelPath: String): ByteBuffer {
        val fileDescriptor = assets.openFd(modelPath)
        val inputStream = FileInputStream(fileDescriptor.fileDescriptor)
        val fileChannel = inputStream.channel
        val startOffset = fileDescriptor.startOffset
        val declaredLength = fileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }

    @Synchronized
    private fun ensureDetectorInterpreter(): Interpreter {
        if (detectorInterpreter == null) {
            detectorInterpreter = Interpreter(loadModelFile(DETECTOR_MODEL_FILE))
        }
        return detectorInterpreter!!
    }

    @Synchronized
    private fun ensurePoseInterpreter(): Interpreter {
        if (poseInterpreter == null) {
            poseInterpreter = Interpreter(loadModelFile(POSE_MODEL_FILE))
        }
        return poseInterpreter!!
    }

    private fun runLiveDetector(
        frameBytes: ByteArray,
        width: Int,
        height: Int,
        rotation: Int
    ): Map<String, Any>? {
        val bitmap = nv21ToBitmap(frameBytes, width, height, rotation)
        try {
            val (detectorBitmap, letterbox) = letterboxBitmap(bitmap, MODEL_INPUT_PIXELS)
            convertBitmapToBuffer(detectorBitmap, detectorInputBuffer)
            detectorBitmap.recycle()

            val detection = runModel(
                interpreter = ensureDetectorInterpreter(),
                buffer = detectorInputBuffer,
                channelCount = DETECTOR_OUTPUT_CHANNELS,
                minConfidence = MIN_DETECT_CONFIDENCE
            ) ?: return null

            val detectionBox = convertToDetectionBox(
                detection = detection,
                letterbox = letterbox,
                imageWidth = bitmap.width,
                imageHeight = bitmap.height
            ) ?: return null

            val normalizedBox = listOf(
                (detectionBox.left / bitmap.width).toDouble(),
                (detectionBox.top / bitmap.height).toDouble(),
                (detectionBox.right / bitmap.width).toDouble(),
                (detectionBox.bottom / bitmap.height).toDouble()
            )

            return mapOf(
                "box" to normalizedBox,
                "confidence" to detectionBox.confidence.toDouble()
            )
        } finally {
            bitmap.recycle()
        }
    }

    private fun runDetectPosePipeline(imagePath: String): List<Any> {
        val originalBitmap = BitmapFactory.decodeFile(imagePath)
            ?: throw IllegalArgumentException("Cannot decode bitmap at $imagePath")
        val originalWidth = originalBitmap.width
        val originalHeight = originalBitmap.height

        try {
            val (detectorBitmap, detectorLetterbox) = letterboxBitmap(originalBitmap, MODEL_INPUT_PIXELS)
            convertBitmapToBuffer(detectorBitmap, detectorInputBuffer)
            detectorBitmap.recycle()

            val detectorOutput = runModel(
                interpreter = ensureDetectorInterpreter(),
                buffer = detectorInputBuffer,
                channelCount = DETECTOR_OUTPUT_CHANNELS,
                minConfidence = MIN_DETECT_CONFIDENCE
            ) ?: return emptyResult()

            val detectionBox = convertToDetectionBox(
                detection = detectorOutput,
                letterbox = detectorLetterbox,
                imageWidth = originalWidth,
                imageHeight = originalHeight
            ) ?: return emptyResult()

            val cropBounds = expandCropBounds(detectionBox, originalWidth, originalHeight) ?: return emptyResult()
            val cropBitmap = Bitmap.createBitmap(
                originalBitmap,
                cropBounds.left,
                cropBounds.top,
                cropBounds.width,
                cropBounds.height
            )

            val cropInfo = CropInfo(
                left = cropBounds.left.toFloat(),
                top = cropBounds.top.toFloat(),
                width = cropBounds.width.toFloat(),
                height = cropBounds.height.toFloat()
            )

            val (poseBitmap, poseLetterbox) = letterboxBitmap(cropBitmap, MODEL_INPUT_PIXELS)
            convertBitmapToBuffer(poseBitmap, poseInputBuffer)
            poseBitmap.recycle()
            cropBitmap.recycle()

            val poseDetection = runModel(
                interpreter = ensurePoseInterpreter(),
                buffer = poseInputBuffer,
                channelCount = POSE_OUTPUT_CHANNELS,
                minConfidence = MIN_POSE_CONFIDENCE
            ) ?: return emptyResult()

            return buildPoseResult(
                detection = poseDetection,
                letterbox = poseLetterbox,
                cropInfo = cropInfo,
                originalWidth = originalWidth,
                originalHeight = originalHeight
            ) ?: emptyResult()
        } finally {
            originalBitmap.recycle()
        }
    }

    private fun letterboxBitmap(source: Bitmap, targetSize: Int): Pair<Bitmap, LetterboxParams> {
        val width = source.width.toFloat()
        val height = source.height.toFloat()
        val scale = min(targetSize / width, targetSize / height)
        val scaledWidth = max(1, (width * scale).roundToInt())
        val scaledHeight = max(1, (height * scale).roundToInt())
        val dx = (targetSize - scaledWidth) / 2f
        val dy = (targetSize - scaledHeight) / 2f

        val resized = Bitmap.createScaledBitmap(source, scaledWidth, scaledHeight, true)
        val letterbox = Bitmap.createBitmap(targetSize, targetSize, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(letterbox)
        canvas.drawColor(Color.BLACK)
        canvas.drawBitmap(resized, dx, dy, null)
        if (resized != source) {
            resized.recycle()
        }

        return Pair(letterbox, LetterboxParams(scale = scale, padX = dx, padY = dy))
    }

    private fun convertBitmapToBuffer(bitmap: Bitmap, buffer: ByteBuffer) {
        buffer.rewind()
        val pixels = IntArray(MODEL_INPUT_PIXELS * MODEL_INPUT_PIXELS)
        bitmap.getPixels(pixels, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)

        var pixelIndex = 0
        for (y in 0 until MODEL_INPUT_PIXELS) {
            for (x in 0 until MODEL_INPUT_PIXELS) {
                val pixelValue = pixels[pixelIndex++]
                buffer.putFloat(((pixelValue shr 16) and 0xFF) / 255.0f)
                buffer.putFloat(((pixelValue shr 8) and 0xFF) / 255.0f)
                buffer.putFloat((pixelValue and 0xFF) / 255.0f)
            }
        }
    }

    private fun runModel(
        interpreter: Interpreter,
        buffer: ByteBuffer,
        channelCount: Int,
        minConfidence: Float
    ): FloatArray? {
        val output = Array(1) { Array(channelCount) { FloatArray(DETECTIONS) } }
        interpreter.run(buffer, output)
        val transposed = transposeOutput(output[0], channelCount)

        var bestDetectionIndex = -1
        var maxConfidence = minConfidence
        for (i in 0 until DETECTIONS) {
            val confidence = transposed[i][CONFIDENCE_INDEX]
            if (confidence > maxConfidence) {
                maxConfidence = confidence
                bestDetectionIndex = i
            }
        }

        return if (bestDetectionIndex == -1) null else transposed[bestDetectionIndex]
    }

    private fun transposeOutput(raw: Array<FloatArray>, channelCount: Int): Array<FloatArray> {
        val transposed = Array(DETECTIONS) { FloatArray(channelCount) }
        for (channel in 0 until channelCount) {
            for (i in 0 until DETECTIONS) {
                transposed[i][channel] = raw[channel][i]
            }
        }
        return transposed
    }

    private fun convertToDetectionBox(
        detection: FloatArray,
        letterbox: LetterboxParams,
        imageWidth: Int,
        imageHeight: Int
    ): DetectionBox? {
        val cx = detection[0]
        val cy = detection[1]
        val w = detection[2]
        val h = detection[3]
        if (w <= 0f || h <= 0f) return null

        val x1Letter = cx - w / 2f
        val y1Letter = cy - h / 2f
        val x2Letter = cx + w / 2f
        val y2Letter = cy + h / 2f

        val x1 = letterboxToOriginal(x1Letter, letterbox.padX, letterbox.scale, imageWidth.toFloat())
        val y1 = letterboxToOriginal(y1Letter, letterbox.padY, letterbox.scale, imageHeight.toFloat())
        val x2 = letterboxToOriginal(x2Letter, letterbox.padX, letterbox.scale, imageWidth.toFloat())
        val y2 = letterboxToOriginal(y2Letter, letterbox.padY, letterbox.scale, imageHeight.toFloat())

        val left = min(x1, x2).coerceIn(0f, imageWidth.toFloat())
        val right = max(x1, x2).coerceIn(0f, imageWidth.toFloat())
        val top = min(y1, y2).coerceIn(0f, imageHeight.toFloat())
        val bottom = max(y1, y2).coerceIn(0f, imageHeight.toFloat())
        if (right - left <= 1f || bottom - top <= 1f) return null

        return DetectionBox(
            left = left,
            top = top,
            right = right,
            bottom = bottom,
            confidence = detection[CONFIDENCE_INDEX]
        )
    }

    private fun expandCropBounds(
        detection: DetectionBox,
        imageWidth: Int,
        imageHeight: Int
    ): CropBounds? {
        val width = detection.right - detection.left
        val height = detection.bottom - detection.top
        if (width <= 0f || height <= 0f) return null

        val padX = width * CROP_PADDING_RATIO
        val padY = height * CROP_PADDING_RATIO
        val left = (detection.left - padX).coerceAtLeast(0f)
        val top = (detection.top - padY).coerceAtLeast(0f)
        val right = (detection.right + padX).coerceAtMost(imageWidth.toFloat())
        val bottom = (detection.bottom + padY).coerceAtMost(imageHeight.toFloat())

        val leftInt = floor(left).toInt().coerceIn(0, imageWidth - 1)
        val topInt = floor(top).toInt().coerceIn(0, imageHeight - 1)
        val rightInt = ceil(right).toInt().coerceIn(leftInt + 1, imageWidth)
        val bottomInt = ceil(bottom).toInt().coerceIn(topInt + 1, imageHeight)
        val widthInt = (rightInt - leftInt).coerceAtLeast(1)
        val heightInt = (bottomInt - topInt).coerceAtLeast(1)

        return CropBounds(leftInt, topInt, widthInt, heightInt)
    }

    private fun buildPoseResult(
        detection: FloatArray,
        letterbox: LetterboxParams,
        cropInfo: CropInfo,
        originalWidth: Int,
        originalHeight: Int
    ): List<Any>? {
        val x1Letter = detection[0] - detection[2] / 2f
        val y1Letter = detection[1] - detection[3] / 2f
        val x2Letter = detection[0] + detection[2] / 2f
        val y2Letter = detection[1] + detection[3] / 2f

        val x1Crop = letterboxToOriginal(x1Letter, letterbox.padX, letterbox.scale, cropInfo.width)
        val y1Crop = letterboxToOriginal(y1Letter, letterbox.padY, letterbox.scale, cropInfo.height)
        val x2Crop = letterboxToOriginal(x2Letter, letterbox.padX, letterbox.scale, cropInfo.width)
        val y2Crop = letterboxToOriginal(y2Letter, letterbox.padY, letterbox.scale, cropInfo.height)

        val x1 = (x1Crop + cropInfo.left).coerceIn(0f, originalWidth.toFloat())
        val y1 = (y1Crop + cropInfo.top).coerceIn(0f, originalHeight.toFloat())
        val x2 = (x2Crop + cropInfo.left).coerceIn(0f, originalWidth.toFloat())
        val y2 = (y2Crop + cropInfo.top).coerceIn(0f, originalHeight.toFloat())
        if (x2 - x1 <= 1f || y2 - y1 <= 1f) return null

        val box = FloatArray(4)
        box[0] = ((x1 + x2) / 2f) / originalWidth
        box[1] = ((y1 + y2) / 2f) / originalHeight
        box[2] = (x2 - x1) / originalWidth
        box[3] = (y2 - y1) / originalHeight

        val keypoints = FloatArray(KEYPOINTS_TOTAL * 3)
        val confidences = DoubleArray(KEYPOINTS_TOTAL)
        for (i in 0 until KEYPOINTS_TOTAL) {
            val kpIndex = KEYPOINTS_START_INDEX + i * 3
            val rawX = detection[kpIndex]
            val rawY = detection[kpIndex + 1]
            val confidence = detection[kpIndex + 2]

            val cropX = letterboxToOriginal(rawX, letterbox.padX, letterbox.scale, cropInfo.width)
            val cropY = letterboxToOriginal(rawY, letterbox.padY, letterbox.scale, cropInfo.height)
            val absX = (cropX + cropInfo.left).coerceIn(0f, originalWidth.toFloat())
            val absY = (cropY + cropInfo.top).coerceIn(0f, originalHeight.toFloat())

            keypoints[i * 3] = absX / originalWidth
            keypoints[i * 3 + 1] = absY / originalHeight
            keypoints[i * 3 + 2] = confidence
            confidences[i] = confidence.toDouble()
        }

        return listOf(box.toList(), keypoints.toList(), confidences.toList())
    }

    private fun letterboxToOriginal(value: Float, pad: Float, scale: Float, limit: Float): Float {
        return ((value - pad) / scale).coerceIn(0f, limit)
    }

    private fun emptyResult(): List<Any> = listOf(FloatArray(0), FloatArray(0), FloatArray(0))

    private fun nv21ToBitmap(
        nv21: ByteArray,
        width: Int,
        height: Int,
        rotation: Int
    ): Bitmap {
        val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), 75, out)
        val jpegBytes = out.toByteArray()
        out.close()
        var bitmap = BitmapFactory.decodeByteArray(jpegBytes, 0, jpegBytes.size)
            ?: throw IllegalArgumentException("Unable to decode preview frame")
        if (rotation != 0) {
            val matrix = Matrix().apply { postRotate(rotation.toFloat()) }
            val rotated = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
            if (rotated != bitmap) {
                bitmap.recycle()
                bitmap = rotated
            }
        }
        return bitmap
    }

    private data class LetterboxParams(
        val scale: Float,
        val padX: Float,
        val padY: Float
    )

    private data class CropInfo(
        val left: Float,
        val top: Float,
        val width: Float,
        val height: Float
    )

    private data class CropBounds(
        val left: Int,
        val top: Int,
        val width: Int,
        val height: Int
    )

    private data class DetectionBox(
        val left: Float,
        val top: Float,
        val right: Float,
        val bottom: Float,
        val confidence: Float
    )

    companion object {
        private const val CHANNEL = "com.example.theia/tflite"
        private const val DETECTOR_MODEL_FILE = "detector_nano_fp32.tflite"
        private const val POSE_MODEL_FILE = "pose_medium_fp32.tflite"

        private const val MODEL_INPUT_PIXELS = 640
        private const val DETECTIONS = 8400
        private const val CONFIDENCE_INDEX = 4
        private const val KEYPOINTS_START_INDEX = 5
        private const val KEYPOINTS_TOTAL = 32

        private const val DETECTOR_OUTPUT_CHANNELS = 5
        private const val POSE_OUTPUT_CHANNELS = 101

        private const val MIN_DETECT_CONFIDENCE = 0.4f
        private const val MIN_POSE_CONFIDENCE = 0.25f
        private const val CROP_PADDING_RATIO = 0.15f
        private const val DEFAULT_BLUR_VARIANCE_THRESHOLD = 120.0

        private const val BYTES_PER_FLOAT = 4
        private const val IMAGE_BYTE_SIZE = 1 * MODEL_INPUT_PIXELS * MODEL_INPUT_PIXELS * 3 * BYTES_PER_FLOAT

        private const val REQUEST_LOCATION_PERMISSION = 2207
    }
}
