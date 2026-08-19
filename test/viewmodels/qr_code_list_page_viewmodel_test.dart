import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';

void main() {
  group('QrCodeListPageViewmodel.sortByCreatedAtDescending', () {
    QRCodeModel model(String id, String createdAt) {
      return QRCodeModel(
        id: id,
        data: 'data-$id',
        name: 'QR $id',
        createdAt: createdAt,
      );
    }

    test('sorts chronologically across month and year boundaries', () {
      final qrCodes = <QRCodeModel>[
        model('dec', '31.12.2025 23:59'),
        model('jan-1', '01.01.2026 00:01'),
        model('jan-2', '02.01.2026 10:00'),
      ];

      QrCodeListPageViewmodel.sortByCreatedAtDescending(qrCodes);

      expect(qrCodes.map((qr) => qr.id), <String>['jan-2', 'jan-1', 'dec']);
    });

    test('sorts by time when dates are on the same day', () {
      final qrCodes = <QRCodeModel>[
        model('early', '18.08.2026 09:05'),
        model('late', '18.08.2026 17:45'),
        model('middle', '18.08.2026 12:30'),
      ];

      QrCodeListPageViewmodel.sortByCreatedAtDescending(qrCodes);

      expect(qrCodes.map((qr) => qr.id), <String>['late', 'middle', 'early']);
    });

    test('keeps malformed legacy dates after valid dates without crashing', () {
      final qrCodes = <QRCodeModel>[
        model('invalid', 'unknown'),
        model('valid-old', '17.08.2026 10:00'),
        model('valid-new', '18.08.2026 10:00'),
      ];

      QrCodeListPageViewmodel.sortByCreatedAtDescending(qrCodes);

      expect(qrCodes.map((qr) => qr.id), <String>[
        'valid-new',
        'valid-old',
        'invalid',
      ]);
    });
  });
}
