import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/repository/main_qrcode_repository.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/views/barcode_scanner_page.dart';
import 'package:qr_coder/views/login_page.dart';
import 'package:qr_coder/views/qr_code_list_page.dart';
import 'package:qr_coder/widgets/banner_ad_widget.dart';
import 'package:qr_coder/widgets/qr_code_display.dart';
import 'package:qr_coder/widgets/qr_code_text_field.dart';

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator>
    with WidgetsBindingObserver {
  late QRCodeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    viewModel = Provider.of<QRCodeViewModel>(context, listen: false);
    viewModel.receiveSharedText(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      viewModel.receiveSharedText(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final GlobalKey repaintKey = GlobalKey();
    final User? user = Auth().currentUser;
    viewModel.repository = MainQrCodeRepository(
      isFirebaseUser: user != null,
      uid: user?.uid,
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context, user),
      body: _buildBody(context),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  AppBar _buildAppBar(BuildContext context, User? user) {
    return AppBar(
      centerTitle: true,
      title: const Text('QR Coder'),
      leading: _buildLogoutButton(context),
      actions: _buildAppBarActions(context, user),
    );
  }

  IconButton _buildLogoutButton(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.qrCodeGenerator_LogOutToolTip,
      onPressed: () => _handleLogout(context),
      icon: const Icon(Icons.logout_rounded),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, User? user) {
    return [
      IconButton(
        onPressed: () {},
        icon: user == null
            ? const Icon(Icons.account_circle_rounded)
            : const Icon(Icons.cloud_rounded),
        tooltip:
            '${user == null ? AppLocalizations.of(context)!.qrCodeGenerator_userType : user.email!.contains('@') == true ? user.email!.substring(0, user.email!.indexOf('@')) : user.email}',
      ),
      IconButton(
        tooltip:
            AppLocalizations.of(context)!.qrCodeGenerator_startScanningToolTip,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BarcodeScannerPage())),
        icon: const Icon(Icons.document_scanner_rounded),
      ),
      IconButton(
        tooltip:
            AppLocalizations.of(context)!.qrcodeGenerator_qrCodeListToolTip,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const QRCodeListPage())),
        icon: const Icon(Icons.format_list_bulleted_rounded),
      ),
    ];
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await Auth().signOut();
      _clearAllViewModels(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Oturum kapatma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.qrCodeGenerator_LogOutErrorMsg),
        ),
      );
    }
  }

  void _clearAllViewModels(BuildContext context) {
    Provider.of<QRCodeViewModel>(context, listen: false).clearAll();
    Provider.of<BarcodeScannerViewmodel>(context, listen: false).clearAll();
    Provider.of<LoginPageViewmodel>(context, listen: false).clearAll();
    Provider.of<QrCodeListPageViewmodel>(context, listen: false).clearAll();
    Provider.of<VerificationPageViewModel>(context, listen: false).clearAll();
    Provider.of<ForgotPasswPageViewmodel>(context, listen: false).clearAll();
  }

  Widget _buildFab(BuildContext context) {
    return Consumer<QRCodeViewModel>(
      builder: (context, viewModel, child) => Semantics(
        label: AppLocalizations.of(context)!.qrCodeGenerator_FabSemantic,
        child: viewModel.qrData.isEmpty
            ? FloatingActionButton.large(
                onPressed: () => _handleGenerateQRCode(context),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                tooltip:
                    AppLocalizations.of(context)!.qrCodeGenerator_FabToolTip,
                child: const Icon(Icons.qr_code_scanner, size: 50),
              )
            : FloatingActionButton(
                onPressed: () => _handleGenerateQRCode(context),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                tooltip:
                    AppLocalizations.of(context)!.qrCodeGenerator_FabToolTip,
                child: const Icon(Icons.qr_code_scanner),
              ),
      ),
    );
  }

  Future<void> _handleGenerateQRCode(BuildContext context) async {
    await viewModel.generateQRCode(context);
    if (viewModel.errorMsg != '' && viewModel.errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMsg,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(context),
                      _buildQRCodeDisplay(context, constraints),
                    ],
                  ),
                ),
              ),
            ),
            const BannerAdWidget(), // Banner ad
          ],
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Consumer<QRCodeViewModel>(
      builder: (context, viewModel, child) {
        return Semantics(
          label: AppLocalizations.of(context)!.qrCodeGenerator_textSemantic,
          child: QRCodeTextField(
            controller: viewModel.controller,
            focusNode: viewModel.focusNode,
            onPressed: () {
              viewModel.clearAll();
              viewModel.focusNode.requestFocus();
            },
          ),
        );
      },
    );
  }

  Widget _buildQRCodeDisplay(BuildContext context, BoxConstraints constraints) {
    final GlobalKey repaintKey = GlobalKey();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: constraints.maxHeight * 0.4,
        maxHeight: constraints.maxHeight * 0.7,
      ),
      child: Consumer<QRCodeViewModel>(
        builder: (context, viewModel, child) {
          return viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: viewModel.qrData.isNotEmpty
                      ? Semantics(
                          label: AppLocalizations.of(context)!
                              .qrCodeGenerator_qrCodeSemantic,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              elevation: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: QRcodeDisplay(
                                      data: viewModel.qrData,
                                      repaintKey: repaintKey),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
        },
      ),
    );
  }
}
