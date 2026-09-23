import 'package:flutter/material.dart';
import '../models/detection_result.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final bool showLabels;

  BoundingBoxPainter({
    required this.detections,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final detection in detections) {
      final rect = Rect.fromLTWH(
        detection.boundingBox.left * size.width,
        detection.boundingBox.top * size.height,
        detection.boundingBox.width * size.width,
        detection.boundingBox.height * size.height,
      );

      final color = detection.boxColor;

      // 1. Fundo semitransparente dentro da caixa delimitadora
      final fillPaint = Paint()
        ..color = color.withOpacity(0.18)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        fillPaint,
      );

      // 2. Borda externa sólida da caixa
      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        strokePaint,
      );

      if (!showLabels) continue;

      // 3. Etiqueta / Badge de Identificação
      final labelText = detection.isLowConfidence
          ? '⚠️ ${detection.displayName} (${detection.confidencePercentage})'
          : '${detection.displayName} (${detection.confidencePercentage})';

      final textSpan = TextSpan(
        text: labelText,
        style: TextStyle(
          color: detection.materialInfo?.textColor ?? Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelHeight = textPainter.height + 8;
      final labelWidth = textPainter.width + 16;

      // Posiciona o badge acima da caixa ou logo dentro se estiver muito no topo
      final labelTop = (rect.top - labelHeight < 0) ? rect.top + 2 : rect.top - labelHeight;
      final labelLeft = rect.left.clamp(0.0, size.width - labelWidth);

      final labelRect = Rect.fromLTWH(labelLeft, labelTop, labelWidth, labelHeight);

      final badgePaint = Paint()
        ..color = color.withOpacity(0.92)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        badgePaint,
      );

      textPainter.paint(
        canvas,
        Offset(labelLeft + 8, labelTop + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections || oldDelegate.showLabels != showLabels;
  }
}
