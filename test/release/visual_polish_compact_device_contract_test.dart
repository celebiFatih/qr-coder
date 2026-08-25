import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/widgets/theme_data.dart';

void main() {
  test(
    'brand palette keeps purple primary and original lime accent family',
    () {
      final themeSource = File('lib/widgets/theme_data.dart')
          .readAsStringSync();
      final light = AppTheme.lightTheme.colorScheme;
      final dark = AppTheme.darkTheme.colorScheme;

      expect(themeSource, contains('_seedColor = Color(0xFF673AB7)'));
      expect(themeSource, contains('_accentSeedColor = Color(0xFFCDDC39)'));
      expect(themeSource, contains('tertiary: accentScheme.primary'));
      expect(light.primary, isNot(equals(light.tertiary)));
      expect(dark.primary, isNot(equals(dark.tertiary)));
    },
  );

  test(
    'banner sizing uses the universal fixed format without deprecated APIs',
    () {
      final banner = File('lib/widgets/banner_ad_widget.dart')
          .readAsStringSync();

      expect(
        banner,
        contains('width >= AdSize.banner.width ? AdSize.banner : null'),
      );
      expect(banner, isNot(contains('AdSize.fullBanner')));
      expect(banner, isNot(contains('AdSize.leaderboard')));
      expect(
        banner,
        isNot(contains('getCurrentOrientationAnchoredAdaptiveBannerAdSize')),
      );
      expect(banner, isNot(contains('getLargeAnchoredAdaptiveBannerAdSize')));
    },
  );

  test('scanner result sheet is draggable and keeps clear action pinned', () {
    final scanner = File('lib/views/barcode_scanner_page.dart')
        .readAsStringSync();

    expect(scanner, contains('DraggableScrollableSheet('));
    expect(scanner, contains('minChildSize: 0.38'));
    expect(scanner, contains('maxChildSize: 0.94'));
    expect(scanner, contains('controller: scrollController'));
    expect(scanner, contains('SafeArea('));
    expect(scanner, contains('scannerViewModel.clearBarcodes'));
    expect(scanner, isNot(contains('_showBottomSheet(context, viewModel);')));
    expect(scanner, isNot(contains('FractionallySizedBox(')));
  });

  test('saved QR preview uses one centered square canvas', () {
    final list = File('lib/views/qr_code_list_page.dart').readAsStringSync();

    expect(list, contains('alignment: Alignment.center'));
    expect(list, contains('width: 58'));
    expect(list, contains('border: Border.all(color: scheme.tertiary'));
    expect(list, contains('padding: EdgeInsets.zero'));
  });

  test('contextual AppBar motion honors reduced-motion setting', () {
    final list = File('lib/views/qr_code_list_page.dart').readAsStringSync();
    final motion = File('lib/widgets/app_motion.dart').readAsStringSync();

    expect(list, contains('AnimatedSwitcher('));
    expect(list, contains('AppMotion.short(context)'));
    expect(motion, contains('MediaQuery.disableAnimationsOf(context)'));
    expect(motion, contains('Duration.zero'));
  });

  test('short auth viewports compact spacing without shrinking controls', () {
    final tokens = File('lib/widgets/app_design_tokens.dart')
        .readAsStringSync();
    final authLayout = File('lib/widgets/app_auth_layout.dart')
        .readAsStringSync();
    final login = File('lib/views/login_page.dart').readAsStringSync();

    expect(tokens, contains('shortViewportHeight = 760'));
    expect(authLayout, contains('AppBreakpoints.isShortViewport'));
    expect(login, contains('isShortViewport ? AppSpacing.md : AppSpacing.lg'));
    expect(login, contains('width: compact ? 56 : 72'));
    expect(login, isNot(contains('MediaQuery.textScalerOf(context).clamp')));
  });
}
