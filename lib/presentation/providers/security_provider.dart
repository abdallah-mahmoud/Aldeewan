import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final securityProvider = StateNotifierProvider<SecurityNotifier, bool>((ref) {
  return SecurityNotifier();
});

class SecurityNotifier extends StateNotifier<bool> {
  SecurityNotifier([super.state = false]) {
    // If we didn't get an initial value (or it was false), we double check prefs.
    // But if we are using overrides in main, this might be redundant but harmless.
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getBool('app_lock_enabled') ?? false;
    if (state != savedValue) {
      state = savedValue;
    }
  }

  Future<void> setAppLock(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', enabled);
  }
}
