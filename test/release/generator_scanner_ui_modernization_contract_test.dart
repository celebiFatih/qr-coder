import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String generatorPage;
  late String scannerPage;
  late String qrTextField;
  late String scannerError;
  late String qrDisplay;

  setUpAll(() {
    generatorPage = File('lib/views/qr_code_generator_page.dart')
        .readAsStringSync();
    scannerPage = File('lib/views/barcode_scanner_page.dart')
        .readAsStringSync();
    qrTextField = File('lib/widgets/qr_code_text_field.dart')
        .readAsStringSync();
    scannerError = File('lib/widgets/scanner_error_widget.dart')
        .readAsStringSync();
    qrDisplay = File('lib/widgets/qr_code_display.dart').readAsStringSync();
  });

  test(
    'generator uses the shared adaptive foundation and inline primary action',
    () {
      expect(generatorPage, contains('AppContentFrame('));
      expect(generatorPage, contains('AppBreakpoints.classify'));
      expect(generatorPage, contains('AppSurface('));
      expect(generatorPage, contains('FilledButton.icon('));
      expect(generatorPage, isNot(contains('FloatingActionButton.large(')));
      expect(generatorPage, isNot(contains('resizeToAvoidBottomInset: false')));
    },
  );

  test(
    'generator exposes shared-text state and a real empty preview state',
    () {
      expect(generatorPage, contains('viewModel.sharedText.isNotEmpty'));
      expect(generatorPage, contains('Icons.ios_share_rounded'));
      expect(generatorPage, contains('AppStateView.empty('));
      expect(generatorPage, contains('qrCodeGenerator_previewEmptyMsg'));
    },
  );

  test('generator input no longer hard-codes legacy Material 2 colors', () {
    expect(qrTextField, contains('InputDecoration('));
    expect(qrTextField, contains('qrCodeGenerator_clearTextToolTip'));
    expect(qrTextField, isNot(contains('Color(0xFF673AB7)')));
    expect(qrTextField, isNot(contains('Color(0xFF757575)')));
    expect(qrTextField, isNot(contains('Color(0xFF212121)')));
    expect(qrTextField, isNot(contains('UnderlineInputBorder')));
  });

  test('scanner replaces the tiny gesture strip with a Material action', () {
    expect(scannerPage, contains('_buildResultsAction(context)'));
    expect(scannerPage, contains('FilledButton.tonalIcon('));
    expect(scannerPage, isNot(contains('_buildBottomToggle')));
    expect(
      scannerPage,
      isNot(contains('height: MediaQuery.of(context).size.width * 0.01')),
    );
  });

  test('scanner result sheet uses themed safe Material 3 sheet behavior', () {
    expect(scannerPage, contains('isScrollControlled: true'));
    expect(scannerPage, contains('useSafeArea: true'));
    expect(scannerPage, contains('showDragHandle: true'));
    expect(scannerPage, contains('AppStateView.empty('));
    expect(scannerPage, isNot(contains('Color(0xFFCDDC39)')));
  });

  test('scanner error state is themed and retryable', () {
    expect(scannerError, contains('AppStateView.error('));
    expect(scannerError, contains('FilledButton.tonalIcon('));
    expect(scannerError, isNot(contains('Colors.black')));
    expect(scannerError, isNot(contains('Colors.white')));
  });

  test('QR logo action keeps at least a 48dp interaction target', () {
    expect(qrDisplay, contains('AppSpacing.xxl'));
    expect(qrDisplay, contains('qrcodeDisplay_remove_logo'));
    expect(qrDisplay, contains('button: true'));
  });
}
