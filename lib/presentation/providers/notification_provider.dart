import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aldeewan_mobile/utils/notification_service.dart';

class NotificationState {
  final bool isEnabled;
  final TimeOfDay time;

  NotificationState({required this.isEnabled, required this.time});
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState(isEnabled: true, time: const TimeOfDay(hour: 20, minute: 0))) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('daily_reminder_enabled') ?? true;
    final hour = prefs.getInt('daily_reminder_hour') ?? 20;
    final minute = prefs.getInt('daily_reminder_minute') ?? 0;
    state = NotificationState(isEnabled: isEnabled, time: TimeOfDay(hour: hour, minute: minute));
  }

  Future<void> toggleReminder(bool value, String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', value);
    state = NotificationState(isEnabled: value, time: state.time);

    if (value) {
      await NotificationService().requestPermissions();
      await _schedule(title, body);
    } else {
      await NotificationService().cancelNotification(0);
    }
  }

  Future<void> setTime(TimeOfDay time, String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_reminder_hour', time.hour);
    await prefs.setInt('daily_reminder_minute', time.minute);
    state = NotificationState(isEnabled: state.isEnabled, time: time);

    if (state.isEnabled) {
      await _schedule(title, body);
    }
  }

  Future<void> updateStrings(String title, String body) async {
    if (state.isEnabled) {
      await _schedule(title, body);
    }
  }

  Future<void> _schedule(String title, String body) async {
    await NotificationService().scheduleDailyReminder(
      id: 0,
      title: title,
      body: body,
      time: state.time,
    );
  }
  Future<bool> requestPermissions() async {
    return await NotificationService().requestPermissions();
  }

  Future<void> showTestNotification(String title, String body) async {
    await NotificationService().showTestNotification(title: title, body: body);
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
