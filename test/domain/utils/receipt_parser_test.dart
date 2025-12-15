import 'package:aldeewan_mobile/domain/utils/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptParser', () {
    test('parses Input 1 (Garbled single line)', () {
      const input = '200140525792001405257907-Dec-2025 07:02:08öjgilà slaw400000.01253 0777 7462 000102516893740001GolgodclbGlus KulesbsJl l, 2024@JJ';
      final result = ReceiptParser.parse(input);

      // Date: 07-Dec-2025
      expect(result.date, isNotNull);
      expect(result.date!.year, 2025);
      expect(result.date!.month, 12);
      expect(result.date!.day, 7);

      // Amount: 400000.01253 (approx 400000)
      expect(result.amount, isNotNull);
      expect(result.amount, closeTo(400000.01253, 0.00001));
    });

    test('parses Input 2 (Clean lines with fallback)', () {
      const input = '''
U-UeC-LULƏ
U-UeC-LULƏ
19:43:57
0313 1125 0918
0001
1163 0238 4917
0001
Abdalla Mahmoud
Azmi Mahmoud
N/A
N/A
19,000.00
Glgo
dcb
Jalgall på
ylus dKilesbysJl 2024®
''';
      final result = ReceiptParser.parse(input);

      // Amount: 19,000.00
      expect(result.amount, isNotNull);
      expect(result.amount, 19000.0);
    });

    test('parses standard receipt with keywords', () {
      const input = '''
      Supermarket
      Date: 2023-10-05
      Item 1: 50.00
      Item 2: 30.00
      Total Amount: 80.00 SDG
      Thank you
      ''';
      final result = ReceiptParser.parse(input);

      expect(result.amount, 80.0);
      expect(result.date!.year, 2023);
      expect(result.date!.month, 10);
      expect(result.date!.day, 5);
    });
  });
}
