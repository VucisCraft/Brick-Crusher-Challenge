import 'package:brick_crusher_challenge/src/components/brick_crusher_challenge.dart';
import 'package:brick_crusher_challenge/src/components/components.dart';
import 'package:brick_crusher_challenge/src/components/powerup.dart';
import 'package:brick_crusher_challenge/src/config.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Ball extends CircleComponent with HasGameRef<BrickBreaker> ,CollisionCallbacks {
  Ball({
    required super.position,
    required double radius,
  }) : super (
    radius: radius,
    anchor: Anchor.center,
    paint: Paint()
    ..color = ballColor
    ..style = PaintingStyle.fill,
  );

  final double randomNumber = math.Random().nextBool() ? 1 : -1;

  final Vector2 velocity = Vector2.zero();

  final CircleHitbox ballHitbox = CircleHitbox();

  //RAY CAST FILTER TO IGNORE POWER UP HITBOXES
  bool raycastFilter(ShapeHitbox hitbox) {
    if(hitbox.parent is PowerUp) return false;
    if(hitbox.parent is Ball) return false;
    return true;
  }

  @override
  Future<void> onLoad() {
    velocity.setFrom(Vector2(randomNumber * 100, -1000));
    //SCALE VELOCITY PER LEVEL VALUE
    double scale = game.level.value.toDouble() / 100;
    //SET BALL MOVEMENT SPEED INCREASE
    velocity.scale(1 + scale);

    add(ballHitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    //POSITION WHERE SHOULD MOVE THIS UPDATE
    Vector2 positionMove = position + velocity * dt;

    //CHECK FOR OBSTACLES BETWEEN CURRENT AND MOVE POSITION
    Vector2? newPosition = performRaycast(position, positionMove, velocity);

    position = newPosition!;
  }

  //RETURN MOVE POSITION OR INTERSECTION POINT IF THERE WAS OBSTACLE
  Vector2? performRaycast(Vector2 startPos, Vector2 endPosition, Vector2 direction) {
    final ray = Ray2(
        origin: startPos,
        direction: direction.normalized(),
    );

    RaycastResult<ShapeHitbox>? result = game.collisionDetection.raycast(
      ray,
      maxDistance: startPos.distanceTo(endPosition),
      hitboxFilter: raycastFilter,
    );

    if(result != null && result.hitbox != null){
      return result.intersectionPoint;
    }else {
      return endPosition;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if(other is PlayArea){
      bool flipX = false;
      bool flipY = false;
      //CHECK EACH INTERSECTION POINT TO PREVENT CORNER ISSUE
      for(Vector2 intersectionPoint in intersectionPoints){
          if(intersectionPoint.x <= 0){
            flipX = true;
          }else if(intersectionPoint.x >= game.width){
            flipX = true;
          }else if(intersectionPoint.y <= 0){
            flipY = true;
          }else if(intersectionPoint.y >= game.height){
            if(game.testMode){
              flipY = true;
            }
          }
      }

      if(flipX){
        velocity.x = -velocity.x;
      }
      if(flipY){
        velocity.y = -velocity.y;
      }

      if(!game.testMode){
        if(intersectionPoints.first.y >= game.height){
          add(RemoveEffect(
            delay: 0.35,
            onComplete: () {
                game.playState = PlayState.gameOver;
            },
          ));
        }
      }
      
    } else if (other is Bat){
      velocity.y = -velocity.y;
      velocity.x = velocity.x + (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is Brick) {
      if(!other.isRemoved){
        other.removeBrick();
        if (position.y < other.position.y - other.size.y / 2) {
          velocity.y = -velocity.y;
        } else if (position.y > other.position.y + other.size.y / 2) {
          velocity.y = -velocity.y;
        } else if (position.x < other.position.x) {
          velocity.x = -velocity.x;
        } else if (position.x > other.position.x) {
          velocity.x = -velocity.x;
        }
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if(soundsPlay){
      FlameAudio.play('hit.wav', volume: soundsVolume);
    }
  }
}