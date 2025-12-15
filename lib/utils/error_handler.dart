import 'dart:async';
import 'dart:io';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class ErrorHandler {
  static String getUserFriendlyErrorMessage(Object error, AppLocalizations l10n) {
    if (error is SocketException) {
      return "Please check your internet connection.";
    } else if (error is TimeoutException) {
      return "The request took too long. Please try again.";
    } else if (error is FormatException) {
      return "Invalid data format.";
    } else {
      // Strip "Exception: " prefix if present for cleaner display
      final message = error.toString().replaceAll('Exception: ', '');
      return message.isNotEmpty ? message : "Something went wrong.";
    }
  }
}
