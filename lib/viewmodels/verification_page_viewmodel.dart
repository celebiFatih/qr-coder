import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/auth_service.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await Auth().reloadAndCheckEmailVerfication();
      final user = Auth().currentUser;
      if (user != null && user.emailVerified) {
        emailVerified = true;
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  Future<void> sendVerificationEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final resentMessage = l10n.verificationPage_verificationEmailResentMsg;
    final sendMailErrorMsg = l10n.verificationPage_sendMailErrorMsg;

    try {
      isLoading = true;
      notifyListeners();
      await Auth().sendEmailVerification();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resentMessage, textAlign: TextAlign.center)),
      );
    } catch (e) {
      errorMessage = sendMailErrorMsg;
      debugPrint('Verification email failed: $e');
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
