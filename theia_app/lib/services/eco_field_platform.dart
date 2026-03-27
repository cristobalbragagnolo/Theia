import 'dart:io';

import 'package:flutter/services.dart';

class EcoCropResult {
  const EcoCropResult({
    required this.ok,
    required this.reason,
    this.confidence,
    this.cropPath,
    this.blurVariance,
  });

  final bool ok;
  final String reason;
  final double? confidence;
  final String? cropPath;
  final double? blurVariance;

  factory EcoCropResult.fromMap(Map<dynamic, dynamic> map) {
    return EcoCropResult(
      ok: map['ok'] == true,
      reason: (map['reason'] ?? '').toString(),
      confidence: (map['confidence'] as num?)?.toDouble(),
      cropPath: map['cropPath']?.toString(),
      blurVariance: (map['blurVariance'] as num?)?.toDouble(),
    );
  }
}

class EcoTelemetry {
  const EcoTelemetry({
    this.latitude,
    this.longitude,
    this.altitude,
    this.accuracy,
    this.heading,
  });

  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? accuracy;
  final double? heading;

  factory EcoTelemetry.fromMap(Map<dynamic, dynamic> map) {
    return EcoTelemetry(
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      heading: (map['heading'] as num?)?.toDouble(),
    );
  }
}

class EcoGallerySaveResult {
  const EcoGallerySaveResult({
    required this.displayName,
    this.uri,
  });

  final String displayName;
  final String? uri;

  factory EcoGallerySaveResult.fromMap(Map<dynamic, dynamic> map) {
    return EcoGallerySaveResult(
      displayName: (map['displayName'] ?? '').toString(),
      uri: map['uri']?.toString(),
    );
  }
}

class EcoFieldPlatform {
  EcoFieldPlatform._();

  static const MethodChannel _channel = MethodChannel('com.example.theia/tflite');

  static Future<bool> requestLocationPermission() async {
    if (!Platform.isAndroid) return false;
    final granted = await _channel.invokeMethod<bool>('requestLocationPermission');
    return granted ?? false;
  }

  static Future<EcoTelemetry> getTelemetry() async {
    if (!Platform.isAndroid) return const EcoTelemetry();
    final data = await _channel.invokeMethod<Map<dynamic, dynamic>>('getEcoTelemetry');
    if (data == null) return const EcoTelemetry();
    return EcoTelemetry.fromMap(data);
  }

  static Future<EcoCropResult> runEcoCrop({
    required String path,
    required bool blurFilterEnabled,
    double blurThreshold = 120,
  }) async {
    if (!Platform.isAndroid) {
      return const EcoCropResult(ok: false, reason: 'UNSUPPORTED_PLATFORM');
    }
    final data = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'runEcoCrop',
      {
        'path': path,
        'blurFilterEnabled': blurFilterEnabled,
        'blurThreshold': blurThreshold,
      },
    );
    if (data == null) {
      return const EcoCropResult(ok: false, reason: 'NULL_RESPONSE');
    }
    return EcoCropResult.fromMap(data);
  }

  static Future<EcoGallerySaveResult> saveImageToGallery({
    required String sourcePath,
    required String sessionFolder,
    required String displayName,
  }) async {
    if (!Platform.isAndroid) {
      return EcoGallerySaveResult(displayName: displayName);
    }
    final data = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'saveImageToGallery',
      {
        'sourcePath': sourcePath,
        'sessionFolder': sessionFolder,
        'displayName': displayName,
      },
    );
    if (data == null) {
      return EcoGallerySaveResult(displayName: displayName);
    }
    return EcoGallerySaveResult.fromMap(data);
  }
}
