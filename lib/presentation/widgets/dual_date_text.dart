import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/calendar_provider.dart';
import 'package:aldeewan_mobile/utils/date_formatter_service.dart';

class DualDateText extends ConsumerWidget {
  final DateTime date;
  final TextStyle? style;
  final TextStyle? secondaryStyle;
  final TextAlign textAlign;
  final String? format;
  final bool showTime;

  const DualDateText({
    super.key,
    required this.date,
    this.style,
    this.secondaryStyle,
    this.textAlign = TextAlign.start,
    this.format,
    this.showTime = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final locale = Localizations.localeOf(context).toString();
    final langCode = Localizations.localeOf(context).languageCode;
    
    final dateFormat = format ?? (showTime ? 'yMMMd hh:mm a' : 'yMMMd');
    final gregorian = DateFormatterService.formatDate(date, locale, format: dateFormat);
    
    if (!calendarState.showHijri) {
      return Text(gregorian, style: style, textAlign: textAlign);
    }
    
    // For Hijri, we typically don't show time, just date
    final hijriStr = DateFormatterService.formatHijriOnly(
      date, 
      langCode,
      adjustment: calendarState.adjustment,
    );
    
    // Determine default secondary style if not provided
    final effectiveSecondaryStyle = secondaryStyle ?? style?.copyWith(
      fontSize: (style?.fontSize ?? 14) * 0.85, 
      color: style?.color?.withValues(alpha: 0.8),
      fontWeight: FontWeight.normal,
    ) ?? Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
    );

    return Column(
      crossAxisAlignment: _getCrossAxis(textAlign),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(gregorian, style: style, textAlign: textAlign),
        const SizedBox(height: 2),
        Text(
          hijriStr, 
          style: effectiveSecondaryStyle, 
          textAlign: textAlign
        ),
      ],
    );
  }

  CrossAxisAlignment _getCrossAxis(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.end:
      case TextAlign.right:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.start;
    }
  }
}
