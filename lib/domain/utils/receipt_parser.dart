class DraftTransaction {
  final double? amount;
  final DateTime? date;
  final String? transactionId;
  final String? note;

  DraftTransaction({
    this.amount,
    this.date,
    this.transactionId,
    this.note,
  });

  @override
  String toString() {
    return 'DraftTransaction(amount: $amount, date: $date, transactionId: $transactionId, note: $note)';
  }
}

class ReceiptParser {
  static DraftTransaction parse(String text) {
    double? amount;
    DateTime? date;
    String? transactionId;

    // Normalize text
    final lines = text.split('\n');
    final fullText = text;

    // 1. Extract Amount
    final amountRegex = RegExp(r'(\d{1,3}(?:,\d{3})+(?:\.\d+)?|\d+(?:\.\d+)?)');
    
    // Prioritize lines containing currency symbols or keywords
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lowerLine = line.toLowerCase();
      
      if (lowerLine.contains('amount') || 
          lowerLine.contains('total') || 
          lowerLine.contains('المبلغ') || 
          lowerLine.contains('الاجمالي') || 
          lowerLine.contains('القيمة') || 
          line.contains('SDG') || 
          line.contains('£')) {
        
        var matches = amountRegex.allMatches(line);
        for (final match in matches) {
          String rawAmount = match.group(0)!.replaceAll(',', '');
          try {
            double val = double.parse(rawAmount);
            if (val > 0 && val != 2023 && val != 2024 && val != 2025) {
               amount = val;
               break;
            }
          } catch (_) {}
        }
        if (amount != null) break;

        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          matches = amountRegex.allMatches(nextLine);
          for (final match in matches) {
            String rawAmount = match.group(0)!.replaceAll(',', '');
            try {
              double val = double.parse(rawAmount);
              if (val > 0 && val != 2023 && val != 2024 && val != 2025) {
                 amount = val;
                 break;
              }
            } catch (_) {}
          }
          if (amount != null) break;
        }
      }
    }
    
    // Fallback: find largest plausible amount
    if (amount == null) {
      double maxAmount = 0;
      for (final line in lines) {
        final matches = amountRegex.allMatches(line);
        for (final match in matches) {
          String rawAmount = match.group(0)!.replaceAll(',', '');
          try {
            double val = double.parse(rawAmount);
            bool isYear = (val >= 2020 && val <= 2030 && val % 1 == 0);
            bool isHugeInteger = (val > 10000000 && val % 1 == 0);
            
            if (val > 0 && !isYear && !isHugeInteger) {
               if (val > maxAmount) {
                 maxAmount = val;
               }
            }
          } catch (_) {}
        }
      }
      if (maxAmount > 0) {
        amount = maxAmount;
      }
    }

    // 2. Extract Date - Enhanced with priority for date-labeled lines
    final dateKeywords = ['date', 'تاريخ', 'time', 'وقت', 'التاريخ'];
    final dateRegex = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})');
    final dateIsoRegex = RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})');
    final dateTextRegex = RegExp(r'(\d{1,2})[-/\s]([A-Za-z]{3})[-/\s](\d{2,4})');

    // First try lines with date keywords
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      bool hasKeyword = dateKeywords.any((kw) => lowerLine.contains(kw));
      if (!hasKeyword) continue;
      
      date = _tryParseDateFromLine(line, dateIsoRegex, dateTextRegex, dateRegex);
      if (date != null) break;
    }

    // Fallback: try all lines
    if (date == null) {
      for (final line in lines) {
        date = _tryParseDateFromLine(line, dateIsoRegex, dateTextRegex, dateRegex);
        if (date != null) break;
      }
    }

    // 3. Extract Transaction/Reference ID only
    // Keywords for transaction/reference IDs in English and Arabic
    final idKeywords = [
      'ref', 'reference', 'txn', 'transaction', 'trans', 'operation',
      'رقم العملية', 'المرجع', 'رقم المرجع', 'رقم الحوالة', 'رقم التحويل',
      'confirmation', 'رقم التأكيد', 'رمز العملية',
    ];
    
    // Pattern: keyword followed by optional colon/space, then alphanumeric ID
    final idPatterns = [
      RegExp(r'(ref|reference|txn|transaction|trans|operation|confirmation)[:\s#]*([A-Za-z0-9]{4,})', caseSensitive: false),
      RegExp(r'(رقم العملية|المرجع|رقم المرجع|رقم الحوالة|رقم التحويل|رقم التأكيد|رمز العملية)[:\s#]*([A-Za-z0-9\u0660-\u0669]{4,})'),
    ];
    
    final extractedIds = <String>[];
    
    // Try pattern matching in full text
    for (final pattern in idPatterns) {
      final matches = pattern.allMatches(fullText);
      for (final match in matches) {
        final id = match.group(2);
        if (id != null && id.length >= 4) {
          extractedIds.add(id);
        }
      }
    }
    
    // Also check each line for keyword proximity
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      
      for (final keyword in idKeywords) {
        if (lowerLine.contains(keyword)) {
          // Find numbers/IDs near the keyword
          final numberRegex = RegExp(r'[A-Za-z0-9]{4,}');
          final matches = numberRegex.allMatches(line);
          for (final match in matches) {
            final id = match.group(0)!;
            // Skip if it's a year or amount
            if (id.length >= 4 && !extractedIds.contains(id)) {
              try {
                double val = double.parse(id);
                if (val >= 2020 && val <= 2030) continue; // Skip years
                if (amount != null && val == amount) continue; // Skip amount
              } catch (_) {}
              extractedIds.add(id);
            }
          }
        }
      }
    }
    
    // Set transactionId to first found
    if (extractedIds.isNotEmpty) {
      transactionId = extractedIds.first;
    }
    
    // Note: only include extracted IDs, each on its own line
    final note = extractedIds.isNotEmpty ? extractedIds.join('\n') : null;

    return DraftTransaction(
      amount: amount,
      date: date,
      transactionId: transactionId,
      note: note,
    );
  }

  static DateTime? _tryParseDateFromLine(
    String line,
    RegExp dateIsoRegex,
    RegExp dateTextRegex,
    RegExp dateRegex,
  ) {
    // Try ISO format (yyyy-MM-dd)
    var match = dateIsoRegex.firstMatch(line);
    if (match != null) {
      try {
        int year = int.parse(match.group(1)!);
        int month = int.parse(match.group(2)!);
        int day = int.parse(match.group(3)!);
        if (year > 2000 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      } catch (_) {}
    }

    // Try text month format (07-Dec-2025)
    match = dateTextRegex.firstMatch(line);
    if (match != null) {
      try {
        int day = int.parse(match.group(1)!);
        String monthStr = match.group(2)!.toLowerCase();
        int year = int.parse(match.group(3)!);
        if (year < 100) year += 2000;

        const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
        int index = months.indexOf(monthStr);
        if (index != -1 && day >= 1 && day <= 31) {
          return DateTime(year, index + 1, day);
        }
      } catch (_) {}
    }

    // Try numeric format (dd/MM/yyyy or dd-MM-yyyy)
    match = dateRegex.firstMatch(line);
    if (match != null) {
      try {
        int p1 = int.parse(match.group(1)!);
        int p2 = int.parse(match.group(2)!);
        int p3 = int.parse(match.group(3)!);
        
        int day, month, year;
        
        if (p3 >= 2000) {
          // Format: dd/MM/yyyy
          day = p1;
          month = p2;
          year = p3;
        } else if (p3 < 100) {
          // Format: dd/MM/yy
          day = p1;
          month = p2;
          year = 2000 + p3;
        } else {
          // Ambiguous, assume dd/MM/yyyy
          day = p1;
          month = p2;
          year = p3;
        }
        
        // Validate
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31 && year >= 2000) {
          return DateTime(year, month, day);
        }
      } catch (_) {}
    }

    return null;
  }
}
