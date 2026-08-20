import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';

class _FakeQrCodeRepository implements QRCodeRepository {
  @override
  Future<void> deleteAllQrCodes() async {}

  @override
  Future<void> deleteQrCode(String id) async {}

  @override
  Future<List<QRCodeModel>> fetchAllQRCodes() async => <QRCodeModel>[];

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
  test('repository follows the active guest/Firebase session', () {
    final calls = <({bool isFirebaseUser, String? uid})>[];

    QRCodeRepository factory(bool isFirebaseUser, String? uid) {
      calls.add((isFirebaseUser: isFirebaseUser, uid: uid));
      return _FakeQrCodeRepository();
    }

    final viewModel = QRCodeViewModel(
      isFirebaseUser: false,
      uid: null,
      repositoryFactory: factory,
    );
    addTearDown(viewModel.dispose);

    expect(calls, <({bool isFirebaseUser, String? uid})>[
      (isFirebaseUser: false, uid: null),
    ]);

    viewModel.configureRepository(isFirebaseUser: true, uid: 'firebase-user-1');

    expect(calls.last, (isFirebaseUser: true, uid: 'firebase-user-1'));
    expect(calls, hasLength(2));

    // Re-applying the same session should not recreate the repository.
    viewModel.configureRepository(isFirebaseUser: true, uid: 'firebase-user-1');
    expect(calls, hasLength(2));

    viewModel.configureRepository(isFirebaseUser: false, uid: null);
    expect(calls.last, (isFirebaseUser: false, uid: null));
    expect(calls, hasLength(3));
  });
}
