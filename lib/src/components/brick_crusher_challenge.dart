import 'dart:async';

import 'package:brick_crusher_challenge/src/components/components.dart';
import 'package:brick_crusher_challenge/src/config.dart';
import 'package:brick_crusher_challenge/src/managers/audio_manager.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PlayState { welcome, playing, gameOver, won, nextLevel }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector, PanDetector {
  BrickBreaker()
      : super(
            camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ));

  double get width => size.x;
  double get height => size.y;

  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
      case PlayState.nextLevel:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
        overlays.remove(PlayState.nextLevel.name);
    }
  }

  //AUDIO
  AudioManager audioManager = AudioManager();

  //MOVEMENT
  Vector2? _pointerStartPosition;

  //GAME DATA
  final ValueNotifier<int> level = ValueNotifier(1);
  final ValueNotifier<int> score = ValueNotifier(0);

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    //LOAD AUDIO
    if (soundsPlay) {
      add(audioManager);
    }

    //FPS COUNTER
    
      final regular = TextPaint(
          style: const TextStyle(
        fontSize: 14.0, // Change the font size here
        color: Color(0xFF333333),
      ));

      add(FpsTextComponent(
        position: Vector2(gameWidth - 20, 10),
        anchor: Anchor.topRight,
        textRenderer: regular,
      ));
    

    camera.viewfinder.anchor = Anchor.topLeft;
    playState = PlayState.welcome;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (playState == PlayState.playing) {
      if (world.children.query<Brick>().isEmpty) {
        playState = PlayState.nextLevel;
        world.removeAll(world.children);
      }
    }
  }

  void startGame() {
    level.value = 1;
    buildLevel();
  }

  void nextLevel() {
    level.value += 1;
    buildLevel();
  }

  void buildLevel() {
    world.add(PlayArea());

    score.value = 0;

    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());

    playState = PlayState.playing;

    world.add(Ball(
      radius: ballRadius,
      position: size / 2,
    ));

    world.add(Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(width / 2, height * 0.95)));

    //LEVEL BRICK GENERATION
    int column = level.value > 10 ? 10 : level.value;
    world.addAll([
      for (var i = 0; i < 10; i++)
        for (var j = 1; j <= column; j++)
          Brick(
            position: Vector2(
              (i + 0.5) * brickWidth,
              (j + 2.0) * brickHeight,
            ),
            color: brickColor,
          ),
    ]);
  }

  @override
  void onTap() {
    super.onTap();
    if (playState == PlayState.welcome) {
      startGame();
    }
    if (playState == PlayState.nextLevel) {
      nextLevel();
    }
    if (playState == PlayState.gameOver) {
      buildLevel();
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    List<Bat> bat = world.children.query<Bat>();

    if (bat.isNotEmpty) {
      if (isLeftKeyPressed) {
        bat.first.batState = BatState.moveLeft;
      } else if (isRightKeyPressed) {
        bat.first.batState = BatState.moveRight;
      } else {
        bat.first.batState = BatState.idle;
      }
    }

    return KeyEventResult.handled;
  }

  //MOVEMENT LOGIC
  @override
  void onPanStart(DragStartInfo info) {
    super.onPanStart(info);
    _pointerStartPosition = info.eventPosition.global;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    super.onPanUpdate(info);
    final pointerCurrentPosition = info.eventPosition.global;

    var delta = pointerCurrentPosition.x - _pointerStartPosition!.x;

    List<Bat> bat = world.children.query<Bat>();

    if (playState == PlayState.playing) {
      //bat.first.position.x = (bat.first.position.x + delta).clamp(0, gameWidth);
      bat.first.moveBy(delta * 5);
      _pointerStartPosition = pointerCurrentPosition;
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    super.onPanEnd(info);
    _pointerStartPosition = null;
  }

  @override
  void onPanCancel() {
    super.onPanCancel();
    _pointerStartPosition = null;
  }

  @override
  Color backgroundColor() => bgColor;
}
