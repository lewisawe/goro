import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// One stacked floor. A dynamic Box2D body (Box2D v3 API via forge2d 0.15)
/// rendered as a slate slab with window rectangles (goro-spec.md §4b).
class Slab extends BodyComponent {
  Slab({required Vector2 spawn, this.width = 8, this.height = 2.4})
      : super(
          renderBody: false,
          bodyDef: BodyDef(type: BodyType.dynamic, position: spawn),
          shapeSpecs: [
            ShapeSpec(
              Polygon.box(width / 2, height / 2),
              ShapeDef(
                density: 1.0,
                material: SurfaceMaterial(friction: 0.8, restitution: 0.0),
              ),
            ),
          ],
        );

  final double width;
  final double height;

  @override
  void render(Canvas canvas) {
    final w = width;
    final h = height;
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    canvas.drawRect(rect, Paint()..color = GoroColors.slab);
    // Top-face shade (isometric hint)
    canvas.drawRect(
      Rect.fromLTWH(-w / 2, -h / 2, w, h * 0.18),
      Paint()..color = GoroColors.slabShade,
    );
    // Outline
    canvas.drawRect(
      rect,
      Paint()
        ..color = GoroColors.slabShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.08,
    );
    // Three windows
    const cols = 3;
    final ww = w * 0.16;
    final wh = h * 0.32;
    final gap = (w - cols * ww) / (cols + 1);
    for (var i = 0; i < cols; i++) {
      final x = -w / 2 + gap + i * (ww + gap);
      canvas.drawRect(
        Rect.fromLTWH(x, -wh / 2, ww, wh),
        Paint()..color = GoroColors.slabWindow,
      );
    }
  }
}
