import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/utils/qr_code_date_utils.dart';

void main() {
  test('valid persisted date is localized without changing its value', () {
    expect(
      QRCodeDateUtils.formatForLocale('20.08.2026 15:30', isEnglish: false),
      '20.08.2026 15:30',
    );
    expect(
      QRCodeDateUtils.formatForLocale('20.08.2026 15:30', isEnglish: true),
      '08.20.2026 15:30',
    );
  });

  test('unknown legacy date format is preserved instead of throwing', () {
    expect(
      QRCodeDateUtils.formatForLocale('legacy-date-value', isEnglish: false),
      'legacy-date-value',
    );
  });

  test('missing legacy date is shown as an em dash', () {
    expect(QRCodeDateUtils.formatForLocale('', isEnglish: true), '—');
  });

  test('tryParse returns null for malformed dates', () {
    expect(QRCodeDateUtils.tryParse('not-a-date'), isNull);
  });
}
