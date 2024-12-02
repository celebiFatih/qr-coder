import 'package:flutter/material.dart';
import 'package:qr_coder/utils/constants.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Locale? get locale => _locale;

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    await Constants()
        .prefs
        .then((prefs) => prefs.setString('locale', locale.languageCode));
  }

  void _loadLocale() async {
    String? localeCode =
        await Constants().prefs.then((prefs) => prefs.getString('locale'));
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }
}
