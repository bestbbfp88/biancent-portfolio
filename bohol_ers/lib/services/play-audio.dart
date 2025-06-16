  import 'package:audioplayers/audioplayers.dart';

class audioPlayer {
  static final audioPlayer _instance = audioPlayer._internal();
  factory audioPlayer() => _instance;

  final AudioPlayer _ringtonePlayer = AudioPlayer();

  audioPlayer._internal();

  Future<void> playRingtone() async {
    try {
      await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
      await _ringtonePlayer.setVolume(1.0);
      await _ringtonePlayer.play(AssetSource('audio/ringtone.mp3'));
      print("🔊 Emergency sound playing in loop.");
    } catch (e) {
      print("❌ Error playing emergency sound: $e");
    }
  }

  Future<void> stopRingtone() async {
    try {
      print("🔇 Emergency sound stopped.");
      await _ringtonePlayer.stop();
      await _ringtonePlayer.release();
    } catch (e) {
      print("❌ Error stopping emergency sound: $e");
    }
  }
}

