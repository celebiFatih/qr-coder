import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (!emailValid) {
      return 'Lütfen geçerli bir e-posta girin';
    }

    return null;
  }

  Future<void> sendResetEmail(BuildContext context) async {
    try {
      isLoading = true;
      emailFocusNode.unfocus();
      notifyListeners();
      await Auth().sendPasswordResetEmail(_emailController.text.trim());
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage =
          AppLocalizations.of(context)!.forgotPasswordPage_sendMailErrorMsg;
      print(e);
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
