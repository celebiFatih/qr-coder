import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app exposes Material 3 light and dark themes', () {
    final theme = File('lib/widgets/theme_data.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();

    expect(theme, contains('useMaterial3: true'));
    expect(theme, contains('ColorScheme.fromSeed('));
    expect(theme, contains('static ThemeData get darkTheme'));
    expect(main, contains('darkTheme: AppTheme.darkTheme'));
    expect(main, contains('themeMode: ThemeMode.system'));
  });

  test('login does not cap the operating system text scale', () {
    final login = File('lib/views/login_page.dart').readAsStringSync();

    expect(login, isNot(contains('textScaler.scale(1.0)')));
    expect(login, isNot(contains('TextScaler.linear(')));
    expect(login, isNot(contains('.clamp(1.0, 1.2)')));
  });

  test(
    'Android activity remains edge-to-edge without locking phone rotation',
    () {
      final activity = File(
        'android/app/src/main/kotlin/com/qrcoder/app/MainActivity.kt',
      ).readAsStringSync();

      expect(
        activity,
        contains('WindowCompat.setDecorFitsSystemWindows(window, false)'),
      );
      expect(activity, isNot(contains('requestedOrientation')));
      expect(
        activity,
        isNot(contains('ActivityInfo.SCREEN_ORIENTATION_PORTRAIT')),
      );
    },
  );

  test('Material theme keeps accessible padded tap targets', () {
    final theme = File('lib/widgets/theme_data.dart').readAsStringSync();

    expect(
      theme,
      contains('materialTapTargetSize: MaterialTapTargetSize.padded'),
    );
    expect(theme, contains('minimumSize: const Size(48, 48)'));
  });
}
