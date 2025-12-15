import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension WidgetAnimationExtensions on Widget {
  /// Adds a horizontal shake animation, useful for error states.
  Widget shake({Key? key, bool enabled = true}) {
    if (!enabled) return this;
    return Animate(
      key: key,
      effects: const [
        ShakeEffect(
          duration: Duration(milliseconds: 400),
          hz: 10,
          offset: Offset(10, 0),
          curve: Curves.easeInOut,
        ),
      ],
      child: this,
    );
  }

  /// Animates a list item with a staggered slide and fade effect.
  /// [index] is the index of the item in the list.
  Widget animateListItem(int index, {Duration delay = const Duration(milliseconds: 50)}) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: delay * index, curve: Curves.easeOut),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 300.ms,
          delay: delay * index,
          curve: Curves.easeOut,
        ),
      ],
      child: this,
    );
  }
  
  /// Standard page transition entry
  Widget animatePageEntry() {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, curve: Curves.easeOut),
        SlideEffect(begin: const Offset(0.05, 0), end: Offset.zero, duration: 300.ms, curve: Curves.easeOut),
      ],
      child: this,
    );
  }
}
