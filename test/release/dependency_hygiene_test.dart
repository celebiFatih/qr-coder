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
      RegExp(r'^  intl: \^0\.20\.3$', multiLine: true).hasMatch(pubspec),
      isTrue,
    );
  });

  test('project SDK floor matches the modernized Flutter toolchain', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains("sdk: '>=3.13.0 <4.0.0'"));
    expect(pubspec, contains("flutter: '>=3.47.0'"));
  });

  test('low-risk dependency baselines stay modernized', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('provider: ^6.1.5+1'));
    expect(pubspec, contains('path: ^1.9.1'));
    expect(pubspec, contains('flutter_dotenv: ^6.0.1'));
    expect(pubspec, contains('url_launcher: ^6.3.2'));
    expect(pubspec, contains('flutter_native_splash: ^2.4.8'));
  });

  test(
    'platform-aware storage dependencies stay on the validated baseline',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(pubspec, contains('path_provider: ^2.1.6'));
      expect(pubspec, contains('shared_preferences: ^2.5.5'));
      expect(pubspec, contains('image_gallery_saver_plus: 5.1.1'));
    },
  );
}
