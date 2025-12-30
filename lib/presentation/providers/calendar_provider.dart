import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarState {
  final bool showHijri;
  final int adjustment;

  const CalendarState({
    this.showHijri = true,
    this.adjustment = 0,
  });

  CalendarState copyWith({
    bool? showHijri,
    int? adjustment,
  }) {
    return CalendarState(
      showHijri: showHijri ?? this.showHijri,
      adjustment: adjustment ?? this.adjustment,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(const CalendarState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final showHijri = prefs.getBool('show_hijri') ?? true;
    final adjustment = prefs.getInt('hijri_adjustment') ?? 0;
    
    state = CalendarState(
      showHijri: showHijri,
      adjustment: adjustment,
    );
  }

  Future<void> toggleHijri(bool enabled) async {
    state = state.copyWith(showHijri: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_hijri', enabled);
  }

  Future<void> setAdjustment(int days) async {
    state = state.copyWith(adjustment: days);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hijri_adjustment', days);
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});
