import 'package:qr_coder/models/qr_code_model.dart';

abstract class QRCodeRepository {
  Future<void> insertQrCode(QRCodeModel qrCode);
  Future<void> deleteQrCode(String id);

  /// Deletes a group of QR codes.
  ///
  /// The default implementation preserves compatibility for test/fake
  /// repositories. Production repositories override this method with an
  /// atomic backend operation.
  Future<void> deleteQrCodes(List<String> ids) async {
    for (final id in ids) {
      await deleteQrCode(id);
    }
  }

  Future<void> deleteAllQrCodes();
  Future<void> updateQRCodeName(String id, Map<String, dynamic> updatedData);
  Future<List<QRCodeModel>> fetchAllQRCodes();
}
