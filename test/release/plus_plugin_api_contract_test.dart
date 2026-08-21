import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QR sharing uses the current share_plus API', () {
    final source = File('lib/viewmodels/qr_code_viewmodel.dart')
        .readAsStringSync();

    expect(source, contains('SharePlus.instance.share('));
    expect(source, contains('ShareParams(files: [XFile(file.path)]'));
  });

  test('device info checks keep Android SDK decisions explicit', () {
    final qrViewModel = File('lib/viewmodels/qr_code_viewmodel.dart')
        .readAsStringSync();
    final scannerPage = File('lib/views/barcode_scanner_page.dart')
        .readAsStringSync();

    expect(qrViewModel, contains('DeviceInfoPlugin().androidInfo'));
    expect(qrViewModel, contains('androidInfo.version.sdkInt <= 28'));
    expect(scannerPage, contains('DeviceInfoPlugin().androidInfo'));
    expect(scannerPage, contains('androidVersion.version.sdkInt >= 33'));
  });
}
