import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_rapository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      : repository =
            MainQrCodeRepository(isFirebaseUser: isFirebaseUser, uid: uid);

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

  void addBarcode(Barcode barcode) {
    final existingBarcodes = _barcodes.map((e) => e.rawValue).toSet();
    if (!existingBarcodes.contains(barcode.rawValue)) {
      _barcodes = List.from(_barcodes)..add(barcode);
      _notifySafely();
    }
  }

  Future<void> saveQrCodeToDb(Barcode barcode, BuildContext context) async {
    errorMsg = '';
    try {
      await repository.insertQrCode(QRCodeModel(
        id: '',
        data: barcode.rawValue ?? '',
        name: AppLocalizations.of(context)!.scannerPage_scannedData,
        createdAt: DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
      ));
    } catch (e) {
      errorMsg = AppLocalizations.of(context)!.scannerPage_saveErrorMsg;
      print(e);
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
