import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_rapository.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRCodeViewModel extends ChangeNotifier {
  MainQrCodeRepository repository;
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

  QRCodeViewModel({required bool isFirebaseUser, required String? uid})
      : repository =
            MainQrCodeRepository(isFirebaseUser: isFirebaseUser, uid: uid);

  void clearAll() async {
    controller.clear();
    sharedText = '';
    qrData = '';
    errorMsg = '';
    qrCodeModel = null;
    isLoading = false;
    isDownloading = false;
    isSharing = false;
    await Constants().prefs.then((prefs) => prefs.setBool('isGuest', false));
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  /// Receive the shared text
  Future<void> receiveSharedText(BuildContext context) async {
    const MethodChannel platform = MethodChannel('com.qrcoder.app/app');
    try {
      final String? sharedData = await platform.invokeMethod('getSharedText');
      if (sharedData != null && sharedData.isNotEmpty) {
        final timestamp = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
        sharedText = sharedData;
        qrData = sharedData;
        controller.text = sharedData;
        qrCodeModel = QRCodeModel(
          id: ' ',
          data: sharedData,
          name: AppLocalizations.of(context)!.qrCodeGenerator_sharedData,
          createdAt: timestamp,
        );
        await saveQRCodeToDb(context);
        notifyListeners();
      }
    } catch (e) {
      errorMsg = AppLocalizations.of(context)!.qrCodeGenerator_receiveErrorMsg;
      print(e);
    }
  }

  /// Save the QR code to the device
  Future<String?> saveQrCode(GlobalKey repaintKey, BuildContext context) async {
    errorMsg = '';
    isDownloading = true;
    String filePath = '';
    notifyListeners();
    try {
      final plugin = DeviceInfoPlugin();
      final androidInfo = await plugin.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      PermissionStatus storageStatus;

      // Android 13 (SDK 33) and above do not require storage permission
      if (sdkInt < 33) {
        storageStatus = await Permission.storage.request();
      } else {
        storageStatus = PermissionStatus.granted;
      }

      if (storageStatus != PermissionStatus.granted) {
        if (storageStatus == PermissionStatus.permanentlyDenied) {
          openAppSettings();
        }
        errorMsg = AppLocalizations.of(context)!
            .qrCodeGenerator_savePermissionErrorMsg;
        print(errorMsg);
        return null;
      }

      // Catch the QR code and save it
      final boundary = repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save the PNG file to the device gallery
      final result = await ImageGallerySaver.saveImage(pngBytes,
          quality: 100,
          name: "qr_code_${DateTime.now().millisecondsSinceEpoch}");
      if (result['isSuccess']) {
        filePath = result['filePath'];
        print('QR kodu galeriye kaydedildi: ${result['filePath']}');
      } else {
        errorMsg = AppLocalizations.of(context)!.qrCodeGenerator_saveErrorMsg;
        print(errorMsg);
      }
    } catch (e) {
      errorMsg = AppLocalizations.of(context)!.qrCodeGenerator_saveErrorMsg;
      print(e);
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
    try {
      await repository.insertQrCode(qrCodeModel!);
    } catch (e) {
      errorMsg = AppLocalizations.of(context)!.qrCodeGenerator_saveToDbErrorMsg;
      print(e);
    }
  }

  /// Share the QR code
  Future<void> shareQrCode(GlobalKey repaintKey, BuildContext context) async {
    errorMsg = '';
    isSharing = true;
    notifyListeners();
    try {
      // Get the QR code image
      final boundary = repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Create a temporary file and save the QR code image
      final tempDir = await getTemporaryDirectory();
      final file = await File(
              '${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          text: AppLocalizations.of(context)!.qrCodeGenerator_sharedTitle);
    } catch (e) {
      errorMsg = AppLocalizations.of(context)!.qrCodeGenerator_sharedErrorMsg;
      print(e);
    } finally {
      isSharing = false;
      notifyListeners();
    }
  }

  /// Generate the QR code
  Future<void> generateQRCode(BuildContext context) async {
    errorMsg = '';
    final data = controller.text;
    if (data.isEmpty) {
      errorMsg = AppLocalizations.of(context)!.qrCodeGenerator_dataEmptyMsg;
      focusNode.requestFocus();
      notifyListeners();
      return;
    } else if (data.length > 2500) {
      errorMsg =
          AppLocalizations.of(context)!.qrCodeGenerator_dataTooLongErrMsg;
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
          name: AppLocalizations.of(context)!.qrCodeGenerator_qrCode);
      await saveQRCodeToDb(context);
      focusNode.unfocus();
      notifyListeners();
    } catch (e) {
      errorMsg =
          AppLocalizations.of(context)!.qrCodeGenerator_qrCodeGeneratorErrMsg;
      focusNode.unfocus();
      print(e);
    }
  }

  void openFile(String? filePath) async {
    if (filePath != null) {
      final uri = Uri.parse(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Dosya açılamadı: $filePath');
      }
    } else {
      print('Dosya yolu geçersiz: $filePath');
    }
  }
}
