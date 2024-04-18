
import 'package:brick_crusher_challenge/src/components/brick_crusher_challenge.dart';
import 'package:brick_crusher_challenge/src/components/components.dart';
import 'package:brick_crusher_challenge/src/config.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
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
  final CircleHitbox ballHitbox = CircleHitbox();

  //NEW MOVEMENT
  BallState ballState = BallState.ideal;
  Vector2 velocity = Vector2.zero();
  double speed = 1;

  @override
  Future<void> onLoad() {
    velocity.setFrom(Vector2(randomNumber * 1, -5));
    //SCALE VELOCITY PER LEVEL VALUE
    double scale = game.level.value.toDouble() / 4;
    //SET BALL MOVEMENT SPEED INCREASE
    velocity.scale(1 + scale);
    //RELEASE BALL
    ballState = BallState.release;

    add(ballHitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (ballState == BallState.release) {
      moveBall(dt);
    }
  }

  void moveBall(double dt) {
    position
      ..x += velocity.x  * speed
      ..y += velocity.y  * speed;
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    ballState = BallState.ideal;

    if(soundsPlay){
        FlameAudio.play('hit.wav', volume: soundsVolume);
    }

    if(other is PlayArea){
      if(intersectionPoints.length == 1){
        reflectFromPlayArea(intersectionPoints);
      } 
      ballState = BallState.release;
      return;
    } else if (other is Bat){
      reflectFromBat(intersectionPoints, other);
      ballState = BallState.release;
      return;
    } else if (other is Brick) {  
      other.removeBrick();
      reflectFromBrick(intersectionPoints);
      ballState = BallState.release;
      return;
    }else{
      ballState = BallState.release;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
     if(other is PlayArea){
      if(intersectionPoints.length != 1){
        final intersectionPointsList = intersectionPoints.toList();
        final averageX = (intersectionPointsList[0].x + intersectionPointsList[1].x) / 2;
        final averageY = (intersectionPointsList[0].y + intersectionPointsList[1].y) / 2;
        if (intersectionPointsList[0].x == intersectionPointsList[1].x ||
            intersectionPointsList[0].y == intersectionPointsList[1].y) {
          sideReflection(Vector2(averageX, averageY), other);
        } else {
          cornerReflection(other, averageX, averageY);
        }
      }
      ballState = BallState.release;
      return;
    }
    super.onCollision(intersectionPoints, other);
  }

  void reflectFromPlayArea(Set<Vector2> intersectionPoints) {
    var isTopHit = false;
    if(intersectionPoints.first.y == 0 && intersectionPoints.first.y <= position.y){
      isTopHit = true;
    }
    var isBottomHit = false;
    if(intersectionPoints.first.y == game.height && intersectionPoints.first.y >= position.y){
      isBottomHit = true;
      /*
      add(RemoveEffect(
          delay: 0.35,
          onComplete: () {
              game.playState = PlayState.gameOver;
          },
      ));
      */
    }
    var isLeftHit =  false;
    if(intersectionPoints.first.x == 0 && intersectionPoints.first.x <= position.x){
      isLeftHit = true;
    }
    var isRightHit = false;
    if(intersectionPoints.first.x == game.width && intersectionPoints.first.x >= position.x){
      isRightHit = true;
    }

    if (isTopHit || isBottomHit) {
      velocity.y *= -1;
    }
    if (isLeftHit || isRightHit) {
      velocity.x *= -1;
    }
  }

  void reflectFromBrick(Set<Vector2> intersectionPoints) {
    if(intersectionPoints.first.y < position.y && velocity.y < 0){
      velocity.y *= -1;
    }

    if(intersectionPoints.first.y > position.y && velocity.y > 0){
      velocity.y *= -1;
    }
  }

  void reflectFromBat(Set<Vector2> intersectionPoints, Bat other) {
    velocity.y *= -1;
    velocity.x += (position.x - other.position.x) * 4 / other.size.x;
  }
  
  void sideReflection( Vector2 intersectionPoints, PlayArea other) {
    final isTopHit = intersectionPoints.y == other.position.y;
    final isBottomHit = intersectionPoints.y ==
        other.position.y + other.size.y;
    final isLeftHit = intersectionPoints.x == other.position.x;
    final isRightHit = intersectionPoints.x ==
        other.position.x + other.size.x;

    if (isTopHit || isBottomHit) {
      velocity.y *= -1;
    } else if (isLeftHit || isRightHit) {
      velocity.x *= -1;
    }
  }
  
  void cornerReflection(other, double averageX, double averageY) {
    velocity *= -1;
  }
}