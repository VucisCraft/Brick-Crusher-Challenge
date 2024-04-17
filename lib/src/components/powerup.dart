import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:brick_crusher_challenge/src/components/components.dart';
import 'package:brick_crusher_challenge/src/config.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class PowerUp extends PositionComponent with CollisionCallbacks {
  PowerUp({
    required super.position,
    required this.type
    }): super(
      anchor: Anchor.center
      );
  

  final int type;
  final Vector2 velocity = Vector2(0, 500);

  @override
  FutureOr<void> onLoad() {
    CircleComponent test = CircleComponent(
      radius: 20,
      anchor: Anchor.center,
      paint: Paint()
    ..color = const Color.fromARGB(255, 12, 175, 25)
    ..style = PaintingStyle.fill,
    );
    add(test);

    add(CircleHitbox(
      radius: 20,
      anchor: Anchor.center
    ));

    //ADD POWER UP TYPE NUMBER
    final regular = TextPaint(style: const TextStyle(fontSize: powerUpTextSize));

    add(TextComponent(
        text: type.toString(),
        textRenderer: regular,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2)));


    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if(position.y > gameHeight){
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if(other is Bat) {
      //POWER UP ADD
      if(soundsPlay) {
        FlameAudio.play('powerUp.wav', volume: soundsVolume);
      }
      other.addPowerUp(type);
      removeFromParent();
    }
  }
}