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
  GoroGame() : super(gravity: Vector2(0, 60), metersToPixels: 16);

  // World is in meters, y grows DOWN (Forge2D default). Ground near origin;
  // the tower grows in the -y direction (upward on screen).
  static const double _groundY = 0;
  static const double _slabHeight = 1.4;
  static const double _slabWidth = 4.2; // slightly smaller, more refined
  // Compressed narrative scale: each floor covers more "altitude" so a normal
  // session climbs through all bands (city -> clouds -> space) in ~25-30
  // floors. Reaching space in a run is the payoff; realistic 3.5m/floor would
  // need thousands of floors to leave the city.
  static const double _metersPerFloor = 140;

  late final Crane crane;
  final List<Slab> _slabs = [];
  Slab? _fallingSlab;

  double heightMeters = 0;
  int floors = 0;
  bool gameOver = false;

  /// Game phase state machine:
  /// ready   — crane holding, waiting for a tap to drop
  /// falling — a slab is dropping; wait for it to settle or fail
  /// rising  — slab stable; crane+camera rising to the next height
  _Phase _phase = _Phase.ready;

  /// The world-y the camera is easing toward (the authoritative height).
  double _cameraTargetY = 0;

  /// HUD state — updated only on real events, listened to by a small
  /// ValueListenableBuilder so the GameWidget itself is never rebuilt
  /// (rebuilding GameWidget on setState was causing whole-screen stutter).
  final ValueNotifier<GoroStats> stats =
      ValueNotifier(const GoroStats(0, 0, Stability.steady, false, 0));

  /// UI callbacks.
  void Function(Landmark landmark)? onLandmarkPassed;
  void Function()? onCollapse;

  Landmark? _lastAnnounced;

  void _publishStats() {
    stats.value = GoroStats(
      heightMeters,
      floors,
      stability,
      gameOver,
      skyDarkness(heightMeters),
    );
  }

  @override
  Color backgroundColor() => const Color(0x00000000); // transparent; SkyBackground shows through

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Base platform.
    final ground = _Ground(y: _groundY, halfWidth: 12);
    world.add(ground);

    // Crane. Its y is driven by the camera each frame (locked together), so
    // it can never separate into a "double image".
    crane = Crane(
      sweepHalfWidth: 5.5,
      sweepSpeed: 3.0,
      y: _craneYForFloors(0),
      slabWidth: _slabWidth,
      slabHeight: _slabHeight,
    );
    world.add(crane);

    _cameraTargetY = _craneYForFloors(0) + 4;
    camera.viewfinder.position = Vector2(0, _cameraTargetY);
    _phase = _Phase.ready;
  }

  // Crane hovers this many meters above the current tower top.
  static const double _craneGap = 9;

  double _towerTopY(int floorCount) => _groundY - floorCount * _slabHeight;
  double _craneYForFloors(int floorCount) => _towerTopY(floorCount) - _craneGap;

  /// Called on tap: drop the currently held slab. Only allowed when ready.
  void dropSlab() {
    if (gameOver || _phase != _Phase.ready) return;
    final slab = Slab(
      spawn: crane.dropPoint,
      width: _slabWidth,
      height: _slabHeight,
    );
    _fallingSlab = slab;
    world.add(slab);
    crane.holding = false;
    _phase = _Phase.falling;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;

    // Ease the camera toward its target (frame-rate independent).
    final cur = camera.viewfinder.position;
    final ny = cur.y + (_cameraTargetY - cur.y) * (10 * dt).clamp(0.0, 1.0);
    camera.viewfinder.position = Vector2(0, ny);

    // LOCK the crane to the camera every frame — a fixed offset above the
    // view center. This guarantees the crane and camera move as one, which
    // removes the "crane appears twice / jumps" double-image.
    crane.craneY = ny - 4;

    switch (_phase) {
      case _Phase.falling:
        _updateFalling();
      case _Phase.rising:
        _updateRising(ny);
      case _Phase.ready:
        break;
    }

    _publishStats();
  }

  void _updateFalling() {
    final falling = _fallingSlab;
    if (falling == null || !falling.isMounted || !falling.isLoaded) return;

    // Fail immediately if this slab (or any) tips past the lean threshold.
    if (_isCollapsing()) {
      _triggerCollapse();
      return;
    }

    // Once the slab is stable → it's a new floor. Rise to the next height.
    final v = falling.body.linearVelocity.length;
    final w = falling.body.angularVelocity.abs();
    if (v < 0.2 && w < 0.2) {
      _slabs.add(falling);
      _fallingSlab = null;
      floors = _slabs.length;
      heightMeters = floors * _metersPerFloor;

      final passed = lastPassed(heightMeters);
      if (passed != null && passed != _lastAnnounced) {
        _lastAnnounced = passed;
        onLandmarkPassed?.call(passed);
      }

      // Set the new camera target; crane rides with the camera. Only after we
      // arrive (rising done) do we spawn the next slab.
      _cameraTargetY = _craneYForFloors(floors) + 4;
      _phase = _Phase.rising;
    }
  }

  void _updateRising(double currentCamY) {
    // Keep checking for collapse while rising.
    if (_isCollapsing()) {
      _triggerCollapse();
      return;
    }
    // Arrived at the new height? Hand the next slab to the crane.
    if ((currentCamY - _cameraTargetY).abs() < 0.3) {
      crane.resume(); // holding = true, next slab appears at the new height
      _phase = _Phase.ready;
    }
  }

  bool _isCollapsing() {
    for (final s in _slabs) {
      if (!s.isMounted || !s.isLoaded) continue;
      // Tighter lean tolerance: ~20° tips the tower (was ~34°).
      if (s.body.angle.abs() > 0.35) return true;
    }
    if (_slabs.isNotEmpty) {
      final top = _slabs.last;
      // Tighter drift: top floor can't wander more than ~6m off center.
      if (top.isMounted && top.isLoaded && top.body.position.x.abs() > 6) {
        return true;
      }
    }
    return false;
  }

  void _triggerCollapse() {
    if (gameOver) return;
    gameOver = true;
    onCollapse?.call();
    _publishStats();
  }

  /// Current lean of the tower top (0 = plumb) for the stability meter.
  /// Tightened so the meter warns earlier and matches the stricter collapse.
  Stability get stability {
    if (_slabs.isEmpty) return Stability.steady;
    final top = _slabs.last;
    if (!top.isMounted || !top.isLoaded) return Stability.steady;
    final a = top.body.angle.abs();
    final drift = top.body.position.x.abs();
    if (a > 0.22 || drift > 4) return Stability.critical;
    if (a > 0.08 || drift > 2) return Stability.wobbling;
    return Stability.steady;
  }
}

/// Phase of the drop→settle→rise loop.
enum _Phase { ready, falling, rising }

/// Immutable HUD snapshot with value equality, so the ValueNotifier only
/// notifies (and the HUD only repaints) when something actually changed.
class GoroStats {
  const GoroStats(this.heightMeters, this.floors, this.stability, this.gameOver,
      this.skyDarkness);
  final double heightMeters;
  final int floors;
  final Stability stability;
  final bool gameOver;
  final double skyDarkness;

  @override
  bool operator ==(Object other) =>
      other is GoroStats &&
      other.heightMeters == heightMeters &&
      other.floors == floors &&
      other.stability == stability &&
      other.gameOver == gameOver &&
      other.skyDarkness == skyDarkness;

  @override
  int get hashCode =>
      Object.hash(heightMeters, floors, stability, gameOver, skyDarkness);
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
