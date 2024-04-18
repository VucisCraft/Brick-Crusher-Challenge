
import 'package:brick_crusher_challenge/src/components/brick_crusher_challenge.dart';
import 'package:brick_crusher_challenge/src/components/components.dart';
import 'package:brick_crusher_challenge/src/config.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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
    //INITIAL BALL MOVEMENT VELOCITY
    velocity.setFrom(Vector2(randomNumber * 1, -5));
    //INCREASE BALL SPEED PER LEVEL VALUE
    speed = 1 + (game.level.value.toDouble() / 4);
    //START BALL MOVEMENT
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

    if(other is PlayArea){
      playCollisionSound();
      reflectFromPlayArea(intersectionPoints);
      ballState = BallState.release;
      return;
    } else if (other is Bat){
      playCollisionSound();
      reflectFromBat(intersectionPoints, other);
      ballState = BallState.release;
      return;
    } else if (other is Brick) {  
      playCollisionSound();
      other.removeBrick();
      reflectFromBrick(intersectionPoints);
      ballState = BallState.release;
      return;
    }else{
      ballState = BallState.release;
    }
  }

   @override
  void onCollisionEnd(PositionComponent other) {
    if(other is PlayArea){
      if(!testMode){
        //GAME OVER BALL Y POSITION CHECK
        if(position.y > game.height){
          add(RemoveEffect(
                delay: 0.35,
                onComplete: () {
                    game.playState = PlayState.gameOver;
                },
            ));
        }

        //CHECK IF COLLIDED AT THE END OF COLLISION
        if(position.x <= 0 || position.x >= game.width){
          velocity.x *= -1;
        }
        if(position.y <= 0){
          velocity.y *= -1;
        }
      }
    }
    super.onCollisionEnd(other);
  }
  

  //BALL COLLISION SOUND
  playCollisionSound(){
    if(soundsPlay){
      FlameAudio.play('hit.wav', volume: soundsVolume);
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
  
  void reflectFromPlayArea(Set<Vector2> intersectionPoints) {
    var isTopHit = false;
    var isBottomHit = false;
    var isLeftHit = false;
    var isRightHit = false;

    for(Vector2 intersectionPoint in intersectionPoints){
      if(intersectionPoint.y <= 0){
        isTopHit = true;
      }

      if(intersectionPoint.y >= game.height){
        isBottomHit = true;
      }

      if(intersectionPoint.x <= 0){
        isLeftHit = true;
      }

      if(intersectionPoint.x >= game.width){
        isRightHit = true;
      }
    }

    if (isTopHit || (isBottomHit && testMode)) {
      velocity.y *= -1;
    }
    if (isLeftHit || isRightHit) {
      velocity.x *= -1;
    }
  }
}