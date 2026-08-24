import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('application lockfile and Gradle wrapper are not ignored', () {
    final gitignore = File('.gitignore').readAsStringSync();

    expect(
      RegExp(r'^pubspec\.lock\s*$', multiLine: true).hasMatch(gitignore),
      isFalse,
    );
    expect(
      RegExp(r'^\*\*/android/gradlew\s*$', multiLine: true).hasMatch(gitignore),
      isFalse,
    );
    expect(
      RegExp(
        r'^\*\*/android/gradle-wrapper\.jar\s*$',
        multiLine: true,
      ).hasMatch(gitignore),
      isFalse,
    );
  });

  test('local secrets and signing material remain ignored', () {
    final gitignore = File('.gitignore').readAsStringSync();

    expect(gitignore, contains('.env'));
    expect(gitignore, contains('!.env.example'));
    expect(gitignore, contains('android/key.properties'));
    expect(gitignore, contains('android/local.properties'));
    expect(gitignore, contains('*.jks'));
    expect(gitignore, contains('*.keystore'));
  });

  test('environment template contains placeholders, not production values', () {
    final envExample = File('.env.example').readAsStringSync();

    expect(envExample, contains('BANNER_AD_UNIT_ID='));
    expect(envExample, contains('REWARDED_AD_UNIT_ID='));
    expect(envExample, contains('TEST_DEVICE_ID='));
    expect(envExample, contains('XXXXXXXXXXXXXXXX'));
  });

  test('source packaging excludes generated machine-local Flutter files', () {
    final script = File('tool/package_source.ps1').readAsStringSync();

    expect(script, contains('.flutter-plugins'));
    expect(script, contains('.flutter-plugins-dependencies'));
    expect(script, contains('Generated.xcconfig'));
    expect(script, contains('flutter_export_environment.sh'));
    expect(script, contains('"ephemeral"'));
    expect(script, contains('"screenshots"'));
  });

  test('source packaging prunes generated directories before recursion', () {
    final script = File('tool/package_source.ps1').readAsStringSync();

    expect(script, contains('function Should-ExcludeDirectory'));
    expect(script, contains('function Get-SourceFiles'));
    expect(script, contains(r'Get-SourceFiles $ProjectRoot'));
    expect(
      script,
      isNot(
        contains(
          r'Get-ChildItem -LiteralPath $ProjectRoot -Force -Recurse -File',
        ),
      ),
    );
  });
}
