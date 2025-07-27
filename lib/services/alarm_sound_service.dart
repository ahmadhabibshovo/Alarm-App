import 'package:audioplayers/audioplayers.dart';

class AlarmSoundService {
  static final AlarmSoundService _instance = AlarmSoundService._internal();
  factory AlarmSoundService() => _instance;
  AlarmSoundService._internal();

  static AlarmSoundService get instance => _instance;

  AudioPlayer? _currentPlayer;

  // Available alarm sounds
  static const List<Map<String, String>> availableSounds = [
    {'name': 'Default', 'path': 'default'},
    {'name': 'Classic Alarm', 'path': 'sounds/classic_alarm.mp3'},
    {'name': 'Gentle Chime', 'path': 'sounds/gentle_chime.mp3'},
    {'name': 'Beep Beep', 'path': 'sounds/beep_beep.mp3'},
    {'name': 'Digital Alarm', 'path': 'sounds/digital_alarm.mp3'},
  ];

  Future<void> playAlarmSound(String soundPath) async {
    try {
      // Stop any currently playing sound
      await stopAlarmSound();

      _currentPlayer = AudioPlayer();

      if (soundPath.isEmpty || soundPath == 'default') {
        // For default, try to use a system notification sound
        // This will use the device's default notification/alarm sound
        print('Using default system alarm sound');

        // You can also try to play a simple tone using platform channels
        // For now, we'll just log that we're using the default sound
        // The notification service will handle the actual sound through the system
        return;
      }

      // Try to play the specified sound
      if (soundPath.startsWith('sounds/')) {
        await _currentPlayer!.play(AssetSource(soundPath));
      } else {
        await _currentPlayer!.play(DeviceFileSource(soundPath));
      }

      // Set to loop for alarms
      await _currentPlayer!.setReleaseMode(ReleaseMode.loop);

      print('Playing alarm sound: $soundPath');
    } catch (e) {
      print('Error playing alarm sound: $e');
      // Fallback to system notification
      // The notification itself will still play the system sound
    }
  }

  Future<void> stopAlarmSound() async {
    if (_currentPlayer != null) {
      await _currentPlayer!.stop();
      await _currentPlayer!.dispose();
      _currentPlayer = null;
    }
  }

  Future<void> testSound(String soundPath) async {
    try {
      final player = AudioPlayer();

      if (soundPath.isEmpty || soundPath == 'default') {
        // Play a brief system sound for testing
        print('Testing default sound');
        return;
      }

      if (soundPath.startsWith('sounds/')) {
        await player.play(AssetSource(soundPath));
      } else {
        await player.play(DeviceFileSource(soundPath));
      }

      // Stop after 3 seconds for testing
      await Future.delayed(const Duration(seconds: 3));
      await player.stop();
      await player.dispose();
    } catch (e) {
      print('Error testing sound: $e');
    }
  }
}
