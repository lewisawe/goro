import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../world/landmarks.dart';
import 'crane.dart';
import 'slab.dart';

/// goro core loop (Phase 1). A Forge2D world with a ground, a swinging crane,
/// and a growing stack of slabs. Drop timing + physics determine the tower's
/// lean and eventual collapse. Height is tracked in meters and floors.
class GoroGame extends Forge2DGame {
  GoroGame()
      : super(
          gravity: Vector2(0, 24),
          camera: CameraComponent.withFixedResolution(width: 48, height: 96),
        );

  static const double _groundY = 90;
  static const double _slabHeight = 2.4;
  static const double _metersPerFloor = 3.5; // narrative scale

  late final Crane crane;
  final List<Slab> _slabs = [];
  Slab? _fallingSlab;

  double heightMeters = 0;
  int floors = 0;
  bool gameOver = false;

  /// UI callbacks.
  void Function(Landmark landmark)? onLandmarkPassed;
  void Function()? onCollapse;
  void Function()? onStateChanged;

  Landmark? _lastAnnounced;

  @override
  Color backgroundColor() => GoroColors.bg;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Ground body — a static floor the first slab rests on.
    final ground = _Ground(y: _groundY, halfWidth: 40);
    world.add(ground);

    // Crane sweeps above the base.
    crane = Crane(sweepHalfWidth: 14, y: _groundY - 30);
    world.add(crane);

    // Point the camera at the base to start.
    camera.moveTo(Vector2(0, _groundY - 20));
  }

  /// Called on tap: drop the currently held slab from the crane's position.
  void dropSlab() {
    if (gameOver || !crane.holding || _fallingSlab != null) return;
    final slab = Slab(spawn: crane.dropPoint);
    _fallingSlab = slab;
    world.add(slab);
    crane.holding = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;

    final falling = _fallingSlab;
    if (falling != null && falling.isMounted) {
      // Wait for the dropped slab to settle (velocity near zero).
      final v = falling.body.linearVelocity.length;
      final w = falling.body.angularVelocity.abs();
      if (v < 0.15 && w < 0.15) {
        _settleSlab(falling);
      }
    }

    _checkCollapse();
  }

  void _settleSlab(Slab slab) {
    _slabs.add(slab);
    _fallingSlab = null;
    floors = _slabs.length;
    heightMeters = floors * _metersPerFloor;

    // Raise the camera to keep the top of the tower in view.
    final topY = _groundY - floors * _slabHeight;
    camera.moveTo(Vector2(0, topY + 20));

    // Landmark reveal on threshold cross.
    final passed = lastPassed(heightMeters);
    if (passed != null && passed != _lastAnnounced) {
      _lastAnnounced = passed;
      onLandmarkPassed?.call(passed);
    }

    crane.resume();
    onStateChanged?.call();
  }

  void _checkCollapse() {
    if (_slabs.isEmpty) return;
    // Collapse if the top slab has drifted too far horizontally from the base,
    // or any settled slab tipped past a lean threshold.
    for (final s in _slabs) {
      if (!s.isMounted) continue;
      final angle = s.body.angle.abs();
      if (angle > 0.6) {
        _triggerCollapse();
        return;
      }
    }
    final top = _slabs.last;
    if (top.isMounted && top.body.position.x.abs() > 20) {
      _triggerCollapse();
    }
  }

  void _triggerCollapse() {
    if (gameOver) return;
    gameOver = true;
    onCollapse?.call();
    onStateChanged?.call();
  }

  /// Current lean of the tower top (0 = plumb) for the stability meter.
  Stability get stability {
    if (_slabs.isEmpty) return Stability.steady;
    final top = _slabs.last;
    if (!top.isMounted) return Stability.steady;
    final a = top.body.angle.abs();
    final drift = top.body.position.x.abs();
    if (a > 0.35 || drift > 10) return Stability.critical;
    if (a > 0.15 || drift > 5) return Stability.wobbling;
    return Stability.steady;
  }
}

/// Static ground the tower is built on.
class _Ground extends BodyComponent {
  _Ground({required double y, required double halfWidth})
      : _y = y,
        _halfWidth = halfWidth,
        super(
          renderBody: false,
          bodyDef: BodyDef(type: BodyType.static, position: Vector2.zero()),
          shapeSpecs: [
            ShapeSpec(
              Polygon.offsetBox(halfWidth, 2, center: Vector2(0, y + 2)),
              ShapeDef(material: SurfaceMaterial(friction: 0.9)),
            ),
          ],
        );

  final double _y;
  final double _halfWidth;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(-_halfWidth, _y, _halfWidth * 2, 4),
      Paint()..color = GoroColors.lineSoft,
    );
  }
}
