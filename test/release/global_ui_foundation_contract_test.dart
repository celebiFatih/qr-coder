import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';

void main() {
  test(
    'responsive breakpoints follow compact medium expanded width classes',
    () {
      expect(AppBreakpoints.classify(599), AppWindowSizeClass.compact);
      expect(AppBreakpoints.classify(600), AppWindowSizeClass.medium);
      expect(AppBreakpoints.classify(839), AppWindowSizeClass.medium);
      expect(AppBreakpoints.classify(840), AppWindowSizeClass.expanded);

      expect(AppLayoutMetrics.horizontalPaddingForWidth(599), AppSpacing.md);
      expect(AppLayoutMetrics.horizontalPaddingForWidth(600), AppSpacing.lg);
      expect(AppLayoutMetrics.horizontalPaddingForWidth(840), AppSpacing.xl);
    },
  );

  test('banner screens use the shared ad-safe page scaffold', () {
    for (final path in <String>[
      'lib/views/qr_code_generator_page.dart',
      'lib/views/qr_code_list_page.dart',
      'lib/views/qr_code_detail_page.dart',
    ]) {
      final source = File(path).readAsStringSync();

      expect(source, contains('AppPageScaffold('), reason: path);
      expect(source, contains('showBannerAd: true'), reason: path);
      expect(source, isNot(contains('BannerAdWidget(')), reason: path);
    }
  });

  test('app bar icon actions use the common accessible icon button', () {
    for (final path in <String>[
      'lib/views/qr_code_generator_page.dart',
      'lib/views/qr_code_list_page.dart',
      'lib/views/qr_code_detail_page.dart',
      'lib/views/barcode_scanner_page.dart',
    ]) {
      final source = File(path).readAsStringSync();

      expect(source, contains('AppIconButton('), reason: path);
    }

    final componentSource = File('lib/widgets/app_components.dart')
        .readAsStringSync();
    expect(componentSource, contains('dimension: AppSpacing.xxl'));
    expect(componentSource, contains('tooltip: tooltip'));
    expect(componentSource, contains('Semantics('));
  });

  test(
    'list loading empty and error states use the common state component',
    () {
      final source = File('lib/views/qr_code_list_page.dart')
          .readAsStringSync();

      expect(source, contains('AppStateView.loading()'));
      expect(source, contains('AppStateView.empty('));
      expect(source, contains('AppStateView.error('));
    },
  );

  test('auth layouts consume the shared responsive breakpoint token', () {
    for (final path in <String>[
      'lib/views/login_page.dart',
      'lib/views/forgot_passw_page.dart',
      'lib/views/verification_page.dart',
    ]) {
      final source = File(path).readAsStringSync();

      expect(source, contains('AppBreakpoints.mediumWidth'), reason: path);
      expect(source, isNot(contains('size.width < 600')), reason: path);
    }
  });

  test('Material theme consumes shared spacing and radius tokens', () {
    final source = File('lib/widgets/theme_data.dart').readAsStringSync();

    expect(source, contains('AppRadii.control'));
    expect(source, contains('AppRadii.surface'));
    expect(source, contains('AppRadii.sheet'));
    expect(source, contains('AppSpacing.md'));
  });
}
