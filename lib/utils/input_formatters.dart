import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats a number with thousand separators (commas).
/// Use AFTER FilteringTextInputFormatter to strip non-digits.
class CommaSeparatorFormatter extends TextInputFormatter {
  final bool allowFraction;
  // Static to avoid creating new NumberFormat on every keystroke
  static final NumberFormat _formatter = NumberFormat.decimalPattern();

  CommaSeparatorFormatter({this.allowFraction = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Handle decimal input
    if (allowFraction && newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      // Multiple decimals - revert
      if (parts.length > 2) return oldValue;
      
      // Format integer part, keep decimal part as-is
      final intPart = int.tryParse(parts[0]) ?? 0;
      final decimalPart = parts.length > 1 ? parts[1] : '';
      final formatted = '${_formatter.format(intPart)}.$decimalPart';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Integer only
    final value = int.tryParse(newValue.text) ?? 0;
    final formatted = _formatter.format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Helper function to get standard amount input formatters.
/// Call this in any TextFormField's inputFormatters property.
/// 
/// Example:
/// ```dart
/// TextFormField(
///   inputFormatters: amountFormatters(allowFraction: true),
/// )
/// ```
List<TextInputFormatter> amountFormatters({bool allowFraction = true}) => [
  // First: Filter to only allow digits (and decimal point if fractions allowed)
  FilteringTextInputFormatter.allow(
    allowFraction ? RegExp(r'[\d.]') : RegExp(r'\d'),
  ),
  // Second: Add thousand separators
  CommaSeparatorFormatter(allowFraction: allowFraction),
];
