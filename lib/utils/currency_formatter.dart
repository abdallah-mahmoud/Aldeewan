import 'package:intl/intl.dart';

/// Centralized currency formatter to avoid creating new NumberFormat instances.
/// This improves performance by reusing the same formatter across the app.
class CurrencyFormatter {
  // Private constructor to prevent instantiation
  CurrencyFormatter._();

  /// Static formatter instance - created once, reused everywhere
  static final NumberFormat _formatter = NumberFormat('#,##0.##');
  
  /// Formats a number with thousand separators
  /// Example: 1234567.89 -> "1,234,567.89"
  static String format(double value, [String? currency]) {
    final formatted = _formatter.format(value);
    if (currency != null && currency.isNotEmpty) {
      return '$currency $formatted';
    }
    return formatted;
  }
  
  /// Parses a formatted string back to double
  /// Example: "1,234,567.89" -> 1234567.89
  static double parse(String value) {
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
  }
}
