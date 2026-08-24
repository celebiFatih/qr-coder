import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auth entry flows use the shared scroll-safe auth frame', () {
    for (final path in <String>[
      'lib/views/login_page.dart',
      'lib/views/forgot_passw_page.dart',
      'lib/views/verification_page.dart',
    ]) {
      final source = File(path).readAsStringSync();

      expect(source, contains('AppAuthPageFrame('), reason: path);
      expect(source, contains('AppPageScaffold('), reason: path);
      expect(source, isNot(contains('elevation: 8')), reason: path);
      expect(
        source,
        isNot(
          contains('backgroundColor: Theme.of(context).colorScheme.primary'),
        ),
        reason: path,
      );
    }
  });

  test('auth shell stays width-responsive and text-scale scroll safe', () {
    final source = File('lib/widgets/app_auth_layout.dart').readAsStringSync();

    expect(source, contains('AppBreakpoints.classify(width)'));
    expect(source, contains('SingleChildScrollView('));
    expect(source, contains('ScrollViewKeyboardDismissBehavior.onDrag'));
    expect(source, contains('AppLayoutMetrics.horizontalPaddingForWidth'));
  });

  test('login exposes Material actions instead of raw tap-only text', () {
    final source = File('lib/views/login_page.dart').readAsStringSync();

    expect(source, contains('FilledButton('));
    expect(source, contains('OutlinedButton.icon('));
    expect(source, contains('TextButton('));
    expect(source, contains('AutofillGroup('));
    expect(source, isNot(contains('GestureDetector(')));
    expect(source, isNot(contains('InkWell(')));
  });

  test('forgot password and verification keep action hierarchy explicit', () {
    final forgot = File('lib/views/forgot_passw_page.dart').readAsStringSync();
    final verification = File('lib/views/verification_page.dart')
        .readAsStringSync();

    expect(forgot, contains('FilledButton.icon('));
    expect(verification, contains('FilledButton.tonalIcon('));
    expect(verification, contains('OutlinedButton.icon('));
    expect(verification, contains('TextButton.icon('));
    expect(verification, contains('viewModel.userEmail'));
    expect(verification, isNot(contains('Auth().currentUser?.email')));
  });

  test(
    'account privacy uses common content surfaces and error role colors',
    () {
      final source = File('lib/views/account_privacy_page.dart')
          .readAsStringSync();

      expect(source, contains('AppPageScaffold('));
      expect(source, contains('AppContentFrame('));
      expect(source, contains('AppSurface('));
      expect(source, contains('scheme.errorContainer'));
      expect(source, contains('scheme.onErrorContainer'));
    },
  );
}
