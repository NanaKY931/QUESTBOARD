import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class VibrationService {
  static Future<void> playLevelUpHaptic() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (await Vibration.hasCustomVibrationsSupport() == true) {
          await Vibration.vibrate(duration: 100, amplitude: 50);
        } else {
          await Vibration.vibrate(duration: 100);
        }
      }
    } catch (e) {
      // Vibration not supported on this platform — safe to ignore
      debugPrint('VibrationService.playLevelUpHaptic: $e');
    }
  }

  static Future<void> playDamageHaptic() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (await Vibration.hasCustomVibrationsSupport() == true) {
          await Vibration.vibrate(
            pattern: [0, 500, 100, 500],
            intensities: [0, 255, 0, 255],
          );
        } else {
          await Vibration.vibrate(duration: 1000);
        }
      }
    } catch (e) {
      // Vibration not supported on this platform — safe to ignore
      debugPrint('VibrationService.playDamageHaptic: $e');
    }
  }
}
