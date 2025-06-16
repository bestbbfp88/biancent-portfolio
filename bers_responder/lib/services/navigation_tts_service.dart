import 'package:flutter_tts/flutter_tts.dart';

class NavigationTTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _hasSpoken = false;

  NavigationTTSService() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
  }

  FlutterTts get flutterTts => _flutterTts;

  void reset() {
    _hasSpoken = false;
  }

  Future<void> speakNavigationInstructions(Map<String, dynamic> route) async {
    if (_hasSpoken) return;

    if (route['legs'] == null || route['legs'].isEmpty) {
      print("⚠️ No route legs found.");
      return;
    }

    final List legs = route['legs'];
    final List steps = legs.first['steps'] ?? [];

    if (steps.isEmpty) {
      print("⚠️ No steps found in this leg.");
      return;
    }

    int spokenCount = 0;
    for (var step in steps) {
      final instruction = step['instruction'] ?? '';
      final distance = step['distance']; // distance in meters

      if (instruction.isNotEmpty && spokenCount < 3) {
        final distanceText = _formatDistance(distance);
        final speechText = distanceText.isNotEmpty
            ? "In $distanceText, $instruction"
            : instruction;

        await _flutterTts.speak(speechText);
        spokenCount++;

        await Future.delayed(const Duration(seconds: 4));
      }
    }

    _hasSpoken = true;
  }

  String _formatDistance(dynamic meters) {
    if (meters == null) return '';
    final value = meters.toDouble();
    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)} kilometers";
    } else {
      return "${value.round()} meters";
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _hasSpoken = false;
  }
}
