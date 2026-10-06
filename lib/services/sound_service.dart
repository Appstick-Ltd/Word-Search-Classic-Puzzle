import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

abstract final class SoundService {
  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _victoryPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static bool get isEnabled => StorageService.getSoundEnabled();

  static Future<void> playTap() async {
    if (!isEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/tap.wav'), volume: 0.85);
    } catch (e) {
      debugPrint('Error playing tap sound: $e');
    }
  }

  static Future<void> playSelect() async {
    if (!isEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/select.wav'), volume: 0.7);
    } catch (e) {
      debugPrint('Error playing select sound: $e');
    }
  }

  static Future<void> playWordFound() async {
    if (!isEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/word_found.wav'), volume: 1.0);
    } catch (e) {
      debugPrint('Error playing word found sound: $e');
    }
  }

  static Future<void> playVictory() async {
    if (!isEnabled) return;
    try {
      await _victoryPlayer.stop();
      await _victoryPlayer.play(AssetSource('audio/victory.wav'), volume: 1.0);
    } catch (e) {
      debugPrint('Error playing victory sound: $e');
    }
  }

  static Future<void> playWrong() async {
    if (!isEnabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/wrong.wav'), volume: 0.65);
    } catch (e) {
      debugPrint('Error playing wrong sound: $e');
    }
  }
}
