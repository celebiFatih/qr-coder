import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';
import 'package:qr_coder/widgets/app_auth_layout.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/app_layout.dart';

class ForgotPasswPage extends StatefulWidget {
  const ForgotPasswPage({super.key});

  @override
  State<ForgotPasswPage> createState() => _ForgotPasswPageState();
}

class _ForgotPasswPageState extends State<ForgotPasswPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _emailFieldKey =
      GlobalKey<FormFieldState<String>>();

  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = Localizations.localeOf(context);
    final localeChanged = _lastLocale != null && _lastLocale != locale;
    _lastLocale = locale;

    if (!localeChanged) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final fieldState = _emailFieldKey.currentState;

      // Locale changes should refresh an already-visible validation error,
      // but must not introduce a new error on an untouched field.
      if (fieldState?.hasError ?? false) {
        fieldState!.validate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswPageViewmodel>();
    final l10n = AppLocalizations.of(context)!;

    return AppPageScaffold(
      appBar: AppBar(title: Text(l10n.login_ForgotPasswordButton)),
      body: Form(
        key: _formKey,
        child: AppAuthPageFrame(
          child: AppSurface(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.lg),
                _buildEmailField(viewModel, context),
                const SizedBox(height: AppSpacing.lg),
                _buildSubmitButton(context, viewModel),
              ],
            ),
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
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: 36,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.login_ForgotPasswordButton,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.forgotPasswordPage_description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(
    ForgotPasswPageViewmodel viewModel,
    BuildContext context,
  ) {
    return TextFormField(
      key: _emailFieldKey,
      controller: viewModel.emailController,
      focusNode: viewModel.emailFocusNode,
      autofocus: true,
      enabled: !viewModel.isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      validator: (value) => viewModel.emailValidator(value, context),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!
            .forgotPasswordPage_textFieldLabelText,
        hintText: AppLocalizations.of(context)!
            .forgotPasswordPage_textFieldHintText,
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: IconButton(
          tooltip: AppLocalizations.of(context)!.accessibility_clearInput,
          icon: const Icon(Icons.close_rounded),
          onPressed: viewModel.isLoading ? null : viewModel.clearAll,
        ),
      ),
      onFieldSubmitted: (_) {
        if (!viewModel.isLoading) {
          _handleSendEmail(context, viewModel);
        }
      },
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    ForgotPasswPageViewmodel viewModel,
  ) {
    return FilledButton.icon(
      onPressed: viewModel.isLoading
          ? null
          : () => _handleSendEmail(context, viewModel),
      icon: viewModel.isLoading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Icon(Icons.send_rounded),
      label: Text(AppLocalizations.of(context)!.forgotPasswordPage_btnSend),
    );
  }

  Future<void> _handleSendEmail(
    BuildContext context,
    ForgotPasswPageViewmodel viewModel,
  ) async {
    // Ignore any duplicate submit that slips through before the disabled
    // button state is rendered.
    if (viewModel.isLoading) return;

    final successMessage = AppLocalizations.of(context)!
        .forgotPasswordPage_sendEmailSuccessMsg;

    if (_formKey.currentState?.validate() ?? false) {
      await viewModel.sendResetEmail(context);
      if (!context.mounted) return;

      if (viewModel.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage, textAlign: TextAlign.center),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(successMessage, textAlign: TextAlign.center),
              ),
            )
            .closed
            .then((value) {
              Timer(const Duration(seconds: 2), () {
                if (!context.mounted) return;
                viewModel.clearAll();
                Navigator.pop(context);
              });
            });
      }
    }
  }
}
