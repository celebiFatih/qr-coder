import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('account page exposes the published privacy and deletion URLs', () {
    final source = File('lib/views/account_privacy_page.dart')
        .readAsStringSync();

    expect(source, contains('https://celebifatih.github.io/qr-coder-privacy/'));
    expect(
      source,
      contains(
        'https://celebifatih.github.io/qr-coder-privacy/account-deletion.html',
      ),
    );
  });

  test(
    'generator menu opens Settings and Settings opens AccountPrivacyPage',
    () {
      final generator = File('lib/views/qr_code_generator_page.dart')
          .readAsStringSync();
      final settings = File('lib/views/settings_page.dart').readAsStringSync();

      expect(generator, contains('SettingsPage(userEmail: user?.email)'));
      expect(settings, contains('AccountPrivacyPage()'));
    },
  );
}
