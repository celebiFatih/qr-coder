import 'package:flutter/material.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeProvider with ChangeNotifier {
  ThemeModeProvider({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? Constants().prefs {
    ready = _loadThemeMode();
  }

  static const String _themeModeKey = 'themeMode';

  final Future<SharedPreferences> _preferences;
  late final Future<void> ready;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      notifyListeners();
    }

    final prefs = await _preferences;
    await prefs.setString(_themeModeKey, themeMode.name);
  }

  Future<void> _loadThemeMode() async {
    final prefs = await _preferences;
    final storedMode = prefs.getString(_themeModeKey);
    final loadedMode = _themeModeFromName(storedMode);

    if (_themeMode == loadedMode) {
      return;
    }

    _themeMode = loadedMode;
    notifyListeners();
  }

  ThemeMode _themeModeFromName(String? name) {
    return switch (name) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
