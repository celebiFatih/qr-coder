import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_repository.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/qr_code_date_utils.dart';
import 'package:qr_coder/utils/qr_code_render_utils.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/views/qr_code_detail_page.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/app_layout.dart';
import 'package:qr_coder/widgets/app_motion.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum _QrCodeListItemAction { edit, delete }

class QRCodeListPage extends StatefulWidget {
  const QRCodeListPage({super.key});

  @override
  State<QRCodeListPage> createState() => _QRCodeListPageState();

  /// Kept public for the existing preview regression test. Production also
  /// uses this exact item builder, with selection/edit/delete callbacks added.
  Widget buildQRCodeListItem(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
    int index, {
    bool selectionMode = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    ValueChanged<bool?>? onSelectedChanged,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final qrCode = viewModel.qrCodes[index];
    final isSelected = viewModel.selectedQRCodes.contains(qrCode.id);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: selectionMode && isSelected ? scheme.secondaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        selected: selectionMode ? isSelected : null,
        label: AppLocalizations.of(context)!.qrCodeList_qrCodeTitle(qrCode.id),
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          leading: _buildQRCodePreview(context, qrCode),
          title: _buildQRCodeName(context, qrCode),
          subtitle: _buildQRCodeSubtitle(context, qrCode),
          trailing: selectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged:
                      onSelectedChanged ??
                      (value) => value == true
                          ? viewModel.selectQRCode(qrCode.id)
                          : viewModel.deselectQRCode(qrCode.id),
                )
              : PopupMenuButton<_QrCodeListItemAction>(
                  tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                  onSelected: (action) async {
                    switch (action) {
                      case _QrCodeListItemAction.edit:
                        if (onEdit != null) {
                          onEdit();
                        } else {
                          viewModel.toggleEditingQRCode(qrCode.id);
                        }
                        break;
                      case _QrCodeListItemAction.delete:
                        if (onDelete != null) {
                          onDelete();
                        } else {
                          await viewModel.deleteQRCode(
                            qrCode.id,
                            AppLocalizations.of(context)!,
                          );
                          if (!context.mounted) return;
                          _showActionError(context, viewModel);
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _QrCodeListItemAction.edit,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(
                          AppLocalizations.of(context)!.qrCodeList_editBtn,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: _QrCodeListItemAction.delete,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          color: scheme.error,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.qrCodeList_deleteBtn,
                          style: TextStyle(color: scheme.error),
                        ),
                      ),
                    ),
                  ],
                ),
          selected: selectionMode && isSelected,
          onTap:
              onTap ??
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QRCodeDetailPage(qrCode: qrCode),
                ),
              ),
          onLongPress: onLongPress,
        ),
      ),
    );
  }

  Widget _buildQRCodeName(BuildContext context, QRCodeModel qrCode) {
    final displayName = qrCode.name.isEmpty
        ? AppLocalizations.of(context)!.qrCodeGenerator_qrCode
        : qrCode.name;

    return Text(
      displayName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildQRCodeSubtitle(BuildContext context, QRCodeModel qrCode) {
    final isEnglish = AppLocalizations.of(context)!.localeName == 'en';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Text(
        QRCodeDateUtils.formatForLocale(qrCode.createdAt, isEnglish: isEnglish),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showActionError(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
  ) {
    final message = viewModel.actionErrorMsg;
    if (message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildQRCodePreview(BuildContext context, QRCodeModel qrCode) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: SizedBox.square(
        dimension: 52,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              child: QrCodePreviewImage(data: qrCode.data),
            ),
          ),
        ),
      ),
    );
  }
}

class _QRCodeListPageState extends State<QRCodeListPage> {
  QrCodeListPageViewmodel? _viewModel;
  Future<void>? _fetchFuture;
  String? _localeName;
  bool _selectionMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final viewModel = context.read<QrCodeListPageViewmodel>();
    final localeName = AppLocalizations.of(context)!.localeName;

    if (!identical(_viewModel, viewModel)) {
      _viewModel = viewModel;
      viewModel.resetTransientState(notify: false);
      _fetchFuture = null;
      _selectionMode = false;
    }

    if (_localeName != localeName) {
      _localeName = localeName;
      _fetchFuture = null;
    }
  }

  @override
  void dispose() {
    _viewModel?.resetTransientState(notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<QrCodeListPageViewmodel>();
    final currentUser = Auth().currentUser;
    viewModel.repository = MainQrCodeRepository(
      isFirebaseUser: currentUser != null,
      uid: currentUser?.uid,
    );
    _fetchFuture ??= viewModel.fetchQRCodes(AppLocalizations.of(context)!);

    return AppPageScaffold(
      appBar: _buildAppBar(context, viewModel),
      body: _buildBody(context, viewModel),
      showBannerAd: true,
    );
  }

  AppBar _buildAppBar(BuildContext context, QrCodeListPageViewmodel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      title: AnimatedSwitcher(
        duration: AppMotion.short(context),
        switchInCurve: AppMotion.standardCurve,
        switchOutCurve: AppMotion.standardCurve,
        child: KeyedSubtree(
          key: ValueKey(_selectionMode),
          child: _selectionMode
              ? Consumer<QrCodeListPageViewmodel>(
                  builder: (context, vm, child) => Text(
                    l10n.qrCodeList_selectedCount(vm.selectedQRCodes.length),
                  ),
                )
              : Text(l10n.qrCodeList_title),
        ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: AppMotion.short(context),
          switchInCurve: AppMotion.standardCurve,
          switchOutCurve: AppMotion.standardCurve,
          child: Row(
            key: ValueKey(_selectionMode),
            mainAxisSize: MainAxisSize.min,
            children: _selectionMode
                ? [
                    AppIconButton(
                      tooltip: l10n.qrCodeList_selectAllBtn,
                      onPressed: viewModel.toggleSelectAllQRCodes,
                      icon: const Icon(Icons.select_all_rounded),
                    ),
                    Consumer<QrCodeListPageViewmodel>(
                      builder: (context, vm, child) => AppIconButton(
                        tooltip: l10n.qrCodeList_deleteSelectedBtn,
                        onPressed: vm.selectedQRCodes.isEmpty
                            ? null
                            : () => _deleteSelected(context, vm),
                        icon: const Icon(Icons.delete_sweep_outlined),
                      ),
                    ),
                    AppIconButton(
                      tooltip: l10n.qrCodeList_exitSelectionBtn,
                      onPressed: () => _exitSelectionMode(viewModel),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ]
                : [
                    AppIconButton(
                      tooltip: l10n.qrCodeList_selectBtn,
                      onPressed: _enterSelectionMode,
                      icon: const Icon(Icons.checklist_rounded),
                    ),
                    MenuAnchor(
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () => _deleteAll(context, viewModel),
                          leadingIcon: Icon(
                            Icons.delete_forever_outlined,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          child: Text(
                            l10n.qrCodeList_deleteAllBtn,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                      builder: (context, controller, child) => AppIconButton(
                        tooltip: MaterialLocalizations.of(context)
                            .moreButtonTooltip,
                        onPressed: controller.isOpen
                            ? controller.close
                            : controller.open,
                        icon: const Icon(Icons.more_vert_rounded),
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, QrCodeListPageViewmodel viewModel) {
    return FutureBuilder<void>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppStateView.loading();
        }

        if (snapshot.hasError) {
          debugPrint('QR code list FutureBuilder error: ${snapshot.error}');
          return _buildFetchError(context, viewModel);
        }

        if (viewModel.errorMsg.isNotEmpty) {
          return _buildFetchError(context, viewModel);
        }

        if (viewModel.qrCodes.isEmpty) {
          return AppStateView.empty(
            message: AppLocalizations.of(context)!.qrCodeList_emptyList,
            icon: Icons.qr_code_2_rounded,
          );
        }

        return _buildQRCodeListView(context, viewModel);
      },
    );
  }

  Widget _buildFetchError(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final message = viewModel.errorMsg.isEmpty
        ? l10n.qrCodeList_fetchListErrorMsg
        : viewModel.errorMsg;

    return AppStateView.error(
      message: message,
      action: FilledButton.tonalIcon(
        onPressed: () => _retryFetch(viewModel),
        icon: const Icon(Icons.refresh_rounded),
        label: Text(l10n.qrCodeList_retryBtn),
      ),
    );
  }

  Widget _buildQRCodeListView(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
  ) {
    return AppContentFrame(
      includeVerticalPadding: false,
      child: Consumer<QrCodeListPageViewmodel>(
        builder: (context, vm, child) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            itemCount: vm.qrCodes.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final qrCode = vm.qrCodes[index];
              final isSelected = vm.selectedQRCodes.contains(qrCode.id);

              return widget.buildQRCodeListItem(
                context,
                vm,
                index,
                selectionMode: _selectionMode,
                onTap: _selectionMode
                    ? () => _setSelected(vm, qrCode.id, !isSelected)
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              QRCodeDetailPage(qrCode: qrCode),
                        ),
                      ),
                onLongPress: _selectionMode
                    ? null
                    : () => _enterSelectionModeWith(vm, qrCode.id),
                onSelectedChanged: (value) =>
                    _setSelected(vm, qrCode.id, value == true),
                onEdit: () => _renameQRCode(context, vm, qrCode),
                onDelete: () => _deleteOne(context, vm, qrCode),
              );
            },
          );
        },
      ),
    );
  }

  void _retryFetch(QrCodeListPageViewmodel viewModel) {
    setState(() {
      _fetchFuture = viewModel.fetchQRCodes(AppLocalizations.of(context)!);
    });
  }

  void _enterSelectionMode() {
    if (_selectionMode) return;
    setState(() => _selectionMode = true);
  }

  void _enterSelectionModeWith(QrCodeListPageViewmodel viewModel, String id) {
    if (!viewModel.selectedQRCodes.contains(id)) {
      viewModel.selectQRCode(id);
    }
    setState(() => _selectionMode = true);
  }

  void _exitSelectionMode(QrCodeListPageViewmodel viewModel) {
    viewModel.resetTransientState();
    setState(() => _selectionMode = false);
  }

  void _setSelected(
    QrCodeListPageViewmodel viewModel,
    String id,
    bool selected,
  ) {
    if (selected) {
      if (!viewModel.selectedQRCodes.contains(id)) {
        viewModel.selectQRCode(id);
      }
    } else if (viewModel.selectedQRCodes.contains(id)) {
      viewModel.deselectQRCode(id);
    }
  }

  Future<void> _renameQRCode(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
    QRCodeModel qrCode,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: qrCode.name);

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.qrCodeList_editTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: l10n.qrCodeList_nameLabel),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.qrCodeList_cancelBtn),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.qrCodeList_saveEditBtn),
          ),
        ],
      ),
    );

    controller.dispose();
    if (name == null || !mounted) return;

    final success = await viewModel.updateQRCodeName(qrCode.id, name, l10n);
    if (!mounted) return;

    if (!success) {
      widget._showActionError(this.context, viewModel);
    }
  }

  Future<void> _deleteOne(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
    QRCodeModel qrCode,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmDelete(
      context,
      title: l10n.qrCodeList_deleteConfirmTitle,
      message: l10n.qrCodeList_deleteConfirmMessage,
      confirmLabel: l10n.qrCodeList_deleteBtn,
    );
    if (!confirmed || !mounted) return;

    await viewModel.deleteQRCode(qrCode.id, l10n);
    if (!mounted) return;
    widget._showActionError(this.context, viewModel);
  }

  Future<void> _deleteSelected(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final count = viewModel.selectedQRCodes.length;
    if (count == 0) return;

    final confirmed = await _confirmDelete(
      context,
      title: l10n.qrCodeList_deleteSelectedConfirmTitle,
      message: l10n.qrCodeList_deleteSelectedConfirmMessage(count),
      confirmLabel: l10n.qrCodeList_deleteSelectedBtn,
    );
    if (!confirmed || !mounted) return;

    final success = await viewModel.deleteSelectedQRCodes(l10n);
    if (!mounted) return;

    if (success) {
      setState(() => _selectionMode = false);
    } else {
      widget._showActionError(this.context, viewModel);
    }
  }

  Future<void> _deleteAll(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmDelete(
      context,
      title: l10n.qrCodeList_deleteAllConfirmTitle,
      message: l10n.qrCodeList_deleteAllConfirmMessage,
      confirmLabel: l10n.qrCodeList_deleteAllBtn,
    );
    if (!confirmed || !mounted) return;

    final success = await viewModel.deleteAllQRCodes(l10n);
    if (!mounted) return;

    if (success) {
      setState(() => _selectionMode = false);
    } else {
      widget._showActionError(this.context, viewModel);
    }
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.qrCodeList_cancelBtn),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class QrCodePreviewImage extends StatelessWidget {
  const QrCodePreviewImage({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    if (!QRCodeRenderUtils.canRender(data)) {
      return const Center(child: Icon(Icons.broken_image_outlined));
    }

    return QrImageView(
      data: data,
      version: QrVersions.auto,
      // QR modules must keep a light, neutral canvas in both app themes so
      // saved-code previews remain readable and scannable in dark mode.
      backgroundColor: Colors.white,
      padding: EdgeInsets.zero,
      errorStateBuilder: (context, error) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}
