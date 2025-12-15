import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

final receiptScannerServiceProvider = Provider((ref) => ReceiptScannerService());

/// Structured data extracted from a receipt
class ParsedReceipt {
  final double? amount;
  final DateTime? date;
  final String? reference;
  final String cleanedNotes;
  final String rawText;

  ParsedReceipt({
    this.amount,
    this.date,
    this.reference,
    required this.cleanedNotes,
    required this.rawText,
  });
}

class ReceiptScannerService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<File?> pickReceiptImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  Future<String> extractTextFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Parse raw OCR text and extract structured receipt data
  Future<ParsedReceipt> parseReceipt(File image) async {
    final rawText = await extractTextFromImage(image);
    
    return ParsedReceipt(
      amount: _extractAmount(rawText),
      date: _extractDate(rawText),
      reference: _extractReference(rawText),
      cleanedNotes: _cleanNotes(rawText),
      rawText: rawText,
    );
  }

  /// Extract the largest currency amount from the text
  double? _extractAmount(String text) {
    // Match various amount patterns:
    // 123.45, 1,234.56, $123.45, 123.45 USD, etc.
    final patterns = [
      // Currency symbol followed by amount: $123.45, €1,234.56
      RegExp(r'[\$€£¥]\s?[\d,]+\.?\d*'),
      // Amount followed by currency code: 123.45 USD, 1234 SAR
      RegExp(r'[\d,]+\.?\d*\s?(?:USD|EUR|GBP|SAR|QAR|EGP|SDG|AED)', caseSensitive: false),
      // Large standalone numbers (likely totals): 1,234.56 or 1234.56
      RegExp(r'(?:total|amount|المبلغ|الإجمالي)[:\s]*[\d,]+\.?\d*', caseSensitive: false),
      // Generic decimal numbers
      RegExp(r'\b\d{1,3}(?:,\d{3})*(?:\.\d{2})?\b'),
    ];

    double? largestAmount;
    
    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final matchText = match.group(0) ?? '';
        // Extract just the number
        final numStr = matchText.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '');
        final amount = double.tryParse(numStr);
        if (amount != null && amount > 0) {
          if (largestAmount == null || amount > largestAmount) {
            largestAmount = amount;
          }
        }
      }
    }
    
    return largestAmount;
  }

  /// Extract date from the text
  DateTime? _extractDate(String text) {
    // Common date formats
    final patterns = [
      // DD/MM/YYYY or DD-MM-YYYY
      RegExp(r'\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})\b'),
      // YYYY/MM/DD or YYYY-MM-DD
      RegExp(r'\b(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})\b'),
      // Month DD, YYYY
      RegExp(r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}\b', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          final matchText = match.group(0) ?? '';
          
          // Try DD/MM/YYYY first
          final ddmmyyyy = RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})').firstMatch(matchText);
          if (ddmmyyyy != null) {
            final day = int.tryParse(ddmmyyyy.group(1) ?? '');
            final month = int.tryParse(ddmmyyyy.group(2) ?? '');
            final year = int.tryParse(ddmmyyyy.group(3) ?? '');
            if (day != null && month != null && year != null && 
                day >= 1 && day <= 31 && month >= 1 && month <= 12) {
              return DateTime(year, month, day);
            }
          }
          
          // Try YYYY/MM/DD
          final yyyymmdd = RegExp(r'(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})').firstMatch(matchText);
          if (yyyymmdd != null) {
            final year = int.tryParse(yyyymmdd.group(1) ?? '');
            final month = int.tryParse(yyyymmdd.group(2) ?? '');
            final day = int.tryParse(yyyymmdd.group(3) ?? '');
            if (day != null && month != null && year != null &&
                day >= 1 && day <= 31 && month >= 1 && month <= 12) {
              return DateTime(year, month, day);
            }
          }
        } catch (_) {
          // Continue to next pattern
        }
      }
    }
    
    return null;
  }

  /// Extract reference/invoice number
  String? _extractReference(String text) {
    final patterns = [
      RegExp(r'(?:ref|reference|invoice|receipt|رقم|فاتورة)[:\s#]*([A-Z0-9\-]+)', caseSensitive: false),
      RegExp(r'#\s*([A-Z0-9\-]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    
    return null;
  }

  /// Clean up the notes - remove garbage and format nicely
  String _cleanNotes(String rawText) {
    // Split into lines
    final lines = rawText.split('\n');
    
    // Filter out noise
    final cleanedLines = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => line.length > 2) // Skip very short lines
        .where((line) => !RegExp(r'^[\d\s\.\,\-\$€£]+$').hasMatch(line)) // Skip pure number lines
        .where((line) => !RegExp(r'^[*\-=_]{3,}$').hasMatch(line)) // Skip separator lines
        .take(5) // Take first 5 meaningful lines
        .toList();
    
    // Join with semicolons for readability
    return cleanedLines.join('; ');
  }

  void dispose() {
    _textRecognizer.close();
  }
}

