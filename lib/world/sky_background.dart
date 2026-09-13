import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Altitude-driven world background: sky color, city skyline, cloud bands,
/// and stars, all interpolated by a 0..1 [darkness] value. Painted BEHIND
/// the transparent game surface (goro-spec.md §4b band progression).
class SkyBackground extends StatelessWidget {
  const SkyBackground({super.key, required this.darkness});

  /// 0 = ground/day, 1 = space/night.
  final double darkness;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _SkyPainter(darkness),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.d);
  final double d; // darkness 0..1

  // Palette anchors (light ground -> dark space), in the blueprint language.
  static const _dayTop = Color(0xFFF7F8F9); // GoroColors.bg
  static const _dayBottom = Color(0xFFEDEFF2);
  static const _spaceTop = Color(0xFF070A0F);
  static const _spaceBottom = GoroColors.bgSpace; // 0xFF0B0F14

  @override
  void paint(Canvas canvas, Size size) {
    final top = Color.lerp(_dayTop, _spaceTop, d)!;
    final bottom = Color.lerp(_dayBottom, _spaceBottom, d)!;

    // Sky gradient
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );

    // Stars fade in as we darken (only visible in the upper half of the ramp).
    final starT = ((d - 0.45) / 0.55).clamp(0.0, 1.0);
    if (starT > 0) _paintStars(canvas, size, starT);

    // Cloud bands appear mid-climb then fade before space.
    final cloudT = (1 - (d - 0.5).abs() * 2).clamp(0.0, 1.0);
    if (cloudT > 0.02) _paintClouds(canvas, size, cloudT);

    // City skyline sits at the bottom, fades as we leave the city band.
    final skylineT = (1 - d * 2.2).clamp(0.0, 1.0);
    if (skylineT > 0.02) _paintSkyline(canvas, size, skylineT);
  }

  void _paintStars(Canvas canvas, Size size, double t) {
    final rng = math.Random(42); // fixed seed = stable star field
    for (var i = 0; i < 55; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.9;
      // Mostly tiny pinpricks, a few slightly larger — subtle, not busy.
      final r = rng.nextDouble() < 0.85
          ? rng.nextDouble() * 0.6 + 0.3
          : rng.nextDouble() * 0.8 + 0.9;
      final a = (0.35 + rng.nextDouble() * 0.45) * t;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = GoroColors.lineSpace.withValues(alpha: a),
      );
    }
  }

  void _paintClouds(Canvas canvas, Size size, double t) {
    // Very subtle, thin translucent haze bands.
    const ys = [0.34, 0.56, 0.74];
    final rng = math.Random(7);
    for (final yf in ys) {
      final y = size.height * yf;
      final w = size.width * (0.45 + rng.nextDouble() * 0.35);
      final x = rng.nextDouble() * (size.width - w);
      final h = 14.0 + rng.nextDouble() * 10;
      final band = Rect.fromLTWH(x, y, w, h);
      final base = d < 0.5 ? GoroColors.lineSoft : Colors.white;
      final paint = Paint()
        ..color = base.withValues(alpha: 0.10 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRRect(
        RRect.fromRectAndRadius(band, Radius.circular(h / 2)),
        paint,
      );
    }
  }

  void _paintSkyline(Canvas canvas, Size size, double t) {
    final paint = Paint()
      ..color = GoroColors.lineSoft.withValues(alpha: 0.32 * t);
    final rng = math.Random(19);
    final baseY = size.height;
    var x = 0.0;
    while (x < size.width) {
      final w = 16 + rng.nextDouble() * 24;
      final h = 24 + rng.nextDouble() * 90; // smaller, more delicate
      canvas.drawRect(Rect.fromLTWH(x, baseY - h, w - 3, h), paint);
      x += w;
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.d != d;
}
