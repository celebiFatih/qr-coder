import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';
import 'package:qr_coder/views/qr_code_detail_page.dart';
import 'package:qr_coder/widgets/scanner_error_widget.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController();
  StreamSubscription<Object>? _streamSubscription;
  bool _isCameraStarted = false;
  late BarcodeScannerViewmodel provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = context.read<BarcodeScannerViewmodel>();
    if (!_isCameraStarted) {
      _startCamera(provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildCameraView(context),
          _buildBottomToggle(context),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _stopCamera(provider);
        break;
      case AppLifecycleState.resumed:
        if (!_isCameraStarted) {
          _startCamera(provider);
        }
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera(provider);
    unawaited(controller.dispose());
    super.dispose();
  }

  // AppBar oluşturma
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.scannerPage_title),
      actions: [
        Consumer<BarcodeScannerViewmodel>(
          builder: (context, viewModel, child) {
            return IconButton(
              tooltip:
                  AppLocalizations.of(context)!.scannerPage_refreshBtnToolTip,
              onPressed: () => _refreshCamera(viewModel),
              icon: const Icon(Icons.refresh),
            );
          },
        ),
      ],
    );
  }

  // Kamera görünümünü oluşturma
  Widget _buildCameraView(BuildContext context) {
    return Consumer<BarcodeScannerViewmodel>(
      builder: (context, viewModel, child) {
        return viewModel.isCameraLoading
            ? const Center(child: CircularProgressIndicator())
            : MobileScanner(
                controller: controller,
                errorBuilder: (context, error) {
                  return viewModel.isCameraLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ScannerErrorWidget(error: error);
                },
                onDetect: (barcodes) {
                  if (!viewModel.isBottomSheetOpen) {
                    _showBottomSheet(context, viewModel);
                  }
                },
              );
      },
    );
  }

  // Alt sayfa tetikleyicisini oluşturma
  Widget _buildBottomToggle(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: _toggleBottomSheet,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.width * 0.01,
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  // Alt sayfa gösterme
  void _showBottomSheet(
      BuildContext context, BarcodeScannerViewmodel viewModel) {
    viewModel.isBottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFCDDC39).withOpacity(0.8),
      constraints: const BoxConstraints(maxHeight: double.infinity),
      builder: (context) => _buildBottomSheetContent(context, viewModel),
    ).whenComplete(() {
      viewModel.isBottomSheetOpen = false;
    });
  }

  // Alt sayfa içeriğini oluşturma
  Widget _buildBottomSheetContent(
      BuildContext context, BarcodeScannerViewmodel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: _buildBarcodesListView()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 10,
            ),
            onPressed: viewModel.clearBarcodes,
            child: Text(
              AppLocalizations.of(context)!.scannerPage_cleanScannedListBtn,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Barkod listeleme görünümü oluşturma
  Widget _buildBarcodesListView() {
    return Consumer<BarcodeScannerViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.barcodes.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.scannerPage_emptyScannedList,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: viewModel.barcodes.length,
          itemBuilder: (context, index) {
            return _buildBarcodeListItem(context, viewModel, index);
          },
        );
      },
    );
  }

  // Barkod liste öğesi oluşturma
  Widget _buildBarcodeListItem(
      BuildContext context, BarcodeScannerViewmodel viewModel, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: const Icon(Icons.qr_code_scanner),
        title: Text(
          '${AppLocalizations.of(context)!.scannerPage_scannedData}:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          viewModel.barcodes[index].rawValue ??
              AppLocalizations.of(context)!.scannerPage_unkonwnBarcode,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: () async {
          await _stopCamera(provider);
          final scaffoldMsg = ScaffoldMessenger.of(context);
          await viewModel.saveQrCodeToDb(viewModel.barcodes[index], context);
          if (viewModel.errorMsg.isNotEmpty) {
            scaffoldMsg.showSnackBar(
              SnackBar(
                content: Text(viewModel.errorMsg, textAlign: TextAlign.center),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRCodeDetailPage(
                  qrCode: QRCodeModel(
                    id: '',
                    data: viewModel.barcodes[index].rawValue ?? '',
                    name: AppLocalizations.of(context)!.scannerPage_scannedData,
                    createdAt:
                        DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
                  ),
                ),
              ),
            ).then((value) => _startCamera(provider));
            scaffoldMsg.showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.scannerPage_savedToListMsg,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Kamerayı başlatma
  Future<void> _startCamera(BarcodeScannerViewmodel provider) async {
    provider.isCameraLoading = true;

    if (Platform.isAndroid && (await _isAndroid33OrAbove())) {
      _streamSubscription = controller.barcodes.listen(_handleBarcode);
      await controller.start().then((_) {
        _isCameraStarted = true;
        provider.isCameraLoading = false;
      }).catchError((error) {
        provider.isCameraLoading = false;
        provider.errorMsg =
            AppLocalizations.of(context)!.scannerPage_cameraStartError;
      });
    } else {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
      if (status.isGranted) {
        _streamSubscription = controller.barcodes.listen(_handleBarcode);
        await controller.start().then((_) {
          _isCameraStarted = true;
          provider.isCameraLoading = false;
        }).catchError((error) {
          provider.isCameraLoading = false;
          provider.errorMsg =
              AppLocalizations.of(context)!.scannerPage_cameraStartError;
        });
      } else {
        provider.isCameraLoading = false;
        provider.errorMsg =
            AppLocalizations.of(context)!.scannerErrorWidget_permissionDenied;
      }
    }
  }

  // Kamerayı durdurma
  Future<void> _stopCamera(BarcodeScannerViewmodel provider) async {
    provider.isCameraLoading = true;
    unawaited(_streamSubscription?.cancel());
    _streamSubscription = null;
    unawaited(controller.stop());
    _isCameraStarted = false;
  }

  // Kamerayı yenileme
  Future<void> _refreshCamera(BarcodeScannerViewmodel provider) async {
    await _stopCamera(provider);
    await Future.delayed(const Duration(milliseconds: 300));
    _startCamera(provider);
  }

  // Barkodları işleme
  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      for (var barcode in barcodes.barcodes) {
        provider.addBarcode(barcode);
      }
    }
  }

  // Alt sayfa tetikleme
  void _toggleBottomSheet() {
    if (provider.isBottomSheetOpen) {
      Navigator.pop(context);
    } else {
      _showBottomSheet(context, provider);
    }
  }

  // Android 33 veya üstü kontrolü
  Future<bool> _isAndroid33OrAbove() async {
    if (Platform.isAndroid) {
      var androidVersion = await DeviceInfoPlugin().androidInfo;
      return androidVersion.version.sdkInt >= 33;
    }
    return false;
  }
}
