import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';

void main() {
  test('null rawValue is rejected', () {
    const barcode = Barcode(rawValue: null);

    expect(BarcodeScannerViewmodel.usableRawValue(barcode), isNull);
    expect(BarcodeScannerViewmodel.hasUsableRawValue(barcode), isFalse);
  });

  test('empty rawValue is rejected', () {
    const barcode = Barcode(rawValue: '');

    expect(BarcodeScannerViewmodel.usableRawValue(barcode), isNull);
    expect(BarcodeScannerViewmodel.hasUsableRawValue(barcode), isFalse);
  });

  test('whitespace-only rawValue is rejected without trimming valid data', () {
    const whitespaceOnly = Barcode(rawValue: '   ');
    const validWithSpaces = Barcode(rawValue: '  payload  ');

    expect(BarcodeScannerViewmodel.usableRawValue(whitespaceOnly), isNull);
    expect(
      BarcodeScannerViewmodel.usableRawValue(validWithSpaces),
      '  payload  ',
    );
  });

  test('addBarcode ignores invalid values and deduplicates valid values', () {
    final viewModel = BarcodeScannerViewmodel(isFirebaseUser: false, uid: null);
    addTearDown(viewModel.dispose);

    expect(viewModel.addBarcode(const Barcode(rawValue: null)), isFalse);
    expect(viewModel.addBarcode(const Barcode(rawValue: '')), isFalse);
    expect(viewModel.addBarcode(const Barcode(rawValue: '   ')), isFalse);
    expect(viewModel.barcodes, isEmpty);

    expect(
      viewModel.addBarcode(const Barcode(rawValue: 'valid-value')),
      isTrue,
    );
    expect(
      viewModel.addBarcode(const Barcode(rawValue: 'valid-value')),
      isFalse,
    );
    expect(viewModel.barcodes, hasLength(1));
    expect(viewModel.barcodes.single.rawValue, 'valid-value');
  });
}
