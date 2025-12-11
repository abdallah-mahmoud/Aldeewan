import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter;
  final bool allowFraction;

  ThousandsSeparatorInputFormatter({this.allowFraction = false})
      : _formatter = NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle deletion
    if (newValue.text.length < oldValue.text.length) {
      // If deleting a comma, delete the digit before it too? 
      // Standard behavior usually handles this by reformatting the raw number.
    }

    String newText = newValue.text;
    
    // If allowing fraction, we need to be careful not to strip the decimal point
    if (allowFraction) {
      // Check if it ends with a decimal point (user just typed it)
      if (newText.endsWith('.')) {
        // Ensure only one decimal point
        if (newText.indexOf('.') == newText.lastIndexOf('.')) {
           // It's valid, but we might want to format the integer part
           List<String> parts = newText.split('.');
           String integerPart = parts[0].replaceAll(RegExp(r'[^\d]'), '');
           if (integerPart.isEmpty) integerPart = '0';
           String formattedInt = _formatter.format(int.parse(integerPart));
           String result = '$formattedInt.';
           return TextEditingValue(
             text: result,
             selection: TextSelection.collapsed(offset: result.length),
           );
        }
      }
      
      // If it has a decimal part
      if (newText.contains('.')) {
         List<String> parts = newText.split('.');
         if (parts.length > 2) {
           // Multiple dots, revert
           return oldValue;
         }
         String integerPart = parts[0].replaceAll(RegExp(r'[^\d]'), '');
         String decimalPart = parts[1].replaceAll(RegExp(r'[^\d]'), ''); // Strip non-digits from decimal
         
         if (integerPart.isEmpty) integerPart = '0';
         
         String formattedInt = _formatter.format(int.parse(integerPart));
         String result = '$formattedInt.$decimalPart';
         
         return TextEditingValue(
           text: result,
           selection: TextSelection.collapsed(offset: result.length),
         );
      }
    }

    // Integer only logic (or if no decimal point yet)
    String cleanText = newText.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    
    int value = int.tryParse(cleanText) ?? 0;
    String formatted = _formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
