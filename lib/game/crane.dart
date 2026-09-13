import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The swinging crane at the top of the play area. Holds the next slab and
/// sweeps left<->right. Purely visual (not a physics body); it reports the
/// current horizontal drop position so the game can spawn a slab there.
/// All coordinates are in meters (Forge2D world space).
class Crane extends PositionComponent {
  Crane({
    required this.sweepHalfWidth,
    required double y,
    required this.slabWidth,
    required this.slabHeight,
    double sweepSpeed = 1.2,
  })  : craneY = y,
        _speed = sweepSpeed;

  final double sweepHalfWidth;

  /// World-space y of the crane gantry. Driven by the game each frame
  /// (locked to the camera) so the crane and view never separate.
  double craneY;
  final double slabWidth;
  final double slabHeight;

  double _t = 0;
  final double _speed; // sweep oscillation rate
  bool holding = true;

  double get dropX => sweepHalfWidth * math.sin(_t);

  /// Where a dropped slab spawns (just below the crane gantry).
  Vector2 get dropPoint => Vector2(dropX, craneY + 2.2);

  void resume() => holding = true;

  @override
  void update(double dt) {
    super.update(dt);
    if (holding) _t += _speed * dt;
  }

  @override
  void render(Canvas canvas) {
    final x = dropX;
    final y = craneY;
    final line = Paint()
      ..color = GoroColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.15;

    // Horizontal gantry
    canvas.drawLine(
        Offset(-sweepHalfWidth - 2, y), Offset(sweepHalfWidth + 2, y), line);
    // A-frame apex above the held point
    final apex = Offset(x, y - 1.8);
    canvas.drawLine(Offset(x - 1.4, y), apex, line);
    canvas.drawLine(Offset(x + 1.4, y), apex, line);
    // Cable down to slab
    canvas.drawLine(Offset(x, y), Offset(x, y + 2.2 - slabHeight / 2), line);

    if (holding) {
      final slabRect = Rect.fromCenter(
          center: Offset(x, y + 2.2), width: slabWidth, height: slabHeight);
      canvas.drawRect(slabRect, Paint()..color = GoroColors.bgAlt);
      canvas.drawRect(
        slabRect,
        Paint()
          ..color = GoroColors.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.15,
      );
      // Dotted drop guide
      final guide = Paint()
        ..color = GoroColors.lineSoft
        ..strokeWidth = 0.08;
      for (double gy = y + 3; gy < y + 20; gy += 0.8) {
        canvas.drawLine(Offset(x, gy), Offset(x, gy + 0.35), guide);
      }
    }
  }
}
