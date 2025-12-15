import 'package:flutter/material.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';

class SoundNavigationObserver extends NavigatorObserver {
  final SoundService _soundService;

  SoundNavigationObserver(this._soundService);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Only play sound for page routes (screens), not dialogs or internal stuff if possible
    // But usually we want it for all navigations.
    // We might want to filter out the initial route or splash screen if needed.
    if (route is PageRoute) {
      _soundService.playClick();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute) {
      // Maybe a different sound for back? Or same click.
      // "Click" is usually fine for back too.
      _soundService.playClick();
    }
  }
  
  // We can also handle replace if needed
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _soundService.playClick();
    }
  }
}
