import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/widgets/wrapper.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with WidgetsBindingObserver {
  late VerificationPageViewModel _viewModel;
  bool _verificationFlowInitialized = false;
  bool _resumeScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_verificationFlowInitialized) {
      return;
    }

    _verificationFlowInitialized = true;
    _viewModel = context.read<VerificationPageViewModel>();
    _scheduleResumeVerificationFlow();
  }

  void _scheduleResumeVerificationFlow() {
    if (_resumeScheduled) {
      return;
    }

    _resumeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resumeScheduled = false;

      if (!mounted || !_verificationFlowInitialized) {
        return;
      }

      unawaited(_viewModel.resumeVerificationFlow());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_verificationFlowInitialized) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _scheduleResumeVerificationFlow();
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _viewModel.pauseVerificationFlow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_verificationFlowInitialized) {
      _viewModel.pauseVerificationFlow();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final viewModel = Provider.of<VerificationPageViewModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: _buildBody(context, viewModel, isSmallScreen),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VerificationPageViewModel viewModel,
    bool isSmallScreen,
  ) {
    return Center(
      child: Card(
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(32.0),
          constraints: BoxConstraints(maxWidth: isSmallScreen ? 300 : 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(isSmallScreen),
                _gap(),
                _buildWelcomeText(context, isSmallScreen),
                _gap(),
                _buildDescriptionText(context, isSmallScreen),
                _gap(),
                _buildVerificationIndicator(viewModel),
                _gap(),
                _buildResendButton(context, isSmallScreen, viewModel),
                const SizedBox(height: 12),
                _buildDifferentAccountButton(context, isSmallScreen, viewModel),
                const SizedBox(height: 8),
                _buildGuestAccessButton(context, isSmallScreen, viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 32);

  Widget _buildLogo(bool isSmallScreen) {
    return Image.asset('assets/img/logo.png', width: isSmallScreen ? 100 : 200);
  }

  Widget _buildWelcomeText(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        AppLocalizations.of(context)!.verificationPage_welcomeTitle,
        style: isSmallScreen
            ? Theme.of(context).textTheme.headlineLarge
            : Theme.of(context).textTheme.displayMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescriptionText(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        AppLocalizations.of(context)!.verificationPage_description,
        style: isSmallScreen
            ? Theme.of(context).textTheme.bodyMedium
            : Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildResendButton(
    BuildContext context,
    bool isSmallScreen,
    VerificationPageViewModel viewModel,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: viewModel.canResend
            ? () => _handleSendVerification(context, viewModel)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: viewModel.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(
                  viewModel.isResendCoolingDown
                      ? AppLocalizations.of(context)!
                            .verificationPage_sendAgainCooldownBtn(
                              viewModel.resendCooldownSeconds,
                            )
                      : AppLocalizations.of(context)!
                            .verificationPage_sendAgainBtn,
                  style: isSmallScreen
                      ? Theme.of(context).textTheme.bodyLarge
                      : Theme.of(context).textTheme.headlineSmall,
                ),
        ),
      ),
    );
  }

  Widget _buildDifferentAccountButton(
    BuildContext context,
    bool isSmallScreen,
    VerificationPageViewModel viewModel,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: viewModel.isLoading
            ? null
            : () => _handleUseDifferentAccount(context, viewModel),
        icon: const Icon(Icons.switch_account_rounded),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            AppLocalizations.of(context)!
                .verificationPage_useDifferentAccountBtn,
            style: isSmallScreen
                ? Theme.of(context).textTheme.bodyMedium
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildGuestAccessButton(
    BuildContext context,
    bool isSmallScreen,
    VerificationPageViewModel viewModel,
  ) {
    return TextButton.icon(
      onPressed: viewModel.isLoading
          ? null
          : () => _handleContinueAsGuest(context, viewModel),
      icon: const Icon(Icons.person_outline_rounded),
      label: Text(
        AppLocalizations.of(context)!.login_GuestAccessButton,
        style: isSmallScreen
            ? Theme.of(context).textTheme.bodyMedium
            : Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Future<void> _handleSendVerification(
    BuildContext context,
    VerificationPageViewModel viewModel,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final successMessage = l10n.verificationPage_verificationEmailResentMsg;
    final errorMessage = l10n.verificationPage_sendMailErrorMsg;
    final tooManyRequestsMessage = l10n.verificationPage_tooManyRequestsMsg;

    final sent = await viewModel.sendVerificationEmail(
      sendMailErrorMsg: errorMessage,
      tooManyRequestsMsg: tooManyRequestsMessage,
    );
    if (!context.mounted) return;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          sent ? successMessage : viewModel.errorMessage,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _handleUseDifferentAccount(
    BuildContext context,
    VerificationPageViewModel viewModel,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final logoutErrorMessage = AppLocalizations.of(context)!
        .qrCodeGenerator_LogOutErrorMsg;

    try {
      final prefs = await Constants().prefs;
      await prefs.setBool('isGuest', false);
      await Auth().signOut();

      viewModel.clearAll();
      if (!context.mounted) return;
      context.read<LoginPageViewmodel>().clearLoginForm();
      // Wrapper, Firebase userChanges sign-out olayını dinlediği için
      // LoginPage'e otomatik olarak geçer.
    } catch (e) {
      debugPrint('Farklı hesap akışında oturum kapatma hatası: $e');
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(logoutErrorMessage, textAlign: TextAlign.center),
        ),
      );
    }
  }

  Future<void> _handleContinueAsGuest(
    BuildContext context,
    VerificationPageViewModel viewModel,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final logoutErrorMessage = AppLocalizations.of(context)!
        .qrCodeGenerator_LogOutErrorMsg;

    try {
      final prefs = await Constants().prefs;
      await prefs.setBool('isGuest', true);
      await Auth().signOut();
      viewModel.clearAll();

      if (!context.mounted) return;
      // Mevcut Wrapper'ın isGuest değeri bellekte tutulduğu için guest flag'ini
      // yeniden okuyacak temiz bir Wrapper ile kök akışı yeniliyoruz.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Wrapper()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint('Misafir moda geçiş hatası: $e');
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(logoutErrorMessage, textAlign: TextAlign.center),
        ),
      );
    }
  }

  Widget _buildVerificationIndicator(VerificationPageViewModel viewModel) {
    return !viewModel.emailVerified
        ? CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            strokeWidth: 3.0,
          )
        : const Icon(Icons.done_all_rounded, size: 100);
  }
}
