import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String generator;
  late String settings;
  late String navigationMenu;
  late String mainSource;
  late String listPage;
  late String detailPage;

  setUpAll(() {
    generator = File('lib/views/qr_code_generator_page.dart')
        .readAsStringSync();
    settings = File('lib/views/settings_page.dart').readAsStringSync();
    navigationMenu = File('lib/widgets/app_navigation_menu.dart')
        .readAsStringSync();
    mainSource = File('lib/main.dart').readAsStringSync();
    listPage = File('lib/views/qr_code_list_page.dart').readAsStringSync();
    detailPage = File('lib/views/qr_code_detail_page.dart').readAsStringSync();
  });

  test('generator keeps one primary scanner action and moves secondary navigation into M3 menu', () {
    expect(generator, contains('AppNavigationMenu('));
    expect(generator, contains('Icons.document_scanner_rounded'));
    expect(generator, contains('SettingsPage(userEmail: user?.email)'));
    expect(generator, isNot(contains('leading: _buildLogoutButton')));
    expect(navigationMenu, contains('MenuAnchor('));
    expect(navigationMenu, contains('MenuItemButton('));
  });

  test('settings exposes locale, theme, account and privacy controls', () {
    expect(settings, contains('SegmentedButton<String>('));
    expect(settings, contains('SegmentedButton<ThemeMode>('));
    expect(settings, contains('LocaleProvider'));
    expect(settings, contains('ThemeModeProvider'));
    expect(settings, contains('AccountPrivacyPage()'));
    expect(settings, contains('privacyOptionsRequired'));
    expect(settings, contains('showPrivacyOptionsForm()'));
  });

  test('theme mode stays system by default but MaterialApp follows persisted provider choice', () {
    final themeProvider = File('lib/viewmodels/theme_mode_provider.dart')
        .readAsStringSync();

    expect(themeProvider, contains('ThemeMode _themeMode = ThemeMode.system'));
    expect(
      mainSource,
      contains(
        'ChangeNotifierProvider(create: (context) => ThemeModeProvider())',
      ),
    );
    expect(mainSource, contains('themeMode: themeModeProvider.themeMode'));
  });

  test('page-level overflow navigation uses Material 3 MenuAnchor', () {
    expect(listPage, contains('MenuAnchor('));
    expect(detailPage, contains('MenuAnchor('));
    expect(detailPage, contains('Icons.home_rounded'));
    expect(detailPage, contains('Icons.format_list_bulleted_rounded'));
  });
}
