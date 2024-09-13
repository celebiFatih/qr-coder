import 'package:qr_coder/models/qr_code_model.dart';

abstract class QRCodeRepository {
  Future<void> insertQrCode(QRCodeModel qrCode);
  Future<void> deleteQrCode(String id);
  Future<void> deleteAllQrCodes();
  Future<void> updateQRCodeName(String id, Map<String, dynamic> updatedData);
  Future<List<QRCodeModel>> fetchAllQRCodes();
}
