import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/l10n/app_localizations_en.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';

class _FakeQrCodeRepository implements QRCodeRepository {
  _FakeQrCodeRepository({this.fetchError, List<QRCodeModel>? qrCodes})
    : qrCodes = qrCodes ?? <QRCodeModel>[];

  Object? fetchError;
  List<QRCodeModel> qrCodes;

  @override
  Future<List<QRCodeModel>> fetchAllQRCodes() async {
    if (fetchError != null) {
      throw fetchError!;
    }
    return List<QRCodeModel>.from(qrCodes);
  }

  @override
  Future<void> deleteAllQrCodes() async {}

  @override
  Future<void> deleteQrCode(String id) async {}

  @override
  Future<void> insertQrCode(QRCodeModel qrCode) async {}

  @override
  Future<void> updateQRCodeName(
    String id,
    Map<String, dynamic> updatedData,
  ) async {}

  @override
  Future<void> deleteQrCodes(List<String> ids) {
    // TODO: implement deleteQrCodes
    throw UnimplementedError();
  }
}

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

  group('QrCodeListPageViewmodel list state', () {
    final l10n = AppLocalizationsEn();

    test(
      'fetch failure exposes an error instead of an empty-list state',
      () async {
        final repository = _FakeQrCodeRepository(
          fetchError: Exception('offline'),
        );
        final viewModel = QrCodeListPageViewmodel(
          isFirebaseUser: false,
          uid: null,
          repository: repository,
        );

        await viewModel.fetchQRCodes(l10n);

        expect(viewModel.errorMsg, l10n.qrCodeList_fetchListErrorMsg);
        expect(viewModel.qrCodes, isEmpty);
      },
    );

    test('successful retry clears a previous fetch error', () async {
      final repository = _FakeQrCodeRepository(
        fetchError: Exception('offline'),
      );
      final viewModel = QrCodeListPageViewmodel(
        isFirebaseUser: false,
        uid: null,
        repository: repository,
      );

      await viewModel.fetchQRCodes(l10n);
      expect(viewModel.errorMsg, isNotEmpty);

      repository
        ..fetchError = null
        ..qrCodes = <QRCodeModel>[
          QRCodeModel(
            id: '1',
            data: 'data',
            name: 'QR',
            createdAt: '19.08.2026 10:00',
          ),
        ];

      await viewModel.fetchQRCodes(l10n);

      expect(viewModel.errorMsg, isEmpty);
      expect(viewModel.qrCodes, hasLength(1));
    });

    test('resetTransientState clears selection and edit state', () {
      final viewModel = QrCodeListPageViewmodel(
        isFirebaseUser: false,
        uid: null,
        repository: _FakeQrCodeRepository(),
      );

      viewModel.selectQRCode('1');
      viewModel.toggleEditingQRCode('1');

      expect(viewModel.selectedQRCodes, contains('1'));
      expect(viewModel.editingQRCodes, contains('1'));

      viewModel.resetTransientState(notify: false);

      expect(viewModel.selectedQRCodes, isEmpty);
      expect(viewModel.editingQRCodes, isEmpty);
    });
  });
}
