import 'dart:async';
import 'dart:ui';

import 'package:brick_crusher_challenge/src/components/brick_crusher_challenge.dart';
import 'package:brick_crusher_challenge/src/components/bullet.dart';
import 'package:brick_crusher_challenge/src/components/powerup.dart';
import 'package:brick_crusher_challenge/src/config.dart';
import 'package:brick_crusher_challenge/src/utils/utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Brick extends PositionComponent
    with HasGameReference<BrickBreaker>, CollisionCallbacks {
  Brick({
    required super.position, 
    required this.color,
    })
      : super(
          size: Vector2(brickWidth, brickHeight),
          anchor: Anchor.center,
          children: [RectangleHitbox()],
        );

  Color color;
  
  @override
  bool isRemoved = false;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    RectangleComponent display = RectangleComponent(
      position: Vector2(size.x / 2, size.y/ 2),
      size: Vector2(brickWidth * 0.9, brickHeight * 0.9),
      anchor: Anchor.center,
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    add(display);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if(other is Bullet){
      removeBrick();
      other.removeFromParent();
    }
  }

  void removeBrick(){
    isRemoved = true;
    removeFromParent();
    game.score.value++;

    //POWERUP DROP
    if(generateRandomNumber(1, 100) > 90){
    game.world.add(PowerUp(
      position: position, 
      type: generateRandomNumber(1, 2),
    ));
    }
  }
}