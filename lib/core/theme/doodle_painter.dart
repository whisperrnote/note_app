import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../theme/colors.dart';

class DoodlePainter extends CustomPainter {
  final String doodleData;
  final Color strokeColor;

  DoodlePainter({
    required this.doodleData,
    this.strokeColor = AppColors.electric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final List<dynamic> json = jsonDecode(doodleData);
      if (json.isEmpty) return;

      final List<Point> points = json
          .map(
            (p) => Point(
              Offset(p['x'].toDouble(), p['y'].toDouble()),
              PointType.values[p['type']],
              p['pressure']?.toDouble() ?? 1.0,
            ),
          )
          .toList();

      // Find bounds of the doodle to scale it
      double minX = double.infinity, minY = double.infinity;
      double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

      for (var p in points) {
        if (p.offset.dx < minX) minX = p.offset.dx;
        if (p.offset.dy < minY) minY = p.offset.dy;
        if (p.offset.dx > maxX) maxX = p.offset.dx;
        if (p.offset.dy > maxY) maxY = p.offset.dy;
      }

      final doodleWidth = maxX - minX;
      final doodleHeight = maxY - minY;

      if (doodleWidth == 0 || doodleHeight == 0) return;

      final scaleX = size.width / doodleWidth;
      final scaleY = size.height / doodleHeight;
      final scale = scaleX < scaleY ? scaleX : scaleY;

      final paint = Paint()
        ..color = strokeColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      Path? currentPath;

      for (var i = 0; i < points.length; i++) {
        final p = points[i];
        final scaledOffset = Offset(
          (p.offset.dx - minX) * scale,
          (p.offset.dy - minY) * scale,
        );

        if (p.type == PointType.tap) {
          if (currentPath != null) {
            canvas.drawPath(currentPath, paint);
          }
          currentPath = Path()..moveTo(scaledOffset.dx, scaledOffset.dy);
        } else if (currentPath != null) {
          currentPath.lineTo(scaledOffset.dx, scaledOffset.dy);
        }
      }

      if (currentPath != null) {
        canvas.drawPath(currentPath, paint);
      }
    } catch (e) {
      // Silent fail for malformed data
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
