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
import 'package:qr_coder/widgets/app_layout.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeListPage extends StatefulWidget {
  const QRCodeListPage({super.key});

  @override
  State<QRCodeListPage> createState() => _QRCodeListPageState();

  Widget buildQRCodeListItem(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
    int index,
  ) {
    final qrCode = viewModel.qrCodes[index];
    final isSelected = viewModel.selectedQRCodes.contains(qrCode.id);
    final isEditing = viewModel.editingQRCodes.contains(qrCode.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Semantics(
        label: AppLocalizations.of(context)!.qrCodeList_qrCodeTitle(qrCode.id),
        child: Tooltip(
          message: qrCode.data,
          child: ListTile(
            title: isEditing
                ? _buildEditingTextField(context, qrCode, viewModel)
                : _buildQRCodeName(context, qrCode),
            subtitle: _buildQRCodeSubtitle(context, qrCode),
            trailing: _buildQRCodeActions(
              viewModel,
              qrCode,
              isSelected,
              isEditing,
              context,
            ),
            leading: _buildQRCodePreview(qrCode),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QRCodeDetailPage(qrCode: qrCode),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingTextField(
    BuildContext context,
    QRCodeModel qrCode,
    QrCodeListPageViewmodel viewModel,
  ) {
    return TextFormField(
      key: ValueKey('qr-name-${qrCode.id}'),
      initialValue: qrCode.name,
      onFieldSubmitted: (value) async {
        final success = await viewModel.updateQRCodeName(
          qrCode.id,
          value,
          AppLocalizations.of(context)!,
        );

        if (!context.mounted) return;

        if (success) {
          viewModel.toggleEditingQRCode(qrCode.id);
        } else {
          _showActionError(context, viewModel);
        }
      },
    );
  }

  Widget _buildQRCodeName(BuildContext context, QRCodeModel qrCode) {
    final displayName = qrCode.name.isEmpty
        ? AppLocalizations.of(context)!.qrCodeGenerator_qrCode
        : qrCode.name;

    return Text(
      displayName,
      style: const TextStyle(overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildQRCodeSubtitle(BuildContext context, QRCodeModel qrCode) {
    final isEnglish = AppLocalizations.of(context)!.localeName == 'en';

    return Text(
      QRCodeDateUtils.formatForLocale(qrCode.createdAt, isEnglish: isEnglish),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildQRCodeActions(
    QrCodeListPageViewmodel viewModel,
    QRCodeModel qrCode,
    bool isSelected,
    bool isEditing,
    BuildContext context,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: isSelected,
          onChanged: (value) => value == true
              ? viewModel.selectQRCode(qrCode.id)
              : viewModel.deselectQRCode(qrCode.id),
        ),
        IconButton(
          onPressed: () => viewModel.toggleEditingQRCode(qrCode.id),
          icon: const Icon(Icons.edit),
          tooltip: AppLocalizations.of(context)!.qrCodeList_editBtn,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await viewModel.deleteQRCode(
              qrCode.id,
              AppLocalizations.of(context)!,
            );

            if (!context.mounted) return;
            _showActionError(context, viewModel);
          },
          tooltip: AppLocalizations.of(context)!.qrCodeList_deleteBtn,
        ),
      ],
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
      ..showSnackBar(
        SnackBar(content: Text(message, textAlign: TextAlign.center)),
      );
  }

  Widget _buildQRCodePreview(QRCodeModel qrCode) {
    return Hero(
      tag: qrCode,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCDDC39), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: QrCodePreviewImage(data: qrCode.data),
      ),
    );
  }
}

class _QRCodeListPageState extends State<QRCodeListPage> {
  QrCodeListPageViewmodel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final viewModel = context.read<QrCodeListPageViewmodel>();
    if (!identical(_viewModel, viewModel)) {
      _viewModel = viewModel;
      viewModel.resetTransientState(notify: false);
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
    viewModel.repository = MainQrCodeRepository(
      isFirebaseUser: Auth().currentUser != null,
      uid: Auth().currentUser?.uid,
    );

    return AppPageScaffold(
      appBar: _buildAppBar(context, viewModel),
      body: _buildBody(context, viewModel),
      showBannerAd: true,
      floatingActionButton: _buildFab(context, viewModel),
    );
  }

  AppBar _buildAppBar(BuildContext context, QrCodeListPageViewmodel viewModel) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.qrCodeList_title),
      actions: [
        AppIconButton(
          tooltip: AppLocalizations.of(context)!.qrCodeList_selectAllBtn,
          onPressed: () => viewModel.toggleSelectAllQRCodes(),
          icon: const Icon(Icons.select_all),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, QrCodeListPageViewmodel viewModel) {
    return _buildQRCodeList(context, viewModel);
  }

  Widget _buildQRCodeList(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
  ) {
    return FutureBuilder<void>(
      future: viewModel.fetchQRCodes(AppLocalizations.of(context)!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppStateView.loading();
        }

        if (snapshot.hasError) {
          debugPrint('QR code list FutureBuilder error: ${snapshot.error}');
          return AppStateView.error(
            message: AppLocalizations.of(context)!.qrCodeList_fetchListErrorMsg,
          );
        }

        if (viewModel.errorMsg.isNotEmpty) {
          return AppStateView.error(message: viewModel.errorMsg);
        }

        if (viewModel.qrCodes.isEmpty) {
          return AppStateView.empty(
            message: AppLocalizations.of(context)!.qrCodeList_emptyList,
          );
        }

        return _buildQRCodeListView(context, viewModel);
      },
    );
  }

  Widget _buildQRCodeListView(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
  ) {
    return Consumer<QrCodeListPageViewmodel>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          itemCount: viewModel.qrCodes.length,
          itemBuilder: (context, index) =>
              widget.buildQRCodeListItem(context, viewModel, index),
        );
      },
    );
  }

  Widget _buildFab(BuildContext context, QrCodeListPageViewmodel viewModel) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: const Color(0xFFCDDC39),
          context: context,
          constraints: const BoxConstraints(maxHeight: double.infinity),
          builder: (context) => _buildBottomSheetActions(context, viewModel),
        );
      },
      child: const Icon(Icons.more_vert),
    );
  }

  Widget _buildBottomSheetActions(
    BuildContext context,
    QrCodeListPageViewmodel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.delete_forever),
              title: Text(
                AppLocalizations.of(context)!.qrCodeList_deleteAllBtn,
              ),
              onTap: () async {
                final l10n = AppLocalizations.of(context)!;
                Navigator.of(context).pop();

                await viewModel.deleteAllQRCodes(l10n);

                if (!mounted) return;
                widget._showActionError(this.context, viewModel);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: Text(
                AppLocalizations.of(context)!.qrCodeList_deleteSelectedBtn,
              ),
              onTap: () async {
                final l10n = AppLocalizations.of(context)!;
                Navigator.of(context).pop();

                await viewModel.deleteSelectedQRCodes(l10n);

                if (!mounted) return;
                widget._showActionError(this.context, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QrCodePreviewImage extends StatelessWidget {
  const QrCodePreviewImage({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    if (!QRCodeRenderUtils.canRender(data)) {
      return const SizedBox.square(
        dimension: 50,
        child: Icon(Icons.broken_image_outlined),
      );
    }

    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 50,
      padding: const EdgeInsets.all(4),
      errorStateBuilder: (context, error) => const SizedBox.square(
        dimension: 50,
        child: Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
