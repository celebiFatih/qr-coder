import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/main_qrcode_repository.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/views/qr_code_detail_page.dart';
import 'package:qr_coder/widgets/banner_ad_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeListPage extends StatelessWidget {
  const QRCodeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel =
        Provider.of<QrCodeListPageViewmodel>(context, listen: false);
    viewModel.repository = MainQrCodeRepository(
      isFirebaseUser: Auth().currentUser != null,
      uid: Auth().currentUser?.uid,
    );
    return Scaffold(
      appBar: _buildAppBar(context, viewModel),
      body: _buildBody(context, viewModel),
      floatingActionButton: _buildFab(context, viewModel),
    );
  }

  AppBar _buildAppBar(BuildContext context, QrCodeListPageViewmodel viewModel) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.qrCodeList_title),
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context)!.qrCodeList_selectAllBtn,
          onPressed: () => viewModel.toggleSelectAllQRCodes(),
          icon: const Icon(Icons.select_all),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, QrCodeListPageViewmodel viewModel) {
    return Column(
      children: [
        Expanded(child: buildQRCodeList(context, viewModel)),
        const BannerAdWidget()
      ],
    );
  }

  Widget buildQRCodeList(
      BuildContext context, QrCodeListPageViewmodel viewModel) {
    return FutureBuilder<void>(
        future: viewModel.fetchQRCodes(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(e);
            return Center(
                child: Text(AppLocalizations.of(context)!
                    .qrCodeList_fetchListErrorMsg));
          } else if (viewModel.qrCodes.isEmpty) {
            return Center(
                child:
                    Text(AppLocalizations.of(context)!.qrCodeList_emptyList));
          }

          return _buildQRCodeListView(context, viewModel);
        });
  }

  Widget _buildQRCodeListView(
      BuildContext context, QrCodeListPageViewmodel viewModel) {
    return Consumer<QrCodeListPageViewmodel>(
        builder: (context, viewModel, child) {
      return ListView.builder(
        itemCount: viewModel.qrCodes.length,
        itemBuilder: (context, index) =>
            buildQRCodeListItem(context, viewModel, index),
      );
    });
  }

  Widget buildQRCodeListItem(
      BuildContext context, QrCodeListPageViewmodel viewModel, index) {
    var qrCode = viewModel.qrCodes[index];
    final isSelected = viewModel.selectedQRCodes.contains(qrCode.id);
    final isEditing = viewModel.editingQRCodes.contains(qrCode.id);
    TextEditingController controller = TextEditingController(text: qrCode.name);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Semantics(
        label: AppLocalizations.of(context)!.qrCodeList_qrCodeTitle(qrCode.id),
        child: Tooltip(
          message: qrCode.data,
          child: ListTile(
            title: isEditing
                ? _buildEditingTextField(context, controller, qrCode, viewModel)
                : _buildQRCodeName(qrCode),
            subtitle: _buildQRCodeSubtitle(context, qrCode),
            trailing: _buildQRCodeActions(
                viewModel, qrCode, isSelected, isEditing, context),
            leading: _buildQRCodePreview(qrCode, context),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => QRCodeDetailPage(qrCode: qrCode))),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingTextField(
      BuildContext context,
      TextEditingController controller,
      QRCodeModel qrCode,
      QrCodeListPageViewmodel viewModel) {
    return TextField(
      controller: controller,
      onSubmitted: (value) async {
        await viewModel.updateQRCodeName(qrCode.id, value, context);
        viewModel.toggleEditingQRCode(qrCode.id);
      },
    );
  }

  Widget _buildQRCodeName(QRCodeModel qrCode) {
    return Text(
      qrCode.name,
      style: const TextStyle(overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildQRCodeSubtitle(BuildContext context, QRCodeModel qrCode) {
    return Text(
        AppLocalizations.of(context)!.localeName == 'en'
            ? DateFormat('MM.dd.yyyy HH:mm')
                .format(DateFormat('dd.MM.yyyy HH:mm').parse(qrCode.createdAt))
            : DateFormat('dd.MM.yyyy HH:mm')
                .format(DateFormat('dd.MM.yyyy HH:mm').parse(qrCode.createdAt)),
        maxLines: 1);
  }

  Widget _buildQRCodeActions(
      QrCodeListPageViewmodel viewModel,
      QRCodeModel qrCode,
      bool isSelected,
      bool isEditing,
      BuildContext context) {
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
          onPressed: () async =>
              await viewModel.deleteQRCode(qrCode.id, context),
          tooltip: AppLocalizations.of(context)!.qrCodeList_deleteBtn,
        ),
      ],
    );
  }

  Widget _buildQRCodePreview(QRCodeModel qrCode, BuildContext context) {
    return Hero(
      tag: qrCode,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCDDC39), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: QrImageView(
            data: AppLocalizations.of(context)!.qrCodeList_defaultQrCode,
            version: QrVersions.auto,
            size: 50,
            padding: const EdgeInsets.all(4)),
      ),
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
      BuildContext context, QrCodeListPageViewmodel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.delete_forever),
              title:
                  Text(AppLocalizations.of(context)!.qrCodeList_deleteAllBtn),
              onTap: () async {
                Navigator.of(context).pop();
                await viewModel.deleteAllQRCodes(context);
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: Text(
                    AppLocalizations.of(context)!.qrCodeList_deleteSelectedBtn),
                onTap: () async {
                  Navigator.of(context).pop();
                  await viewModel.deleteSelectedQRCodes(context);
                }),
          ),
        ],
      ),
    );
  }
}
