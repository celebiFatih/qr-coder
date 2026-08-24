import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/widgets/app_auth_layout.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/app_layout.dart';
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
    final viewModel = context.watch<VerificationPageViewModel>();

    return AppPageScaffold(
      body: AppAuthPageFrame(
        maxWidth: 520,
        child: AppSurface(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              _buildVerificationStatus(context, viewModel),
              const SizedBox(height: AppSpacing.lg),
              _buildResendButton(context, viewModel),
              const SizedBox(height: AppSpacing.sm),
              _buildDifferentAccountButton(context, viewModel),
              const SizedBox(height: AppSpacing.xs),
              _buildGuestAccessButton(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Image.asset('assets/img/logo.png', width: 72),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.verificationPage_welcomeTitle,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.verificationPage_description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerificationStatus(
    BuildContext context,
    VerificationPageViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final userEmail = viewModel.userEmail;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Row(
          children: [
            if (viewModel.emailVerified)
              Icon(
                Icons.verified_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              )
            else
              const SizedBox.square(
                dimension: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            if (userEmail != null && userEmail.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  userEmail,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResendButton(
    BuildContext context,
    VerificationPageViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return FilledButton.tonalIcon(
      onPressed: viewModel.canResend
          ? () => _handleSendVerification(context, viewModel)
          : null,
      icon: viewModel.isLoading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Icon(Icons.forward_to_inbox_rounded),
      label: Text(
        viewModel.isResendCoolingDown
            ? l10n.verificationPage_sendAgainCooldownBtn(
                viewModel.resendCooldownSeconds,
              )
            : l10n.verificationPage_sendAgainBtn,
      ),
    );
  }

  Widget _buildDifferentAccountButton(
    BuildContext context,
    VerificationPageViewModel viewModel,
  ) {
    return OutlinedButton.icon(
      onPressed: viewModel.isLoading
          ? null
          : () => _handleUseDifferentAccount(context, viewModel),
      icon: const Icon(Icons.switch_account_rounded),
      label: Text(
        AppLocalizations.of(context)!.verificationPage_useDifferentAccountBtn,
      ),
    );
  }

  Widget _buildGuestAccessButton(
    BuildContext context,
    VerificationPageViewModel viewModel,
  ) {
    return TextButton.icon(
      onPressed: viewModel.isLoading
          ? null
          : () => _handleContinueAsGuest(context, viewModel),
      icon: const Icon(Icons.person_outline_rounded),
      label: Text(AppLocalizations.of(context)!.login_GuestAccessButton),
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
}
