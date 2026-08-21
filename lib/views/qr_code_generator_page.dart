import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/ad_consent_service.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_display_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/views/account_privacy_page.dart';
import 'package:qr_coder/views/barcode_scanner_page.dart';
import 'package:qr_coder/widgets/wrapper.dart';
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
  final GlobalKey _repaintKey = GlobalKey();
  bool _didCheckInitialSharedText = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    viewModel = Provider.of<QRCodeViewModel>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The provider is created before Firebase restores the persisted session.
    // Always bind the repository to the current auth session before handling
    // an incoming shared text, otherwise a signed-in user's QR can be written
    // to the local guest database.
    _syncRepositoryWithCurrentSession();

    if (_didCheckInitialSharedText) {
      return;
    }

    _didCheckInitialSharedText = true;
    unawaited(_handleReceiveSharedText());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        _didCheckInitialSharedText) {
      // A share intent can arrive while the app is in the background. Make
      // sure the repository still matches the active session before reading
      // and persisting that shared text.
      _syncRepositoryWithCurrentSession();
      unawaited(_handleReceiveSharedText());
    }
  }

  void _syncRepositoryWithCurrentSession() {
    final user = Auth().currentUser;
    viewModel.configureRepository(isFirebaseUser: user != null, uid: user?.uid);
  }

  Future<void> _handleReceiveSharedText() async {
    await viewModel.receiveSharedText(context);
    if (!mounted || viewModel.errorMsg.isEmpty) {
      return;
    }

    final message = viewModel.errorMsg;

    // On cold start receiveSharedText can complete while the first frame is
    // still settling. Show the validation/database error only after a frame
    // where the ScaffoldMessenger is guaranteed to be attached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message, textAlign: TextAlign.center)),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Auth().currentUser;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context, user),
      body: _buildBody(context),
      bottomNavigationBar: const BannerAdWidget(),
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
      ListenableBuilder(
        listenable: AdConsentService.instance,
        builder: (context, child) {
          if (!AdConsentService.instance.privacyOptionsRequired) {
            return const SizedBox.shrink();
          }

          return IconButton(
            tooltip: AppLocalizations.of(context)!
                .qrCodeGenerator_privacyOptionsToolTip,
            onPressed: () => _showPrivacyOptions(context),
            icon: const Icon(Icons.privacy_tip_outlined),
          );
        },
      ),
      IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AccountPrivacyPage()),
        ),
        icon: user == null
            ? const Icon(Icons.account_circle_rounded)
            : const Icon(Icons.cloud_rounded),
        tooltip:
            '${user == null
                ? AppLocalizations.of(context)!.qrCodeGenerator_userType
                : user.email!.contains('@') == true
                ? user.email!.substring(0, user.email!.indexOf('@'))
                : user.email}',
      ),
      IconButton(
        tooltip: AppLocalizations.of(context)!
            .qrCodeGenerator_startScanningToolTip,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
        ),
        icon: const Icon(Icons.document_scanner_rounded),
      ),
      IconButton(
        tooltip: AppLocalizations.of(context)!
            .qrcodeGenerator_qrCodeListToolTip,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRCodeListPage()),
        ),
        icon: const Icon(Icons.format_list_bulleted_rounded),
      ),
    ];
  }

  Future<void> _showPrivacyOptions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final formError = await AdConsentService.instance.showPrivacyOptionsForm();

    if (formError != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.qrCodeGenerator_privacyOptionsErrorMsg,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final wasAuthenticated = Auth().currentUser != null;

    final qrCodeViewModel = context.read<QRCodeViewModel>();
    final barcodeScannerViewModel = context.read<BarcodeScannerViewmodel>();
    final loginPageViewModel = context.read<LoginPageViewmodel>();
    final qrCodeListPageViewModel = context.read<QrCodeListPageViewmodel>();
    final verificationPageViewModel = context.read<VerificationPageViewModel>();
    final forgotPasswPageViewModel = context.read<ForgotPasswPageViewmodel>();

    try {
      await Auth().signOut();
      final prefs = await Constants().prefs;
      await prefs.setBool('isGuest', false);

      qrCodeViewModel.clearAll();
      barcodeScannerViewModel.clearAll();
      loginPageViewModel.clearAll();
      qrCodeListPageViewModel.clearAll();
      verificationPageViewModel.clearAll();
      forgotPasswPageViewModel.clearAll();

      if (!context.mounted) return;

      // Firebase kullanıcısında Wrapper.userChanges sign-out olayını yakalar
      // ve LoginPage'i kendisi gösterir. Guest oturumunda Firebase olayı
      // olmadığı için yeni bir Wrapper oluşturarak guest flag'ini yeniden okuruz.
      if (!wasAuthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Wrapper()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('Oturum kapatma hatası: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.qrCodeGenerator_LogOutErrorMsg,
          ),
        ),
      );
    }
  }

  Widget _buildFab(BuildContext context) {
    return Consumer<QRCodeViewModel>(
      builder: (context, viewModel, child) => Semantics(
        label: AppLocalizations.of(context)!.qrCodeGenerator_FabSemantic,
        child: viewModel.qrData.isEmpty
            ? FloatingActionButton.large(
                onPressed: viewModel.isLoading
                    ? null
                    : () => _handleGenerateQRCode(context),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                tooltip: AppLocalizations.of(context)!
                    .qrCodeGenerator_FabToolTip,
                child: const Icon(Icons.qr_code_scanner, size: 50),
              )
            : FloatingActionButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => _handleGenerateQRCode(context),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                tooltip: AppLocalizations.of(context)!
                    .qrCodeGenerator_FabToolTip,
                child: const Icon(Icons.qr_code_scanner),
              ),
      ),
    );
  }

  Future<void> _handleGenerateQRCode(BuildContext context) async {
    await viewModel.generateQRCode(context);
    if (!context.mounted) return;
    if (viewModel.errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMsg, textAlign: TextAlign.center),
        ),
      );
    }
  }

  Future<void> _handleRemoveLogo() async {
    if (!mounted) return;

    // Use the page State's context rather than the short-lived QR subtree
    // context. The generator can rebuild while the confirmation dialog is
    // open; State.context remains valid for the whole page lifetime.
    await context.read<QRCodeDisplayViewModel>().promptRemoveLogo(context);
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(context),
                _buildQRCodeDisplay(context, constraints),
              ],
            ),
          ),
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
                                    key: ObjectKey(viewModel.qrCodeModel),
                                    data: viewModel.qrData,
                                    repaintKey: _repaintKey,
                                    onLogoTap: _handleRemoveLogo,
                                  ),
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
