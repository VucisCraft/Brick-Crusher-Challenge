import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends PositionComponent {
  Bullet({
    required super.position,
  }) : super(anchor: Anchor.center);

  final Vector2 velocity = Vector2(0, -500);

  @override
  FutureOr<void> onLoad() {
    //debugMode = true;

    CircleComponent test = CircleComponent(
      radius: 4,
      anchor: Anchor.center,
      paint: Paint()
        ..color = const Color.fromARGB(255, 226, 11, 11)
        ..style = PaintingStyle.fill,
    );
    add(test);

    add(CircleHitbox(radius: 4, anchor: Anchor.center));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if (position.y < 0) {
      removeFromParent();
    }
  }
}
