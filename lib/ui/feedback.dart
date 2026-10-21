import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Bip e vibrazione della cassa.
class ScanFeedback {
  final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<void> ok() async {
    HapticFeedback.mediumImpact();
    await _play('sounds/beep.wav');
  }

  Future<void> error() async {
    HapticFeedback.heavyImpact();
    await _play('sounds/error.wav');
  }

  Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Il suono non è essenziale.
    }
  }

  void dispose() => _player.dispose();
}
