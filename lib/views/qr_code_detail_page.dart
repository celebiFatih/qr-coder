import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/utils/qr_code_date_utils.dart';
import 'package:qr_coder/viewmodels/qr_code_display_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/views/qr_code_list_page.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_accessibility.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/app_layout.dart';
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
    // Sayfaya her gelişte logo açık başlasın.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<QRCodeDisplayViewModel>().resetLogo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QRCodeViewModel>(context, listen: false);

    return AppPageScaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context),
      body: _buildBody(context, viewModel),
      showBannerAd: true,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final title = widget.qrCode.name.isEmpty
        ? AppLocalizations.of(context)!.qrCodeGenerator_qrCode
        : widget.qrCode.name;

    return AppBar(
      title: Text(title),
      actions: [
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              leadingIcon: const Icon(Icons.home_rounded),
              child: Text(
                AppLocalizations.of(context)!.qrCodeDetail_homePageNavToolTip,
              ),
            ),
            MenuItemButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const QRCodeListPage()),
              ),
              leadingIcon: const Icon(Icons.format_list_bulleted_rounded),
              child: Text(
                AppLocalizations.of(context)!.qrCodeDetail_listPageNavToolTip,
              ),
            ),
          ],
          builder: (context, controller, child) => AppIconButton(
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            onPressed: controller.isOpen ? controller.close : controller.open,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, QRCodeViewModel viewModel) {
    return AppContentFrame(
      maxWidth: AppLayoutMetrics.wideContentMaxWidth,
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final windowClass = AppBreakpoints.classify(constraints.maxWidth);
            final detailPanel = _buildDetailPanel(context, viewModel);
            final preview = _buildPreview(context);

            if (windowClass == AppWindowSizeClass.expanded &&
                !AppAccessibility.usesLargeText(context)) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: preview),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(flex: 5, child: detailPanel),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                preview,
                const SizedBox(height: AppSpacing.lg),
                detailPanel,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AppSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AspectRatio(
            aspectRatio: 1,
            child: QRcodeDisplay(
              data: widget.qrCode.data,
              repaintKey: repaintKey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(BuildContext context, QRCodeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActions(context, viewModel),
        const SizedBox(height: AppSpacing.lg),
        BuildContent(qrCode: widget.qrCode),
        const SizedBox(height: AppSpacing.md),
        _buildCreateDateTime(context),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildCreateDateTime(BuildContext context) {
    final isEnglish = AppLocalizations.of(context)!.localeName == 'en';
    final createdAt = QRCodeDateUtils.formatForLocale(
      widget.qrCode.createdAt,
      isEnglish: isEnglish,
    );
    final scheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!
                  .qrCodeDetail_createdDateTime(createdAt),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, QRCodeViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<QRCodeViewModel>(
      builder: (context, vm, child) {
        final busy = vm.isDownloading || vm.isSharing;
        final saveIcon = vm.isDownloading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_alt_rounded);
        final shareIcon = vm.isSharing
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.share_rounded);

        return LayoutBuilder(
          builder: (context, constraints) {
            final stackActions =
                constraints.maxWidth < AppBreakpoints.mediumWidth ||
                AppAccessibility.usesLargeText(context);

            final saveButton = FilledButton.icon(
              onPressed: busy ? null : () => _saveQRCode(context, viewModel),
              icon: saveIcon,
              label: Text(l10n.qrCodeDetail_saveQrCodeButtonToolTip),
            );
            final shareButton = OutlinedButton.icon(
              onPressed: busy ? null : () => _shareQRCode(context, viewModel),
              icon: shareIcon,
              label: Text(l10n.qrCodeDetail_shareQrCodeBtnToolTip),
            );

            if (stackActions) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  saveButton,
                  const SizedBox(height: AppSpacing.sm),
                  shareButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: saveButton),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: shareButton),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveQRCode(
    BuildContext context,
    QRCodeViewModel viewModel,
  ) async {
    final selectedResolution = await _showResolutionPicker(context);
    if (selectedResolution == null || !context.mounted) return;

    final filePath = await viewModel.saveQrCode(
      repaintKey,
      context,
      selectedResolution,
    );
    if (!context.mounted) return;
    _handleSaveResult(context, viewModel, filePath);
  }

  void _handleSaveResult(
    BuildContext context,
    QRCodeViewModel viewModel,
    String? filePath,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (filePath == null) {
      if (viewModel.errorMsg.isNotEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(viewModel.errorMsg)));
      }
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.qrCodeDetail_saveSuccessMsg,
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.qrCodeDetail_openSavedQrCode,
          onPressed: () => viewModel.openFile(filePath),
        ),
      ),
    );
  }

  Future<void> _shareQRCode(
    BuildContext context,
    QRCodeViewModel viewModel,
  ) async {
    await viewModel.shareQrCode(repaintKey, context);
    if (!context.mounted) return;

    if (viewModel.errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(viewModel.errorMsg)));
    }
  }

  Future<double?> _showResolutionPicker(BuildContext context) {
    final resolutions = [1.0, 2.0, 3.0];
    final labels = [
      AppLocalizations.of(context)!.qrCodeDetail_resolutionStandard,
      AppLocalizations.of(context)!.qrCodeDetail_resolutionHigh,
      AppLocalizations.of(context)!.qrCodeDetail_resolutionUltra,
    ];

    return showModalBottomSheet<double>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Consumer<QRCodeViewModel>(
                builder: (context, vm, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSectionHeader(
                        title: AppLocalizations.of(context)!
                            .qrCodeDetail_resolution,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (var index = 0; index < resolutions.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: ListTile(
                            selected:
                                resolutions[index] == vm.selectedResolution,
                            selectedTileColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.control,
                              ),
                            ),
                            title: Text(labels[index]),
                            trailing:
                                resolutions[index] == vm.selectedResolution
                                ? const Icon(Icons.check_rounded)
                                : null,
                            onTap: () =>
                                vm.selectedResolution = resolutions[index],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      FilledButton.icon(
                        onPressed: () =>
                            Navigator.of(sheetContext)
                                .pop(vm.selectedResolution),
                        icon: const Icon(Icons.download_rounded),
                        label: Text(
                          AppLocalizations.of(context)!.qrCodeDetail_download,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
