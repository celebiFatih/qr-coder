import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_display_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/views/barcode_scanner_page.dart';
import 'package:qr_coder/views/settings_page.dart';
import 'package:qr_coder/widgets/wrapper.dart';
import 'package:qr_coder/views/qr_code_list_page.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/app_layout.dart';
import 'package:qr_coder/widgets/app_navigation_menu.dart';
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
    return AppPageScaffold(
      appBar: _buildAppBar(context, user),
      body: _buildBody(context),
      showBannerAd: true,
    );
  }

  AppBar _buildAppBar(BuildContext context, User? user) {
    final l10n = AppLocalizations.of(context)!;
    final sessionLabel = user?.email?.isNotEmpty == true
        ? user!.email!
        : l10n.qrCodeGenerator_userType;

    return AppBar(
      centerTitle: true,
      title: const Text('QR Coder'),
      actions: [
        AppIconButton(
          tooltip: l10n.qrCodeGenerator_startScanningToolTip,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
          ),
          icon: const Icon(Icons.document_scanner_rounded),
        ),
        AppNavigationMenu(
          isSignedIn: user != null,
          sessionLabel: sessionLabel,
          onSavedQRCodes: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRCodeListPage()),
          ),
          onSettings: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(userEmail: user?.email),
            ),
          ),
          onLogout: () => _handleLogout(context),
        ),
      ],
    );
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
    return SafeArea(
      top: false,
      child: AppContentFrame(
        maxWidth: AppLayoutMetrics.wideContentMaxWidth,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isExpanded =
                  AppBreakpoints.classify(constraints.maxWidth) ==
                  AppWindowSizeClass.expanded;

              final composer = _buildComposer(context);
              final preview = _buildPreview(context);

              if (isExpanded) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: composer),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: preview),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  composer,
                  const SizedBox(height: AppSpacing.lg),
                  preview,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppSurface(
      child: Consumer<QRCodeViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(
                title: l10n.qrCodeGenerator_qrCode,
                subtitle: l10n.qrCodeGenerator_textFieldHintText,
              ),
              if (viewModel.sharedText.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: const Icon(Icons.ios_share_rounded),
                    label: Text(l10n.qrCodeGenerator_sharedData),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: l10n.qrCodeGenerator_textSemantic,
                textField: true,
                child: QRCodeTextField(
                  controller: viewModel.controller,
                  focusNode: viewModel.focusNode,
                  onPressed: () {
                    viewModel.clearAll();
                    viewModel.focusNode.requestFocus();
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: l10n.qrCodeGenerator_FabSemantic,
                button: true,
                child: FilledButton.icon(
                  onPressed: viewModel.isLoading
                      ? null
                      : () => _handleGenerateQRCode(context),
                  icon: viewModel.isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.qr_code_2_rounded),
                  label: Text(l10n.qrCodeGenerator_FabToolTip),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l10n.qrCodeGenerator_qrCodeSemantic),
          const SizedBox(height: AppSpacing.md),
          Consumer<QRCodeViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const SizedBox(
                  height: 300,
                  child: AppStateView.loading(),
                );
              }

              if (viewModel.qrData.isEmpty) {
                return SizedBox(
                  height: 300,
                  child: AppStateView.empty(
                    message: l10n.qrCodeGenerator_previewEmptyMsg,
                    icon: Icons.qr_code_2_rounded,
                  ),
                );
              }

              return Semantics(
                label: l10n.qrCodeGenerator_qrCodeSemantic,
                image: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
