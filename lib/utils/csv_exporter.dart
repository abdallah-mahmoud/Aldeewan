import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExporter {
  static Future<void> exportToCsv({
    required String fileName,
    required List<List<dynamic>> rows,
    required String subject,
    required String text,
  }) async {
    // Convert rows to CSV string
    final csvContent = rows.map((row) {
      return row.map((field) {
        if (field == null) return '';
        String value = field.toString();
        // Escape double quotes
        if (value.contains('"')) {
          value = value.replaceAll('"', '""');
        }
        // Wrap in quotes if contains comma, newline or quotes
        if (value.contains(',') || value.contains('\n') || value.contains('"')) {
          value = '"$value"';
        }
        return value;
      }).join(',');
    }).join('\n');

    // Save to temporary file
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvContent);

    // Share file
    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: text,
    );
  }
}
