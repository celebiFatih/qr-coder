import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String scannerPage;

  setUpAll(() {
    scannerPage = File('lib/views/barcode_scanner_page.dart')
        .readAsStringSync();
  });

  test('scanner keeps explicit lifecycle ownership', () {
    expect(scannerPage, contains('with WidgetsBindingObserver'));
    expect(scannerPage, contains('autoStart: false'));
    expect(scannerPage, contains('WidgetsBinding.instance.addObserver(this)'));
    expect(
      scannerPage,
      contains('WidgetsBinding.instance.removeObserver(this)'),
    );
  });

  test('scanner pauses and resumes camera with app lifecycle', () {
    expect(scannerPage, contains('case AppLifecycleState.paused:'));
    expect(scannerPage, contains('_stopCamera(provider);'));
    expect(scannerPage, contains('case AppLifecycleState.resumed:'));
    expect(scannerPage, contains('_startCamera(provider);'));
  });

  test('barcode stream subscription is cancelled before camera restart', () {
    expect(scannerPage, contains('controller.barcodes.listen(_handleBarcode)'));
    expect(scannerPage, contains('await streamSubscription.cancel();'));
    expect(scannerPage, contains('await controller.stop();'));
  });

  test('detail navigation stops and restarts scanner', () {
    final stopIndex = scannerPage.indexOf('await _stopCamera(provider);');
    final navigationIndex = scannerPage.indexOf('await Navigator.push(');
    final restartIndex = scannerPage.indexOf(
      'await _startCamera(provider);',
      navigationIndex,
    );

    expect(stopIndex, greaterThanOrEqualTo(0));
    expect(navigationIndex, greaterThan(stopIndex));
    expect(restartIndex, greaterThan(navigationIndex));
  });

  test('refresh keeps scanner widget mounted and restarts camera', () {
    expect(scannerPage, contains('if (provider.isCameraLoading)'));
    expect(
      scannerPage,
      contains(
        'await Future<void>.delayed(const Duration(milliseconds: 300));',
      ),
    );
    expect(scannerPage, contains('await _startCamera(provider);'));
  });

  test('scanner detection path keeps unusable raw values out', () {
    expect(scannerPage, contains('BarcodeScannerViewmodel.hasUsableRawValue'));
    expect(
      scannerPage,
      contains('BarcodeScannerViewmodel.usableRawValue(barcode)'),
    );
  });
}
