import 'package:flutter/material.dart';

class RouteMapPlaceholder extends StatelessWidget {
  const RouteMapPlaceholder({super.key, this.height = 170});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _RouteMapPainter()),
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFE5E9E8);
    canvas.drawRect(Offset.zero & size, background);

    final blockPaint = Paint()..color = const Color(0xFFD3DCD8);
    for (var row = 0; row < 5; row++) {
      for (var column = 0; column < 6; column++) {
        final left = (column + (row.isEven ? 0.25 : 0.6)) * size.width / 5.5;
        final top = (row + (column.isEven ? 0.2 : 0.55)) * size.height / 5.5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, size.width * 0.13, size.height * 0.11),
            const Radius.circular(3),
          ),
          blockPaint,
        );
      }
    }

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final roadPath = Path()
      ..moveTo(-10, size.height * 0.78)
      ..lineTo(size.width * 0.28, size.height * 0.63)
      ..lineTo(size.width * 0.52, size.height * 0.42)
      ..lineTo(size.width * 0.83, size.height * 0.2)
      ..lineTo(size.width + 10, size.height * 0.1);
    canvas.drawPath(roadPath, roadPaint);

    final routePaint = Paint()
      ..color = const Color(0xFF0B75D1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final routePath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.78)
      ..lineTo(size.width * 0.42, size.height * 0.55)
      ..lineTo(size.width * 0.64, size.height * 0.35)
      ..lineTo(size.width * 0.86, size.height * 0.2);
    canvas.drawPath(routePath, routePaint);

    final markerPaint = Paint()..color = const Color(0xFF0B75D1);
    final start = Offset(size.width * 0.15, size.height * 0.78);
    final end = Offset(size.width * 0.86, size.height * 0.2);
    canvas.drawCircle(start, 7, markerPaint);
    canvas.drawCircle(end, 7, Paint()..color = const Color(0xFF35A744));
    canvas.drawCircle(start, 3, Paint()..color = Colors.white);
    canvas.drawCircle(end, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
