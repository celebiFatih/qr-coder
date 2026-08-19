import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_repository.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

typedef QrCodeRepositoryFactory =
    QRCodeRepository Function(bool isFirebaseUser, String? uid);

QRCodeRepository _createMainQrCodeRepository(bool isFirebaseUser, String? uid) {
  return MainQrCodeRepository(isFirebaseUser: isFirebaseUser, uid: uid);
}

class QRCodeViewModel extends ChangeNotifier {
  late QRCodeRepository _repository;
  final QrCodeRepositoryFactory _repositoryFactory;
  bool _repositoryInitialized = false;
  bool _usesFirebaseRepository = false;
  String? _repositoryUid;
  final TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  String sharedText = '';
  String qrData = '';
  bool isLoading = false;
  bool isDownloading = false;
  bool isSharing = false;
  QRCodeModel? qrCodeModel;
  List<QRCodeModel> qrCodes = [];
  String errorMsg = '';
  double _selectedResolution = 2.0;

  QRCodeViewModel({
    required bool isFirebaseUser,
    required String? uid,
    QrCodeRepositoryFactory? repositoryFactory,
  }) : _repositoryFactory = repositoryFactory ?? _createMainQrCodeRepository {
    configureRepository(isFirebaseUser: isFirebaseUser, uid: uid);
  }

  void configureRepository({
    required bool isFirebaseUser,
    required String? uid,
  }) {
    final useFirebase = isFirebaseUser && uid != null;
    final normalizedUid = useFirebase ? uid : null;

    if (_repositoryInitialized &&
        _usesFirebaseRepository == useFirebase &&
        _repositoryUid == normalizedUid) {
      return;
    }

    _repository = _repositoryFactory(useFirebase, normalizedUid);
    _repositoryInitialized = true;
    _usesFirebaseRepository = useFirebase;
    _repositoryUid = normalizedUid;
  }

  void clearAll() {
    controller.clear();
    sharedText = '';
    qrData = '';
    errorMsg = '';
    qrCodeModel = null;
    isLoading = false;
    isDownloading = false;
    isSharing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  double get selectedResolution => _selectedResolution;
  set selectedResolution(double value) {
    if (_selectedResolution != value) {
      _selectedResolution = value;
      notifyListeners();
    }
  }

  /// Receive the shared text
  Future<void> receiveSharedText(BuildContext context) async {
    const MethodChannel platform = MethodChannel('com.qrcoder.app/app');
    final l10n = AppLocalizations.of(context)!;
    final sharedDataName = l10n.qrCodeGenerator_sharedData;
    final receiveErrorMsg = l10n.qrCodeGenerator_receiveErrorMsg;

    try {
      final String? sharedData = await platform.invokeMethod('getSharedText');
      if (!context.mounted) return;
      if (sharedData != null && sharedData.isNotEmpty) {
        final timestamp = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
        sharedText = sharedData;
        qrData = sharedData;
        controller.text = sharedData;
        qrCodeModel = QRCodeModel(
          id: ' ',
          data: sharedData,
          name: sharedDataName,
          createdAt: timestamp,
        );
        await saveQRCodeToDb(context);
        notifyListeners();
      }
    } catch (e) {
      errorMsg = receiveErrorMsg;
      debugPrint('Shared text receive failed: $e');
    }
  }

  /// Save the QR code to the device
  Future<String?> saveQrCode(
    GlobalKey repaintKey,
    BuildContext context,
    double pixelRatio,
  ) async {
    errorMsg = '';
    isDownloading = true;
    String filePath = '';
    final l10n = AppLocalizations.of(context)!;
    final savePermissionErrorMsg = l10n.qrCodeGenerator_savePermissionErrorMsg;
    final saveErrorMsg = l10n.qrCodeGenerator_saveErrorMsg;
    notifyListeners();

    try {
      PermissionStatus storageStatus = PermissionStatus.granted;

      // Legacy storage permission is only relevant on older Android versions.
      // Android 13+ uses scoped media storage and does not grant
      // READ/WRITE_EXTERNAL_STORAGE.
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt < 33) {
          storageStatus = await Permission.storage.request();
        }
      }

      if (storageStatus != PermissionStatus.granted) {
        if (storageStatus == PermissionStatus.permanentlyDenied) {
          openAppSettings();
        }
        errorMsg = savePermissionErrorMsg;
        // print(errorMsg);
        return null;
      }

      // Catch the QR code and save it
      await WidgetsBinding
          .instance
          .endOfFrame; // UI güncellensin, logo kaldırıldıysa yansısın
      final boundary =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save the PNG file to the device gallery
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: "qr_code_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        filePath = result['filePath'];
        // print('QR kodu galeriye kaydedildi: ${result['filePath']}');
      } else {
        errorMsg = saveErrorMsg;
        return null;
      }
    } catch (e) {
      errorMsg = saveErrorMsg;
      return null;
    } finally {
      isDownloading = false;
      await Future.delayed(const Duration(seconds: 2));
      notifyListeners();
    }
    return filePath;
  }

  /// Save the QR code to the database
  Future<void> saveQRCodeToDb(BuildContext context) async {
    errorMsg = '';
    final saveToDbErrorMsg = AppLocalizations.of(
      context,
    )!.qrCodeGenerator_saveToDbErrorMsg;
    try {
      await _repository.insertQrCode(qrCodeModel!);
    } catch (e) {
      errorMsg = saveToDbErrorMsg;
      debugPrint('QR code database save failed: $e');
    }
  }

  /// Share the QR code
  Future<void> shareQrCode(GlobalKey repaintKey, BuildContext context) async {
    errorMsg = '';
    isSharing = true;
    final l10n = AppLocalizations.of(context)!;
    final sharedTitle = l10n.qrCodeGenerator_sharedTitle;
    final sharedErrorMsg = l10n.qrCodeGenerator_sharedErrorMsg;
    notifyListeners();
    try {
      // Get the QR code image
      await WidgetsBinding
          .instance
          .endOfFrame; // UI güncellensin, logo kaldırıldıysa yansısın
      final boundary =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: selectedResolution);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Create a temporary file and save the QR code image
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      // Share the file using the current share_plus API.
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: sharedTitle),
      );
    } catch (e) {
      errorMsg = sharedErrorMsg;
    } finally {
      isSharing = false;
      notifyListeners();
    }
  }

  /// Generate the QR code
  Future<void> generateQRCode(BuildContext context) async {
    errorMsg = '';
    final l10n = AppLocalizations.of(context)!;
    final generatedQrName = l10n.qrCodeGenerator_qrCode;
    final generatorErrorMsg = l10n.qrCodeGenerator_qrCodeGeneratorErrMsg;
    final data = controller.text;
    if (data.isEmpty) {
      errorMsg = l10n.qrCodeGenerator_dataEmptyMsg;
      focusNode.requestFocus();
      notifyListeners();
      return;
    } else if (data.length > 2500) {
      errorMsg = l10n.qrCodeGenerator_dataTooLongErrMsg;
      focusNode.unfocus();
      notifyListeners();
      return;
    }
    try {
      final timestamp = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
      qrData = data;
      qrCodeModel = QRCodeModel(
        id: '',
        data: data,
        createdAt: timestamp,
        name: generatedQrName,
      );
      await saveQRCodeToDb(context);
      focusNode.unfocus();
      notifyListeners();
    } catch (e) {
      errorMsg = generatorErrorMsg;
      focusNode.unfocus();
      debugPrint('QR code generation failed: $e');
    }
  }

  void openFile(String? filePath) async {
    if (filePath != null) {
      final uri = Uri.parse(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        debugPrint('Dosya açılamadı: $filePath');
      }
    } else {
      debugPrint('Dosya yolu geçersiz: $filePath');
    }
  }
}
