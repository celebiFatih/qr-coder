import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/viewmodels/qr_code_display_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/views/qr_code_list_page.dart';
import 'package:qr_coder/widgets/banner_ad_widget.dart';
import 'package:qr_coder/widgets/build_content.dart';
import 'package:qr_coder/widgets/qr_code_display.dart';

class QRCodeDetailPage extends StatefulWidget {
  final QRCodeModel qrCode;
  const QRCodeDetailPage({super.key, required this.qrCode});

  @override
  State<QRCodeDetailPage> createState() => _QRCodeDetailPageState();
}

class _QRCodeDetailPageState extends State<QRCodeDetailPage> {
  final GlobalKey repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Sayfaya her gelişte logo açık başlasın
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<QRCodeDisplayViewModel>().resetLogo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QRCodeViewModel>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFabs(context, viewModel),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.qrCode.name),
      actions: [
        IconButton(
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          icon: const Icon(Icons.home_rounded),
          tooltip:
              AppLocalizations.of(context)!.qrCodeDetail_homePageNavToolTip,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QRCodeListPage())),
          icon: const Icon(Icons.format_list_bulleted_rounded),
          tooltip:
              AppLocalizations.of(context)!.qrCodeDetail_listPageNavToolTip,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // QR alanı — Generator ile aynı mantık
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // Generator'daki gibi, ekrana göre esneyen bir aralık
                    minHeight: constraints.maxHeight * 0.35,
                    maxHeight: constraints.maxHeight * 0.60,
                  ),
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: QRcodeDisplay(
                          data: widget.qrCode.data,
                          repaintKey: repaintKey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Alt kısım (detaylar) Generator’daki gibi Expanded + scroll
            Expanded(
              child: BuildContent(qrCode: widget.qrCode),
            ),
            const SizedBox(height: 8),
            _buildCreateDateTime(context),
            const BannerAdWidget(),
          ],
        );
      },
    );
  }

  // Widget _buildQRCodeSquare() {
  //   return Card(
  //     elevation: 8,
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: RepaintBoundary(
  //         key: repaintKey,
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             final side = constraints.biggest.shortestSide;
  //             final logoSide = side * 0.12;
  //             return SizedBox.expand(
  //               child: Consumer<QRCodeDisplayViewModel>(
  //                 builder: (context, vm, child) =>
  //                     Stack(fit: StackFit.expand, children: [
  //                   QrImageView(
  //                     data: widget.qrCode.data,
  //                     backgroundColor: Colors.white,
  //                     version: QrVersions.auto,
  //                     errorCorrectionLevel: QrErrorCorrectLevel.H,
  //                     embeddedImage: vm.isLogoRemoved
  //                         ? null
  //                         : const AssetImage('assets/img/logo.png'),
  //                     embeddedImageStyle:
  //                         QrEmbeddedImageStyle(size: Size(logoSide, logoSide)),
  //                     errorStateBuilder: (cxt, err) => Center(
  //                       child: Text(AppLocalizations.of(context)!
  //                           .qrcodeDisplay_pageTitle),
  //                     ),
  //                   ),
  //                   if (!vm.isLogoRemoved)
  //                     Center(
  //                       child: SizedBox(
  //                         width: logoSide,
  //                         height: logoSide,
  //                         child: GestureDetector(
  //                           onTap: () => vm.promptRemoveLogo(context),
  //                           behavior: HitTestBehavior.opaque,
  //                         ),
  //                       ),
  //                     )
  //                 ]),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCreateDateTime(BuildContext context) {
    final created =
        DateFormat('dd.MM.yyyy HH:mm').parse(widget.qrCode.createdAt);
    final isEn = AppLocalizations.of(context)!.localeName == 'en';
    final fmt =
        isEn ? DateFormat('MM.dd.yyyy HH:mm') : DateFormat('dd.MM.yyyy HH:mm');
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!
            .qrCodeDetail_createdDateTime(fmt.format(created))),
      ],
    );
  }

  Widget _buildFabs(BuildContext context, QRCodeViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSaveButton(context, viewModel),
        const SizedBox(height: 16),
        _buildShareButton(context, viewModel),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, QRCodeViewModel viewModel) {
    return Consumer<QRCodeViewModel>(
      builder: (context, value, child) {
        return value.isDownloading
            ? const CircularProgressIndicator()
            : FloatingActionButton(
                heroTag: 'saverFab',
                tooltip: AppLocalizations.of(context)!
                    .qrCodeDetail_saveQrCodeButtonToolTip,
                onPressed: () async {
                  _showResolutionPicker(context,
                      (double selectedResolution) async {
                    final filePath = await viewModel.saveQrCode(
                      repaintKey,
                      context,
                      viewModel.selectedResolution, // gerçekten seçilen
                    );
                    _handleSaveResult(context, viewModel, filePath);
                  });
                },
                child: const Icon(Icons.save_alt_rounded),
              );
      },
    );
  }

  void _handleSaveResult(
      BuildContext context, QRCodeViewModel viewModel, String? filePath) {
    if (filePath == null && viewModel.errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMsg, textAlign: TextAlign.center),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            spacing: 5.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.qrCodeDetail_saveSuccessMsg),
              GestureDetector(
                onTap: () => viewModel.openFile(filePath),
                child: Text(
                  AppLocalizations.of(context)!.qrCodeDetail_openSavedQrCode,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildShareButton(BuildContext context, QRCodeViewModel viewModel) {
    return Consumer<QRCodeViewModel>(
      builder: (context, value, child) {
        return value.isSharing
            ? const CircularProgressIndicator()
            : FloatingActionButton(
                heroTag: 'sharerFab',
                tooltip: AppLocalizations.of(context)!
                    .qrCodeDetail_shareQrCodeBtnToolTip,
                onPressed: () async {
                  await viewModel.shareQrCode(repaintKey, context);
                  _handleShareResult(context, viewModel);
                },
                child: const Icon(Icons.share_rounded),
              );
      },
    );
  }

  void _handleShareResult(BuildContext context, QRCodeViewModel viewModel) {
    if (viewModel.errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMsg, textAlign: TextAlign.center),
        ),
      );
    }
  }

  void _showResolutionPicker(
    BuildContext context,
    Function(double) onDownload,
  ) {
    final resolutions = [1.0, 2.0, 3.0];
    final labels = [
      AppLocalizations.of(context)!.qrCodeDetail_resolutionStandard,
      AppLocalizations.of(context)!.qrCodeDetail_resolutionHigh,
      AppLocalizations.of(context)!.qrCodeDetail_resolutionUltra,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.qrCodeDetail_resolution,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.onSurface,
                thickness: 1.0,
                indent: 16.0, // Başlangıç boşluğu
                endIndent: 16.0, // Bitiş boşluğu
              ),
              Consumer<QRCodeViewModel>(
                builder: (context, vm, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: resolutions.length,
                    itemBuilder: (context, index) {
                      final res = resolutions[index];
                      final isSelected = res == vm.selectedResolution;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          onTap: () => vm.selectedResolution = res,
                          tileColor: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            labels[index],
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          trailing: isSelected
                              ? ElevatedButton.icon(
                                  label: Text(AppLocalizations.of(context)!
                                      .qrCodeDetail_download),
                                  icon: const Icon(
                                      Icons.download_for_offline_rounded),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    onDownload(vm.selectedResolution);
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
