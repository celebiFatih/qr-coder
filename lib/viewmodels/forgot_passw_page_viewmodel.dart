import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/auth_service.dart';

class ForgotPasswPageViewmodel extends ChangeNotifier {
  String errorMessage = '';
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  TextEditingController get emailController => _emailController;
  FocusNode get emailFocusNode => _emailFocusNode;

  void clearAll() {
    _emailController.clear();
    errorMessage = '';
    isLoading = false;
    notifyListeners();
  }

  String? emailValidator(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.forgotPasswordPage_emailValidator;
    }

    bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);
    if (!emailValid) {
      return AppLocalizations.of(context)!
          .forgotPasswordPage_emailValidatorError;
    }

    return null;
  }

  Future<void> sendResetEmail(BuildContext context) async {
    final sendMailErrorMsg = AppLocalizations.of(context)!
        .forgotPasswordPage_sendMailErrorMsg;

    try {
      // Clear a previous failure before starting a new request so a
      // successful retry is not mistaken for the old error.
      errorMessage = '';
      isLoading = true;
      emailFocusNode.unfocus();
      notifyListeners();
      await Auth().sendPasswordResetEmail(_emailController.text.trim());
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = sendMailErrorMsg;
      debugPrint('Password reset email failed: $e');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }
}
