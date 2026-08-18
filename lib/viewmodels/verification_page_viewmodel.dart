import 'dart:async';

import 'package:flutter/material.dart';
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
    _timer = null;
    notifyListeners();
  }

  void startEmailVerificationCheckTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        await Auth().reloadAndCheckEmailVerfication();
        final user = Auth().currentUser;
        if (user != null && user.emailVerified) {
          emailVerified = true;
          _timer?.cancel();
          _timer = null;
          notifyListeners();
        }
      } catch (e) {
        // Geçici ağ hatalarında doğrulama ekranında kalıp bir sonraki
        // periyodik kontrolde yeniden deniyoruz.
        debugPrint('E-posta doğrulama kontrolü başarısız: $e');
      }
    });
  }

  Future<bool> sendVerificationEmail({required String sendMailErrorMsg}) async {
    errorMessage = '';
    isLoading = true;
    notifyListeners();

    try {
      await Auth().sendEmailVerification();
      return true;
    } catch (e) {
      errorMessage = sendMailErrorMsg;
      debugPrint('Verification email failed: $e');
      return false;
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
