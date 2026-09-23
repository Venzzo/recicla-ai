import 'package:flutter/material.dart';
import 'material_info.dart';

class DetectionResult {
  final Rect boundingBox; // Normalized [0, 1] relative to image width & height
  final int classId;
  final String className;
  final double confidence;
  final MaterialInfo? materialInfo;

  const DetectionResult({
    required this.boundingBox,
    required this.classId,
    required this.className,
    required this.confidence,
    this.materialInfo,
  });

  bool get isLowConfidence => confidence < 0.40;
  bool get isHighConfidence => confidence >= 0.60;

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  String get confidenceLabel {
    if (isLowConfidence) {
      return 'Baixa confiança (${confidencePercentage})';
    } else if (isHighConfidence) {
      return 'Alta confiança (${confidencePercentage})';
    }
    return 'Média confiança (${confidencePercentage})';
  }

  String get displayName => materialInfo?.namePt ?? className;

  Color get boxColor => materialInfo?.color ?? Colors.teal;
}
