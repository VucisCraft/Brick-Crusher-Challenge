import 'package:brick_crusher_challenge/src/components/brick_crusher_challenge.dart';
import 'package:brick_crusher_challenge/src/widgets/level_card.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import 'overlay_screen.dart';
import 'score_card.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final BrickBreaker game;

  @override
  void initState() {
    super.initState();
    game = BrickBreaker();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Brick Crusher Challenge",
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientOne,
                gradientTwo,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LevelCard(level: game.level),
                        ScoreCard(score: game.score),
                      ],
                    ),
                    Expanded(
                      child: FittedBox(
                        child: SizedBox(
                          width: gameWidth,
                          height: gameHeight,
                          child: GameWidget(
                            game: game,
                            overlayBuilderMap: {
                              PlayState.welcome.name: (context, game) =>
                                  const OverlayScreen(
                                    title: 'TAP TO PLAY',
                                    subtitle: 'Use arrow keys or swipe',
                                  ),
                              PlayState.gameOver.name: (context, game) =>
                                  const OverlayScreen(
                                    title: 'GAME OVER',
                                    subtitle: 'Tap to Play Again',
                                  ),
                              PlayState.nextLevel.name: (context, game) =>
                              const OverlayScreen(
                                title: 'LEVEL COMPLETED!',
                                subtitle: 'Tap to proceed to the next level',
                              ),
                              PlayState.won.name: (context, game) =>
                                  const OverlayScreen(
                                    title: 'YOU WON!',
                                    subtitle: 'Tap to Play Again',
                                  ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}