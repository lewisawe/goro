import 'dart:async';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../world/landmarks.dart';

/// goro — Forge2D world. Phase 1 skeleton (see goro-spec.md §8).
///
/// This is the game loop + physics world. Crane, slab, tower, and camera-rig
/// components attach here in Phase 1. Gravity is tuned low so drops read as
/// deliberate and the collapse is legible.
class GoroGame extends Forge2DGame {
  GoroGame() : super(gravity: Vector2(0, 30), zoom: 10);

  /// Current tower height in meters (drives HUD + landmark reveals).
  double heightMeters = 0;
  int floors = 0;

  /// Callbacks the UI layer listens to.
  void Function(Landmark landmark)? onLandmarkPassed;
  void Function()? onCollapse;

  Landmark? _lastAnnounced;

  @override
  Color backgroundColor() => const Color(0xFFF7F8F9); // GoroColors.bg

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Phase 1 TODO: add Crane, ground body, camera rig.
    // Phase 2 TODO: add band backgrounds + skyline.
  }

  /// Called by tower logic after a slab settles. Updates height and fires
  /// a landmark reveal when a new threshold is crossed.
  void registerFloorSettled(int floorCount, double meters) {
    floors = floorCount;
    heightMeters = meters;
    final passed = lastPassed(meters);
    if (passed != null && passed != _lastAnnounced) {
      _lastAnnounced = passed;
      onLandmarkPassed?.call(passed);
    }
  }

  void triggerCollapse() => onCollapse?.call();
}
