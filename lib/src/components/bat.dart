import 'dart:async';
import 'dart:ui';

import 'package:brick_crusher_challenge/src/components/brick_crusher_challenge.dart';
import 'package:brick_crusher_challenge/src/components/bullet.dart';
import 'package:brick_crusher_challenge/src/config.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';

enum BatState { idle, moveLeft, moveRight }

class Bat extends PositionComponent with HasGameReference<BrickBreaker> {
  Bat({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
          children: [RectangleHitbox()],
        );

  BatState batState = BatState.idle;

  final Radius cornerRadius;

  final _paint = Paint()
    ..color = batColor
    ..style = PaintingStyle.fill;

  //POWER UPS
  List<int> powerUps = [];

  //1 - SHOOTING TIMER
  late TimerComponent timer;

  @override
  FutureOr<void> onLoad() {
    addShootingTimer();
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (batState == BatState.moveLeft) {
      moveBy(-batStep.toDouble() * dt);
    } else if (batState == BatState.moveRight) {
      moveBy(batStep.toDouble() * dt);
    }

    checkPowerUps();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size.toSize(), cornerRadius),
        _paint);
  }

  void moveBy(double dx) {
    add(MoveToEffect(
        Vector2((position.x + (dx)).clamp(0, game.width), position.y),
        EffectController(duration: 0.1)));
  }

  //POWER UP ADD REMOVE
  void addPowerUp(int powerUp) {
    powerUps.add(powerUp);

    Duration delayDuration = const Duration(seconds: 3);
    Future.delayed(delayDuration, () {
      powerUps.remove(powerUp);
    });
  }

  //POWER UPS CHECK
  void checkPowerUps() {
    // 1 - SHOOTING START/END
    if (powerUps.contains(1)) {
      if (!timer.timer.isRunning()) {
        timer.timer.start();
      }
    } else {
      if (timer.timer.isRunning()) {
        timer.timer.stop();
      }
    }

    // 2 - WIDTH INCREASE
    if (powerUps.contains(2)) {
      size.x *= 1.1;
      powerUps.remove(2);
    }
  }

  //SHOOTING FIRE RATE TIMER
  void addShootingTimer() {
    timer = TimerComponent(
      period: 0.5,
      repeat: true,
      onTick: () => shoot(),
    );

    add(timer);
  }

  //SHOOTING LOGIC
  void shoot() {
    if (soundsPlay) {
      FlameAudio.play('shoot.wav', volume: soundsVolume);
    }
    game.world.addAll([
      Bullet(position: Vector2(position.x - size.x / 2, position.y)),
      Bullet(position: Vector2(position.x + size.x / 2, position.y))
    ]);
  }
}
