import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The swinging crane at the top of the play area. Holds the next slab and
/// sweeps left<->right. Purely visual (not a physics body); it reports the
/// current horizontal drop position so the game can spawn a slab there.
class Crane extends PositionComponent {
  Crane({required this.sweepHalfWidth, required this.y});

  /// Half the horizontal sweep range, in world units.
  final double sweepHalfWidth;

  /// World-space y where the crane rides.
  @override
  final double y;

  double _t = 0;
  final double _speed = 1.4; // radians/sec of the sweep oscillation
  bool holding = true;

  /// Current world-space x of the held slab (follows the swing).
  double get dropX => sweepHalfWidth * math.sin(_t);

  /// Current world position where a dropped slab should spawn.
  Vector2 get dropPoint => Vector2(dropX, y + 2.5);

  void resume() => holding = true;

  @override
  void update(double dt) {
    super.update(dt);
    if (holding) _t += _speed * dt;
  }

  @override
  void render(Canvas canvas) {
    // Rendered in world coordinates by the game's world; the crane draws its
    // A-frame + cable + held slab + dotted guide relative to dropX.
    final x = dropX;
    final line = Paint()
      ..color = GoroColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.12;

    // A-frame gantry across the top
    canvas.drawLine(Offset(-sweepHalfWidth - 4, y), Offset(sweepHalfWidth + 4, y), line);
    // Apex + legs above the held slab
    final apex = Offset(x, y - 3.2);
    canvas.drawLine(Offset(x - 2.4, y), apex, line);
    canvas.drawLine(Offset(x + 2.4, y), apex, line);
    // Cable down to the slab
    canvas.drawLine(Offset(x, y), Offset(x, y + 2.5), line);

    if (holding) {
      // Held slab (outline style, matching the reference's empty slab)
      final slabRect = Rect.fromCenter(center: Offset(x, y + 2.5 + 1.2), width: 8, height: 2.4);
      canvas.drawRect(slabRect, Paint()..color = GoroColors.bgAlt);
      canvas.drawRect(
        slabRect,
        Paint()
          ..color = GoroColors.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.12,
      );
      // Dotted vertical drop guide
      final guide = Paint()
        ..color = GoroColors.lineSoft
        ..strokeWidth = 0.06;
      for (double gy = y + 4; gy < y + 40; gy += 1.2) {
        canvas.drawLine(Offset(x, gy), Offset(x, gy + 0.5), guide);
      }
    }
  }
}
