import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/l10n/app_localizations_en.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';

class _CrudRepository implements QRCodeRepository {
  Object? updateError;
  Object? deleteError;
  Object? deleteAllError;
  Object? deleteSelectedError;

  List<QRCodeModel> qrCodes = <QRCodeModel>[];
  List<String>? lastDeleteSelectedIds;

  @override
  Future<List<QRCodeModel>> fetchAllQRCodes() async =>
      List<QRCodeModel>.from(qrCodes);

  @override
  Future<void> insertQrCode(QRCodeModel qrCode) async {}

  @override
  Future<void> updateQRCodeName(
    String id,
    Map<String, dynamic> updatedData,
  ) async {
    if (updateError != null) {
      throw updateError!;
    }
  }

  @override
  Future<void> deleteQrCode(String id) async {
    if (deleteError != null) {
      throw deleteError!;
    }
  }

  @override
  Future<void> deleteAllQrCodes() async {
    if (deleteAllError != null) {
      throw deleteAllError!;
    }
    qrCodes.clear();
  }

  @override
  Future<void> deleteQrCodes(List<String> ids) async {
    lastDeleteSelectedIds = List<String>.from(ids);

    if (deleteSelectedError != null) {
      throw deleteSelectedError!;
    }

    qrCodes.removeWhere((qrCode) => ids.contains(qrCode.id));
  }
}

QRCodeModel _model(String id) {
  return QRCodeModel(
    id: id,
    data: 'data-$id',
    name: 'QR $id',
    createdAt: '20.08.2026 12:00',
  );
}

void main() {
  final l10n = AppLocalizationsEn();

  test('rename failure exposes action error and notifies listeners', () async {
    final repository = _CrudRepository()..updateError = Exception('offline');
    final viewModel = QrCodeListPageViewmodel(
      isFirebaseUser: false,
      uid: null,
      repository: repository,
    );
    addTearDown(viewModel.dispose);

    var notificationCount = 0;
    viewModel.addListener(() => notificationCount++);

    final success = await viewModel.updateQRCodeName('1', 'New name', l10n);

    expect(success, isFalse);
    expect(viewModel.actionErrorMsg, l10n.qrCodeList_updateDescriptionErrorMsg);
    expect(notificationCount, greaterThan(0));
    expect(viewModel.errorMsg, isEmpty);
  });

  test(
    'single-delete failure keeps list state and exposes action error',
    () async {
      final repository = _CrudRepository()
        ..qrCodes = <QRCodeModel>[_model('1')]
        ..deleteError = Exception('permission-denied');

      final viewModel = QrCodeListPageViewmodel(
        isFirebaseUser: false,
        uid: null,
        repository: repository,
      );
      addTearDown(viewModel.dispose);

      viewModel.qrCodes = List<QRCodeModel>.from(repository.qrCodes);

      final success = await viewModel.deleteQRCode('1', l10n);

      expect(success, isFalse);
      expect(viewModel.qrCodes, hasLength(1));
      expect(viewModel.actionErrorMsg, l10n.qrCodeList_deleteErrorMsg);
      expect(viewModel.errorMsg, isEmpty);
    },
  );

  test('delete-all failure does not clear current list', () async {
    final repository = _CrudRepository()
      ..qrCodes = <QRCodeModel>[_model('1'), _model('2')]
      ..deleteAllError = Exception('offline');

    final viewModel = QrCodeListPageViewmodel(
      isFirebaseUser: false,
      uid: null,
      repository: repository,
    );
    addTearDown(viewModel.dispose);

    viewModel.qrCodes = List<QRCodeModel>.from(repository.qrCodes);

    final success = await viewModel.deleteAllQRCodes(l10n);

    expect(success, isFalse);
    expect(viewModel.qrCodes, hasLength(2));
    expect(viewModel.actionErrorMsg, l10n.qrCodeList_deleteAllErrorMsg);
  });

  test(
    'selected-delete failure is one operation and preserves selection',
    () async {
      final repository = _CrudRepository()
        ..qrCodes = <QRCodeModel>[_model('1'), _model('2')]
        ..deleteSelectedError = Exception('offline');

      final viewModel = QrCodeListPageViewmodel(
        isFirebaseUser: false,
        uid: null,
        repository: repository,
      );
      addTearDown(viewModel.dispose);

      viewModel.qrCodes = List<QRCodeModel>.from(repository.qrCodes);
      viewModel.selectQRCode('1');
      viewModel.selectQRCode('2');

      final success = await viewModel.deleteSelectedQRCodes(l10n);

      expect(success, isFalse);
      expect(repository.lastDeleteSelectedIds, <String>['1', '2']);
      expect(viewModel.selectedQRCodes, <String>['1', '2']);
      expect(viewModel.qrCodes, hasLength(2));
      expect(viewModel.actionErrorMsg, l10n.qrCodeList_deleteSelectedErrorMsg);
    },
  );

  test(
    'successful selected delete clears selection and refreshes list',
    () async {
      final repository = _CrudRepository()
        ..qrCodes = <QRCodeModel>[_model('1'), _model('2'), _model('3')];

      final viewModel = QrCodeListPageViewmodel(
        isFirebaseUser: false,
        uid: null,
        repository: repository,
      );
      addTearDown(viewModel.dispose);

      viewModel.qrCodes = List<QRCodeModel>.from(repository.qrCodes);
      viewModel.selectQRCode('1');
      viewModel.selectQRCode('2');

      final success = await viewModel.deleteSelectedQRCodes(l10n);

      expect(success, isTrue);
      expect(viewModel.selectedQRCodes, isEmpty);
      expect(viewModel.qrCodes.map((e) => e.id), <String>['3']);
      expect(viewModel.actionErrorMsg, isEmpty);
    },
  );
}
