import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy database service files have been removed', () {
    expect(File('lib/db/firebase_database_servise.dart').existsSync(), isFalse);
    expect(File('lib/db/local_database_helper.dart').existsSync(), isFalse);
  });

  test('runtime dependency list does not contain build-only flutter_gen', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(
      RegExp(r'^  flutter_gen:', multiLine: true).hasMatch(pubspec),
      isFalse,
    );
  });

  test('flutter_native_splash is a dev dependency', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final devDependenciesIndex = pubspec.indexOf('dev_dependencies:');
    final splashIndex = pubspec.indexOf('  flutter_native_splash:');

    expect(devDependenciesIndex, greaterThanOrEqualTo(0));
    expect(splashIndex, greaterThan(devDependenciesIndex));
  });

  test('intl uses an explicit compatible constraint', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(
      RegExp(r'^  intl: \^0\.20\.2$', multiLine: true).hasMatch(pubspec),
      isTrue,
    );
  });
}
