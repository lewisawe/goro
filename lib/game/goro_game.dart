import 'dart:async';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../world/landmarks.dart';
import 'crane.dart';
import 'slab.dart';

/// goro core loop (Phase 1). A Forge2D world with a ground, a swinging crane,
/// and a growing stack of slabs. Uses the default Forge2D viewfinder
/// (metersToPixels), coordinates kept small (meters) as Box2D expects.
class GoroGame extends Forge2DGame {
  GoroGame() : super(gravity: Vector2(0, 24), metersToPixels: 16);

  // World is in meters, y grows DOWN (Forge2D default). Ground near origin;
  // the tower grows in the -y direction (upward on screen).
  static const double _groundY = 0;
  static const double _slabHeight = 1.4;
  static const double _slabWidth = 4.0;
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

    // Ground body at origin.
    final ground = _Ground(y: _groundY, halfWidth: 20);
    world.add(ground);

    // Crane hovers a fixed gap above the current tower top.
    crane = Crane(
      sweepHalfWidth: 6,
      y: _craneYForFloors(0),
      slabWidth: _slabWidth,
      slabHeight: _slabHeight,
    );
    world.add(crane);

    _focusCamera(instant: true);
  }

  // Crane hovers this many meters above the current tower top.
  static const double _craneGap = 9;

  double _towerTopY(int floorCount) => _groundY - floorCount * _slabHeight;
  double _craneYForFloors(int floorCount) => _towerTopY(floorCount) - _craneGap;

  /// Frame the crane and the tower top together.
  void _focusCamera({bool instant = false}) {
    // Look at a point a little below the crane so both crane and the growing
    // top are comfortably in view.
    final target = Vector2(0, crane.craneY + 4);
    camera.moveTo(target);
  }

  /// Called on tap: drop the currently held slab from the crane's position.
  void dropSlab() {
    if (gameOver || !crane.holding || _fallingSlab != null) return;
    final slab = Slab(
      spawn: crane.dropPoint,
      width: _slabWidth,
      height: _slabHeight,
    );
    _fallingSlab = slab;
    world.add(slab);
    crane.holding = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;

    final falling = _fallingSlab;
    if (falling != null && falling.isMounted && falling.isLoaded) {
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

    // Raise the crane above the new top, and follow with the camera.
    crane.craneY = _craneYForFloors(floors);
    _focusCamera();

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
    for (final s in _slabs) {
      if (!s.isMounted || !s.isLoaded) continue;
      if (s.body.angle.abs() > 0.6) {
        _triggerCollapse();
        return;
      }
    }
    final top = _slabs.last;
    if (top.isMounted && top.isLoaded && top.body.position.x.abs() > 12) {
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
    if (!top.isMounted || !top.isLoaded) return Stability.steady;
    final a = top.body.angle.abs();
    final drift = top.body.position.x.abs();
    if (a > 0.35 || drift > 6) return Stability.critical;
    if (a > 0.15 || drift > 3) return Stability.wobbling;
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
    // Thin ground line at the base.
    canvas.drawRect(
      Rect.fromLTWH(-_halfWidth, _y, _halfWidth * 2, 0.6),
      Paint()..color = GoroColors.lineSoft,
    );
  }
}
