import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class DateFormatterService {
  /// Formats date with Gregorian and optionally Hijri
  /// Returns a string with newline separator if Hijri is enabled
  static String formatDualDate(
    DateTime date,
    BuildContext context, {
    bool showHijri = true,
    int hijriAdjustment = 0,
    String? format,
  }) {
    final locale = Localizations.localeOf(context).toString();
    final langCode = Localizations.localeOf(context).languageCode;
    
    // Default format yMMMd (e.g., Dec 29, 2025)
    final dateFormat = format ?? 'yMMMd';
    String gregorian = DateFormat(dateFormat, locale).format(date);
    
    // Force Western numerals for Gregorian
    gregorian = forceWesternNumerals(gregorian);
    
    if (!showHijri) return gregorian;
    
    // Set locale for Hijri (hijri package uses static setLocal)
    // We set it before creating the Hijri object to be safe
    HijriCalendar.setLocal(langCode);
    
    // Apply adjustment for Hijri calculation
    final adjustedDate = date.add(Duration(days: hijriAdjustment));
    final hijri = HijriCalendar.fromDate(adjustedDate);
    
    String hijriStr = hijri.toFormat("dd MMMM yyyy");
    
    // Force Western numerals for Hijri
    hijriStr = forceWesternNumerals(hijriStr);
    
    return '$gregorian\n$hijriStr';
  }

  /// Formats a Gregorian date with forced Western numerals
  static String formatDate(DateTime date, String locale, {String format = 'yMMMd'}) {
    final formatted = DateFormat(format, locale).format(date);
    return forceWesternNumerals(formatted);
  }
  
  /// Get just the Hijri string for a date
  static String formatHijriOnly(
    DateTime date,
    String langCode, {
    int adjustment = 0,
    String format = "dd MMMM yyyy",
  }) {
    HijriCalendar.setLocal(langCode);
    final adjustedDate = date.add(Duration(days: adjustment));
    final hijri = HijriCalendar.fromDate(adjustedDate);
    
    String formatted = hijri.toFormat(format);
    
    // Force Western numerals (0-9)
    return forceWesternNumerals(formatted);
  }

  /// Utility to force Western Arabic numerals (0-9)
  static String forceWesternNumerals(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    
    String result = text;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }
}
