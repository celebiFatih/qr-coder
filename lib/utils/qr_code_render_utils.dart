import 'package:qr_flutter/qr_flutter.dart';

abstract final class QRCodeRenderUtils {
  static bool canRender(
    String data, {
    int errorCorrectionLevel = QrErrorCorrectLevel.L,
  }) {
    try {
      final result = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: errorCorrectionLevel,
      );

      final qrCode = result.qrCode;
      if (!result.isValid || qrCode == null) {
        return false;
      }

      // qr_flutter 4.1.0's validator can report an auto-version payload as
      // valid before the QR module matrix is actually generated. The full
      // capacity check happens when QrImage builds that matrix, which is also
      // what QrPainter does before rendering.
      //
      // Constructing QrImage here makes this preflight match the real render
      // path and lets us handle oversized/malformed legacy payloads before a
      // QrImageView reaches Flutter's rendering pipeline.
      QrImage(qrCode);
      return true;
    } on Exception {
      return false;
    }
  }
}
