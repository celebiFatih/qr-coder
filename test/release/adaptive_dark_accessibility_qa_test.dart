import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/theme_data.dart';

void main() {
  test(
    'adaptive screens keep OS text scaling and orientation unrestricted',
    () {
      final material3 = File(
        'test/release/material3_foundation_contract_test.dart',
      ).readAsStringSync();
      final activity = File(
        'android/app/src/main/kotlin/com/qrcoder/app/MainActivity.kt',
      ).readAsStringSync();

      expect(
        material3,
        contains('login does not cap the operating system text scale'),
      );
      expect(activity, isNot(contains('requestedOrientation')));
    },
  );

  test('large text prefers single-column generator/detail layouts', () {
    final generator = File('lib/views/qr_code_generator_page.dart')
        .readAsStringSync();
    final detail = File('lib/views/qr_code_detail_page.dart')
        .readAsStringSync();
    final accessibility = File('lib/widgets/app_accessibility.dart')
        .readAsStringSync();

    expect(accessibility, contains('largeTextScaleThreshold = 1.5'));
    expect(generator, contains('!AppAccessibility.usesLargeText(context)'));
    expect(detail, contains('!AppAccessibility.usesLargeText(context)'));
    expect(detail, contains('AppAccessibility.usesLargeText(context)'));
  });

  test('dark-mode QR content and previews use explicit readable colors', () {
    final content = File('lib/widgets/build_content.dart').readAsStringSync();
    final list = File('lib/views/qr_code_list_page.dart').readAsStringSync();

    expect(content, contains('textColor: scheme.onSurface'));
    expect(content, contains('linkColor: scheme.primary'));
    expect(list, contains('backgroundColor: Colors.white'));
  });

  test('scanner guide reserves separate vertical space for help and frame', () {
    final scanner = File('lib/views/barcode_scanner_page.dart')
        .readAsStringSync();
    final guideStart = scanner.indexOf('Widget _buildScannerGuide');
    final resultsStart = scanner.indexOf('Widget _buildResultsAction');
    final guide = scanner.substring(guideStart, resultsStart);

    expect(guide, contains('child: Column('));
    expect(guide, contains('Expanded('));
    expect(guide, contains('constraints.maxHeight'));
    expect(guide, isNot(contains('return Stack(')));
  });

  test('icon-only auth controls expose localized tooltips', () {
    final login = File('lib/views/login_page.dart').readAsStringSync();
    final forgot = File('lib/views/forgot_passw_page.dart').readAsStringSync();
    final dialog = File('lib/widgets/account_deletion_password_dialog.dart')
        .readAsStringSync();

    expect(login, contains('accessibility_clearForm'));
    expect(login, contains('accessibility_showPassword'));
    expect(login, contains('accessibility_hidePassword'));
    expect(forgot, contains('accessibility_clearInput'));
    expect(dialog, contains('tooltip: _obscurePassword'));
  });

  test(
    'shared page scaffold protects horizontal safe areas and banner pages',
    () {
      final layout = File('lib/widgets/app_layout.dart').readAsStringSync();

      expect(layout, contains('body: SafeArea('));
      expect(layout, contains('top: appBar == null'));
      expect(layout, contains('bottom: !showBannerAd'));
    },
  );

  test('Material light/dark semantic text roles retain strong contrast', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final scheme = theme.colorScheme;

      expect(
        _contrastRatio(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(scheme.onPrimaryContainer, scheme.primaryContainer),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(scheme.onErrorContainer, scheme.errorContainer),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(scheme.onTertiaryContainer, scheme.tertiaryContainer),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets('common icon action meets Android tap/labelling guidelines', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: AppIconButton(
              tooltip: 'Refresh',
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ),
      ),
    );

    expect(tester, meetsGuideline(androidTapTargetGuideline));
    expect(tester, meetsGuideline(labeledTapTargetGuideline));
  });

  testWidgets(
    'adaptive choice group stacks without overflow at 2.0 text scale',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(360, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: Scaffold(
              body: AppAdaptiveChoiceGroup<int>(
                options: const [
                  AppChoiceOption(
                    value: 0,
                    label: 'System',
                    icon: Icons.brightness_auto_outlined,
                  ),
                  AppChoiceOption(
                    value: 1,
                    label: 'Light',
                    icon: Icons.light_mode_outlined,
                  ),
                  AppChoiceOption(
                    value: 2,
                    label: 'Dark',
                    icon: Icons.dark_mode_outlined,
                  ),
                ],
                selected: 0,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsNWidgets(3));
      expect(tester.takeException(), isNull);
      expect(tester, meetsGuideline(androidTapTargetGuideline));
    },
  );
}

double _contrastRatio(Color foreground, Color background) {
  final lighter = foreground.computeLuminance() > background.computeLuminance()
      ? foreground.computeLuminance()
      : background.computeLuminance();
  final darker = foreground.computeLuminance() > background.computeLuminance()
      ? background.computeLuminance()
      : foreground.computeLuminance();

  return (lighter + 0.05) / (darker + 0.05);
}
