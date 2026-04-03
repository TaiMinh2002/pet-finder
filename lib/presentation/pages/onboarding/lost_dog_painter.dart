import 'dart:math';
import 'package:flutter/material.dart';

/// Slide 1: Lost dog with red collar and floating question marks
class LostDogPainter extends CustomPainter {
  final double animValue; // 0..1 for floating
  const LostDogPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.48;
    final float = sin(animValue * 2 * pi) * 6;

    canvas.save();
    canvas.translate(0, float);

    // ── Ground shadow ───────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 85), width: 120, height: 22), shadowPaint);

    // ── Body ────────────────────────────────────────────────────
    final bodyPaint = Paint()..color = const Color(0xFFF5C98A);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 10, cy + 28), width: 110, height: 88), bodyPaint);

    // ── Head ────────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx + 34, cy - 4), 46, bodyPaint);

    // ── Ears ────────────────────────────────────────────────────
    final earPaint = Paint()..color = const Color(0xFFE8A84A);
    _drawRotatedOval(canvas, Offset(cx + 12, cy - 33), 18, 24, -0.26, earPaint);
    _drawRotatedOval(canvas, Offset(cx + 57, cy - 36), 18, 24, 0.26, earPaint);

    // ── Tail ────────────────────────────────────────────────────
    final tailPaint = Paint()
      ..color = const Color(0xFFE8A84A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final tailPath = Path()
      ..moveTo(cx - 66, cy + 18)
      ..cubicTo(cx - 96, cy - 16, cx - 82, cy - 46, cx - 68, cy - 32);
    canvas.drawPath(tailPath, tailPaint);

    // ── Front legs ──────────────────────────────────────────────
    final legRect1 = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 30, cy + 68, 22, 30), const Radius.circular(11));
    final legRect2 = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 8, cy + 68, 22, 30), const Radius.circular(11));
    canvas.drawRRect(legRect1, bodyPaint);
    canvas.drawRRect(legRect2, bodyPaint);

    // ── Eyes ────────────────────────────────────────────────────
    final eyePaint = Paint()..color = const Color(0xFF3D2800);
    canvas.drawCircle(Offset(cx + 20, cy - 8), 8, eyePaint);
    canvas.drawCircle(Offset(cx + 46, cy - 8), 8, eyePaint);
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx + 22, cy - 10), 3, shinePaint);
    canvas.drawCircle(Offset(cx + 48, cy - 10), 3, shinePaint);

    // ── Nose ────────────────────────────────────────────────────
    final nosePaint = Paint()..color = const Color(0xFFC07830);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 32, cy + 6), width: 14, height: 10), nosePaint);

    // ── Mouth ───────────────────────────────────────────────────
    final mouthPaint = Paint()
      ..color = const Color(0xFFC07830)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..moveTo(cx + 22, cy + 14)
      ..quadraticBezierTo(cx + 32, cy + 21, cx + 42, cy + 14);
    canvas.drawPath(mouthPath, mouthPaint);

    // ── Red collar ──────────────────────────────────────────────
    final collarPaint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final collarPath = Path()
      ..moveTo(cx + 2, cy + 27)
      ..quadraticBezierTo(cx + 34, cy + 38, cx + 66, cy + 25);
    canvas.drawPath(collarPath, collarPaint);

    // Collar tag
    final tagPaint = Paint()..color = const Color(0xFFCC4444);
    canvas.drawCircle(Offset(cx + 34, cy + 35), 6, tagPaint);

    // ── Heart ───────────────────────────────────────────────────
    _drawHeart(canvas, Offset(cx + 12, cy - 66), 22, const Color(0xFFFF6B6B));

    canvas.restore();

    // ── Paw prints (static, no float) ──────────────────────────
    _drawPaw(canvas, Offset(cx - 88, cy + 50), 9, Colors.black.withValues(alpha: 0.13));
    _drawPaw(canvas, Offset(cx - 100, cy + 72), 7, Colors.black.withValues(alpha: 0.09));

    // ── Question marks ──────────────────────────────────────────
    final qStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w900,
      color: const Color(0xFFFF6B6B).withValues(alpha: 0.7),
      fontFamily: 'Nunito',
    );
    _drawText(canvas, '?', Offset(cx - 108, cy - 60), qStyle);
    _drawText(canvas, '?', Offset(cx + 86, cy - 80),
        qStyle.copyWith(fontSize: 18, color: const Color(0xFFFF6B6B).withValues(alpha: 0.45)));
    _drawText(canvas, '?', Offset(cx - 78, cy - 100),
        qStyle.copyWith(fontSize: 13, color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)));
  }

  void _drawRotatedOval(Canvas canvas, Offset center, double rx, double ry, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), paint);
    canvas.restore();
  }

  void _drawHeart(Canvas canvas, Offset pos, double size, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(pos.dx, pos.dy + size * 0.3);
    path.cubicTo(pos.dx, pos.dy, pos.dx - size, pos.dy - size * 0.5, pos.dx - size, pos.dy + size * 0.2);
    path.quadraticBezierTo(pos.dx - size, pos.dy + size, pos.dx, pos.dy + size * 1.4);
    path.quadraticBezierTo(pos.dx + size, pos.dy + size, pos.dx + size, pos.dy + size * 0.2);
    path.cubicTo(pos.dx + size, pos.dy - size * 0.5, pos.dx, pos.dy, pos.dx, pos.dy + size * 0.3);
    canvas.drawPath(path, paint);
  }

  void _drawPaw(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center + Offset(-r * 0.7, -r * 0.85), r * 0.42, paint);
    canvas.drawCircle(center + Offset(r * 0.7, -r * 0.85), r * 0.42, paint);
    canvas.drawCircle(center + Offset(-r * 1.05, r * 0.05), r * 0.35, paint);
    canvas.drawCircle(center + Offset(r * 1.05, r * 0.05), r * 0.35, paint);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(LostDogPainter oldDelegate) => oldDelegate.animValue != animValue;
}
