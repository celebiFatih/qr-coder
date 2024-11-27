import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/views/qr_code_list_page.dart';
import 'package:qr_coder/widgets/banner_ad_widget.dart';
import 'package:qr_coder/widgets/build_content.dart';
import 'package:qr_coder/widgets/qr_code_display.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRCodeDetailPage extends StatelessWidget {
  final QRCodeModel qrCode;
  const QRCodeDetailPage({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    final GlobalKey repaintKey = GlobalKey();
    final viewModel = Provider.of<QRCodeViewModel>(context, listen: false);
    repaintKey.currentContext?.findRenderObject()?.dispose();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, repaintKey),
      floatingActionButton: _buildFabs(context, repaintKey, viewModel),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(qrCode.name),
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

  Widget _buildBody(BuildContext context, GlobalKey repaintKey) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildQRCodeCard(context, repaintKey),
          const SizedBox(height: 16),
          Expanded(flex: 3, child: BuildContent(qrCode: qrCode)),
          const SizedBox(height: 8),
          _buildCreateDateTime(context),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildQRCodeCard(BuildContext context, GlobalKey repaintKey) {
    return Center(
      child: Hero(
        tag: qrCode,
        child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: QRcodeDisplay(data: qrCode.data, repaintKey: repaintKey),
            )),
      ),
    );
  }

  Widget _buildCreateDateTime(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.qrCodeDetail_createdDateTime(
            AppLocalizations.of(context)!.localeName == 'en'
                ? DateFormat('MM.dd.yyyy HH:mm').format(
                    DateFormat('dd.MM.yyyy HH:mm').parse(qrCode.createdAt))
                : DateFormat('dd.MM.yyyy HH:mm').format(
                    DateFormat('dd.MM.yyyy HH:mm').parse(qrCode.createdAt)))),
      ],
    );
  }

  Widget _buildFabs(
      BuildContext context, GlobalKey repaintKey, QRCodeViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSaveButton(context, repaintKey, viewModel),
        const SizedBox(height: 16),
        _buildShareButton(context, repaintKey, viewModel),
      ],
    );
  }

  Widget _buildSaveButton(
      BuildContext context, GlobalKey repaintKey, QRCodeViewModel viewModel) {
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
                        repaintKey, context, selectedResolution);
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget _buildShareButton(
      BuildContext context, GlobalKey repaintKey, QRCodeViewModel viewModel) {
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
      BuildContext context, Function(double) onDownload) {
    List<double> resolutions = [1.0, 2.0, 3.0]; // Çözünürlük seçenekleri
    double selectedResolution = 2.0; // Varsayılan çözünürlük
    List<String> resolutionLabels = [
      AppLocalizations.of(context)!.qrCodeDetail_resolutionStandard,
      AppLocalizations.of(context)!.qrCodeDetail_resolutionHigh,
      AppLocalizations.of(context)!.qrCodeDetail_resolutionUltra
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
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
                builder: (context, viewModel, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: resolutions.length,
                    itemBuilder: (context, index) {
                      final resolution = resolutions[index];
                      final isSelected =
                          resolution == viewModel.selectedResolution;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          onTap: () {
                            viewModel.selectedResolution = resolution;
                          },
                          tileColor: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            resolutionLabels[index],
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
                                    onDownload(selectedResolution);
                                  },
                                  style:
                                      ElevatedButton.styleFrom(elevation: 4.0),
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
