import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final securityProvider = StateNotifierProvider<SecurityNotifier, bool>((ref) {
  return SecurityNotifier();
});

class SecurityNotifier extends StateNotifier<bool> {
  SecurityNotifier() : super(false) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('app_lock_enabled') ?? false;
  }

  Future<void> setAppLock(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_lock_enabled', enabled);
  }
}
