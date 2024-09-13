// main_qrcode_repository.dart
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/firebase_qrcode_repository.dart';
import 'package:qr_coder/repository/local_qrcode_repository.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';

class MainQrCodeRepository implements QRCodeRepository {
  late final QRCodeRepository _repository;

  MainQrCodeRepository({required bool isFirebaseUser, required String? uid}) {
    if (isFirebaseUser && uid != null) {
      _repository = FirebaseQrCodeRepository(uid);
    } else {
      _repository = LocalQrCodeRepository();
    }
  }

  @override
  Future<void> insertQrCode(QRCodeModel qrCode) {
    return _repository.insertQrCode(qrCode);
  }

  @override
  Future<void> deleteQrCode(String id) {
    return _repository.deleteQrCode(id);
  }

  @override
  Future<void> deleteAllQrCodes() {
    return _repository.deleteAllQrCodes();
  }

  @override
  Future<void> updateQRCodeName(String id, Map<String, dynamic> updatedData) {
    return _repository.updateQRCodeName(id, updatedData);
  }

  @override
  Future<List<QRCodeModel>> fetchAllQRCodes() {
    return _repository.fetchAllQRCodes();
  }
}
