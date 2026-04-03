import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pet_finder/l10n/app_localizations.dart';

/// Slide 3: Community network with avatars orbiting a central paw
class CommunityPainter extends CustomPainter {
  final double animValue;
  final AppLocalizations l;
  const CommunityPainter({required this.animValue, required this.l});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.44;
    final orbitR = 92.0;
    final pulse = (sin(animValue * 2 * pi) + 1) / 2;

    // ── Orbit ring ──────────────────────────────────────────────
    final orbitPaint = Paint()
      ..color = const Color(0xFF56D49A).withValues(alpha: 0.18 + pulse * 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _drawDashedCircle(canvas, Offset(cx, cy), orbitR, orbitPaint);

    // ── Connection lines ─────────────────────────────────────────
    final linePaint = Paint()
      ..color = const Color(0xFF56D49A).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final avatarAngles = [-pi / 2, 0, pi / 2, pi]; // top, right, bottom, left
    for (final angle in avatarAngles) {
      final innerPt = Offset(cx + cos(angle) * 52, cy + sin(angle) * 52);
      final outerPt = Offset(cx + cos(angle) * (orbitR - 22), cy + sin(angle) * (orbitR - 22));
      _drawDashedLine(canvas, innerPt, outerPt, linePaint);
    }

    // ── Central paw circle ───────────────────────────────────────
    final centerBg1 = Paint()..color = const Color(0xFFE8FBF2);
    canvas.drawCircle(Offset(cx, cy), 52, centerBg1);
    final centerBg2 = Paint()..color = const Color(0xFFC8F5E0);
    canvas.drawCircle(Offset(cx, cy), 44, centerBg2);

    // Paw icon (drawn with circles)
    _drawPaw(canvas, Offset(cx, cy), 18, const Color(0xFF56D49A));

    // ── Avatars at orbit positions ───────────────────────────────
    final avatarData = [
      _AvatarData(emoji: '👩', angle: -pi / 2, badge: true),   // top
      _AvatarData(emoji: '👨', angle: 0, badge: false),         // right
      _AvatarData(emoji: '👩‍🦱', angle: pi / 2, badge: true),   // bottom
      _AvatarData(emoji: '🧓', angle: pi, badge: false),        // left
    ];

    for (final av in avatarData) {
      final pos = Offset(cx + cos(av.angle) * orbitR, cy + sin(av.angle) * orbitR);
      _drawAvatar(canvas, pos, av.emoji, av.badge);
    }

    // ── Stat cards ───────────────────────────────────────────────
    _drawStatCard(canvas, Rect.fromLTWH(16, size.height - 75.0, (size.width - 48) / 2, 58),
        '12k+', l.painterMembers);
    _drawStatCard(canvas, Rect.fromLTWH(size.width / 2 + 8, size.height - 75.0, (size.width - 48) / 2, 58),
        '94%', l.painterFound);
  }

  void _drawPaw(Canvas canvas, Offset center, double r, Color color) {
    final p = Paint()..color = color;
    // Main pad
    canvas.drawCircle(center, r * 0.6, p);
    // Toes
    canvas.drawCircle(center + Offset(-r * 0.55, -r * 0.7), r * 0.33, p);
    canvas.drawCircle(center + Offset(r * 0.55, -r * 0.7), r * 0.33, p);
    canvas.drawCircle(center + Offset(-r * 0.9, -r * 0.1), r * 0.28, p);
    canvas.drawCircle(center + Offset(r * 0.9, -r * 0.1), r * 0.28, p);
  }

  void _drawAvatar(Canvas canvas, Offset center, String emoji, bool hasBadge) {
    // Avatar background
    final bgPaint = Paint()..color = const Color(0xFFA8E6C8);
    canvas.drawCircle(center, 24, bgPaint);

    // Emoji
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 22)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center + Offset(-tp.width / 2, -tp.height / 2 + 2));

    // Badge checkmark
    if (hasBadge) {
      final badgeCenter = center + const Offset(16, -16);
      final badgePaint = Paint()..color = const Color(0xFF56D49A);
      canvas.drawCircle(badgeCenter, 9, badgePaint);

      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final checkPath = Path()
        ..moveTo(badgeCenter.dx - 4, badgeCenter.dy)
        ..lineTo(badgeCenter.dx - 1, badgeCenter.dy + 3)
        ..lineTo(badgeCenter.dx + 4, badgeCenter.dy - 3);
      canvas.drawPath(checkPath, checkPaint);
    }
  }

  void _drawStatCard(Canvas canvas, Rect rect, String value, String label) {
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(rRect.shift(const Offset(0, 3)), shadowPaint);

    final cardPaint = Paint()..color = Colors.white;
    canvas.drawRRect(rRect, cardPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF56D49A).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rRect, borderPaint);

    // Value text
    final valueTp = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Color(0xFF56D49A),
          fontFamily: 'Nunito',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    valueTp.paint(canvas, Offset(rect.center.dx - valueTp.width / 2, rect.top + 10));

    // Label text
    final labelTp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Color(0xFF888888),
          fontFamily: 'Nunito',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelTp.paint(canvas, Offset(rect.center.dx - labelTp.width / 2, rect.top + 38));
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final dist = sqrt(dx * dx + dy * dy);
    const dashLen = 4.0;
    const gapLen = 3.0;
    var drawn = 0.0;
    bool drawing = true;

    while (drawn < dist) {
      final segLen = drawing ? dashLen : gapLen;
      final t0 = drawn / dist;
      final t1 = min((drawn + segLen) / dist, 1.0);
      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + dx * t0, start.dy + dy * t0),
          Offset(start.dx + dx * t1, start.dy + dy * t1),
          paint,
        );
      }
      drawn += segLen;
      drawing = !drawing;
    }
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
        ..addArc(Rect.fromCircle(center: center, radius: radius), startAngle, dashAngle);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CommunityPainter oldDelegate) => oldDelegate.animValue != animValue;
}

class _AvatarData {
  final String emoji;
  final double angle;
  final bool badge;
  const _AvatarData({required this.emoji, required this.angle, required this.badge});
}
