import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';

class SoundSettingsNotifier extends StateNotifier<bool> {
  final SoundService _soundService;

  SoundSettingsNotifier(this._soundService) : super(true) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('is_sound_enabled') ?? true;
    state = isEnabled;
    _soundService.setEnabled(isEnabled);
  }

  Future<void> setSoundEnabled(bool value) async {
    state = value;
    _soundService.setEnabled(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_sound_enabled', value);
  }
}

final soundSettingsProvider = StateNotifierProvider<SoundSettingsNotifier, bool>((ref) {
  final soundService = ref.watch(soundServiceProvider);
  return SoundSettingsNotifier(soundService);
});
