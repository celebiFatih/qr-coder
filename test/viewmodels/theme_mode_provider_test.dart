import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/viewmodels/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme mode defaults to system', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = ThemeModeProvider(preferences: Future.value(prefs));
    addTearDown(provider.dispose);

    await provider.ready;

    expect(provider.themeMode, ThemeMode.system);
  });

  test('stored theme mode is restored and changes are persisted', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final provider = ThemeModeProvider(preferences: Future.value(prefs));
    addTearDown(provider.dispose);

    await provider.ready;
    expect(provider.themeMode, ThemeMode.dark);

    await provider.setThemeMode(ThemeMode.light);

    expect(provider.themeMode, ThemeMode.light);
    expect(prefs.getString('themeMode'), 'light');
  });

  test('unknown stored theme mode falls back to system', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'legacy'});
    final prefs = await SharedPreferences.getInstance();
    final provider = ThemeModeProvider(preferences: Future.value(prefs));
    addTearDown(provider.dispose);

    await provider.ready;

    expect(provider.themeMode, ThemeMode.system);
  });
}
