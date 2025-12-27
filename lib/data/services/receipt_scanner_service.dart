import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// A Riverpod provider that exposes an instance of [ReceiptScannerService].
///
/// This allows other parts of the application to easily access and use the service
/// for scanning and parsing receipts.
final receiptScannerServiceProvider = Provider((ref) => ReceiptScannerService());

/// Structured data extracted from a receipt after OCR and parsing.
class ParsedReceipt {
  /// The extracted monetary amount from the receipt, if found.
  final double? amount;
  /// The extracted date from the receipt, if found.
  final DateTime? date;
  /// An extracted reference or invoice number from the receipt, if found.
  final String? reference;
  /// Cleaned and formatted notes or item descriptions from the receipt's text.
  final String cleanedNotes;
  /// The raw, unparsed text extracted from the receipt image via OCR.
  final String rawText;

  /// Constructs a [ParsedReceipt] instance with the extracted data.
  ParsedReceipt({
    this.amount,
    this.date,
    this.reference,
    required this.cleanedNotes,
    required this.rawText,
  });
}

/// A service class responsible for scanning physical receipts and extracting structured data.
///
/// This service integrates with `image_picker` to acquire receipt images and
/// `google_mlkit_text_recognition` to perform OCR (Optical Character Recognition)
/// to convert image text into digital text. It then parses this raw text to
/// extract relevant financial details.
class ReceiptScannerService {
  /// An instance of `ImagePicker` to handle image selection from the device's gallery or camera.
  final ImagePicker _picker = ImagePicker();
  /// An instance of `TextRecognizer` from Google ML Kit for performing OCR on images.
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Allows the user to pick a receipt image from a specified source (gallery or camera).
  ///
  /// - Parameters:
  ///   - `source`: The source to pick the image from (e.g., `ImageSource.gallery` or `ImageSource.camera`).
  /// - Returns: A `Future<File?>` containing the selected image file, or `null` if no image was picked.
  Future<File?> pickReceiptImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;
    return File(image.path);
  }

  /// Extracts raw text from a given image file using OCR.
  ///
  /// - Parameters:
  ///   - `image`: The image `File` from which to extract text.
  /// - Returns: A `Future<String>` containing the recognized text from the image.
  Future<String> extractTextFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Parses the raw OCR text extracted from a receipt image and extracts structured data.
  ///
  /// This method first extracts text from the image, then attempts to identify
  /// the amount, date, reference number, and cleans up notes from the raw text.
  /// - Parameters:
  ///   - `image`: The image `File` of the receipt to be parsed.
  /// - Returns: A `Future<ParsedReceipt>` containing the structured data extracted from the receipt.
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

  /// Extracts the largest currency amount from the provided text.
  ///
  /// This method uses various regular expressions to match common amount patterns
  /// (e.g., with currency symbols, decimal separators, currency codes) and returns
  /// the largest positive amount found.
  /// - Parameters:
  ///   - `text`: The raw text string from which to extract the amount.
  /// - Returns: A `double?` representing the largest extracted amount, or `null` if no valid amount is found.
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

  /// Extracts a date from the provided text string.
  ///
  /// This method attempts to match common date formats (DD/MM/YYYY, YYYY-MM-DD, Month DD, YYYY)
  /// and parses the first valid date found.
  /// - Parameters:
  ///   - `text`: The raw text string from which to extract the date.
  /// - Returns: A `DateTime?` object if a valid date is found and parsed successfully, otherwise `null`.
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

  /// Extracts a reference or invoice number from the provided text string.
  ///
  /// This method uses regular expressions to find patterns typically associated
  /// with reference numbers (e.g., "ref: ABC-123", "invoice: 456", "#XYZ789").
  /// - Parameters:
  ///   - `text`: The raw text string from which to extract the reference.
  /// - Returns: A `String?` containing the extracted reference number, or `null` if not found.
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

  /// Cleans and formats the raw text from the receipt into a more readable notes string.
  ///
  /// This method splits the raw text into lines, filters out noise (e.g., empty lines,
  /// very short lines, pure numbers, separator lines), and then joins the first few
  /// meaningful lines with semicolons for better readability.
  /// - Parameters:
  ///   - `rawText`: The unparsed text extracted from the receipt.
  /// - Returns: A `String` containing the cleaned and formatted notes.
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

  /// Disposes of the `TextRecognizer` to release resources.
  ///
  /// This method should be called when the `ReceiptScannerService` is no longer needed
  /// to prevent memory leaks.
  void dispose() {
    _textRecognizer.close();
  }
}

