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
import 'package:qr_coder/repository/main_qrcode_repository.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';
import 'package:qr_coder/views/qr_code_detail_page.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/scanner_error_widget.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
  );
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

    final user = Auth().currentUser;
    provider.repository = MainQrCodeRepository(
      isFirebaseUser: user != null,
      uid: user?.uid,
    );

    if (!_isCameraStarted) {
      _startCamera(provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraView(context),
          _buildScannerGuide(context),
          _buildResultsAction(context),
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
            return AppIconButton(
              tooltip: AppLocalizations.of(context)!
                  .scannerPage_refreshBtnToolTip,
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
        final scheme = Theme.of(context).colorScheme;

        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: controller,
              errorBuilder: (context, error) {
                return ScannerErrorWidget(
                  error: error,
                  onRetry: () {
                    unawaited(_refreshCamera(viewModel));
                  },
                );
              },
              onDetect: (capture) {
                // The controller stream owns list updates. Detection must not
                // steal focus by opening a modal sheet on the first scan; the
                // user opens results explicitly from the persistent count button.
                if (!capture.barcodes.any(
                  BarcodeScannerViewmodel.hasUsableRawValue,
                )) {
                  return;
                }
              },
            ),
            if (viewModel.isCameraLoading)
              ColoredBox(
                color: scheme.scrim.withValues(alpha: 0.55),
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildScannerGuide(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return IgnorePointer(
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          96,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayoutMetrics.compactStateMaxWidth,
                ),
                child: Material(
                  color: scheme.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(AppRadii.control),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!
                          .scannerPage_emptyScannedList,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var side = constraints.maxWidth;
                  if (side > constraints.maxHeight) {
                    side = constraints.maxHeight;
                  }
                  if (side > 320) side = 320;

                  return Center(
                    child: SizedBox.square(
                      dimension: side,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.surface),
                          border: Border.all(color: scheme.tertiary, width: 3),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsAction(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.md),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Consumer<BarcodeScannerViewmodel>(
          builder: (context, viewModel, child) {
            return FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .tertiaryContainer,
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onTertiaryContainer,
              ),
              onPressed: _toggleBottomSheet,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: Text(
                '${AppLocalizations.of(context)!.scannerPage_scannedData} '
                '(${viewModel.barcodes.length})',
              ),
            );
          },
        ),
      ),
    );
  }

  // Alt sayfa gösterme
  void _showBottomSheet(
    BuildContext context,
    BarcodeScannerViewmodel viewModel,
  ) {
    viewModel.isBottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final availableHeight = MediaQuery.sizeOf(context).height;
        final initialSize = AppBreakpoints.isShortViewport(availableHeight)
            ? 0.76
            : 0.56;

        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.38,
          initialChildSize: initialSize,
          maxChildSize: 0.94,
          builder: (context, scrollController) =>
              _buildBottomSheetContent(context, viewModel, scrollController),
        );
      },
    ).whenComplete(() {
      viewModel.isBottomSheetOpen = false;
    });
  }

  // Alt sayfa içeriğini oluşturma
  Widget _buildBottomSheetContent(
    BuildContext context,
    BarcodeScannerViewmodel viewModel,
    ScrollController scrollController,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l10n.scannerPage_scannedData),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: _buildBarcodesListView(scrollController)),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(top: AppSpacing.sm),
            child: Consumer<BarcodeScannerViewmodel>(
              builder: (context, scannerViewModel, child) {
                if (scannerViewModel.barcodes.isEmpty) {
                  return const SizedBox.shrink();
                }

                return OutlinedButton.icon(
                  onPressed: scannerViewModel.clearBarcodes,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text(l10n.scannerPage_cleanScannedListBtn),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Barkod listeleme görünümü oluşturma
  Widget _buildBarcodesListView(ScrollController scrollController) {
    return Consumer<BarcodeScannerViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.barcodes.isEmpty) {
          return CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppStateView.empty(
                  message: AppLocalizations.of(context)!
                      .scannerPage_emptyScannedList,
                  icon: Icons.qr_code_scanner_rounded,
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          itemCount: viewModel.barcodes.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            return _buildBarcodeListItem(context, viewModel, index);
          },
        );
      },
    );
  }

  // Barkod liste öğesi oluşturma
  Widget _buildBarcodeListItem(
    BuildContext context,
    BarcodeScannerViewmodel viewModel,
    int index,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final scannedDataName = l10n.scannerPage_scannedData;
    final savedToListMsg = l10n.scannerPage_savedToListMsg;

    final displayValue =
        viewModel.barcodes[index].rawValue ?? l10n.scannerPage_unkonwnBarcode;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: const Icon(Icons.qr_code_2_rounded),
        title: Text(
          displayValue,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(scannedDataName),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final barcode = viewModel.barcodes[index];
          final rawValue = BarcodeScannerViewmodel.usableRawValue(barcode);

          // Invalid scanner results are filtered before they reach the list,
          // but keep this boundary guard so an empty payload can never be
          // persisted or forwarded to the detail page.
          if (rawValue == null) {
            return;
          }

          await _stopCamera(provider);
          if (!mounted) return;
          if (!context.mounted) {
            await _startCamera(provider);
            return;
          }

          final saved = await viewModel.saveQrCodeToDb(barcode, context);
          if (!mounted) return;
          if (!context.mounted) {
            await _startCamera(provider);
            return;
          }

          final scaffoldMsg = ScaffoldMessenger.of(context);
          if (!saved) {
            if (viewModel.errorMsg.isNotEmpty) {
              scaffoldMsg.showSnackBar(
                SnackBar(
                  content: Text(
                    viewModel.errorMsg,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Kayıt başarısız olduğunda kullanıcı taramaya devam edebilsin.
            await _startCamera(provider);
            return;
          }

          scaffoldMsg.showSnackBar(
            SnackBar(
              content: Text(savedToListMsg, textAlign: TextAlign.center),
            ),
          );

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRCodeDetailPage(
                qrCode: QRCodeModel(
                  id: '',
                  data: rawValue,
                  name: scannedDataName,
                  createdAt: DateFormat('dd.MM.yyyy HH:mm')
                      .format(DateTime.now()),
                ),
              ),
            ),
          );

          if (!mounted) return;
          await _startCamera(provider);
        },
      ),
    );
  }

  // Kamerayı başlatma
  Future<void> _startCamera(BarcodeScannerViewmodel provider) async {
    if (_isCameraStarted) {
      provider.isCameraLoading = false;
      return;
    }

    provider.isCameraLoading = true;
    final l10n = AppLocalizations.of(context)!;
    final cameraStartError = l10n.scannerPage_cameraStartError;
    final permissionDeniedError = l10n.scannerErrorWidget_permissionDenied;

    if (Platform.isAndroid && (await _isAndroid33OrAbove())) {
      _streamSubscription = controller.barcodes.listen(_handleBarcode);
      await controller
          .start()
          .then((_) {
            _isCameraStarted = true;
            provider.isCameraLoading = false;
          })
          .catchError((error) {
            provider.isCameraLoading = false;
            provider.errorMsg = cameraStartError;
          });
    } else {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
      if (status.isGranted) {
        _streamSubscription = controller.barcodes.listen(_handleBarcode);
        await controller
            .start()
            .then((_) {
              _isCameraStarted = true;
              provider.isCameraLoading = false;
            })
            .catchError((error) {
              provider.isCameraLoading = false;
              provider.errorMsg = cameraStartError;
            });
      } else {
        provider.isCameraLoading = false;
        provider.errorMsg = permissionDeniedError;
      }
    }
  }

  // Kamerayı durdurma
  Future<void> _stopCamera(BarcodeScannerViewmodel provider) async {
    final streamSubscription = _streamSubscription;
    _streamSubscription = null;

    if (streamSubscription != null) {
      try {
        await streamSubscription.cancel();
      } catch (error) {
        debugPrint('Barcode stream cancellation failed: $error');
      }
    }

    try {
      await controller.stop();
    } catch (error) {
      debugPrint('Camera stop failed: $error');
    } finally {
      _isCameraStarted = false;
    }
  }

  // Kamerayı yenileme
  Future<void> _refreshCamera(BarcodeScannerViewmodel provider) async {
    if (provider.isCameraLoading) {
      return;
    }

    // Refresh süresince MobileScanner widget tree'de kalır; kullanıcıya yalnızca
    // kamera görünümünün üzerinde bir loading overlay gösterilir.
    provider.isCameraLoading = true;

    try {
      await _stopCamera(provider);

      if (!mounted) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!mounted) {
        return;
      }

      await _startCamera(provider);
    } finally {
      if (mounted) {
        provider.isCameraLoading = false;
      }
    }
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
