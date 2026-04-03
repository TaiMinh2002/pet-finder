import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary: Deep Forest Teal ────────────────────────────────────────────
  static const Color primary = Color(0xFF14796A);
  static const Color primaryLight = Color(0xFF1AA38F);
  static const Color primaryDark = Color(0xFF0D5A4E);
  static const Color primaryContainer = Color(0xFFD1F0EA);

  // ── CTA: Warm Amber (action, energy) ─────────────────────────────────────
  static const Color cta = Color(0xFFF97316);
  static const Color ctaLight = Color(0xFFFB923C);
  static const Color ctaDark = Color(0xFFEA6A0A);
  static const Color ctaContainer = Color(0xFFFFEDD5);

  // ── Lost: Coral Rose (urgency, care) ─────────────────────────────────────
  static const Color lost = Color(0xFFF43F5E);
  static const Color lostContainer = Color(0xFFFFF0F3);

  // ── Found: Emerald (hope, success) ───────────────────────────────────────
  static const Color found = Color(0xFF10B981);
  static const Color foundContainer = Color(0xFFD1FAE5);

  // ── Resolved: Warm Slate ─────────────────────────────────────────────────
  static const Color resolved = Color(0xFF64748B);
  static const Color resolvedContainer = Color(0xFFF1F5F9);

  // ── Surface — Warm Cream (not stark white) ───────────────────────────────
  static const Color background = Color(0xFFFEFCF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7F6);
  static const Color surfaceTeal = Color(0xFFEEF7F5);
  static const Color border = Color(0xFFE2E8E6);
  static const Color borderLight = Color(0xFFF0F4F3);
  static const Color divider = Color(0xFFF0F4F3);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A2E2A);
  static const Color textSecondary = Color(0xFF5C7A74);
  static const Color textHint = Color(0xFF9BB5B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnCta = Color(0xFFFFFFFF);

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D1B19);
  static const Color darkSurface = Color(0xFF162420);
  static const Color darkSurfaceVariant = Color(0xFF1E312D);
  static const Color darkBorder = Color(0xFF2A3D39);
  static const Color darkTextPrimary = Color(0xFFF0FAF8);
  static const Color darkTextSecondary = Color(0xFF7AADA5);

  // ── Gradients ─────────────────────────────────────────────────────────────
  /// Main brand gradient — teal sweep
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF14796A), Color(0xFF1AA38F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warm cream background — subtle warmth
  static const LinearGradient warmBackground = LinearGradient(
    colors: [Color(0xFFFEFCF8), Color(0xFFEEF7F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// CTA gradient — amber burst
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA6A0A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Lost card accent
  static const LinearGradient lostGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Found card accent
  static const LinearGradient foundGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Clay Shadow Helpers ───────────────────────────────────────────────────
  static List<BoxShadow> clayShadow({
    Color? color,
    double elevation = 1.0,
  }) {
    final base = color ?? const Color(0xFF14796A);
    return [
      // Outer drop shadow
      BoxShadow(
        color: base.withValues(alpha: 0.12 * elevation),
        blurRadius: 20 * elevation,
        offset: Offset(0, 8 * elevation),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: base.withValues(alpha: 0.06 * elevation),
        blurRadius: 6 * elevation,
        offset: Offset(0, 2 * elevation),
      ),
      // Inner highlight (top-left)
      const BoxShadow(
        color: Color(0xBBFFFFFF),
        blurRadius: 1,
        offset: Offset(-1, -1),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF14796A).withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
}
