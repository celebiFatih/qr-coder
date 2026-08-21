import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';

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
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final viewModel = Provider.of<ForgotPasswPageViewmodel>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Form(
        key: _formKey,
        child: Center(
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
                    _buildEmailField(viewModel, context),
                    _gap(),
                    const Icon(Icons.mark_email_unread_outlined, size: 100),
                    _gap(),
                    _buildSubmitButton(context, isSmallScreen, viewModel),
                    _gap(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 15);

  Widget _buildLogo(bool isSmallScreen) {
    return Image.asset('assets/img/logo.png', width: isSmallScreen ? 100 : 200);
  }

  Widget _buildWelcomeText(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        AppLocalizations.of(context)!.login_WelcomeText,
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
        AppLocalizations.of(context)!.forgotPasswordPage_description,
        style: isSmallScreen
            ? Theme.of(context).textTheme.bodyMedium
            : Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
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
      validator: (value) => viewModel.emailValidator(value, context),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!
            .forgotPasswordPage_textFieldLabelText,
        hintText: AppLocalizations.of(context)!
            .forgotPasswordPage_textFieldHintText,
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: viewModel.clearAll,
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    bool isSmallScreen,
    ForgotPasswPageViewmodel viewModel,
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
        onPressed: viewModel.isLoading
            ? null
            : () => _handleSendEmail(context, viewModel),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: viewModel.isLoading
              ? const CircularProgressIndicator()
              : Text(
                  AppLocalizations.of(context)!.forgotPasswordPage_btnSend,
                  style: isSmallScreen
                      ? Theme.of(context).textTheme.bodyLarge
                      : Theme.of(context).textTheme.headlineSmall,
                ),
        ),
      ),
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
