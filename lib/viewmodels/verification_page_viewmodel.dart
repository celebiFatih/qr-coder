import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerificationPageViewModel extends ChangeNotifier {
  Timer? _timer;
  String errorMessage = '';
  bool isLoading = false;
  bool emailVerified = false;

  void clearAll() {
    errorMessage = '';
    isLoading = false;
    emailVerified = false;
    _timer?.cancel();
    notifyListeners();
  }

  void startEmailVerificationCheckTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        await Auth().reloadAndCheckEmailVerfication();
        final user = Auth().currentUser;
        if (user != null && user.emailVerified) {
          emailVerified = true;
          _timer?.cancel();
          notifyListeners();
        }
      },
    );
  }

  Future<void> sendVerificationEmail(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      await Auth().sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .verificationPage_verificationEmailResentMsg,
            textAlign:
                TextAlign.center, // "Doğrulama bağlantısı tekrar gönderildi."
          ),
        ),
      );
    } catch (e) {
      errorMessage =
          AppLocalizations.of(context)!.verificationPage_sendMailErrorMsg;
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
