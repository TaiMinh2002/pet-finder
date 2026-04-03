import 'dart:math';
import 'package:flutter/material.dart';

/// Slide 2: Interactive map with pins and notification card
class MapPainter extends CustomPainter {
  final double animValue;
  const MapPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = (sin(animValue * 2 * pi) + 1) / 2;

    // ── Map card ────────────────────────────────────────────────
    final mapRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 10, size.width - 40, 210),
      const Radius.circular(22),
    );
    final mapBg = Paint()..color = const Color(0xFFE8F5FF);
    canvas.drawRRect(mapRect, mapBg);

    // Clip to map bounds
    canvas.save();
    canvas.clipRRect(mapRect);

    // Roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round;

    roadPaint.strokeWidth = 9;
    canvas.drawLine(const Offset(20, 100), Offset(size.width - 20, 100), roadPaint);
    canvas.drawLine(Offset(size.width * 0.47, 10), Offset(size.width * 0.47, 220), roadPaint);

    roadPaint.strokeWidth = 6;
    canvas.drawLine(const Offset(20, 165), Offset(size.width - 20, 165), roadPaint);
    canvas.drawLine(const Offset(90, 10), const Offset(90, 220), roadPaint);

    // Blocks
    final blockColors = [
      const Color(0xFFC8E6FF),
      const Color(0xFFB8DFFF),
    ];
    final blocks = [
      Rect.fromLTWH(28, 18, 54, 74),
      Rect.fromLTWH(98, 18, 48, 74),
      Rect.fromLTWH(size.width * 0.47 + 8, 18, 52, 74),
      Rect.fromLTWH(size.width * 0.47 + 68, 18, 50, 74),
      Rect.fromLTWH(28, 108, 54, 50),
      Rect.fromLTWH(size.width * 0.47 + 8, 108, 54, 50),
      Rect.fromLTWH(size.width * 0.47 + 68, 108, 54, 50),
      Rect.fromLTWH(28, 173, 54, 40),
      Rect.fromLTWH(98, 173, 48, 40),
      Rect.fromLTWH(size.width * 0.47 + 8, 173, 110, 40),
    ];
    for (int i = 0; i < blocks.length; i++) {
      final bp = Paint()..color = blockColors[i % 2].withValues(alpha: 0.8);
      canvas.drawRRect(RRect.fromRectAndRadius(blocks[i], const Radius.circular(6)), bp);
    }

    // Range circle around user pin (pulsing)
    final userPos = Offset(size.width * 0.62, 138);
    final rangePaint = Paint()
      ..color = const Color(0xFF4EAEFF).withValues(alpha: 0.08 + pulse * 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(userPos, 58 + pulse * 4, rangePaint);
    final rangeBorder = Paint()
      ..color = const Color(0xFF4EAEFF).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _drawDashedCircle(canvas, userPos, 58 + pulse * 4, rangeBorder);

    // Small pin 1
    _drawPin(canvas, Offset(65, 180), const Color(0xFFFF9500), 10, false);
    // Small pin 2
    _drawPin(canvas, Offset(size.width - 52, 85), const Color(0xFFFF6B6B), 9, false);
    // Main lost-pet pin
    _drawPin(canvas, Offset(size.width * 0.38, 75), const Color(0xFFFF6B6B), 18, true);
    // User pin
    _drawUserPin(canvas, userPos);

    canvas.restore();

    // ── Notification card ────────────────────────────────────────
    final cardY = size.height - 80.0;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, cardY, size.width - 40, 58),
      const Radius.circular(14),
    );
    final cardPaint = Paint()..color = Colors.white;
    final cardShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(cardRect.shift(const Offset(0, 3)), cardShadow);
    canvas.drawRRect(cardRect, cardPaint);

    final cardBorder = Paint()
      ..color = const Color(0xFF4EAEFF).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(cardRect, cardBorder);

    // Avatar circle
    final avatarPaint = Paint()..color = const Color(0xFFFFE5E5);
    canvas.drawCircle(Offset(48, cardY + 29), 14, avatarPaint);

    // Dog emoji text
    _drawEmoji(canvas, '🐕', Offset(40, cardY + 36), 13);

    // Text content
    _drawStyledText(canvas, 'Phát hiện gần bạn!',
        Offset(70, cardY + 19), 12, FontWeight.w700, const Color(0xFF1a1207));
    _drawStyledText(canvas, 'Cách bạn 350m • 5 phút trước',
        Offset(70, cardY + 37), 10, FontWeight.w400, const Color(0xFF888888));

    // Notification badge
    final badgePaint = Paint()..color = const Color(0xFFFF6B6B);
    canvas.drawCircle(Offset(size.width - 34, cardY + 17), 8, badgePaint);
    _drawStyledText(canvas, '1', Offset(size.width - 37, cardY + 23), 9,
        FontWeight.w700, Colors.white);
  }

  void _drawPin(Canvas canvas, Offset tip, Color color, double r, bool isMain) {
    final pinPaint = Paint()..color = color;
    final head = Offset(tip.dx, tip.dy - r * 1.4);
    canvas.drawCircle(head, r, pinPaint);
    final triangle = Path()
      ..moveTo(tip.dx - r * 0.5, tip.dy - r * 0.8)
      ..lineTo(tip.dx + r * 0.5, tip.dy - r * 0.8)
      ..lineTo(tip.dx, tip.dy)
      ..close();
    canvas.drawPath(triangle, pinPaint);

    if (isMain) {
      _drawEmoji(canvas, '🐾', Offset(tip.dx - r * 0.75, tip.dy - r * 1.5), r * 1.1);
    } else {
      final innerPaint = Paint()..color = Colors.white;
      canvas.drawCircle(head, r * 0.42, innerPaint);
    }
  }

  void _drawUserPin(Canvas canvas, Offset pos) {
    // Blue filled circle
    final outer = Paint()..color = const Color(0xFF4EAEFF);
    canvas.drawCircle(pos, 14, outer);
    final triangle = Path()
      ..moveTo(pos.dx - 7, pos.dy + 8)
      ..lineTo(pos.dx + 7, pos.dy + 8)
      ..lineTo(pos.dx, pos.dy + 17)
      ..close();
    canvas.drawPath(triangle, outer);
    final inner = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 6, inner);
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashCount = 24;
    const gapFraction = 0.4;
    const fullAngle = 2 * pi;
    final dashAngle = fullAngle / dashCount * (1 - gapFraction);
    final gapAngle = fullAngle / dashCount * gapFraction;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (dashAngle + gapAngle);
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          dashAngle,
        );
      canvas.drawPath(path, paint);
    }
  }

  void _drawEmoji(Canvas canvas, String emoji, Offset pos, double size) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  void _drawStyledText(Canvas canvas, String text, Offset pos, double fontSize,
      FontWeight weight, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: weight,
              color: color,
              fontFamily: 'Nunito')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => oldDelegate.animValue != animValue;
}
