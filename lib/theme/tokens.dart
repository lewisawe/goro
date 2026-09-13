import 'package:flutter/material.dart';

/// goro design tokens — locked art direction (see goro-spec.md §4b).
/// Minimalist architectural / blueprint aesthetic.
class GoroColors {
  GoroColors._();

  static const bg = Color(0xFFF7F8F9); // off-white ground
  static const bgAlt = Color(0xFFFFFFFF); // cards / slab face highlight
  static const line = Color(0xFF1F2933); // near-black line work
  static const lineSoft = Color(0xFFC7CDD4); // faint rules, skyline, ticks
  static const slab = Color(0xFF8A94A6); // floor body (slate-blue-gray)
  static const slabShade = Color(0xFF6B7280); // slab top-face / side shading
  static const slabWindow = Color(0xFFE8EBEE); // window rectangles
  static const accent = Color(0xFF0F9D8A); // teal — STEADY / primary CTA only
  static const warn = Color(0xFFE0A458); // amber — stability drifting
  static const danger = Color(0xFFD0555B); // red — critical lean
  static const textStrong = Color(0xFF1F2933);
  static const textMuted = Color(0xFF8A94A6);

  // Dark inversion for stratosphere/space bands.
  static const bgSpace = Color(0xFF0B0F14);
  static const lineSpace = Color(0xFFDDE3EA);
}

/// Stability state drives the meter color. Teal is reserved for [steady].
enum Stability { steady, wobbling, critical }

extension StabilityColor on Stability {
  Color get color => switch (this) {
        Stability.steady => GoroColors.accent,
        Stability.wobbling => GoroColors.warn,
        Stability.critical => GoroColors.danger,
      };

  String get label => switch (this) {
        Stability.steady => 'STEADY',
        Stability.wobbling => 'WOBBLING',
        Stability.critical => 'CRITICAL',
      };
}
