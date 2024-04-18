import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager extends Component{

late AudioPool audioBallCollision;
late AudioPool audioBatShoot;
late AudioPool audioPowerUp;

@override
  FutureOr<void> onLoad() async {
    super.onLoad();
    audioBallCollision = await FlameAudio.createPool(
      'hit.wav',
      minPlayers: 1,
      maxPlayers: 4,
    );

    audioBatShoot = await FlameAudio.createPool(
      'shoot.wav',
      minPlayers: 1,
      maxPlayers: 4,
    );

    audioPowerUp = await FlameAudio.createPool(
      'powerUp.wav',
      minPlayers: 1,
      maxPlayers: 4,
    );
  }
}