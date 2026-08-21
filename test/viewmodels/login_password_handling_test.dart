import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login and registration pass password text without trimming', () {
    final source = File('lib/viewmodels/login_page_viewmodel.dart')
        .readAsStringSync();

    expect(
      source,
      isNot(contains('password: _passwordController.text.trim()')),
    );

    expect(
      RegExp(r'password:\s*_passwordController\.text,')
          .allMatches(source)
          .length,
      2,
    );
  });

  test('email normalization still trims surrounding whitespace', () {
    final source = File('lib/viewmodels/login_page_viewmodel.dart')
        .readAsStringSync();

    expect(
      RegExp(r'email:\s*_emailController\.text\.trim\(\),')
          .allMatches(source)
          .length,
      2,
    );
  });
}
