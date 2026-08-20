import 'package:intl/intl.dart';

abstract final class QRCodeDateUtils {
  static final DateFormat _persistedFormat = DateFormat('dd.MM.yyyy HH:mm');

  static DateTime? tryParse(String value) {
    try {
      return _persistedFormat.parseStrict(value);
    } on FormatException {
      return null;
    }
  }

  /// Formats the current persisted timestamp format for the active locale.
  ///
  /// Unknown legacy formats are preserved as-is rather than guessed or
  /// rewritten. A missing timestamp is represented with an em dash.
  static String formatForLocale(String value, {required bool isEnglish}) {
    final parsed = tryParse(value);
    if (parsed == null) {
      return value.isEmpty ? '—' : value;
    }

    final displayFormat = DateFormat(
      isEnglish ? 'MM.dd.yyyy HH:mm' : 'dd.MM.yyyy HH:mm',
    );
    return displayFormat.format(parsed);
  }
}
