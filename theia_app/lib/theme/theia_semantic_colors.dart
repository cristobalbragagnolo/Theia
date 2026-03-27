import 'package:flutter/material.dart';

@immutable
class TheiaSemanticColors extends ThemeExtension<TheiaSemanticColors> {
  const TheiaSemanticColors({
    required this.statusApproved,
    required this.statusRejected,
    required this.statusEdited,
    required this.onStatusApproved,
    required this.onStatusRejected,
    required this.onStatusEdited,
    required this.confidenceLow,
    required this.confidenceMedium,
    required this.confidenceHigh,
  });

  final Color statusApproved;
  final Color statusRejected;
  final Color statusEdited;
  final Color onStatusApproved;
  final Color onStatusRejected;
  final Color onStatusEdited;

  // Se mantienen explícitamente para preservar semántica histórica:
  // rojo = baja, verde = media, azul = alta.
  final Color confidenceLow;
  final Color confidenceMedium;
  final Color confidenceHigh;

  factory TheiaSemanticColors.fromScheme(ColorScheme scheme) {
    return TheiaSemanticColors(
      statusApproved: scheme.primary,
      statusRejected: scheme.error,
      statusEdited: scheme.secondary,
      onStatusApproved: scheme.onPrimary,
      onStatusRejected: scheme.onError,
      onStatusEdited: scheme.onSecondary,
      confidenceLow: Colors.red,
      confidenceMedium: Colors.green,
      confidenceHigh: Colors.blue,
    );
  }

  @override
  TheiaSemanticColors copyWith({
    Color? statusApproved,
    Color? statusRejected,
    Color? statusEdited,
    Color? onStatusApproved,
    Color? onStatusRejected,
    Color? onStatusEdited,
    Color? confidenceLow,
    Color? confidenceMedium,
    Color? confidenceHigh,
  }) {
    return TheiaSemanticColors(
      statusApproved: statusApproved ?? this.statusApproved,
      statusRejected: statusRejected ?? this.statusRejected,
      statusEdited: statusEdited ?? this.statusEdited,
      onStatusApproved: onStatusApproved ?? this.onStatusApproved,
      onStatusRejected: onStatusRejected ?? this.onStatusRejected,
      onStatusEdited: onStatusEdited ?? this.onStatusEdited,
      confidenceLow: confidenceLow ?? this.confidenceLow,
      confidenceMedium: confidenceMedium ?? this.confidenceMedium,
      confidenceHigh: confidenceHigh ?? this.confidenceHigh,
    );
  }

  @override
  TheiaSemanticColors lerp(
      ThemeExtension<TheiaSemanticColors>? other, double t) {
    if (other is! TheiaSemanticColors) return this;
    return TheiaSemanticColors(
      statusApproved: Color.lerp(statusApproved, other.statusApproved, t)!,
      statusRejected: Color.lerp(statusRejected, other.statusRejected, t)!,
      statusEdited: Color.lerp(statusEdited, other.statusEdited, t)!,
      onStatusApproved:
          Color.lerp(onStatusApproved, other.onStatusApproved, t)!,
      onStatusRejected:
          Color.lerp(onStatusRejected, other.onStatusRejected, t)!,
      onStatusEdited: Color.lerp(onStatusEdited, other.onStatusEdited, t)!,
      confidenceLow: Color.lerp(confidenceLow, other.confidenceLow, t)!,
      confidenceMedium:
          Color.lerp(confidenceMedium, other.confidenceMedium, t)!,
      confidenceHigh: Color.lerp(confidenceHigh, other.confidenceHigh, t)!,
    );
  }
}
