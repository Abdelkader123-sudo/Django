
import 'package:flutter/material.dart';

import '../../models/measurement.dart';

class RealtimeChart extends StatelessWidget {
  final List<Measurement> measurements;

  const RealtimeChart({super.key, required this.measurements});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: measurements.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : CustomPaint(
                  painter: _RealtimeChartPainter(
                    values: measurements.map((measurement) => measurement.value).toList(),
                    lineColor: Theme.of(context).colorScheme.primary,
                    gridColor: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  child: const SizedBox.expand(),
                ),
        ),
      ),
    );
  }

}

class _RealtimeChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color gridColor;

  const _RealtimeChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 8.0;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    if (rect.width <= 0 || rect.height <= 0 || values.isEmpty) return;

    final gridPaint = Paint()..color = gridColor;
    for (var i = 0; i <= 4; i++) {
      final y = rect.top + rect.height * i / 4;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }
    canvas.drawRect(rect, gridPaint..style = PaintingStyle.stroke);

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final padding = range == 0 ? 1.0 : range * 0.1;
    final lowerBound = minValue - padding;
    final valueRange = range + padding * 2;
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? rect.center.dx
          : rect.left + rect.width * i / (values.length - 1);
      final y = rect.bottom -
          (values[i] - lowerBound) / valueRange * rect.height;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, rect.bottom)
      ..lineTo(points.first.dx, rect.bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = lineColor.withValues(alpha: 0.15),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RealtimeChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.gridColor != gridColor;
}