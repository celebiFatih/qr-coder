import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_repository.dart';

class BarcodeScannerViewmodel extends ChangeNotifier {
  MainQrCodeRepository repository;
  List<Barcode> _barcodes = [];
  bool _isBottomSheetOpen = false;
  bool _isCameraLoading = true;
  bool _isDisposed = false;
  String errorMsg = '';

  bool get isBottomSheetOpen => _isBottomSheetOpen;
  bool get isCameraLoading => _isCameraLoading;
  List<Barcode> get barcodes => List.unmodifiable(_barcodes);

  BarcodeScannerViewmodel({required bool isFirebaseUser, required String? uid})
    : repository = MainQrCodeRepository(
        isFirebaseUser: isFirebaseUser,
        uid: uid,
      );

  void clearAll() {
    _barcodes.clear();
    _isBottomSheetOpen = false;
    _isCameraLoading = true;
    _isDisposed = false;
    errorMsg = '';
    notifyListeners();
  }

  set isBottomSheetOpen(bool value) {
    if (_isBottomSheetOpen != value) {
      _isBottomSheetOpen = value;
      _notifySafely();
    }
  }

  set isCameraLoading(bool value) {
    if (_isCameraLoading != value) {
      _isCameraLoading = value;
      _notifySafely();
    }
  }

  void _notifySafely() {
    if (!_isDisposed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          notifyListeners();
        }
      });
    }
  }

  static String? usableRawValue(Barcode barcode) {
    final rawValue = barcode.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    return rawValue;
  }

  static bool hasUsableRawValue(Barcode barcode) {
    return usableRawValue(barcode) != null;
  }

  bool addBarcode(Barcode barcode) {
    final rawValue = usableRawValue(barcode);
    if (rawValue == null) {
      return false;
    }

    final existingBarcodes = _barcodes
        .map(usableRawValue)
        .whereType<String>()
        .toSet();

    if (existingBarcodes.contains(rawValue)) {
      return false;
    }

    _barcodes = List.from(_barcodes)..add(barcode);
    _notifySafely();
    return true;
  }

  Future<bool> saveQrCodeToDb(Barcode barcode, BuildContext context) async {
    errorMsg = '';

    final rawValue = usableRawValue(barcode);
    if (rawValue == null) {
      return false;
    }

    final l10n = AppLocalizations.of(context)!;
    final scannedDataName = l10n.scannerPage_scannedData;
    final saveErrorMsg = l10n.scannerPage_saveErrorMsg;

    try {
      await repository.insertQrCode(
        QRCodeModel(
          id: '',
          data: rawValue,
          name: scannedDataName,
          createdAt: DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
        ),
      );
      return true;
    } catch (e) {
      errorMsg = saveErrorMsg;
      debugPrint('QR code save failed: $e');
      return false;
    }
  }

  void clearBarcodes() {
    _barcodes.clear();
    _notifySafely();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
